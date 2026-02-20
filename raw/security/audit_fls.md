# Audit - Field-Level Security (FLS)

**Data**: 2026-02-20 17:05
**Org ID**: 00Dg5000005Sp7zEAC
**Username**: giuseppe.villani101020.b5bd075bbc5f@agentforce.com
**API Version**: 65.0

---

## FieldPermissions Presenti in Org (da metadata retrieved)

### Quote_Operator
**Total**: 30 field permissions

- Account.ERP_Customer_Code__c (RE)
- Account.Finish_Default__c (RE)
- Account.Prerequisiti_Note__c (RE)
- Account.Silkscreen_Default__c (RE)
- Account.Solder_Default__c (RE)
- Account.Spessore_Default__c (RE)
- Account.Tolleranze_Default__c (RE)
- Quote.Anagrafica_Contatto__c (RE)
- Quote.Customer_Code_Snapshot__c (RE)
- Quote.Giorni_Consegna__c (RE)
- Quote.Inside_Sales__c (RE)
- Quote.Note_Special_Needs__c (RE)
- Quote.Num_Circuiti__c (RE)
- Quote.Purchase_Order__c (RE)
- Quote.Servizio_90_10__c (RE)
- Quote.Servizio__c (RE)
- Quote.Trasporto__c (RE)
- QuoteLineItem.Customer_Circuit_Code__c (RE)
- QuoteLineItem.Dimensioni_Array__c (RE)
- QuoteLineItem.Finish__c (RE)
- QuoteLineItem.Internal_Circuit_Code__c (RE)
- QuoteLineItem.Materiale_Custom_Value__c (RE)
- QuoteLineItem.Materiale__c (RE)
- QuoteLineItem.Rame_Custom_Value__c (RE)
- QuoteLineItem.Silkscreen_Specifico__c (RE)
- QuoteLineItem.Solder_Specifico__c (RE)
- QuoteLineItem.Spessore_Complessivo__c (RE)
- QuoteLineItem.Spessore_Custom_Value__c (RE)
- QuoteLineItem.Spessore_Rame_Esterni__c (RE)
- QuoteLineItem.Tipologia_Prodotto__c (RE)

### Visit_Operator
**Total**: 5 field permissions

- Visit_Attendee__c.Email_Sent__c (RE)
- Visit_Report__c.FollowUp_Sent_On__c (RE)
- Visit_Report__c.FollowUp_Sent__c (RE)
- Visit_Report__c.Next_Steps__c (RE)
- Visit_Report__c.Summary__c (RE)

### TechSpec_Operator
**Total**: 4 field permissions

- Account_Tech_Spec__c.Is_Active__c (RE)
- Account_Tech_Spec__c.Notes__c (RE)
- Account_Tech_Spec__c.Source__c (RE)
- Account_Tech_Spec__c.UoM__c (RE)

---

## Legenda
- **RE**: Read + Edit permissions
- **R-**: Read only
- **-E**: Edit only (raro)

---

## Note
- I dati sono estratti dai metadata retrieved dall'org
- File JSON completo: `raw/security/current_fls_in_org.json`
- Prossimo step: confrontare con expected fields (FASE D-E)
