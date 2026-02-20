// ============================================================================
// Required FLS Security Test
// ============================================================================
// Test se l'assenza di FieldPermissions su campi required blocca l'operatore
// ============================================================================

// IDs (sostituiti da Codex)
String testUserId = '005g50000042WHdAAM';
String accountId = '001g500000CAxccAAD';
String contactId = '003g5000009R8txAAC';

// Recupera test user
User testUser = [SELECT Id, Username, Profile.Name FROM User WHERE Id = :testUserId LIMIT 1];
System.debug('TEST USER: ' + testUser.Username + ' (Profile: ' + testUser.Profile.Name + ')');

// Struttura risultati
Map<String, Object> finalReport = new Map<String, Object>();
List<Map<String, Object>> testResults = new List<Map<String, Object>>();

// ============================================================================
// TEST 1: Visit_Report__c (required: Account__c, Subject__c, Visit_DateTime__c, Visit_Type__c)
// ============================================================================
System.runAs(testUser) {
    Map<String, Object> visitReportTest = new Map<String, Object>();
    visitReportTest.put('objectName', 'Visit_Report__c');

    try {
        // Costruisci record con tutti i required valorizzati
        Visit_Report__c vr = new Visit_Report__c(
            Account__c = accountId,
            Subject__c = 'FLS Security Test',
            Visit_DateTime__c = DateTime.now(),
            Visit_Type__c = 'Visita'
        );

        // Applica stripInaccessible
        List<Visit_Report__c> vrList = new List<Visit_Report__c>{vr};
        SObjectAccessDecision securityDecision = Security.stripInaccessible(
            AccessType.CREATABLE,
            vrList
        );

        // Check removed fields
        Set<String> removedFields = securityDecision.getRemovedFields().get('Visit_Report__c');
        visitReportTest.put('removedFields', removedFields != null ? new List<String>(removedFields) : new List<String>());

        // Prova insert
        List<Visit_Report__c> sanitizedRecords = securityDecision.getRecords();
        insert sanitizedRecords;

        visitReportTest.put('insertSuccess', true);
        visitReportTest.put('recordId', sanitizedRecords[0].Id);
        visitReportTest.put('error', null);

    } catch (Exception e) {
        visitReportTest.put('insertSuccess', false);
        visitReportTest.put('recordId', null);
        visitReportTest.put('error', e.getTypeName() + ': ' + e.getMessage());
    }

    testResults.add(visitReportTest);
}

// ============================================================================
// TEST 2: Visit_Attendee__c (required: Visit_Report__c, Contact__c)
// ============================================================================
System.runAs(testUser) {
    Map<String, Object> visitAttendeeTest = new Map<String, Object>();
    visitAttendeeTest.put('objectName', 'Visit_Attendee__c');

    try {
        // Prima crea un Visit_Report as admin per avere un ID valido
        Visit_Report__c vrForAttendee = new Visit_Report__c(
            Account__c = accountId,
            Subject__c = 'Visit for Attendee Test',
            Visit_DateTime__c = DateTime.now(),
            Visit_Type__c = 'Visita'
        );
        insert vrForAttendee;

        // Ora System.runAs per testare Attendee
        User currentTestUser = [SELECT Id FROM User WHERE Id = :testUserId];

        System.runAs(currentTestUser) {
            // Costruisci Visit_Attendee con required
            Visit_Attendee__c va = new Visit_Attendee__c(
                Visit_Report__c = vrForAttendee.Id,
                Contact__c = contactId
            );

            // Applica stripInaccessible
            List<Visit_Attendee__c> vaList = new List<Visit_Attendee__c>{va};
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                AccessType.CREATABLE,
                vaList
            );

            // Check removed fields
            Set<String> removedFields = securityDecision.getRemovedFields().get('Visit_Attendee__c');
            visitAttendeeTest.put('removedFields', removedFields != null ? new List<String>(removedFields) : new List<String>());

            // Prova insert
            List<Visit_Attendee__c> sanitizedRecords = securityDecision.getRecords();
            insert sanitizedRecords;

            visitAttendeeTest.put('insertSuccess', true);
            visitAttendeeTest.put('recordId', sanitizedRecords[0].Id);
            visitAttendeeTest.put('error', null);
        }

    } catch (Exception e) {
        visitAttendeeTest.put('insertSuccess', false);
        visitAttendeeTest.put('recordId', null);
        visitAttendeeTest.put('error', e.getTypeName() + ': ' + e.getMessage());
    }

    testResults.add(visitAttendeeTest);
}

// ============================================================================
// TEST 3: Account_Tech_Spec__c (required: Account__c, Category__c, Parameter__c, Value__c)
// ============================================================================
System.runAs(testUser) {
    Map<String, Object> techSpecTest = new Map<String, Object>();
    techSpecTest.put('objectName', 'Account_Tech_Spec__c');

    try {
        // Costruisci record con tutti i required valorizzati
        Account_Tech_Spec__c ats = new Account_Tech_Spec__c(
            Account__c = accountId,
            Category__c = 'Materiali',
            Parameter__c = 'Tipo di Laminato (FR-4)',
            Value__c = 'Test Value'
        );

        // Applica stripInaccessible
        List<Account_Tech_Spec__c> atsList = new List<Account_Tech_Spec__c>{ats};
        SObjectAccessDecision securityDecision = Security.stripInaccessible(
            AccessType.CREATABLE,
            atsList
        );

        // Check removed fields
        Set<String> removedFields = securityDecision.getRemovedFields().get('Account_Tech_Spec__c');
        techSpecTest.put('removedFields', removedFields != null ? new List<String>(removedFields) : new List<String>());

        // Prova insert
        List<Account_Tech_Spec__c> sanitizedRecords = securityDecision.getRecords();
        insert sanitizedRecords;

        techSpecTest.put('insertSuccess', true);
        techSpecTest.put('recordId', sanitizedRecords[0].Id);
        techSpecTest.put('error', null);

    } catch (Exception e) {
        techSpecTest.put('insertSuccess', false);
        techSpecTest.put('recordId', null);
        techSpecTest.put('error', e.getTypeName() + ': ' + e.getMessage());
    }

    testResults.add(techSpecTest);
}

// ============================================================================
// FINAL REPORT
// ============================================================================
finalReport.put('testUser', testUser.Username);
finalReport.put('testDate', DateTime.now().format('yyyy-MM-dd HH:mm:ss'));
finalReport.put('testResults', testResults);

// Calcola summary
Integer totalTests = testResults.size();
Integer successCount = 0;
Integer failureCount = 0;
Integer fieldsRemovedCount = 0;

for (Map<String, Object> result : testResults) {
    if ((Boolean)result.get('insertSuccess')) {
        successCount++;
    } else {
        failureCount++;
    }

    List<String> removed = (List<String>)result.get('removedFields');
    if (removed != null && !removed.isEmpty()) {
        fieldsRemovedCount += removed.size();
    }
}

finalReport.put('summary', new Map<String, Object>{
    'totalTests' => totalTests,
    'successCount' => successCount,
    'failureCount' => failureCount,
    'fieldsRemovedCount' => fieldsRemovedCount,
    'conclusion' => failureCount == 0 && fieldsRemovedCount == 0 ? 'NO_IMPACT' : 'BLOCKING'
});

// Output JSON
String reportJson = JSON.serializePretty(finalReport);
System.debug('FINAL_REPORT_JSON:' + reportJson);
