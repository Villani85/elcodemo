// P6 Demo Seed Data Script
// Creates sample data for demonstrating Elco PCB quote-to-cash flow

// 1. Create Account with prerequisiti offerta
Account demoAccount = new Account(
    Name = 'DEMO - Cliente PCB',
    Tolleranze_Default__c = 'Standard',
    Solder_Default__c = 'Verde',
    Silkscreen_Default__c = 'Bianco',
    Finish_Default__c = 'ENIG',
    Spessore_Default__c = '1.6 mm',
    ERP_Customer_Code__c = 'ERP-DEMO-001'
);

// Try to set Partita_IVA if field exists, otherwise use BillingCountry
try {
    demoAccount.put('Partita_IVA__c', 'IT01234567890');
} catch (Exception e) {
    System.debug('Partita_IVA__c field not found, skipping');
}

insert demoAccount;
System.debug('Created Account: ' + demoAccount.Id);

// 2. Create 2 Contacts
Contact contact1 = new Contact(
    AccountId = demoAccount.Id,
    FirstName = 'Mario',
    LastName = 'Rossi',
    Email = 'mario.rossi@democlient.it',
    Title = 'Responsabile Acquisti'
);

Contact contact2 = new Contact(
    AccountId = demoAccount.Id,
    FirstName = 'Laura',
    LastName = 'Bianchi',
    Title = 'Ingegnere Progettazione'
);

insert new List<Contact>{contact1, contact2};
System.debug('Created Contacts: ' + contact1.Id + ', ' + contact2.Id);

// 3. Create Opportunity
Opportunity demoOpp = new Opportunity(
    AccountId = demoAccount.Id,
    Name = 'DEMO - Offerta PCB Prototipo',
    StageName = 'Prospecting',
    CloseDate = Date.today().addDays(30),
    Amount = 5000
);

insert demoOpp;
System.debug('Created Opportunity: ' + demoOpp.Id);

// 4. Create Quote with Standard Price Book
// First, get Standard Price Book ID
Id pricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;

Quote demoQuote = new Quote(
    OpportunityId = demoOpp.Id,
    Name = 'DEMO - Preventivo PCB',
    Pricebook2Id = pricebookId,
    Status = 'Draft'
);

insert demoQuote;
System.debug('Created Quote: ' + demoQuote.Id);

// 5. Try to create Quote Line Item if Product exists
try {
    // Look for a product (any product will do for demo)
    List<Product2> products = [SELECT Id FROM Product2 LIMIT 1];

    if (!products.isEmpty()) {
        // Get PricebookEntry for standard pricebook
        List<PricebookEntry> pbes = [
            SELECT Id, UnitPrice
            FROM PricebookEntry
            WHERE Product2Id = :products[0].Id
            AND Pricebook2Id = :pricebookId
            LIMIT 1
        ];

        if (!pbes.isEmpty()) {
            QuoteLineItem qli = new QuoteLineItem(
                QuoteId = demoQuote.Id,
                PricebookEntryId = pbes[0].Id,
                Quantity = 100,
                UnitPrice = pbes[0].UnitPrice != null ? pbes[0].UnitPrice : 50.00
            );

            // Try to set custom fields if they exist
            try {
                qli.put('Tipologia_Prodotto__c', 'Rigido');
                qli.put('Materiale__c', 'FR4');
                qli.put('Spessore_Complessivo__c', '1.6 mm');
            } catch (Exception e) {
                System.debug('Custom QLI fields not all available: ' + e.getMessage());
            }

            insert qli;
            System.debug('Created QuoteLineItem: ' + qli.Id);
        }
    }
} catch (Exception e) {
    System.debug('Could not create QuoteLineItem: ' + e.getMessage());
}

// 6. Create Visit Report
Visit_Report__c visit = new Visit_Report__c(
    Account__c = demoAccount.Id,
    Subject__c = 'DEMO - Visita Cliente',
    Visit_DateTime__c = DateTime.now().addDays(-7),
    Summary__c = 'Discussione requisiti tecnici per nuovi prototipi PCB',
    Visit_Type__c = 'Visita'
);

insert visit;
System.debug('Created Visit Report: ' + visit.Id);

// 7. Create Visit Attendees
List<Visit_Attendee__c> attendees = new List<Visit_Attendee__c>();

Visit_Attendee__c att1 = new Visit_Attendee__c(
    Visit_Report__c = visit.Id,
    Contact__c = contact1.Id
);
attendees.add(att1);

Visit_Attendee__c att2 = new Visit_Attendee__c(
    Visit_Report__c = visit.Id,
    Contact__c = contact2.Id
);
attendees.add(att2);

insert attendees;
System.debug('Created Visit Attendees: ' + attendees.size());

// 8. Print summary with links
System.debug('\n=== DEMO DATA CREATED ===');
System.debug('ACCOUNT_URL=/' + demoAccount.Id);
System.debug('OPPORTUNITY_URL=/' + demoOpp.Id);
System.debug('QUOTE_URL=/' + demoQuote.Id);
System.debug('VISIT_URL=/' + visit.Id);
System.debug('=========================\n');
