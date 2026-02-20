public with sharing class CrifSearchJsonMapper {

    public class Request {
        @InvocableVariable(required=true label='Search JSON' description='Raw JSON response from CRIF search API')
        public String searchJson;

        @InvocableVariable(label='HTTP Status' description='HTTP status code from search API')
        public Integer httpStatus;

        @InvocableVariable(label='P.IVA normalizzata' description='P.IVA normalizzata (11 cifre)')
        public String vat11;
    }

    public class Response {
        // Core business fields
        @InvocableVariable(label='Stato Attività')
        public String statoAttivita;

        @InvocableVariable(label='Fatturato')
        public Decimal fatturato;

        @InvocableVariable(label='Anno Fatturato')
        public String annoFatturato;

        @InvocableVariable(label='Numero Dipendenti')
        public Decimal numeroDipendenti;

        @InvocableVariable(label='EBITDA')
        public Decimal ebitda;

        @InvocableVariable(label='Valore Credito')
        public Decimal valoreCredito;

        // Company identification
        @InvocableVariable(label='Company ID')
        public String companyId;

        // Scores
        @InvocableVariable(label='Real Estate Lease Score')
        public Decimal realEstateLeaseScore;

        @InvocableVariable(label='Factoring Score')
        public Decimal factoringScore;

        @InvocableVariable(label='DnB Rating')
        public String dnbRating;

        // Notice flags
        @InvocableVariable(label='Has Delinquency Notices')
        public Boolean hasDelinquencyNotices;

        @InvocableVariable(label='Has Negative Notices')
        public Boolean hasNegativeNotices;

        @InvocableVariable(label='Has Bankruptcy Notices')
        public Boolean hasBankruptcyNotices;

        // Status fields
        @InvocableVariable(label='Last Status')
        public String lastStatus;

        @InvocableVariable(label='Mapping Error')
        public String mappingError;
    }

    @InvocableMethod(
        label='CRIF - Map Search JSON to Business Fields'
        description='Estrae valori business da searchJson CRIF senza esporre secrets/logs'
        category='CRIF Integration'
    )
    public static List<Response> mapSearchJson(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            Response resp = new Response();

            try {
                if (String.isBlank(req.searchJson)) {
                    resp.mappingError = 'searchJson is blank';
                    resp.lastStatus = 'ERROR';
                    responses.add(resp);
                    continue;
                }

                // Parse JSON
                Map<String, Object> searchData = (Map<String, Object>) JSON.deserializeUntyped(req.searchJson);

                // Determine status based on HTTP status and data presence
                if (req.httpStatus == 200) {
                    resp.lastStatus = 'SUCCESS';
                } else if (req.httpStatus != null && req.httpStatus >= 400) {
                    resp.lastStatus = 'ERROR';
                } else {
                    resp.lastStatus = 'UNKNOWN';
                }

                // Extract company ID (common paths)
                resp.companyId = safeGetString(searchData, 'companyId');
                if (String.isBlank(resp.companyId)) {
                    resp.companyId = safeGetString(searchData, 'id');
                }
                if (String.isBlank(resp.companyId)) {
                    Object content = searchData.get('content');
                    if (content instanceof List<Object>) {
                        List<Object> contentList = (List<Object>) content;
                        if (!contentList.isEmpty() && contentList[0] instanceof Map<String, Object>) {
                            Map<String, Object> firstItem = (Map<String, Object>) contentList[0];
                            resp.companyId = safeGetString(firstItem, 'companyId');
                            if (String.isBlank(resp.companyId)) {
                                resp.companyId = safeGetString(firstItem, 'id');
                            }
                        }
                    }
                }

                // Extract business data from common structures
                Map<String, Object> businessData = null;

                // Try content[0] structure
                Object content = searchData.get('content');
                if (content instanceof List<Object>) {
                    List<Object> contentList = (List<Object>) content;
                    if (!contentList.isEmpty() && contentList[0] instanceof Map<String, Object>) {
                        businessData = (Map<String, Object>) contentList[0];
                    }
                }

                // If no content array, use root
                if (businessData == null) {
                    businessData = searchData;
                }

                // Extract fields from business data
                extractBusinessFields(businessData, resp);

            } catch (Exception e) {
                resp.mappingError = e.getMessage();
                resp.lastStatus = 'ERROR';
            }

            responses.add(resp);
        }

        return responses;
    }

    private static void extractBusinessFields(Map<String, Object> data, Response resp) {
        // Stato attività
        resp.statoAttivita = safeGetString(data, 'statoAttivita');
        if (String.isBlank(resp.statoAttivita)) {
            resp.statoAttivita = safeGetString(data, 'businessStatus');
        }

        // Fatturato (try multiple paths)
        resp.fatturato = safeGetDecimal(data, 'fatturato');
        if (resp.fatturato == null) {
            resp.fatturato = safeGetDecimal(data, 'revenue');
        }
        if (resp.fatturato == null) {
            Map<String, Object> operatingResults = safeGetMap(data, 'operatingResults');
            if (operatingResults != null) {
                resp.fatturato = safeGetDecimal(operatingResults, 'revenue');
                resp.ebitda = safeGetDecimal(operatingResults, 'ebitda');
            }
        }

        // EBITDA (try root level if not found in operatingResults)
        if (resp.ebitda == null) {
            resp.ebitda = safeGetDecimal(data, 'ebitda');
        }

        // Anno fatturato
        resp.annoFatturato = safeGetString(data, 'annoFatturato');
        if (String.isBlank(resp.annoFatturato)) {
            resp.annoFatturato = safeGetString(data, 'revenueYear');
        }
        if (String.isBlank(resp.annoFatturato)) {
            Map<String, Object> operatingResults = safeGetMap(data, 'operatingResults');
            if (operatingResults != null) {
                resp.annoFatturato = safeGetString(operatingResults, 'year');
            }
        }

        // Numero dipendenti
        resp.numeroDipendenti = safeGetDecimal(data, 'numeroDipendenti');
        if (resp.numeroDipendenti == null) {
            resp.numeroDipendenti = safeGetDecimal(data, 'employees');
        }
        if (resp.numeroDipendenti == null) {
            Map<String, Object> employeesData = safeGetMap(data, 'employees');
            if (employeesData != null) {
                resp.numeroDipendenti = safeGetDecimal(employeesData, 'total');
            }
        }

        // Valore credito
        resp.valoreCredito = safeGetDecimal(data, 'valoreCredito');
        if (resp.valoreCredito == null) {
            resp.valoreCredito = safeGetDecimal(data, 'creditValue');
        }

        // Scores
        Map<String, Object> scores = safeGetMap(data, 'scores');
        if (scores != null) {
            resp.realEstateLeaseScore = safeGetDecimal(scores, 'realEstateLease');
            resp.factoringScore = safeGetDecimal(scores, 'factoring');
        } else {
            resp.realEstateLeaseScore = safeGetDecimal(data, 'realEstateLeaseScore');
            resp.factoringScore = safeGetDecimal(data, 'factoringScore');
        }

        // DnB Rating
        resp.dnbRating = safeGetString(data, 'dnbRating');
        if (String.isBlank(resp.dnbRating)) {
            resp.dnbRating = safeGetString(data, 'rating');
        }

        // Notices
        Map<String, Object> notices = safeGetMap(data, 'notices');
        if (notices != null) {
            resp.hasDelinquencyNotices = safeGetBoolean(notices, 'delinquency');
            resp.hasNegativeNotices = safeGetBoolean(notices, 'negative');
            resp.hasBankruptcyNotices = safeGetBoolean(notices, 'bankruptcy');
        } else {
            resp.hasDelinquencyNotices = safeGetBoolean(data, 'hasDelinquencyNotices');
            resp.hasNegativeNotices = safeGetBoolean(data, 'hasNegativeNotices');
            resp.hasBankruptcyNotices = safeGetBoolean(data, 'hasBankruptcyNotices');
        }
    }

    // Safe getter methods
    private static String safeGetString(Map<String, Object> data, String key) {
        if (data == null || !data.containsKey(key)) {
            return null;
        }
        Object value = data.get(key);
        return value != null ? String.valueOf(value) : null;
    }

    private static Decimal safeGetDecimal(Map<String, Object> data, String key) {
        if (data == null || !data.containsKey(key)) {
            return null;
        }
        Object value = data.get(key);
        if (value == null) {
            return null;
        }
        if (value instanceof Decimal) {
            return (Decimal) value;
        }
        if (value instanceof Integer) {
            return Decimal.valueOf((Integer) value);
        }
        if (value instanceof Long) {
            return Decimal.valueOf((Long) value);
        }
        try {
            return Decimal.valueOf(String.valueOf(value));
        } catch (Exception e) {
            return null;
        }
    }

    private static Boolean safeGetBoolean(Map<String, Object> data, String key) {
        if (data == null || !data.containsKey(key)) {
            return null;
        }
        Object value = data.get(key);
        if (value == null) {
            return null;
        }
        if (value instanceof Boolean) {
            return (Boolean) value;
        }
        String strValue = String.valueOf(value).toLowerCase();
        return strValue == 'true' || strValue == '1';
    }

    private static Map<String, Object> safeGetMap(Map<String, Object> data, String key) {
        if (data == null || !data.containsKey(key)) {
            return null;
        }
        Object value = data.get(key);
        if (value instanceof Map<String, Object>) {
            return (Map<String, Object>) value;
        }
        return null;
    }
}
