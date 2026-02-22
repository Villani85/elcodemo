@IsTest
private class VisitFollowupEmailInvocableTest {

    @IsTest
    static void testFollowupEmailWithMixedContacts() {
        // Setup: Account + 2 Contacts (one with Email, one without)
        Account acc = new Account(Name = 'Test Account P4');
        insert acc;

        Contact c1 = new Contact(
            FirstName = 'Mario',
            LastName = 'Rossi',
            Email = 'mario.rossi@example.com',
            AccountId = acc.Id
        );

        Contact c2 = new Contact(
            FirstName = 'Luigi',
            LastName = 'Verdi',
            Email = null, // NO EMAIL
            AccountId = acc.Id
        );

        insert new List<Contact>{c1, c2};

        // Create Visit_Report__c
        Visit_Report__c visit = new Visit_Report__c(
            Account__c = acc.Id,
            Subject__c = 'Test Visit',
            Visit_DateTime__c = System.now(),
            Visit_Type__c = 'Visita',
            Summary__c = 'Test summary',
            Next_Steps__c = 'Test next steps'
        );
        insert visit;

        // Create 2 Visit_Attendee__c
        Visit_Attendee__c att1 = new Visit_Attendee__c(
            Visit_Report__c = visit.Id,
            Contact__c = c1.Id,
            Email_Sent__c = false
        );

        Visit_Attendee__c att2 = new Visit_Attendee__c(
            Visit_Report__c = visit.Id,
            Contact__c = c2.Id,
            Email_Sent__c = false
        );

        insert new List<Visit_Attendee__c>{att1, att2};

        // Prepare invocable request
        VisitFollowupEmailInvocable.Request req = new VisitFollowupEmailInvocable.Request();
        req.visitReportId = visit.Id;
        req.subject = 'Test Follow-up';
        req.bodyText = 'This is a test follow-up email body.';

        Test.startTest();
        List<VisitFollowupEmailInvocable.Result> results =
            VisitFollowupEmailInvocable.send(new List<VisitFollowupEmailInvocable.Request>{req});
        Test.stopTest();

        // Assertions
        System.assertEquals(1, results.size(), 'Should return 1 result');

        VisitFollowupEmailInvocable.Result res = results[0];
        System.assertEquals(2, res.recipientsTotal, 'Total recipients should be 2');
        System.assertEquals(1, res.recipientsWithEmail, 'Recipients with email should be 1');
        System.assertEquals(1, res.sentCount, 'Sent count should be 1 in test context');
        System.assertEquals(1, res.skippedNoEmailCount, 'Skipped count should be 1');

        // Verify Visit_Report__c tracking
        Visit_Report__c updatedVisit = [
            SELECT FollowUp_Sent__c, FollowUp_Sent_On__c
            FROM Visit_Report__c
            WHERE Id = :visit.Id
        ];

        System.assertEquals(true, updatedVisit.FollowUp_Sent__c, 'FollowUp_Sent__c should be true');
        System.assertNotEquals(null, updatedVisit.FollowUp_Sent_On__c, 'FollowUp_Sent_On__c should be set');

        // Verify Visit_Attendee__c tracking
        List<Visit_Attendee__c> updatedAttendees = [
            SELECT Email_Sent__c, Contact__c
            FROM Visit_Attendee__c
            WHERE Visit_Report__c = :visit.Id
            ORDER BY Contact__c
        ];

        System.assertEquals(2, updatedAttendees.size(), 'Should have 2 attendees');

        // Find which attendee is which
        Visit_Attendee__c attWithEmail = null;
        Visit_Attendee__c attWithoutEmail = null;

        for (Visit_Attendee__c att : updatedAttendees) {
            if (att.Contact__c == c1.Id) {
                attWithEmail = att;
            } else if (att.Contact__c == c2.Id) {
                attWithoutEmail = att;
            }
        }

        System.assertNotEquals(null, attWithEmail, 'Should find attendee with email');
        System.assertNotEquals(null, attWithoutEmail, 'Should find attendee without email');

        System.assertEquals(true, attWithEmail.Email_Sent__c, 'Email_Sent should be true for contact with email');
        System.assertEquals(false, attWithoutEmail.Email_Sent__c, 'Email_Sent should be false for contact without email');
    }

    @IsTest
    static void testFollowupEmailNoContacts() {
        // Setup: Account + Visit without attendees
        Account acc = new Account(Name = 'Test Account No Contacts');
        insert acc;

        Visit_Report__c visit = new Visit_Report__c(
            Account__c = acc.Id,
            Subject__c = 'Test Visit No Contacts',
            Visit_DateTime__c = System.now(),
            Visit_Type__c = 'Teams'
        );
        insert visit;

        // Prepare invocable request
        VisitFollowupEmailInvocable.Request req = new VisitFollowupEmailInvocable.Request();
        req.visitReportId = visit.Id;
        req.subject = 'Test Follow-up';
        req.bodyText = 'Test body';

        Test.startTest();
        List<VisitFollowupEmailInvocable.Result> results =
            VisitFollowupEmailInvocable.send(new List<VisitFollowupEmailInvocable.Request>{req});
        Test.stopTest();

        // Assertions
        System.assertEquals(1, results.size(), 'Should return 1 result');

        VisitFollowupEmailInvocable.Result res = results[0];
        System.assertEquals(0, res.recipientsTotal, 'Total recipients should be 0');
        System.assertEquals(0, res.recipientsWithEmail, 'Recipients with email should be 0');
        System.assertEquals(0, res.sentCount, 'Sent count should be 0');
        System.assertEquals('Nessun contatto con Email', res.errorMessage, 'Should have error message');
    }
}
