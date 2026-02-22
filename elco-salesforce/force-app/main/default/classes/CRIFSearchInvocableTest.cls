@isTest
private class CRIFSearchInvocableTest {

    @isTest
    static void testSearchSuccess() {
        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new CRIFMockSuccess());

        CRIFSearchInvocable.CRIFRequest req = new CRIFSearchInvocable.CRIFRequest();
        req.partitaIVA = 'IT01234567890';

        Test.startTest();
        List<CRIFSearchInvocable.CRIFResult> results = CRIFSearchInvocable.searchByVAT(
            new List<CRIFSearchInvocable.CRIFRequest>{ req }
        );
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Should return 1 result');
        CRIFSearchInvocable.CRIFResult result = results[0];

        System.assertEquals(true, result.success, 'Should be successful');
        System.assertNotEquals(null, result.ragioneSociale, 'Should have ragione sociale');
    }

    @isTest
    static void testSearchNotFound() {
        Test.setMock(HttpCalloutMock.class, new CRIFMockNotFound());

        CRIFSearchInvocable.CRIFRequest req = new CRIFSearchInvocable.CRIFRequest();
        req.partitaIVA = '99999999999';

        Test.startTest();
        List<CRIFSearchInvocable.CRIFResult> results = CRIFSearchInvocable.searchByVAT(
            new List<CRIFSearchInvocable.CRIFRequest>{ req }
        );
        Test.stopTest();

        CRIFSearchInvocable.CRIFResult result = results[0];
        System.assertEquals(false, result.success, 'Should fail when not found');
        System.assertEquals(0, result.totalResults, 'Should have 0 results');
    }

    // Mock HTTP Callout - Success
    private class CRIFMockSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            // Token request
            if (req.getEndpoint().contains('/oauth2/token')) {
                res.setStatusCode(200);
                res.setBody('{"access_token":"mock_token_12345","token_type":"Bearer","expires_in":3600}');
                return res;
            }

            // Search request
            if (req.getEndpoint().contains('/margo/v1/prospecting/search')) {
                res.setStatusCode(200);
                String mockResponse = '{'
                    + '"totalElements":1,'
                    + '"content":[{'
                    + '"businessName":"Test Company SRL",'
                    + '"taxCode":"TSTCMP01234567890",'
                    + '"addressData":{'
                    + '"address":"Via Test 123",'
                    + '"city":"Milano",'
                    + '"zipCode":"20100",'
                    + '"province":"MI"'
                    + '},'
                    + '"dataPacket":{'
                    + '"contacts":{'
                    + '"phone":"0212345678",'
                    + '"email":"info@testcompany.it"'
                    + '},'
                    + '"pec":{'
                    + '"address":"pec@testcompany.it"'
                    + '},'
                    + '"webAndSocial":{'
                    + '"website":"www.testcompany.it"'
                    + '}'
                    + '}'
                    + '}]'
                    + '}';
                res.setBody(mockResponse);
                return res;
            }

            // Default
            res.setStatusCode(404);
            return res;
        }
    }

    // Mock HTTP Callout - Not Found
    private class CRIFMockNotFound implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            if (req.getEndpoint().contains('/oauth2/token')) {
                res.setStatusCode(200);
                res.setBody('{"access_token":"mock_token","token_type":"Bearer","expires_in":3600}');
            } else if (req.getEndpoint().contains('/margo/v1/prospecting/search')) {
                res.setStatusCode(200);
                res.setBody('{"totalElements":0,"content":[]}');
            }

            return res;
        }
    }
}
