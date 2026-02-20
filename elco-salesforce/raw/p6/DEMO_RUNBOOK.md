# Elco Demo Runbook

**Purpose**: Demonstrate Quote-to-Cash flow with Quick Actions
**Prerequisites**: Execute `scripts/apex/demo_seed.apex` to create demo data
**Duration**: 10-15 minutes

---

## Demo Data Created

After running the seed script, you will have:

- **Account**: DEMO - Cliente PCB (`/001g500000CCQOjAAP`)
- **Contacts**: Mario Rossi, Laura Bianchi
- **Opportunity**: DEMO - Offerta PCB Prototipo (`/006g5000001qWpdAAE`)
- **Quote**: DEMO - Preventivo PCB (`/0Q0g50000004kqfCAA`)
- **Visit Report**: VR-XXXXXX (`/a02g5000005amL0AAI`)
- **Visit Attendees**: 2 attendees linked to visit

---

## Demo Walkthrough

### Step 1: Account - CRIF Integration
1. Navigate to **Account** record: DEMO - Cliente PCB
2. Click **CRIF - Aggiorna Dati** Quick Action (if visible in highlights panel)
   - This action would trigger CRIF credit check integration
   - Flow: Account → CRIF API → Update financial fields
3. Click **CRIF Storico** Quick Action
   - View historical CRIF credit reports
4. Click **Storico Offerte** Quick Action
   - View quote history for this customer

### Step 2: Account - Technical Specifications
1. On same Account record, click **Gestisci Specifiche Tecniche** Quick Action
   - Opens flow to manage customer's default technical specifications
   - Fields: Tolleranze, Solder, Silkscreen, Finish, Spessore

### Step 3: Opportunity - Create Quote
1. Navigate to **Opportunity** record: DEMO - Offerta PCB Prototipo
2. Click **Crea Offerta** Quick Action (if visible in highlights panel)
   - Opens flow to create new Quote
   - Pre-populates Account data and prerequisiti offerta
   - Note: Demo already has a Quote created

### Step 4: Quote - Add Line Item
1. Navigate to **Quote** record: DEMO - Preventivo PCB
2. Click **Aggiungi Riga Offerta** Quick Action
   - Opens flow to add QuoteLineItem with PCB specifications
   - Fields: Tipologia_Prodotto, Materiale, Spessore_Complessivo, etc.

### Step 5: Account - Create Visit Report
1. Return to **Account** record: DEMO - Cliente PCB
2. Click **Crea Report Visita** Quick Action
   - Opens flow to create new Visit_Report__c
   - Links to Account and allows adding Visit_Attendee__c records
   - Note: Demo already has a Visit Report created

### Step 6: Visit Report - Send Follow-up
1. Navigate to **Visit Report** record created by seed (VR-XXXXXX)
2. Click **Invia Followup** Quick Action
   - Opens flow to send follow-up email to visit attendees
   - Sets FollowUp_Sent__c = true and FollowUp_Sent_On__c = NOW()

---

## Account 360 Page (If Activated)

**Note**: If Account_360 FlexiPage is not yet activated, see `raw/p5/ACTIVATION_UI_STEPS.md` for manual setup instructions.

Once activated, navigate to Account record and view the tabbed layout:

1. **Tab 1**: Dati Finanziari & CRIF
   - Shows CRIF fields: Partita_IVA, Company_Name, Fido_Richiesto, etc.

2. **Tab 2**: Specifiche Tecniche
   - Related List: Account_Tech_Spec__c records

3. **Tab 3**: Amministrazione & Zucchetti
   - Shows Zucchetti ERP integration fields

4. **Tab 4**: Tableau
   - Placeholder for embedded Tableau dashboard

---

## Verification Quick Actions Are Present

After P6 deployment, verify Quick Actions appear on layouts:

### Account Layout
- CRIF_Aggiorna_Dati
- CRIF_Storico
- Storico_Offerte
- Gestisci_Specifiche_Tecniche
- Crea_Report_Visita

### Opportunity Layout
- Crea_Offerta

### Quote Layout
- Aggiungi_Riga_Offerta (already deployed in P5)

### Visit_Report__c Layout
- Invia_Followup (already deployed in P5)

**How to verify**:
1. Open record detail page
2. Look for actions in Highlights panel or "More Actions" dropdown
3. If actions are missing, see `raw/p6/deploy_errors.txt` for troubleshooting

---

## Cleanup (Optional)

To remove demo data:
1. Navigate to Account: DEMO - Cliente PCB
2. Delete Account (cascades to Contacts, Opportunity, Quote, Visit Reports)

Or use Developer Console:
```apex
List<Account> demoAccounts = [SELECT Id FROM Account WHERE Name = 'DEMO - Cliente PCB'];
delete demoAccounts;
```

---

**Last Updated**: 2026-02-20
**P6**: Closeout UX + Demo Pack
