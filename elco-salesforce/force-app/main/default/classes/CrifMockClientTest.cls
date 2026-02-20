@isTest
private class CrifMockClientTest {

    /**
     * Mock HttpCalloutMock per token + search
     */
    private class CrifMockHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            // Token endpoint
            if (req.getEndpoint().contains('/oauth2/token')) {
                res.setStatusCode(200);
                res.setBody('{"access_token":"mock_access_token_12345","token_type":"Bearer","expires_in":3600}');
            }
            // Search endpoint
            else if (req.getEndpoint().contains('/margo/v1/prospecting/search')) {
                res.setStatusCode(200);
                res.setBody('{"totalElements":1,"content":[{"companyName":"DEMO SRL","vat":"IT01234567890"}]}');
            }
            else {
                res.setStatusCode(404);
                res.setBody('{"error":"Not found"}');
            }

            return res;
        }
    }

    @isTest
    static void test_normalizeVatTo11_valid() {
        // Test vari formati
        System.assertEquals('01234567890', CrifMockClient.normalizeVatTo11('IT01234567890'));
        System.assertEquals('01234567890', CrifMockClient.normalizeVatTo11('01234567890'));
        System.assertEquals('01234567890', CrifMockClient.normalizeVatTo11('1234567890'));
        System.assertEquals('00000000123', CrifMockClient.normalizeVatTo11('123'));
    }

    @isTest
    static void test_normalizeVatTo11_invalid() {
        try {
            CrifMockClient.normalizeVatTo11('');
            System.assert(false, 'Dovrebbe lanciare eccezione per P.IVA vuota');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('vuota'));
        }

        try {
            CrifMockClient.normalizeVatTo11('IT123456789012345'); // troppo lunga
            System.assert(false, 'Dovrebbe lanciare eccezione per P.IVA troppo lunga');
        } catch (IllegalArgumentException e) {
            System.assert(e.getMessage().contains('non valida'));
        }
    }

    @isTest
    static void test_searchByVat_success() {
        Test.setMock(HttpCalloutMock.class, new CrifMockHttpMock());

        Test.startTest();
        CrifMockClient.CrifMockResult result = CrifMockClient.searchByVat(
            'IT01234567890',
            true,
            null,
            0,
            15,
            'it-IT'
        );
        Test.stopTest();

        // Verifica token
        System.assertEquals(200, result.tokenHttpStatus, 'Token HTTP status deve essere 200');
        System.assert(result.tokenRaw.contains('access_token'), 'Token raw deve contenere access_token');

        // Verifica search
        System.assertEquals(200, result.searchHttpStatus, 'Search HTTP status deve essere 200');
        System.assert(result.searchRaw.contains('totalElements'), 'Search raw deve contenere totalElements');
        System.assertEquals(null, result.error, 'Non deve esserci errore');
    }

    @isTest
    static void test_searchByVat_withoutDataPacketList() {
        Test.setMock(HttpCalloutMock.class, new CrifMockHttpMock());

        Test.startTest();
        CrifMockClient.CrifMockResult result = CrifMockClient.searchByVat(
            '01234567890',
            false, // NO dataPacketList
            null,
            null,
            null,
            null
        );
        Test.stopTest();

        System.assertEquals(200, result.tokenHttpStatus);
        System.assertEquals(200, result.searchHttpStatus);
    }

    @isTest
    static void test_invocable_run_success() {
        Test.setMock(HttpCalloutMock.class, new CrifMockHttpMock());

        CrifMockSearchInvocable.Request req = new CrifMockSearchInvocable.Request();
        req.piva = 'IT01234567890';
        req.includeDataPacketList = true;

        Test.startTest();
        List<CrifMockSearchInvocable.Response> responses = CrifMockSearchInvocable.run(
            new List<CrifMockSearchInvocable.Request>{ req }
        );
        Test.stopTest();

        System.assertEquals(1, responses.size());
        CrifMockSearchInvocable.Response resp = responses[0];

        System.assertEquals('01234567890', resp.vat11, 'P.IVA normalizzata deve essere 01234567890');
        System.assertEquals(200, resp.tokenHttpStatus);
        System.assertEquals(200, resp.searchHttpStatus);
        System.assert(resp.searchJson != null);
        System.assertEquals(null, resp.error);
    }

    @isTest
    static void test_invocable_run_invalidVat() {
        CrifMockSearchInvocable.Request req = new CrifMockSearchInvocable.Request();
        req.piva = ''; // P.IVA vuota

        Test.startTest();
        List<CrifMockSearchInvocable.Response> responses = CrifMockSearchInvocable.run(
            new List<CrifMockSearchInvocable.Request>{ req }
        );
        Test.stopTest();

        System.assertEquals(1, responses.size());
        CrifMockSearchInvocable.Response resp = responses[0];

        System.assert(resp.error != null, 'Deve esserci errore per P.IVA vuota');
        System.assertEquals(null, resp.vat11);
    }
}
