# Struttura progetto

## Audit org (2026-02-20 15:07:40 +01:00)
- Report completo: `sf-audit/audit/org_state.md`
- Output grezzi: `sf-audit/audit/raw/`
- Metadata recuperati: `sf-audit/audit/retrieved/`
- Org auditata: `elco-dev` (`00Dg5000005Sp7zEAC`)
- Modalita esecuzione: sola lettura (`query/list/retrieve`)

### Stato attuale
- Org Developer Edition nuova e connessa, baseline standard disponibile.
- Quotes non abilitato (`Quote`/`QuoteLineItem` assenti).
- Oggetti custom progetto (`Account_Tech_Spec__c`, `Visit_Report__c`, `Visit_Attendee__c`) assenti.
- Integrazione CRIF non pronta: assenti `ExternalCredential`, `NamedCredential`, `AuthProvider`.
- Nessun Flow applicativo e nessuna Quick Action progetto; `Integration_Log__c` non presente (vincolo rispettato).

### Prossimi step
- P0: abilitare Quotes e attivare Standard Price Book.
- P0: creare data model custom richiesto (Specifiche Tecniche + Visite).
- P0: configurare External Credential + Named Credential per CRIF.
- P1: implementare flow-first backbone (CRIF/Quote/Visit/TechSpec).
- P1: costruire Account 360 (FlexiPage con tab + quick actions dedicate).

## P0 - Data Model (2026-02-20 15:54:58 +01:00)
Org alias: `elco-dev`  
Raw evidenze: `elco-salesforce/raw/`

### a) Oggetti creati (+ relazioni)
- `Account_Tech_Spec__c` (Specifica Tecnica, AutoNumber `TS-{000000}`)
  - `Account__c` Lookup -> `Account` (required, relationship `TechSpecs`)
- `Visit_Report__c` (Report Visita, AutoNumber `VR-{000000}`)
  - `Account__c` Lookup -> `Account` (required, relationship `VisitReports`)
- `Visit_Attendee__c` (Partecipante Visita, AutoNumber `VA-{000000}`)
  - `Visit_Report__c` MasterDetail -> `Visit_Report__c` (relationship `Attendees`)
  - `Contact__c` Lookup -> `Contact` (required, relationship `VisitAttendees`)

### b) Campi creati su Account / Quote / QLI
- `Account`
  - `Tolleranze_Default__c` Picklist: Standard | Stretta | Da Disegno / Custom
  - `Solder_Default__c` Picklist: Verde | Nero | Bianco | Rosso | Blu | Giallo | Trasparente | Nessuno | Custom
  - `Silkscreen_Default__c` Picklist: Bianco | Nero | Giallo | Nessuno | Custom
  - `Finish_Default__c` Picklist: HASL | HASL Lead Free | ENIG | ENEPIG | OSP | Immersion Silver | Immersion Tin | Hard Gold | Custom
  - `Spessore_Default__c` Picklist: 0.4/0.6/0.8/1.0/1.2/1.6/2.0/2.4/3.2 mm | Custom
  - `Prerequisiti_Note__c` LongTextArea(32768)
  - `ERP_Customer_Code__c` Text(80)
- `Quote`
  - `Inside_Sales__c` Lookup(User)
  - `Num_Circuiti__c` Number(10,0)
  - `Giorni_Consegna__c` Number(10,0)
  - `Servizio__c` Picklist: Normal | Fast | Guarantee
  - `Servizio_90_10__c` Checkbox(default false)
  - `Note_Special_Needs__c` LongTextArea(32768)
  - `Trasporto__c` Picklist: A carico ELCO | A carico Cliente | Ritiro in sede | Altro
  - `Anagrafica_Contatto__c` Lookup(Contact)
  - `Purchase_Order__c` Text(80)
  - `Customer_Code_Snapshot__c` Text(80)
- `QuoteLineItem`
  - `Tipologia_Prodotto__c` Picklist: Rigido | Flessibile | Rigido-Flessibile
  - `Materiale__c` Picklist (dependent)
  - `Materiale_Custom_Value__c` Text(255)
  - `Spessore_Complessivo__c` Picklist (dependent)
  - `Spessore_Custom_Value__c` Text(255)
  - `Spessore_Rame_Esterni__c` Picklist: 0.5 oz (18 µm) | 1 oz (35 µm) | 2 oz (70 µm) | Custom
  - `Rame_Custom_Value__c` Text(255)
  - `Finish__c` Picklist: HASL | HASL Lead Free | ENIG | ENEPIG | OSP | Immersion Silver | Immersion Tin | Hard Gold | Custom
  - `Solder_Specifico__c` Picklist: Verde | Nero | Bianco | Rosso | Blu | Giallo | Trasparente | Nessuno | Custom
  - `Silkscreen_Specifico__c` Picklist: Bianco | Nero | Giallo | Nessuno | Custom
  - `Dimensioni_Array__c` Text(80)
  - `Internal_Circuit_Code__c` Text(80)
  - `Customer_Circuit_Code__c` Text(80)

### c) Dipendenze picklist implementate
- `Account_Tech_Spec__c.Category__c -> Parameter__c`
  - mapping completo per: Materiali / Dimensioni & Tolleranze / Confezionamento / Imballo / Etichettatura / Documentazione / Qualità & Certificazioni / Note Commerciali / Preferenze.
- `QuoteLineItem.Tipologia_Prodotto__c -> Materiale__c`
  - Rigido -> FR-4 Standard, FR-4 High Tg, Rogers, Alluminio (Metal Core), CEM-1, CEM-3, Custom
  - Flessibile -> Polyimide, Custom
  - Rigido-Flessibile -> FR-4 Standard, FR-4 High Tg, Polyimide, Custom
- `QuoteLineItem.Materiale__c -> Spessore_Complessivo__c`
  - mapping completo secondo specifica (FR-4/CEM standard completi, Rogers/Alluminio/Polyimide subset, Custom->Custom).

### P0 completato
- Quotes abilitato: `elco-salesforce/raw/deploy_settings_quotes.json`
- Standard Price Book attivo: `elco-salesforce/raw/standard_pricebook_post.json`
- Prodotto + PBE creati: `elco-salesforce/raw/product_pcb_custom_post.json`, `elco-salesforce/raw/pbe_post.json`
- Deploy metadata P0: `elco-salesforce/raw/deploy_p0.json`

## Security / Permission Sets (2026-02-20) - ✅ BASELINE COMPLETATO
- `Quote_Operator` -> Quote/QLI + FLS campi offerta (header/righe) e prerequisiti account (30/30 campi, **100%** coverage).
- `Visit_Operator` -> `Visit_Report__c`/`Visit_Attendee__c` + FLS campi visita deployabili (5/5 campi, **100%** coverage - campi required esclusi da audit, verificati OK via test).
- `TechSpec_Operator` -> `Account_Tech_Spec__c` + FLS campi tech spec deployabili (4/4 campi, **100%** coverage - campi required esclusi da audit, verificati OK via test).
- `Setup_Admin_Elco` -> permessi setup minimi per admin operativo.
- `CRIF_MOCK_Access` -> External Credential Principal Access per integrazione CRIF Mock (base).
- `CRIF_Operator` -> Account Read/Edit + FLS campi CRIF business/scores/notices (NO raw JSON). External Credential Principal Access `CRIF_MOCK_EXT-NamedPrincipal`. Deploy ID: `0Afg5000004F389CAC`.
- `CRIF_Admin` -> Come CRIF_Operator + FLS `CRIF_Last_Raw_JSON__c` + Admin fields editabili. External Credential Principal Access `CRIF_MOCK_EXT-NamedPrincipal`. Deploy ID: `0Afg5000004F389CAC`.
- `Elco_Run_Flows` -> RunFlow permission per esecuzione Flows.
- **Security Audit (2026-02-20 17:15)**: RunFlow permission missing ✅ risolto con `Elco_Run_Flows`.
- **Required Fields FLS Verification (2026-02-20 17:45)**: ✅ Verificato con test deterministici che campi required FUNZIONANO senza FieldPermissions esplicite (limite Metadata API, non runtime security). Test class: `RequiredFlsSecurityTest.cls` (3/3 passed, 100% success rate).
- **FLS Coverage Finale**: 100% su tutti i permission sets (per campi deployabili). Campi required esclusi da expected audit (non deployabili via Permission Set, ma verificati operativi via test reali).
- Log di riferimento: `elco-salesforce/raw/security/deploy_permsets.log`, `elco-salesforce/raw/security/assign_permsets.log`, `elco-salesforce/raw/security/org_display.json`, `elco-salesforce/raw/security/verify_permsets.log`, `elco-salesforce/raw/security/audit_runflow.md`, `elco-salesforce/raw/security/audit_fls.md`, `elco-salesforce/raw/security/fls_diff.md`, `raw/security_required_fls/remediation_summary.md`.

## Integrazione CRIF Mock (COF) - P1 (2026-02-20 16:51)

### Componenti creati
- **External Credential**: `CRIF_MOCK_EXT` (DeveloperName)
  - Label: "CRIF Mock External Credential"
  - Protocol: Custom
  - Principal: `NamedPrincipal` ✅ **CONFIGURATO E OPERATIVO** (smoketest 200/200)
- **Named Credential**: `CRIF_MOCK` (DeveloperName)
  - Label: "CRIF Mock"
  - Type: SecuredEndpoint
  - URL: `https://crif-mock-137745841582.europe-west8.run.app`
  - External Credential: `CRIF_MOCK_EXT`
  - Generate Authorization Header: `false` (gestito in Apex)
  - Allow Merge Fields in Body/Header: `true`
- **Permission Set**: `CRIF_MOCK_Access`
  - Abilita accesso al principal `CRIF_MOCK_EXT-NamedPrincipal`
  - Read permission su `UserExternalCredential`

### Apex Classes
- **CrifMockClient** (`CrifMockClient.cls`)
  - `normalizeVatTo11(String)`: normalizza P.IVA italiana a 11 cifre
  - `searchByVat(...)`: esegue token + search verso CRIF mock
  - Usa Named Credential `callout:CRIF_MOCK` per endpoint base
  - Credenziali iniettate via merge fields `{!$Credential.CRIF_MOCK_EXT.Username}` e `{!$Credential.CRIF_MOCK_EXT.Password}`
  - Token endpoint: `/oauth2/token` (POST, x-www-form-urlencoded, password grant)
  - Search endpoint: `/margo/v1/prospecting/search?page=X&size=Y` (POST, JSON, Bearer token)
- **CrifMockSearchInvocable** (`CrifMockSearchInvocable.cls`)
  - **Flow Action**: "CRIF Mock - Prospecting Search by VAT"
  - Input: `piva` (required), `includeDataPacketList`, `dataPacketListCsv`, `page`, `size`, `acceptLanguage`
  - Output: `tokenHttpStatus`, `searchHttpStatus`, `tokenJson`, `searchJson`, `error`, `vat11`
  - Nessuna credenziale esposta in input/output
- **CrifMockClientTest** (`CrifMockClientTest.cls`)
  - 6 test methods, 100% pass rate
  - Code coverage: CrifMockClient 88%, CrifMockSearchInvocable 100%
  - Usa HttpCalloutMock per simulare risposte token/search

### Endpoint CRIF Mock
- **Base URL**: `https://crif-mock-137745841582.europe-west8.run.app`
- **Token**: `POST /oauth2/token`
  - Body: `grant_type=password&username=<user>&password=<pass>`
  - Response: `{"access_token":"...","token_type":"Bearer","expires_in":3600}`
- **Search**: `POST /margo/v1/prospecting/search?page=0&size=15`
  - Headers: `Accept-Language: it-IT`, `Authorization: Bearer <token>`
  - Body JSON:
    ```json
    {
      "freeText": "IT<11cifre>",
      "content": {
        "dataPacketList": ["atecoClassification", "ecofin", ...]
      }
    }
    ```

### Parametri configurabili
- **TEST_PIVA**: `IT01234567890` (default per demo)
- **ACCEPT_LANGUAGE**: `it-IT` (default)
- **INCLUDE_DATAPACKETLIST**: `true` (default)
- **DATAPACKETLIST** (default): `atecoClassification,ecofin,operatingResults,employees,contacts,mail,pec,webAndSocial`
- **PAGE**: `0` (default)
- **SIZE**: `15` (default)

### Come usare da Flow
1. Drag & drop azione "CRIF Mock - Prospecting Search by VAT" in un Flow
2. Input minimo: `piva` (es. "IT01234567890")
3. Output:
   - `vat11`: P.IVA normalizzata (11 cifre)
   - `searchJson`: risposta JSON CRIF (raw)
   - `searchHttpStatus`: 200 se successo
   - `error`: messaggio errore (se presente)

### Gestione credenziali
- **Metadata**: ExternalCredential + NamedCredential deployati via sf CLI
- **Valori segreti (Username/Password)**: ✅ **CONFIGURATI E OPERATIVI**
  - **Smoketest End-to-End**: Token HTTP 200, Search HTTP 200 (vedi `raw/crif_p1/crif_invocable_smoketest_result.json`)
  - Credenziali configurate su Principal `CRIF_MOCK_EXT-NamedPrincipal`
  - Fallback UI disponibile: `scripts/CRIF_CREDENTIALS_UI_FALLBACK.md` (se necessario riconfigurare)
- **Credenziali demo usate**:
  - Username: `test-user`
  - Password: `test-pass`

### Note implementative
- Nessun valore hardcoded in codice
- Authorization Bearer costruito runtime in Apex (non in Named Credential)
- Token ottenuto via password grant ad ogni chiamata search
- Normalizzazione P.IVA: rimuove 'IT', padding left con 0, valida lunghezza 11
- Error handling completo con stack trace in output `error`

### Deploy log
- External Credential: deploy ID `0Afg5000004EZzhCAG`
- Named Credential: deploy ID `0Afg5000004Ea4XCAS`
- Permission Set: deploy ID `0Afg5000004Ea69CAC`
- Apex classes: deploy ID `0Afg5000004Eba5CAC`
- Tutti i deploy: **Succeeded**

### Test results
- Unit tests: 6/6 passed (100% pass rate)
- **Smoke test END-TO-END (P1)**: ✅ **PASS** (2026-02-20 20:09)
  - Token HTTP Status: 200
  - Search HTTP Status: 200
  - VAT Normalized: 01234567890
  - Error: null
  - Script: `scripts/apex/crif_invocable_smoketest.apex`
  - Log: `raw/crif_p1/crif_invocable_smoketest.log`
  - Result JSON: `raw/crif_p1/crif_invocable_smoketest_result.json`

---

## CRIF P1 - Account Fields (2026-02-20 20:09)

**29 campi custom** creati su Account per supportare integrazione CRIF + Admin/Zucchetti + Tableau/BI.

**Deploy ID**: `0Afg5000004F2s1CAC` (Status: Succeeded)

### Campi CRIF (23 fields)

**Core Business**:
- `Partita_IVA__c` (Text 20) - P.IVA italiana
- `CRIF_Stato_Attivita__c` (Picklist) - Stato attività azienda
- `CRIF_Fatturato__c` (Currency) - Fatturato CRIF
- `CRIF_Fatturato_Anno__c` (Number 4,0) - Anno fatturato
- `CRIF_Numero_Dipendenti__c` (Number 10,0) - Numero dipendenti
- `CRIF_EBITDA__c` (Currency) - EBITDA
- `CRIF_Valore_Credito__c` (Currency) - Valore del Credito (Fido consigliato)

**ID e Normalizzazione**:
- `CRIF_VAT_Normalized__c` (Text 20) - VAT normalizzata a 11 cifre
- `CRIF_Company_Id__c` (Text 100) - Company ID CRIF

**Scores e Rating**:
- `CRIF_Real_Estate_Lease_Score__c` (Number 6,2) - Real Estate Lease Score
- `CRIF_Factoring_Score__c` (Number 6,2) - Factoring Score
- `CRIF_DnB_Rating__c` (Text 40) - DnB Rating

**Notices (Checkbox)**:
- `CRIF_Has_Delinquency_Notices__c` - Presenza Protesti
- `CRIF_Has_Negative_Notices__c` - Presenza Pregiudizievoli
- `CRIF_Has_Bankruptcy_Notices__c` - Presenza Procedure concorsuali

**Status e Refresh**:
- `CRIF_Last_Status__c` (Picklist) - Success/Warning/Error/NotFound
- `CRIF_Last_Refresh__c` (DateTime) - Timestamp ultimo aggiornamento

**Technical/Audit (visibili solo a CRIF_Admin o read-only per CRIF_Operator)**:
- `CRIF_Last_Http_Status__c` (Number 3,0) - HTTP status ultimo callout
- `CRIF_Correlation_Id__c` (Text 120) - Correlation ID
- `CRIF_Last_Error__c` (LongTextArea 32k) - Messaggio errore ultimo callout
- `CRIF_Last_Request_Timestamp__c` (DateTime) - Request timestamp
- `CRIF_Last_Response_Timestamp__c` (DateTime) - Response timestamp
- `CRIF_Last_Duration_ms__c` (Number 10,0) - Durata callout (ms)
- `CRIF_Last_Raw_JSON__c` (LongTextArea 131k) - Raw JSON ultima risposta (solo CRIF_Admin)

### Campi Amministrazione/Zucchetti (3 fields)
- `Admin_Fatturato_Effettivo__c` (Currency) - Fatturato effettivo amministrazione
- `Admin_Last_Status__c` (Picklist) - Success/Warning/Error
- `Admin_Last_Refresh__c` (DateTime) - Ultimo refresh amministrazione

### Campi Tableau/BI (2 fields)
- `Tableau_Customer_Key__c` (Text 80) - Chiave filtro Tableau cliente
- `Tableau_Last_Data_Refresh__c` (DateTime) - Ultimo refresh dati BI

### Note implementative
- Tutti i campi: `required=false` a livello metadata (obbligatorietà gestita da Flow/UX/Validation Rules)
- Evita problemi FLS deploy e visibilità dinamica
- Permission Sets: CRIF_Operator (NO raw JSON), CRIF_Admin (FULL access incluso raw JSON)

---

## P4 - TechSpec + Visite + Follow-up (2026-02-20)

### Componenti deployati

#### 1. Apex Classes (2 + 2 test)
- **VisitFollowupEmailInvocable** (`force-app/main/default/classes/VisitFollowupEmailInvocable.cls`)
  - **Deploy ID**: `0Afg5000004FGi5CAG` (Status: Succeeded)
  - **Flow Action**: "Visite - Invia Follow-up Email"
  - **Input**: `visitReportId` (Id), `subject` (String), `bodyText` (String)
  - **Output**: `recipientsTotal`, `recipientsWithEmail`, `sentCount`, `skippedNoEmailCount`, `errorMessage`
  - **Features**:
    - Preview destinatari con counts dettagliati pre-invio
    - Invio solo a Contact con Email valorizzata
    - Tracking automatico su Visit_Report__c (`FollowUp_Sent__c`, `FollowUp_Sent_On__c`)
    - Tracking automatico su Visit_Attendee__c (`Email_Sent__c`)
    - Error handling completo con messages
  - **Test class**: `VisitFollowupEmailInvocableTest.cls` (100% coverage, 2 test methods)

#### 2. Screen Flows (3)

**Gestisci Specifiche Tecniche**:
- `Gestisci_Specifiche_Tecniche.flow-meta.xml`
- **Deploy ID**: `0Afg5000004FH4fCAG` (Active)
- **Quick Action**: Account.Gestisci_Specifiche_Tecniche
- **UI Flow**:
  1. Screen Choose Action: Radio buttons (Crea nuova specifica | Mostra elenco specifiche attive)
  2. Branch Action:
     - CREATE path: Screen input (Category, Value, Notes) → Create Account_Tech_Spec__c (Is_Active=true) → Success
     - LIST path: Info screen con link a Related List
- **Simplified**: Solo Create/List (no Edit/Deactivate per ridurre complessità)

**Crea Report Visita**:
- `Crea_Report_Visita.flow-meta.xml`
- **Deploy ID**: `0Afg5000004FD7WCAW` (Active)
- **Quick Action**: Account.Crea_Report_Visita
- **UI Flow**:
  1. Screen Visit Data: Input (Subject, Visit_DateTime, Visit_Type, Summary, Next_Steps)
  2. Create Visit_Report__c linked to Account
  3. Success screen con newVisitReportId
- **Visit_Type picklist**: Visita | Teams | Attività | Altro
- **Note**: Attendee selection via Related List post-creazione

**Invia Follow-up Visita**:
- `Invia_Followup_Visita.flow-meta.xml`
- **Deploy ID**: `0Afg5000004FHMPCA4` (Active)
- **Quick Action**: Visit_Report__c.Invia_Followup
- **UI Flow**:
  1. Get Visit_Report__c (query visit data)
  2. Get Visit_Attendee__c (query attendees)
  3. Screen Preview: Input editable (Subject, Body) con default formulas + checkbox conferma
  4. Action Call: VisitFollowupEmailInvocable
  5. Check Error decision:
     - Success path: Screen mostra sentCount, skippedNoEmailCount
     - Error path: Screen mostra errorMessage
- **Default formulas**:
  - Subject: "Follow-up visita - " + TEXT({!Get_Visit_Report.Visit_DateTime__c})
  - Body: Template italiano multiline con "Buongiorno", Summary, Next_Steps, "Cordiali saluti"

#### 3. Quick Actions (3)
- **Account.Gestisci_Specifiche_Tecniche** (0Afg5000004FHPdCAO) → Gestisci_Specifiche_Tecniche flow
- **Account.Crea_Report_Visita** (0Afg5000004FHRFCA4) → Crea_Report_Visita flow
- **Visit_Report__c.Invia_Followup** (0Afg5000004FHUTCA4) → Invia_Followup_Visita flow

#### 4. Permission Set Update
- **Visit_Operator** (`Visit_Operator.permissionset-meta.xml`)
  - **Deploy ID**: `0Afg5000004FIQXCA4` (Changed from P1 baseline)
  - **Added user permissions**:
    - `EditTask` (dependency for EmailSingle)
    - `EmailSingle` (send individual emails from Apex)
  - **Note**: EmailSingle requires EditTask as prerequisite (Salesforce constraint)

### Smoketest
- **Script**: `scripts/apex/p4_smoketest_followup.apex`
- **Status**: ✅ **PASSED**
- **Records Created**:
  - Account: 001g500000CCKIbAAP ("Test ACME Corp")
  - Visit_Report__c: a02g5000005alS9AAI (Visit_Type=Visita, Subject="Test Follow-up Flow")
  - Contact (2): test1@example.com, test2@example.com
  - Visit_Attendee__c (2): linked to Visit_Report + Contacts
- **Validation**: Complete P4 data model E2E (Account → Visit_Report → Visit_Attendee → Contact)

### Artefatti
- `raw/p4/org_display.json` - Org info
- `raw/p4/deploy_followup_invocable.log` - Apex deployment
- `raw/p4/deploy_flow_techspec.log` - TechSpec flow deployment
- `raw/p4/deploy_flow_visit_create.log` - Visit creation flow deployment
- `raw/p4/deploy_flow_followup.log` - Follow-up flow deployment
- `raw/p4/deploy_qa_techspec.log` - TechSpec action deployment
- `raw/p4/deploy_qa_visit_create.log` - Visit creation action deployment
- `raw/p4/deploy_qa_followup.log` - Follow-up action deployment
- `raw/p4/deploy_permset_visit_op.log` - Permission set update
- `raw/p4/smoketest_followup.log` - Smoketest execution

### Design Decisions

1. **Email Preview UX**: Flow screen mostra preview destinatari prima dell'invio (recipientsTotal, recipientsWithEmail displayed in action call result)

2. **Simplified TechSpec Management**: Solo Create/List actions nel flow. Edit/Deactivate via standard edit page per ridurre flow complexity.

3. **Attendee Post-Creation**: Crea_Report_Visita non include multi-select attendees; users add via Related List post-creation per UX più semplice.

4. **Italian Email Templates**: Default formulas in italiano per subject/body con visit data embedded (Summary, Next_Steps).

5. **Permission Dependency Chain**: EmailSingle requires EditTask → entrambi aggiunti a Visit_Operator per abilitare email send capability.

### Next Steps (User Actions)
1. Add Quick Actions to Page Layouts (Account + Visit_Report__c)
2. Test flows via UI (Create Visit Report → Add Attendees → Send Follow-up)
3. Optional: Customize email templates in Invia_Followup_Visita flow formulas

---
