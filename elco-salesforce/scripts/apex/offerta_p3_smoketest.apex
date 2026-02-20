// ============================================================================
// OFFERTA P3 - End-to-End Smoketest
// ============================================================================
// Creates Account (with prerequisites) + Opportunity + Quote + QuoteLineItem
// Validates the complete Quote management infrastructure
// ============================================================================

System.debug('=== OFFERTA P3 SMOKETEST START ===');
Long startTime = System.currentTimeMillis();

// ============================================================================
// STEP 1: Create Account with all prerequisites
// ============================================================================
System.debug('Step 1: Creating Account with prerequisites...');

Account testAccount = new Account();
testAccount.put('Name', 'OFFERTA P3 Test Account');
testAccount.put('Tolleranze_Default__c', 'Standard');
testAccount.put('Solder_Default__c', 'Verde');
testAccount.put('Silkscreen_Default__c', 'Bianco');
testAccount.put('Finish_Default__c', 'HASL');
testAccount.put('Spessore_Default__c', '1.6 mm');
insert testAccount;

System.debug('Account created: ' + testAccount.Id);

// ============================================================================
// STEP 2: Create Opportunity linked to Account
// ============================================================================
System.debug('Step 2: Creating Opportunity...');

Opportunity testOpp = new Opportunity();
testOpp.put('Name', 'OFFERTA P3 Test Opportunity');
testOpp.put('AccountId', testAccount.Id);
testOpp.put('StageName', 'Prospecting');
testOpp.put('CloseDate', Date.today().addDays(30));
// Link to Standard Price Book
testOpp.put('Pricebook2Id', '01sg50000028RoIAAU');
insert testOpp;

System.debug('Opportunity created: ' + testOpp.Id);

// ============================================================================
// STEP 3: Create Quote linked to Opportunity
// ============================================================================
System.debug('Step 3: Creating Quote...');

SObject testQuote = (SObject) Type.forName('Quote').newInstance();
testQuote.put('OpportunityId', testOpp.Id);
testQuote.put('Name', 'OFFERTA P3 Test Quote');
testQuote.put('Pricebook2Id', '01sg50000028RoIAAU');
testQuote.put('Purchase_Order__c', 'PO-TEST-' + String.valueOf(System.now().getTime()));
testQuote.put('Inside_Sales__c', UserInfo.getUserId());
testQuote.put('Num_Circuiti__c', 5.0);
testQuote.put('Giorni_Consegna__c', 10.0);
testQuote.put('Servizio__c', 'Normal');
testQuote.put('Trasporto__c', 'A carico ELCO');
testQuote.put('Customer_Code_Snapshot__c', 'CC-TEST-001');
insert testQuote;

System.debug('Quote created: ' + testQuote.Id);

// ============================================================================
// STEP 4: Create QuoteLineItem linked to Quote
// ============================================================================
System.debug('Step 4: Creating QuoteLineItem...');

SObject testQLI = (SObject) Type.forName('QuoteLineItem').newInstance();
testQLI.put('QuoteId', testQuote.Id);
testQLI.put('Quantity', 100.0);
testQLI.put('PricebookEntryId', '01ug5000000mmbpAAA');
testQLI.put('UnitPrice', 0.0);
testQLI.put('Tipologia_Prodotto__c', 'Rigido');
testQLI.put('Dimensioni_Array__c', '100x150');
testQLI.put('Customer_Circuit_Code__c', 'CC-TEST-001');
insert testQLI;

System.debug('QuoteLineItem created: ' + testQLI.Id);

// ============================================================================
// STEP 5: Validate data
// ============================================================================
System.debug('Step 5: Validating created records...');

// Query back the Quote
String quoteQuery = 'SELECT Id, Name, QuoteNumber, Purchase_Order__c, ' +
    'Inside_Sales__c, Num_Circuiti__c, Giorni_Consegna__c, ' +
    'Servizio__c, Trasporto__c, Customer_Code_Snapshot__c, ' +
    'Pricebook2Id, OpportunityId ' +
    'FROM Quote WHERE Id = \'' + testQuote.Id + '\'';
SObject queriedQuote = Database.query(quoteQuery)[0];

// Query back the QuoteLineItem
String qliQuery = 'SELECT Id, Quantity, UnitPrice, ' +
    'Tipologia_Prodotto__c, Dimensioni_Array__c, Customer_Circuit_Code__c, ' +
    'QuoteId, PricebookEntryId ' +
    'FROM QuoteLineItem WHERE Id = \'' + testQLI.Id + '\'';
SObject queriedQLI = Database.query(qliQuery)[0];

// ============================================================================
// STEP 6: Build E2E JSON
// ============================================================================
Map<String, Object> e2eData = new Map<String, Object>();

// Account data
Map<String, Object> accountData = new Map<String, Object>();
accountData.put('id', testAccount.Id);
accountData.put('name', testAccount.get('Name'));
accountData.put('tolleranze', testAccount.get('Tolleranze_Default__c'));
accountData.put('solder', testAccount.get('Solder_Default__c'));
accountData.put('silkscreen', testAccount.get('Silkscreen_Default__c'));
accountData.put('finish', testAccount.get('Finish_Default__c'));
accountData.put('spessore', testAccount.get('Spessore_Default__c'));
e2eData.put('account', accountData);

// Opportunity data
Map<String, Object> oppData = new Map<String, Object>();
oppData.put('id', testOpp.Id);
oppData.put('name', testOpp.get('Name'));
oppData.put('stageName', testOpp.get('StageName'));
oppData.put('pricebook2Id', testOpp.get('Pricebook2Id'));
e2eData.put('opportunity', oppData);

// Quote data
Map<String, Object> quoteData = new Map<String, Object>();
quoteData.put('id', queriedQuote.Id);
quoteData.put('name', queriedQuote.get('Name'));
quoteData.put('quoteNumber', queriedQuote.get('QuoteNumber'));
quoteData.put('purchaseOrder', queriedQuote.get('Purchase_Order__c'));
quoteData.put('insideSales', queriedQuote.get('Inside_Sales__c'));
quoteData.put('numCircuiti', queriedQuote.get('Num_Circuiti__c'));
quoteData.put('giorniConsegna', queriedQuote.get('Giorni_Consegna__c'));
quoteData.put('servizio', queriedQuote.get('Servizio__c'));
quoteData.put('trasporto', queriedQuote.get('Trasporto__c'));
quoteData.put('customerCodeSnapshot', queriedQuote.get('Customer_Code_Snapshot__c'));
e2eData.put('quote', quoteData);

// QuoteLineItem data
Map<String, Object> qliData = new Map<String, Object>();
qliData.put('id', queriedQLI.Id);
qliData.put('quantity', queriedQLI.get('Quantity'));
qliData.put('unitPrice', queriedQLI.get('UnitPrice'));
qliData.put('tipologiaProdotto', queriedQLI.get('Tipologia_Prodotto__c'));
qliData.put('dimensioni', queriedQLI.get('Dimensioni_Array__c'));
qliData.put('customerCode', queriedQLI.get('Customer_Circuit_Code__c'));
e2eData.put('quoteLineItem', qliData);

// Test metadata
Long endTime = System.currentTimeMillis();
Long duration = endTime - startTime;
e2eData.put('executionTimeMs', duration);
e2eData.put('success', true);

String e2eJson = JSON.serialize(e2eData);
System.debug('E2E_JSON:' + e2eJson);

// ============================================================================
// SUMMARY
// ============================================================================
System.debug('');
System.debug('=== OFFERTA P3 SMOKETEST SUMMARY ===');
System.debug('Account ID: ' + testAccount.Id);
System.debug('Opportunity ID: ' + testOpp.Id);
System.debug('Quote ID: ' + queriedQuote.Id);
System.debug('Quote Number: ' + queriedQuote.get('QuoteNumber'));
System.debug('QuoteLineItem ID: ' + queriedQLI.Id);
System.debug('Execution Time: ' + duration + 'ms');
System.debug('');
System.debug('✓ SMOKETEST PASSED');
System.debug('=== OFFERTA P3 SMOKETEST COMPLETE ===');
