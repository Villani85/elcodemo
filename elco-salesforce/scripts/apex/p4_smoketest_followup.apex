// Try to find existing test account, create if not found
List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'Test ACME Corp' LIMIT 1];
Account a;
if (accounts.isEmpty()) {
    a = new Account(Name = 'Test ACME Corp');
    insert a;
    System.debug('Created test Account: ' + a.Id);
} else {
    a = accounts[0];
    System.debug('Found existing Account: ' + a.Id);
}

Visit_Report__c vr = new Visit_Report__c(
    Account__c = a.Id,
    Subject__c = 'Test Follow-up Flow',
    Visit_DateTime__c = System.now(),
    Visit_Type__c = 'Visita',
    Summary__c = 'Test',
    Next_Steps__c = 'Test next steps'
);
insert vr;
System.debug('Created Visit_Report__c: ' + vr.Id);

List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :a.Id LIMIT 2];
if (contacts.isEmpty()) {
    // Create test contacts if none exist
    contacts = new List<Contact>{
        new Contact(FirstName = 'Test', LastName = 'Contact1', AccountId = a.Id, Email = 'test1@example.com'),
        new Contact(FirstName = 'Test', LastName = 'Contact2', AccountId = a.Id, Email = 'test2@example.com')
    };
    insert contacts;
    System.debug('Created ' + contacts.size() + ' test contacts');
} else {
    System.debug('Found ' + contacts.size() + ' existing contacts');
}

List<Visit_Attendee__c> attendees = new List<Visit_Attendee__c>();
for (Contact c : contacts) {
    attendees.add(new Visit_Attendee__c(
        Visit_Report__c = vr.Id,
        Contact__c = c.Id
    ));
}
insert attendees;
System.debug('Created ' + attendees.size() + ' attendees');

System.debug('Smoketest passed: P4 data created successfully');
