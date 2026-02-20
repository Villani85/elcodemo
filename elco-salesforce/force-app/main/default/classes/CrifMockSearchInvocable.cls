public with sharing class CrifMockSearchInvocable {

    public class Request {
        @InvocableVariable(required=true label='P.IVA da cercare' description='P.IVA italiana (formato IT01234567890 o 01234567890)')
        public String piva;

        @InvocableVariable(label='Include DataPacketList' description='Se true, include dataPacketList nella richiesta (default: true)')
        public Boolean includeDataPacketList;

        @InvocableVariable(label='DataPacketList CSV' description='Lista CSV di datapacket (default: atecoClassification,ecofin,...)')
        public String dataPacketListCsv;

        @InvocableVariable(label='Pagina' description='Numero pagina (default: 0)')
        public Integer page;

        @InvocableVariable(label='Dimensione pagina' description='Elementi per pagina (default: 15)')
        public Integer size;

        @InvocableVariable(label='Accept-Language' description='Header Accept-Language (default: it-IT)')
        public String acceptLanguage;
    }

    public class Response {
        @InvocableVariable(label='Token HTTP Status')
        public Integer tokenHttpStatus;

        @InvocableVariable(label='Search HTTP Status')
        public Integer searchHttpStatus;

        @InvocableVariable(label='Token JSON Response')
        public String tokenJson;

        @InvocableVariable(label='Search JSON Response')
        public String searchJson;

        @InvocableVariable(label='Errore')
        public String error;

        @InvocableVariable(label='P.IVA normalizzata (11 cifre)')
        public String vat11;
    }

    @InvocableMethod(
        label='CRIF Mock - Prospecting Search by VAT'
        description='Esegue token + search verso CRIF mock. Non espone credenziali. Usa Named Credential CRIF_MOCK.'
        category='CRIF Integration'
    )
    public static List<Response> run(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            Response resp = new Response();

            try {
                // Normalizza P.IVA
                resp.vat11 = CrifMockClient.normalizeVatTo11(req.piva);

                // Esegui search
                CrifMockClient.CrifMockResult crifResult = CrifMockClient.searchByVat(
                    req.piva,
                    req.includeDataPacketList,
                    req.dataPacketListCsv,
                    req.page,
                    req.size,
                    req.acceptLanguage
                );

                // Popola response
                resp.tokenHttpStatus = crifResult.tokenHttpStatus;
                resp.searchHttpStatus = crifResult.searchHttpStatus;
                resp.tokenJson = crifResult.tokenRaw;
                resp.searchJson = crifResult.searchRaw;
                resp.error = crifResult.error;

            } catch (Exception e) {
                resp.error = e.getMessage();
                resp.vat11 = null;
            }

            responses.add(resp);
        }

        return responses;
    }
}