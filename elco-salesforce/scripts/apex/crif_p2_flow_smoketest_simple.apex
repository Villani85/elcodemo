// ============================================================================
// CRIF P2 Flow - Simplified Smoketest
// ============================================================================
// Tests the CRIF P2 flow - simplified to avoid metadata cache issues
// ============================================================================

// Create a test Account with P.IVA
String testPiva = 'IT01234567890';

Account testAccount = new Account(Name = 'CRIF P2 Test Account');
// Set P.IVA via put (to avoid compile-time field reference)
testAccount.put('Partita_IVA__c', testPiva);
insert testAccount;
System.debug('Created test Account: ' + testAccount.Id);

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

// Query the updated Account (without field name references)
String query = 'SELECT Id, Name, ' +
    'CRIF_VAT_Normalized__c, ' +
    'CRIF_Last_Status__c, ' +
    'CRIF_Last_Http_Status__c, ' +
    'CRIF_Fatturato__c, ' +
    'CRIF_Company_Id__c ' +
    'FROM Account WHERE Id = \'' + testAccount.Id + '\'';

Account updatedAccount = (Account) Database.query(query)[0];

// Construct E2E JSON
Map<String, Object> e2eData = new Map<String, Object>();
e2eData.put('flowSuccess', success);
e2eData.put('flowError', errorMessage);
e2eData.put('flowDurationMs', duration);
e2eData.put('accountId', updatedAccount.Id);
e2eData.put('lastStatus', updatedAccount.get('CRIF_Last_Status__c'));
e2eData.put('httpStatus', updatedAccount.get('CRIF_Last_Http_Status__c'));
e2eData.put('vatNormalized', updatedAccount.get('CRIF_VAT_Normalized__c'));
e2eData.put('fatturato', updatedAccount.get('CRIF_Fatturato__c'));
e2eData.put('companyId', updatedAccount.get('CRIF_Company_Id__c'));

String e2eJson = JSON.serialize(e2eData);
System.debug('E2E_JSON:' + e2eJson);

// Summary
System.debug('=== CRIF P2 Flow Smoketest Summary ===');
System.debug('Account ID: ' + updatedAccount.Id);
System.debug('Flow Success: ' + success);
System.debug('CRIF Last Status: ' + updatedAccount.get('CRIF_Last_Status__c'));
System.debug('HTTP Status: ' + updatedAccount.get('CRIF_Last_Http_Status__c'));
System.debug('VAT Normalized: ' + updatedAccount.get('CRIF_VAT_Normalized__c'));
System.debug('Duration: ' + duration + 'ms');

Integer httpStatus = (Integer) updatedAccount.get('CRIF_Last_Http_Status__c');
if (success && httpStatus == 200) {
    System.debug('✓ SMOKETEST PASSED');
} else {
    System.debug('✗ SMOKETEST FAILED');
}
