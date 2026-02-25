public with sharing class QuoteRequestPdfEmailService {

    /**
     * Metodo wrapper chiamato dal Job (Queueable).
     * Delega l'esecuzione al metodo asincrono @future.
     */
    public static void sendEmailsForQuotes(List<Id> quoteIds) {
        sendEmailsAsync(quoteIds);
    }

    /**
     * Metodo chiamato dal trigger dopo insert.
     * Viene eseguito fuori dal contesto del trigger
     * ed è abilitato ai callout (getContentAsPDF).
     */
    @future(callout=true)
    public static void sendEmailsAsync(List<Id> quoteIds) {
        if (quoteIds == null || quoteIds.isEmpty()) {
            return;
        }

        // Query dei preventivi + dati Lead
        List<Quote_Request__c> quotes = [
            SELECT Id,
                   QuoteNumber__c,
                   Price__c,
                   RequestedOn__c,
                   Status__c,
                   Source__c,
                   External_Id__c,
                   GerberFileName__c,
                   GerberSizeKB__c,
                   Params__c,
                   Owner.Name,
                   Lead__r.Id,
                   Lead__r.FirstName,
                   Lead__r.LastName,
                   Lead__r.Email,
                   Lead__r.Company,
                   Lead__r.Phone
            FROM Quote_Request__c
            WHERE Id IN :quoteIds
        ];

        if (quotes.isEmpty()) {
            return;
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Quote_Request__c qr : quotes) {

            // 1) Genero il PDF dalla Visualforce
            PageReference pdfPage = Page.QuoteRequest_Pdf;
            pdfPage.getParameters().put('id', qr.Id);
            Blob pdfBody = pdfPage.getContentAsPDF();

            // 2) Nome Lead
            String leadName = '';
            if (qr.Lead__r != null) {
                if (qr.Lead__r.FirstName != null) {
                    leadName += qr.Lead__r.FirstName + ' ';
                }
                if (qr.Lead__r.LastName != null) {
                    leadName += qr.Lead__r.LastName;
                }
            }

            // 3) Email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            // 👉 per i test, tieni pure il tuo indirizzo
            mail.setToAddresses(new String[] { 'servizi.villani@gmail.com' });

            String subject = 'Offerta PCB – ' +
                (qr.QuoteNumber__c != null ? qr.QuoteNumber__c : (String)qr.Id);

            mail.setSubject(subject);

            String body =
'Gentile ' + (String.isNotBlank(leadName) ? leadName : 'cliente') + ',\n\n' +
'in allegato trovi il riepilogo in PDF del tuo preventivo PCB ELCO.\n\n' +
'Numero preventivo: ' + (qr.QuoteNumber__c != null ? qr.QuoteNumber__c : (String)qr.Id) + '\n' +
'Valore totale: ' + (qr.Price__c != null ? String.valueOf(qr.Price__c) + ' EUR' : 'n/d') + '\n\n' +
'Cordiali saluti,\n' +
'ELCO PCB Quick Quote\n';

            mail.setPlainTextBody(body);

            // 4) Allegato PDF
            Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
            att.setFileName(
                'Offerta_PCB_' + (qr.QuoteNumber__c != null ? qr.QuoteNumber__c : (String)qr.Id) + '.pdf'
            );
            att.setContentType('application/pdf');
            att.setBody(pdfBody);

            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { att });

            emails.add(mail);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}