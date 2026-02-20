public with sharing class CrifMockClient {

    // Constants
    private static final String NC_NAME = 'CRIF_MOCK';
    private static final String TOKEN_PATH = '/oauth2/token';
    private static final String SEARCH_PATH = '/margo/v1/prospecting/search';
    private static final String DEFAULT_ACCEPT_LANG = 'it-IT';
    private static final String DEFAULT_DATAPACKET_CSV = 'atecoClassification,ecofin,operatingResults,employees,contacts,mail,pec,webAndSocial';

    // Response classes
    public class TokenResponse {
        public String access_token;
        public String token_type;
        public Integer expires_in;
    }

    public class CrifMockResult {
        public Integer tokenHttpStatus;
        public Integer searchHttpStatus;
        public String tokenRaw;
        public String searchRaw;
        public String error;
    }

    /**
     * Normalizza P.IVA italiana a 11 cifre
     * @param input - P.IVA in formato IT01234567890, 01234567890, o numero
     * @return String - 11 cifre normalizzate
     * @throws IllegalArgumentException se P.IVA non valida
     */
    public static String normalizeVatTo11(String input) {
        if (String.isBlank(input)) {
            throw new IllegalArgumentException('P.IVA vuota');
        }

        // Rimuovi IT prefix se presente
        String cleaned = input.trim().toUpperCase();
        if (cleaned.startsWith('IT')) {
            cleaned = cleaned.substring(2);
        }

        // Rimuovi caratteri non-digit
        cleaned = cleaned.replaceAll('[^0-9]', '');

        // Pad left con 0 se < 11 cifre
        while (cleaned.length() < 11) {
            cleaned = '0' + cleaned;
        }

        // Verifica lunghezza finale
        if (cleaned.length() != 11) {
            throw new IllegalArgumentException('P.IVA non valida: lunghezza != 11 dopo normalizzazione (input: ' + input + ')');
        }

        return cleaned;
    }

    /**
     * Esegue token + search CRIF Mock
     * @param vatInput - P.IVA da cercare
     * @param includeDataPacketList - se true, include dataPacketList nella richiesta
     * @param dataPacketListCsv - CSV di datapacket (se null usa default)
     * @param page - numero pagina (default 0)
     * @param size - elementi per pagina (default 15)
     * @param acceptLanguage - header Accept-Language (default 'it-IT')
     * @return CrifMockResult con status e raw JSON
     */
    public static CrifMockResult searchByVat(
        String vatInput,
        Boolean includeDataPacketList,
        String dataPacketListCsv,
        Integer page,
        Integer size,
        String acceptLanguage
    ) {
        CrifMockResult result = new CrifMockResult();

        try {
            // Normalizza P.IVA
            String vat11 = normalizeVatTo11(vatInput);
            String freeText = 'IT' + vat11;

            // Default params
            if (includeDataPacketList == null) { includeDataPacketList = true; }
            if (page == null) { page = 0; }
            if (size == null) { size = 15; }
            if (String.isBlank(acceptLanguage)) { acceptLanguage = DEFAULT_ACCEPT_LANG; }
            if (String.isBlank(dataPacketListCsv)) { dataPacketListCsv = DEFAULT_DATAPACKET_CSV; }

            // STEP 1: TOKEN
            String accessToken = getToken(result);
            if (accessToken == null) {
                return result; // error già impostato
            }

            // STEP 2: SEARCH
            performSearch(result, accessToken, freeText, includeDataPacketList, dataPacketListCsv, page, size, acceptLanguage);

        } catch (Exception e) {
            result.error = e.getMessage() + '\n' + e.getStackTraceString();
        }

        return result;
    }

    /**
     * Esegue chiamata token
     */
    private static String getToken(CrifMockResult result) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:' + NC_NAME + TOKEN_PATH);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        // Body con merge fields per credenziali
        String body = 'grant_type=password';
        body += '&username={!$Credential.CRIF_MOCK_EXT.Username}';
        body += '&password={!$Credential.CRIF_MOCK_EXT.Password}';
        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);

        result.tokenHttpStatus = res.getStatusCode();
        result.tokenRaw = res.getBody();

        if (res.getStatusCode() < 200 || res.getStatusCode() >= 300) {
            result.error = 'Token request failed with status ' + res.getStatusCode();
            return null;
        }

        // Parse access_token
        Map<String, Object> tokenMap = (Map<String, Object>) JSON.deserializeUntyped(result.tokenRaw);
        if (!tokenMap.containsKey('access_token')) {
            result.error = 'Token response missing access_token';
            return null;
        }

        return (String) tokenMap.get('access_token');
    }

    /**
     * Esegue chiamata search
     */
    private static void performSearch(
        CrifMockResult result,
        String accessToken,
        String freeText,
        Boolean includeDataPacketList,
        String dataPacketListCsv,
        Integer page,
        Integer size,
        String acceptLanguage
    ) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:' + NC_NAME + SEARCH_PATH + '?page=' + page + '&size=' + size);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept-Language', acceptLanguage);
        req.setHeader('Authorization', 'Bearer ' + accessToken);

        // Build body
        Map<String, Object> bodyMap = new Map<String, Object>();
        bodyMap.put('freeText', freeText);

        if (includeDataPacketList) {
            List<String> dataPacketList = dataPacketListCsv.split(',');
            Map<String, Object> content = new Map<String, Object>();
            content.put('dataPacketList', dataPacketList);
            bodyMap.put('content', content);
        }

        req.setBody(JSON.serialize(bodyMap));

        Http http = new Http();
        HttpResponse res = http.send(req);

        result.searchHttpStatus = res.getStatusCode();
        result.searchRaw = res.getBody();

        if (res.getStatusCode() < 200 || res.getStatusCode() >= 300) {
            result.error = (result.error != null ? result.error + '; ' : '') +
                           'Search request failed with status ' + res.getStatusCode();
        }
    }
}