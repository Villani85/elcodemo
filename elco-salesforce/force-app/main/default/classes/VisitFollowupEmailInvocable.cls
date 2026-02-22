/**
 * Apex Invocable per invio follow-up email post-visita
 * Sicurezza: preview destinatari, invio solo a contatti con Email, tracking
 */
public with sharing class VisitFollowupEmailInvocable {

    public class Request {
        @InvocableVariable(required=true)
        public Id visitReportId;

        @InvocableVariable(required=true)
        public String subject;

        @InvocableVariable(required=true)
        public String bodyText;
    }

    public class Result {
        @InvocableVariable
        public Integer recipientsTotal;

        @InvocableVariable
        public Integer recipientsWithEmail;

        @InvocableVariable
        public Integer sentCount;

        @InvocableVariable
        public Integer skippedNoEmailCount;

        @InvocableVariable
        public String errorMessage;
    }

    @InvocableMethod(label='Visite - Invia Follow-up Email' category='Visite')
    public static List<Result> send(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request req : requests) {
            Result res = new Result();
            res.recipientsTotal = 0;
            res.recipientsWithEmail = 0;
            res.sentCount = 0;
            res.skippedNoEmailCount = 0;
            res.errorMessage = '';

            try {
                // 1) Query Visit_Report__c
                List<Visit_Report__c> visits = [
                    SELECT Id, Account__c, FollowUp_Sent__c, FollowUp_Sent_On__c
                    FROM Visit_Report__c
                    WHERE Id = :req.visitReportId
                    LIMIT 1
                ];

                if (visits.isEmpty()) {
                    res.errorMessage = 'Visit Report not found';
                    results.add(res);
                    continue;
                }

                Visit_Report__c visit = visits[0];

                // 2) Query Visit_Attendee__c con Contact
                List<Visit_Attendee__c> attendees = [
                    SELECT Id, Contact__c, Contact__r.Email, Contact__r.Name, Email_Sent__c
                    FROM Visit_Attendee__c
                    WHERE Visit_Report__c = :req.visitReportId
                ];

                res.recipientsTotal = attendees.size();

                // 3) Costruisci lista email unique
                Set<String> emailSet = new Set<String>();
                Map<String, List<Id>> emailToAttendeeIds = new Map<String, List<Id>>();

                for (Visit_Attendee__c att : attendees) {
                    String email = att.Contact__r.Email;
                    if (String.isNotBlank(email)) {
                        email = email.trim();
                        emailSet.add(email);

                        if (!emailToAttendeeIds.containsKey(email)) {
                            emailToAttendeeIds.put(email, new List<Id>());
                        }
                        emailToAttendeeIds.get(email).add(att.Id);
                    }
                }

                res.recipientsWithEmail = emailSet.size();
                res.skippedNoEmailCount = res.recipientsTotal - res.recipientsWithEmail;

                // 4) Invia email
                if (emailSet.isEmpty()) {
                    res.errorMessage = 'Nessun contatto con Email';
                    results.add(res);
                    continue;
                }

                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

                for (String email : emailSet) {
                    Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
                    m.setToAddresses(new String[]{email});
                    m.setSubject(req.subject);
                    m.setPlainTextBody(req.bodyText);
                    emails.add(m);
                }

                // Send emails
                List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emails);

                // Check for errors
                for (Integer i = 0; i < sendResults.size(); i++) {
                    if (sendResults[i].isSuccess()) {
                        res.sentCount++;
                    } else {
                        if (String.isBlank(res.errorMessage)) {
                            List<Messaging.SendEmailError> errors = sendResults[i].getErrors();
                            if (!errors.isEmpty()) {
                                String errMsg = errors[0].getMessage();
                                res.errorMessage = errMsg.abbreviate(2550);
                            }
                        }
                    }
                }

                // 5) Tracking: Update Visit_Report__c
                if (res.sentCount > 0) {
                    visit.FollowUp_Sent__c = true;
                    visit.FollowUp_Sent_On__c = System.now();
                    update visit;

                    // Update Visit_Attendee__c - solo quelli con email
                    List<Visit_Attendee__c> attendeesToUpdate = new List<Visit_Attendee__c>();
                    for (Visit_Attendee__c att : attendees) {
                        if (String.isNotBlank(att.Contact__r.Email)) {
                            att.Email_Sent__c = true;
                            attendeesToUpdate.add(att);
                        }
                    }

                    if (!attendeesToUpdate.isEmpty()) {
                        update attendeesToUpdate;
                    }
                }

            } catch (Exception e) {
                res.errorMessage = e.getMessage().abbreviate(2550);
            }

            results.add(res);
        }

        return results;
    }
}
