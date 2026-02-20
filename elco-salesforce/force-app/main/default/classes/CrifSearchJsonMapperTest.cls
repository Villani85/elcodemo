@isTest
private class CrifSearchJsonMapperTest {

    @isTest
    static void testMapSearchJson_Success() {
        // Arrange
        String searchJson = '{"companyId":"12345","statoAttivita":"ACTIVE","fatturato":1000000,"annoFatturato":"2023","numeroDipendenti":50,"ebitda":150000,"valoreCredito":500000,"realEstateLeaseScore":75,"factoringScore":80,"dnbRating":"AAA","hasDelinquencyNotices":false,"hasNegativeNotices":false,"hasBankruptcyNotices":false}';

        CrifSearchJsonMapper.Request req = new CrifSearchJsonMapper.Request();
        req.searchJson = searchJson;
        req.httpStatus = 200;
        req.vat11 = '01234567890';

        // Act
        Test.startTest();
        List<CrifSearchJsonMapper.Response> responses = CrifSearchJsonMapper.mapSearchJson(new List<CrifSearchJsonMapper.Request>{req});
        Test.stopTest();

        // Assert
        System.assertEquals(1, responses.size(), 'Should return 1 response');
        CrifSearchJsonMapper.Response resp = responses[0];
        System.assertEquals('SUCCESS', resp.lastStatus, 'Status should be SUCCESS');
        System.assertEquals('12345', resp.companyId, 'Company ID should match');
        System.assertEquals('ACTIVE', resp.statoAttivita, 'Stato attività should match');
        System.assertEquals(1000000, resp.fatturato, 'Fatturato should match');
        System.assertEquals('2023', resp.annoFatturato, 'Anno fatturato should match');
        System.assertEquals(50, resp.numeroDipendenti, 'Numero dipendenti should match');
        System.assertEquals(150000, resp.ebitda, 'EBITDA should match');
        System.assertEquals(500000, resp.valoreCredito, 'Valore credito should match');
        System.assertEquals(75, resp.realEstateLeaseScore, 'Real estate lease score should match');
        System.assertEquals(80, resp.factoringScore, 'Factoring score should match');
        System.assertEquals('AAA', resp.dnbRating, 'DnB rating should match');
        System.assertEquals(false, resp.hasDelinquencyNotices, 'Has delinquency notices should be false');
        System.assertEquals(false, resp.hasNegativeNotices, 'Has negative notices should be false');
        System.assertEquals(false, resp.hasBankruptcyNotices, 'Has bankruptcy notices should be false');
        System.assertEquals(null, resp.mappingError, 'Should have no mapping error');
    }

    @isTest
    static void testMapSearchJson_WithContentArray() {
        // Arrange - CRIF API often returns content array
        String searchJson = '{"content":[{"companyId":"67890","statoAttivita":"ACTIVE","fatturato":2000000}],"totalElements":1}';

        CrifSearchJsonMapper.Request req = new CrifSearchJsonMapper.Request();
        req.searchJson = searchJson;
        req.httpStatus = 200;
        req.vat11 = '09876543210';

        // Act
        Test.startTest();
        List<CrifSearchJsonMapper.Response> responses = CrifSearchJsonMapper.mapSearchJson(new List<CrifSearchJsonMapper.Request>{req});
        Test.stopTest();

        // Assert
        System.assertEquals(1, responses.size(), 'Should return 1 response');
        CrifSearchJsonMapper.Response resp = responses[0];
        System.assertEquals('SUCCESS', resp.lastStatus, 'Status should be SUCCESS');
        System.assertEquals('67890', resp.companyId, 'Company ID from content array should match');
        System.assertEquals('ACTIVE', resp.statoAttivita, 'Stato attività should match');
        System.assertEquals(2000000, resp.fatturato, 'Fatturato should match');
    }

    @isTest
    static void testMapSearchJson_WithNestedStructures() {
        // Arrange - Test nested structures like operatingResults, employees, scores, notices
        String searchJson = '{"companyId":"11111","operatingResults":{"revenue":3000000,"ebitda":450000,"year":"2024"},"employees":{"total":100},"scores":{"realEstateLease":85,"factoring":90},"notices":{"delinquency":true,"negative":false,"bankruptcy":false}}';

        CrifSearchJsonMapper.Request req = new CrifSearchJsonMapper.Request();
        req.searchJson = searchJson;
        req.httpStatus = 200;

        // Act
        Test.startTest();
        List<CrifSearchJsonMapper.Response> responses = CrifSearchJsonMapper.mapSearchJson(new List<CrifSearchJsonMapper.Request>{req});
        Test.stopTest();

        // Assert
        CrifSearchJsonMapper.Response resp = responses[0];
        System.assertEquals('SUCCESS', resp.lastStatus, 'Status should be SUCCESS');
        System.assertEquals('11111', resp.companyId, 'Company ID should match');
        System.assertEquals(3000000, resp.fatturato, 'Fatturato from operatingResults should match');
        System.assertEquals(450000, resp.ebitda, 'EBITDA from operatingResults should match');
        System.assertEquals('2024', resp.annoFatturato, 'Anno from operatingResults should match');
        System.assertEquals(100, resp.numeroDipendenti, 'Employees from nested structure should match');
        System.assertEquals(85, resp.realEstateLeaseScore, 'Real estate score from scores object should match');
        System.assertEquals(90, resp.factoringScore, 'Factoring score from scores object should match');
        System.assertEquals(true, resp.hasDelinquencyNotices, 'Delinquency from notices should be true');
        System.assertEquals(false, resp.hasNegativeNotices, 'Negative from notices should be false');
        System.assertEquals(false, resp.hasBankruptcyNotices, 'Bankruptcy from notices should be false');
    }

    @isTest
    static void testMapSearchJson_BlankJson() {
        // Arrange
        CrifSearchJsonMapper.Request req = new CrifSearchJsonMapper.Request();
        req.searchJson = '';
        req.httpStatus = 400;

        // Act
        Test.startTest();
        List<CrifSearchJsonMapper.Response> responses = CrifSearchJsonMapper.mapSearchJson(new List<CrifSearchJsonMapper.Request>{req});
        Test.stopTest();

        // Assert
        System.assertEquals(1, responses.size(), 'Should return 1 response');
        CrifSearchJsonMapper.Response resp = responses[0];
        System.assertEquals('ERROR', resp.lastStatus, 'Status should be ERROR');
        System.assertEquals('searchJson is blank', resp.mappingError, 'Should have blank json error');
    }

    @isTest
    static void testMapSearchJson_InvalidJson() {
        // Arrange
        CrifSearchJsonMapper.Request req = new CrifSearchJsonMapper.Request();
        req.searchJson = 'invalid json {{{';
        req.httpStatus = 200;

        // Act
        Test.startTest();
        List<CrifSearchJsonMapper.Response> responses = CrifSearchJsonMapper.mapSearchJson(new List<CrifSearchJsonMapper.Request>{req});
        Test.stopTest();

        // Assert
        System.assertEquals(1, responses.size(), 'Should return 1 response');
        CrifSearchJsonMapper.Response resp = responses[0];
        System.assertEquals('ERROR', resp.lastStatus, 'Status should be ERROR');
        System.assertNotEquals(null, resp.mappingError, 'Should have mapping error');
    }

    @isTest
    static void testMapSearchJson_HttpError() {
        // Arrange
        String searchJson = '{"error":"Not found"}';

        CrifSearchJsonMapper.Request req = new CrifSearchJsonMapper.Request();
        req.searchJson = searchJson;
        req.httpStatus = 404;

        // Act
        Test.startTest();
        List<CrifSearchJsonMapper.Response> responses = CrifSearchJsonMapper.mapSearchJson(new List<CrifSearchJsonMapper.Request>{req});
        Test.stopTest();

        // Assert
        System.assertEquals(1, responses.size(), 'Should return 1 response');
        CrifSearchJsonMapper.Response resp = responses[0];
        System.assertEquals('ERROR', resp.lastStatus, 'Status should be ERROR for 404');
    }

    @isTest
    static void testMapSearchJson_MultipleRequests() {
        // Arrange
        CrifSearchJsonMapper.Request req1 = new CrifSearchJsonMapper.Request();
        req1.searchJson = '{"companyId":"111","fatturato":1000000}';
        req1.httpStatus = 200;

        CrifSearchJsonMapper.Request req2 = new CrifSearchJsonMapper.Request();
        req2.searchJson = '{"companyId":"222","fatturato":2000000}';
        req2.httpStatus = 200;

        // Act
        Test.startTest();
        List<CrifSearchJsonMapper.Response> responses = CrifSearchJsonMapper.mapSearchJson(new List<CrifSearchJsonMapper.Request>{req1, req2});
        Test.stopTest();

        // Assert
        System.assertEquals(2, responses.size(), 'Should return 2 responses');
        System.assertEquals('111', responses[0].companyId, 'First company ID should match');
        System.assertEquals(1000000, responses[0].fatturato, 'First fatturato should match');
        System.assertEquals('222', responses[1].companyId, 'Second company ID should match');
        System.assertEquals(2000000, responses[1].fatturato, 'Second fatturato should match');
    }
}
