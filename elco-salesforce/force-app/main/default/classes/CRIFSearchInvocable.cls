/**
 * CRIF Search Invocable - chiamata da Flow
 * Esegue OAuth2 + Search su CRIF Mock API
 */
public with sharing class CRIFSearchInvocable {

    // Configurazione (TODO: spostare in Custom Settings/Metadata)
    private static final String BASE_URL = 'https://crif-mock-137745841582.europe-west8.run.app';
    private static final String TOKEN_PATH = '/oauth2/token';
    private static final String SEARCH_PATH = '/margo/v1/prospecting/search';
    private static final String USERNAME = 'test-user';
    private static final String PASSWORD = 'test-pass';

    @InvocableMethod(label='CRIF Search by P.IVA' description='Cerca azienda su CRIF da Partita IVA')
    public static List<CRIFResult> searchByVAT(List<CRIFRequest> requests) {
        List<CRIFResult> results = new List<CRIFResult>();

        for (CRIFRequest req : requests) {
            results.add(executeSingleSearch(req));
        }

        return results;
    }

    private static CRIFResult executeSingleSearch(CRIFRequest req) {
        CRIFResult result = new CRIFResult();
        result.success = false;

        try {
            // Normalizza P.IVA (aggiungi IT se manca)
            String vat = normalizeVAT(req.partitaIVA);

            // Step 1: Get OAuth2 Token
            String accessToken = getAccessToken();

            // Step 2: Search
            HttpResponse searchResp = executeSearch(vat, accessToken);

            // Step 3: Parse response
            if (searchResp.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(searchResp.getBody());
                result = parseSearchResponse(responseMap, vat);
            } else {
                result.errorMessage = 'CRIF Search failed: HTTP ' + searchResp.getStatusCode() + ' - ' + searchResp.getBody();
            }

        } catch (Exception e) {
            result.errorMessage = 'Error: ' + e.getMessage() + '\n' + e.getStackTraceString();
        }

        return result;
    }

    private static String getAccessToken() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + TOKEN_PATH);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body = 'grant_type=password&username=' + EncodingUtil.urlEncode(USERNAME, 'UTF-8')
                    + '&password=' + EncodingUtil.urlEncode(PASSWORD, 'UTF-8');
        req.setBody(body);
        req.setTimeout(120000); // 2 min

        Http http = new Http();
        HttpResponse resp = http.send(req);

        if (resp.getStatusCode() != 200) {
            throw new CalloutException('Token request failed: HTTP ' + resp.getStatusCode() + ' - ' + resp.getBody());
        }

        Map<String, Object> tokenData = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
        String token = (String) tokenData.get('access_token');

        if (String.isBlank(token)) {
            throw new CalloutException('No access_token in response: ' + resp.getBody());
        }

        return token;
    }

    private static HttpResponse executeSearch(String vat, String accessToken) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + SEARCH_PATH + '?page=0&size=15');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Accept-Language', 'it-IT');

        // Body con dataPacketList completo
        Map<String, Object> requestBody = new Map<String, Object>{
            'freeText' => vat,
            'content' => new Map<String, Object>{
                'dataPacketList' => new List<String>{
                    'atecoClassification', 'ecofin', 'operatingResults',
                    'employees', 'contacts', 'mail', 'pec', 'webAndSocial'
                }
            }
        };

        req.setBody(JSON.serialize(requestBody));
        req.setTimeout(120000);

        Http http = new Http();
        return http.send(req);
    }

    private static CRIFResult parseSearchResponse(Map<String, Object> responseMap, String vat) {
        CRIFResult result = new CRIFResult();
        result.success = true;
        result.partitaIVA = vat;

        // Store raw JSON for debugging
        result.rawJSON = JSON.serialize(responseMap);

        // Estrai totalElements
        Integer totalElements = (Integer) responseMap.get('totalElements');
        result.totalResults = totalElements != null ? totalElements : 0;

        if (result.totalResults == 0) {
            result.success = false;
            result.errorMessage = 'Nessuna azienda trovata per P.IVA: ' + vat;
            return result;
        }

        // Estrai primo risultato dalla lista
        List<Object> content = (List<Object>) responseMap.get('content');
        if (content == null || content.isEmpty()) {
            result.success = false;
            result.errorMessage = 'Response content vuoto';
            return result;
        }

        Map<String, Object> firstResult = (Map<String, Object>) content[0];

        // Extract from companyDetails
        Map<String, Object> companyDetails = getMap(firstResult, 'companyDetails');
        if (companyDetails != null) {
            result.ragioneSociale = getString(companyDetails, 'businessName');
            if (result.ragioneSociale == null) {
                result.ragioneSociale = getString(companyDetails, 'name');
            }
            if (result.ragioneSociale == null) {
                result.ragioneSociale = getString(companyDetails, 'companyName');
            }

            result.codiceFiscale = getString(companyDetails, 'taxCode');
            if (result.codiceFiscale == null) {
                result.codiceFiscale = getString(companyDetails, 'fiscalCode');
            }
        }

        // Extract from registeredOffice (handles nested objects)
        Map<String, Object> registeredOffice = getMap(firstResult, 'registeredOffice');
        if (registeredOffice != null) {
            // Address might be nested object with streetName
            Object addressObj = registeredOffice.get('address');
            if (addressObj instanceof Map<String, Object>) {
                Map<String, Object> addressMap = (Map<String, Object>) addressObj;
                result.indirizzo = getString(addressMap, 'streetName');
                result.citta = getString(addressMap, 'town');
                result.cap = getString(addressMap, 'zipCode');
            } else {
                result.indirizzo = getString(registeredOffice, 'address');
                result.citta = getString(registeredOffice, 'city');
                result.cap = getString(registeredOffice, 'zipCode');
            }

            // Province might be nested object with code/description
            Object provinceObj = registeredOffice.get('province');
            if (provinceObj instanceof Map<String, Object>) {
                Map<String, Object> provinceMap = (Map<String, Object>) provinceObj;
                result.provincia = getString(provinceMap, 'code');
                if (result.provincia == null) {
                    result.provincia = getString(provinceMap, 'description');
                }
            } else {
                result.provincia = getString(registeredOffice, 'province');
            }
        }

        // Extract contacts (phone/email from contacts object)
        Map<String, Object> contacts = getMap(firstResult, 'contacts');
        if (contacts != null) {
            // Phone might be nested
            Object phoneObj = contacts.get('phone');
            if (phoneObj instanceof Map<String, Object>) {
                result.telefono = getString((Map<String, Object>) phoneObj, 'number');
            } else {
                result.telefono = getString(contacts, 'phone');
            }

            // Email might be nested object
            Object emailObj = contacts.get('email');
            if (emailObj instanceof Map<String, Object>) {
                result.email = getString((Map<String, Object>) emailObj, 'email');
            } else {
                result.email = getString(contacts, 'email');
            }
        }

        // PEC - direct string value
        result.pec = getString(firstResult, 'pec');

        // Website (might be in contacts or separate)
        if (contacts != null) {
            result.website = getString(contacts, 'website');
        }

        // If ragioneSociale is still null, set error message with available fields
        if (String.isBlank(result.ragioneSociale)) {
            result.success = false;
            result.errorMessage = 'Impossibile estrarre ragioneSociale. Campi disponibili: ' + String.join(new List<String>(firstResult.keySet()), ', ');
        }

        return result;
    }

    private static String normalizeVAT(String input) {
        if (String.isBlank(input)) {
            throw new IllegalArgumentException('Partita IVA richiesta');
        }

        String cleaned = input.trim().toUpperCase();

        // Se inizia con IT, rimuovi per poi rimetterlo
        if (cleaned.startsWith('IT')) {
            cleaned = cleaned.substring(2);
        }

        // Rimuovi caratteri non numerici
        cleaned = cleaned.replaceAll('[^0-9]', '');

        // Padding a 11 cifre
        while (cleaned.length() < 11) {
            cleaned = '0' + cleaned;
        }

        if (cleaned.length() != 11) {
            throw new IllegalArgumentException('P.IVA deve avere 11 cifre. Valore: ' + input);
        }

        return 'IT' + cleaned;
    }

    // Helper methods
    private static String getString(Map<String, Object> inputMap, String key) {
        if (inputMap == null || !inputMap.containsKey(key)) {
            return null;
        }
        Object val = inputMap.get(key);
        return val != null ? String.valueOf(val) : null;
    }

    private static Map<String, Object> getMap(Map<String, Object> inputMap, String key) {
        if (inputMap == null || !inputMap.containsKey(key)) {
            return null;
        }
        Object val = inputMap.get(key);
        return val instanceof Map<String, Object> ? (Map<String, Object>) val : null;
    }

    // Inner Classes per Flow
    public class CRIFRequest {
        @InvocableVariable(required=true label='Partita IVA')
        public String partitaIVA;
    }

    public class CRIFResult {
        @InvocableVariable
        public Boolean success;

        @InvocableVariable
        public String errorMessage;

        @InvocableVariable
        public Integer totalResults;

        @InvocableVariable
        public String partitaIVA;

        @InvocableVariable
        public String ragioneSociale;

        @InvocableVariable
        public String codiceFiscale;

        @InvocableVariable
        public String indirizzo;

        @InvocableVariable
        public String citta;

        @InvocableVariable
        public String cap;

        @InvocableVariable
        public String provincia;

        @InvocableVariable
        public String telefono;

        @InvocableVariable
        public String email;

        @InvocableVariable
        public String pec;

        @InvocableVariable
        public String website;

        @InvocableVariable
        public String rawJSON;
    }
}
