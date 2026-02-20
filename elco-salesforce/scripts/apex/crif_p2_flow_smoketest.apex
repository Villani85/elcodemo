// ============================================================================
// CRIF P2 Flow - End-to-End Smoketest
// ============================================================================
// Tests the complete CRIF P2 flow by invoking the autolaunched flow
// ============================================================================

// Find or create a test Account with P.IVA
String testPiva = 'IT01234567890';
List<Account> existingAccounts = [
    SELECT Id, Name, Partita_IVA__c
    FROM Account
    WHERE Partita_IVA__c = :testPiva
    LIMIT 1
];

Account testAccount;
if (existingAccounts.isEmpty()) {
    testAccount = new Account(
        Name = 'Test Account CRIF P2',
        Partita_IVA__c = testPiva
    );
    insert testAccount;
    System.debug('Created new test Account: ' + testAccount.Id);
} else {
    testAccount = existingAccounts[0];
    System.debug('Using existing test Account: ' + testAccount.Id);
}

// Prepare flow inputs
Map<String, Object> flowInputs = new Map<String, Object>();
flowInputs.put('recordId', testAccount.Id);

// Invoke the CRIF_Core_Refresh flow
System.debug('Invoking CRIF_Core_Refresh flow...');
Long startTime = System.currentTimeMillis();

Flow.Interview crifFlow = new Flow.Interview.CRIF_Core_Refresh(flowInputs);
crifFlow.start();

Long endTime = System.currentTimeMillis();
Long duration = endTime - startTime;

// Get flow outputs
Boolean success = (Boolean) crifFlow.getVariableValue('success');
String errorMessage = (String) crifFlow.getVariableValue('errorMessage');

System.debug('Flow execution completed in ' + duration + 'ms');
System.debug('Success: ' + success);
if (!success) {
    System.debug('Error: ' + errorMessage);
}

// Query the updated Account
Account updatedAccount = [
    SELECT Id, Name, Partita_IVA__c,
           CRIF_VAT_Normalized__c,
           CRIF_Last_Status__c,
           CRIF_Last_Refresh__c,
           CRIF_Last_Http_Status__c,
           CRIF_Fatturato__c,
           CRIF_Company_Id__c
    FROM Account
    WHERE Id = :testAccount.Id
];

// Construct E2E JSON
Map<String, Object> e2eData = new Map<String, Object>();
e2eData.put('flowSuccess', success);
e2eData.put('flowError', errorMessage);
e2eData.put('flowDurationMs', duration);
e2eData.put('accountId', updatedAccount.Id);
e2eData.put('lastStatus', updatedAccount.CRIF_Last_Status__c);
e2eData.put('lastRefresh', updatedAccount.CRIF_Last_Refresh__c);
e2eData.put('httpStatus', updatedAccount.CRIF_Last_Http_Status__c);
e2eData.put('vatNormalized', updatedAccount.CRIF_VAT_Normalized__c);
e2eData.put('fatturato', updatedAccount.CRIF_Fatturato__c);
e2eData.put('companyId', updatedAccount.CRIF_Company_Id__c);

String e2eJson = JSON.serialize(e2eData);
System.debug('E2E_JSON:' + e2eJson);

// Summary
System.debug('=== CRIF P2 Flow Smoketest Summary ===');
System.debug('Account ID: ' + updatedAccount.Id);
System.debug('Flow Success: ' + success);
System.debug('CRIF Last Status: ' + updatedAccount.CRIF_Last_Status__c);
System.debug('HTTP Status: ' + updatedAccount.CRIF_Last_Http_Status__c);
System.debug('VAT Normalized: ' + updatedAccount.CRIF_VAT_Normalized__c);
System.debug('Duration: ' + duration + 'ms');

if (success && updatedAccount.CRIF_Last_Http_Status__c == 200) {
    System.debug('✓ SMOKETEST PASSED');
} else {
    System.debug('✗ SMOKETEST FAILED');
}
