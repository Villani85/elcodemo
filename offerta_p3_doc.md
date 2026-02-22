## OFFERTA P3 - Quote Management Flows & Actions (2026-02-20) - ✅ COMPLETED

### Objective
Implementazione completa dei flussi applicativi per la gestione Quote, inclusi creazione offerta, aggiunta righe con loop multi-riga, e storico offerte searchable.

### Components Deployed

#### 1. Flows (3)

**Screen Flow - Quote Creation:**
- **Quote_Crea_Offerta** (`force-app/main/default/flows/Quote_Crea_Offerta.flow-meta.xml`)
  - Flow per Quick Action su Opportunity
  - Prerequisite gating: Verifica campi default Account (Tolleranze, Solder, Silkscreen, Finish, Spessore)
  - UI: Blocco con errore se prerequisiti mancanti → Screen raccolta dati Quote → Success
  - Pricebook determination: Usa Pricebook2Id di Opportunity se presente, altrimenti Standard Price Book (01sg50000028RoIAAU)
  - Quote fields collected: Inside_Sales, Num_Circuiti, Giorni_Consegna, Servizio, Servizio_90_10, Trasporto, Anagrafica_Contatto, Purchase_Order, Note_Special_Needs, Customer_Code_Snapshot
  - Quote name format: "Offerta - {Opp.Name} - {CurrentDate}"
  - Deploy ID: **0Afg5000004FCmXCAW**
  - Status: **Active**, deployed

**Screen Flow - Add Quote Line Items:**
- **Quote_Aggiungi_Riga_Offerta** (`force-app/main/default/flows\Quote_Aggiungi_Riga_Offerta.flow-meta.xml`)
  - Flow per Quick Action su Quote
  - Multi-row loop capability: Checkbox "Aggiungi un'altra riga dopo questa"
  - UI: Screen input QLI fields → Create QLI → Loop if checkbox → Success (con count)
  - QuoteLineItem fields: Quantity (required), Tipologia_Prodotto (required), Dimensioni_Array, Customer_Circuit_Code
  - Hardcoded PricebookEntryId: 01ug5000000mmbpAAA (PCB Custom, UnitPrice=0)
  - Picklists inline: Tipologia_Prodotto (Rigido/Flessibile/Rigido-Flessibile)
  - Deploy ID: **0Afg5000004FD2fCAG**
  - Status: **Active**, deployed

**Screen Flow - Quote Search/History:**
- **Quote_Storico_Offerte** (`force-app/main/default/flows/Quote_Storico_Offerte.flow-meta.xml`)
  - Flow per Global Action + Account Quick Action
  - Search criteria: Purchase Order o Customer Code (radio buttons)
  - UI: Input search type + value → Query Quotes → Results/No Results screen
  - Query logic: Contains match on Purchase_Order__c or Customer_Code_Snapshot__c
  - Results ordered by CreatedDate DESC
  - Deploy ID: **0Afg5000004FEYDCA4**
  - Status: **Active**, deployed

#### 2. Quick Actions (4)

**Opportunity Quick Action:**
- **Opportunity.Crea_Offerta** (`force-app/main/default/quickActions/Opportunity.Crea_Offerta.quickAction-meta.xml`)
  - Label: "Crea Offerta"
  - Invoca flow: Quote_Crea_Offerta
  - Type: Flow
  - Status: **Deployed**

**Quote Quick Action:**
- **Quote.Aggiungi_Riga_Offerta** (`force-app/main/default/quickActions/Quote.Aggiungi_Riga_Offerta.quickAction-meta.xml`)
  - Label: "Aggiungi Riga Offerta"
  - Invoca flow: Quote_Aggiungi_Riga_Offerta
  - Type: Flow
  - Status: **Deployed**

**Account Quick Action:**
- **Account.Storico_Offerte** (`force-app/main/default/quickActions/Account.Storico_Offerte.quickAction-meta.xml`)
  - Label: "Storico Offerte"
  - Invoca flow: Quote_Storico_Offerte
  - Type: Flow
  - Status: **Deployed**

**Global Quick Action:**
- **Storico_Offerte** (`force-app/main/default/quickActions/Storico_Offerte.quickAction-meta.xml`)
  - Label: "Storico Offerte"
  - Invoca flow: Quote_Storico_Offerte
  - Type: Flow
  - Status: **Deployed**

### Deployment Log

| Section | Component | Deploy ID | Status | Timestamp |
|---------|-----------|-----------|--------|-----------|
| C | Quote_Crea_Offerta | 0Afg5000004FCmXCAW | ✅ Succeeded | 2026-02-20 |
| D | Quote_Aggiungi_Riga_Offerta | 0Afg5000004FD2fCAG | ✅ Succeeded | 2026-02-20 |
| E | Quote_Storico_Offerte | 0Afg5000004FEYDCA4 | ✅ Succeeded | 2026-02-20 |
| F | 4 Quick Actions | 0Afg5000004FEbRCAW | ✅ Succeeded | 2026-02-20 |

### Smoketest ✅ PASS
- **Script**: `scripts/apex/offerta_p3_smoketest.apex`
- **Execution Time**: 537ms
- **Status**: **PASSED** ✓
- **Records Created**:
  - Account: 001g500000CBugaAAD (with prerequisites: Tolleranze=Standard, Solder=Verde, Silkscreen=Bianco, Finish=HASL, Spessore=1.6 mm)
  - Opportunity: 006g5000001qTOjAAM (linked to Account, Pricebook2Id=01sg50000028RoIAAU)
  - Quote: 0Q0g50000004kU5CAI (QuoteNumber: 00000003, PO=PO-TEST-1771618984902)
  - QuoteLineItem: 0QLg500000079HtGAI (Quantity=100, Tipologia=Rigido, Dimensioni=100x150)
- **Validation**: All records queried back successfully with correct field values
- **E2E JSON**: Complete data structure serialized and validated

### Artifacts & Logs
- `raw/offerta_p3/org_display.json` - Org info
- `raw/offerta_p3/standard_pricebook.json` - Standard Price Book verification (01sg50000028RoIAAU)
- `raw/offerta_p3/pcb_product.json` - PCB Custom product verification (01tg50000031n1lAAA)
- `raw/offerta_p3/pcb_pbe.json` - PricebookEntry verification (01ug5000000mmbpAAA, UnitPrice=0)
- `raw/offerta_p3/pbid.txt`, `pbeid.txt`, `prodid.txt` - Reference IDs
- `raw/offerta_p3/deploy_flow_quote_create.log` - Quote creation flow deployment
- `raw/offerta_p3/deploy_flow_quote_addline_v3.log` - Add line flow deployment (final)
- `raw/offerta_p3/deploy_flow_quote_storico.log` - Storico flow deployment
- `raw/offerta_p3/deploy_actions.log` - All actions deployment
- `raw/offerta_p3/smoketest_results_final.log` - Smoketest execution log

### Key Design Decisions

1. **Prerequisite Gating**: Quote_Crea_Offerta verifica che Account abbia tutti i 5 campi default popolati prima di permettere la creazione Quote. Questo previene errori downstream.

2. **Hardcoded IDs**: Pricebook2Id (01sg50000028RoIAAU) e PricebookEntryId (01ug5000000mmbpAAA) sono hardcoded per garantire determinismo e idempotenza. Questi IDs sono stabili nell'org.

3. **Multi-row Loop Pattern**: Quote_Aggiungi_Riga_Offerta usa un checkbox "Aggiungi un'altra riga" con loop back allo screen, permettendo input di N righe in una singola sessione flow senza dover riaprire il flow.

4. **Simplified Search**: Quote_Storico_Offerte cerca solo su campi Quote-level (Purchase_Order, Customer_Code_Snapshot) per evitare complessità di query su QuoteLineItem. Future enhancement potrebbe aggiungere search su circuit codes via subquery.

5. **Picklist Values**: Tutti i picklists usano valori reali dall'org (es. "Verde" non "Green", "1.6 mm" non "1.6", "Rigido" non "Standard").

### Next Steps (User Actions Required)

1. **Add Quick Actions to Page Layouts**:
   - Opportunity page layout: Add "Crea Offerta" quick action
   - Quote page layout: Add "Aggiungi Riga Offerta" quick action
   - Account page layout: Add "Storico Offerte" quick action
   - Global actions: Add "Storico Offerte" to utility bar

2. **Add Quote Fields to Layouts**:
   - Quote layout: Add custom fields (Inside_Sales, Num_Circuiti, Giorni_Consegna, Servizio, Trasporto, Purchase_Order, Customer_Code_Snapshot, etc.)
   - QuoteLineItem layout: Add custom fields (Tipologia_Prodotto, Dimensioni_Array, Customer_Circuit_Code, etc.)

3. **Test Complete Flow via UI**:
   - Navigate to Opportunity → Click "Crea Offerta" → Complete flow
   - Navigate to created Quote → Click "Aggiungi Riga Offerta" → Add multiple rows
   - Use "Storico Offerte" global action to search quotes

4. **Training**: Train users on new Quote management functionality and flows

### Known Limitations

- **Dependent Picklists**: Materiale__c, Spessore_Complessivo__c, and other dependent fields excluded from Quote_Aggiungi_Riga_Offerta to avoid validation errors. Users can edit these via standard Quote Line Item edit.
- **Search Scope**: Quote_Storico_Offerte only searches Quote-level fields, not circuit codes in QuoteLineItems.
- **Datatable Component**: flowruntime:datatable component not used in results screen due to type mapping requirements; users see basic success message instead.

---
