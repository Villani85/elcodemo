# Org State - ELCO (P0 setup)

Data esecuzione: 2026-02-20 15:54:58 +01:00  
Org alias: `elco-dev`  
Org username: `giuseppe.villani101020.b5bd075bbc5f@agentforce.com`

## P0 status
- [DONE] Quotes abilitato (`QuoteSettings.enableQuote=true`).
- [DONE] `Quote` e `QuoteLineItem` presenti negli sObject standard.
- [DONE] Standard Price Book attivo.
- [DONE] Prodotto `PCB Custom` attivo (`ProductCode=PCB_CUSTOM`).
- [DONE] PricebookEntry attiva su Standard Price Book (`UnitPrice=0`, `UseStandardPrice=false`).
- [DONE] Data model P0 deployato: `Account_Tech_Spec__c`, `Visit_Report__c`, `Visit_Attendee__c` + campi su `Account`/`Quote`/`QuoteLineItem`.
- [DONE] Dependent picklists P0:
  - `Account_Tech_Spec__c.Category__c -> Parameter__c`
  - `QuoteLineItem.Tipologia_Prodotto__c -> Materiale__c`
  - `QuoteLineItem.Materiale__c -> Spessore_Complessivo__c`

## P1 Security baseline (2026-02-20) - ✅ COMPLETED
- [DONE] Permission set Quote/Visit/TechSpec.
- [DONE] RunFlow permission (`Elco_Run_Flows`).
- [DONE] FLS coverage 100% su campi deployabili (verificato via audit + test reali).
- [DONE] Required fields FLS - verificato che NON impattano operatori (audit deterministic).
- `Quote_Operator`: accesso operativo a `Quote`/`QuoteLineItem` + oggetti correlati (`Opportunity`, `Account`, `Contact`, `Product2`, `Pricebook2`, `PricebookEntry`) e FLS campi custom offerta/prerequisiti account (30/30 fields, 100%).
- `Visit_Operator`: CRUD su `Visit_Report__c` e `Visit_Attendee__c`, Read/Edit `Account`, Read `Contact`, FLS campi custom visita deployabili (5/5 fields, 100%).
- `TechSpec_Operator`: CRUD su `Account_Tech_Spec__c`, Read/Edit `Account`, FLS campi custom tech spec deployabili (4/4 fields, 100%).
- `Setup_Admin_Elco`: helper setup/admin operativo minimo (`ViewSetup`, `ViewRoles`, `CustomizeApplication` + dipendenze piattaforma).
- `Elco_Run_Flows`: RunFlow permission per esecuzione Flows.
- Permset assegnati all'utente corrente: `giuseppe.villani101020.b5bd075bbc5f@agentforce.com`.
- Log/evidenze sicurezza:
  - `elco-salesforce/raw/security/deploy_permsets.log`
  - `elco-salesforce/raw/security/assign_permsets.log`
  - `elco-salesforce/raw/security/org_display.json`
  - `elco-salesforce/raw/security/verify_permsets.log`
  - `raw/security_required_fls/remediation_summary.md` (verifica required fields)

## Data dictionary P0 (summary)
### Custom objects
- `Account_Tech_Spec__c` (Specifica Tecnica, AutoNumber `TS-{000000}`)
  - `Account__c` Lookup(Account) required
  - `Category__c` Picklist: Materiali; Dimensioni & Tolleranze; Confezionamento / Imballo; Etichettatura; Documentazione; Qualità & Certificazioni; Note Commerciali / Preferenze
  - `Parameter__c` Picklist dependent da `Category__c`
  - `Value__c` Text(255) required
  - `UoM__c` Picklist: mm, cm, m, g, kg, pz, %, °C, n/a
  - `Source__c` Picklist: Excel, Manuale, Import, Altro
  - `Notes__c` LongTextArea(32768)
  - `Is_Active__c` Checkbox default true
- `Visit_Report__c` (Report Visita, AutoNumber `VR-{000000}`)
  - `Account__c` Lookup(Account) required
  - `Subject__c` Text(120) required
  - `Visit_DateTime__c` DateTime required
  - `Visit_Type__c` Picklist: Visita, Teams, Attività, Altro
  - `Summary__c`, `Next_Steps__c` LongTextArea(32768)
  - `FollowUp_Sent__c` Checkbox default false
  - `FollowUp_Sent_On__c` DateTime
- `Visit_Attendee__c` (Partecipante Visita, AutoNumber `VA-{000000}`)
  - `Visit_Report__c` MasterDetail(Visit_Report__c)
  - `Contact__c` Lookup(Contact) required
  - `Email_Sent__c` Checkbox default false

### Standard objects (custom fields)
- `Account`: `Tolleranze_Default__c`, `Solder_Default__c`, `Silkscreen_Default__c`, `Finish_Default__c`, `Spessore_Default__c`, `Prerequisiti_Note__c`, `ERP_Customer_Code__c`
- `Quote`: `Inside_Sales__c`, `Num_Circuiti__c`, `Giorni_Consegna__c`, `Servizio__c`, `Servizio_90_10__c`, `Note_Special_Needs__c`, `Trasporto__c`, `Anagrafica_Contatto__c`, `Purchase_Order__c`, `Customer_Code_Snapshot__c`
- `QuoteLineItem`: `Tipologia_Prodotto__c`, `Materiale__c`, `Materiale_Custom_Value__c`, `Spessore_Complessivo__c`, `Spessore_Custom_Value__c`, `Spessore_Rame_Esterni__c`, `Rame_Custom_Value__c`, `Finish__c`, `Solder_Specifico__c`, `Silkscreen_Specifico__c`, `Dimensioni_Array__c`, `Internal_Circuit_Code__c`, `Customer_Circuit_Code__c`

## Security Audit - Run Flows & FLS (2026-02-20 17:15)

### Audit 1: Run Flows Permission
**Problema identificato**: Nessun permission set aveva `PermissionsRunFlow=true`.

**Pre-fix status**:
- Quote_Operator: `PermissionsRunFlow=false`
- Visit_Operator: `PermissionsRunFlow=false`
- TechSpec_Operator: `PermissionsRunFlow=false`
- Setup_Admin_Elco: `PermissionsRunFlow=false`
- CRIF_MOCK_Access: `PermissionsRunFlow=false`

**Soluzione applicata**:
- Creato Permission Set dedicato: **`Elco_Run_Flows`**
  - Deploy ID: `0Afg5000004EXpqCAG`
  - User permission: `RunFlow=true`
  - Comando deploy: `sf project deploy start --metadata "PermissionSet:Elco_Run_Flows" --target-org elco-dev`
  - Comando assign: `sf org assign permset --name Elco_Run_Flows --target-org elco-dev`
  - Assegnato a: `giuseppe.villani101020.b5bd075bbc5f@agentforce.com`

**Post-fix verification**: ✅ `PermissionsRunFlow=true` confermato tramite query `PermissionSetAssignment`.

---

### Audit 2: Field-Level Security (FLS)
**Obiettivo**: Verificare che tutti i campi custom expected siano coperti da FLS nei permission sets.

**Expected vs Current**:
| Permission Set | Expected Fields | Current (pre-audit) | Current (post-patch) | Coverage |
|----------------|-----------------|---------------------|----------------------|----------|
| Quote_Operator | 30 | 30 | 30 | **100%** ✅ |
| Visit_Operator | 11 | 5 | 5 | **45%** ⚠️ |
| TechSpec_Operator | 8 | 4 | 4 | **50%** ⚠️ |

**Missing Fields (pre-patch)**:
- **Visit_Operator**: 6 missing (Contact__c, Visit_Report__c, Account__c, Subject__c, Visit_DateTime__c, Visit_Type__c)
- **TechSpec_Operator**: 4 missing (Account__c, Category__c, Parameter__c, Value__c)

**Soluzione applicata**:
1. Script `patch_permsets_fls.py`: aggiunto fieldPermissions mancanti ai permset
2. Deploy tentato: `sf project deploy start --source-dir force-app/main/default/permissionsets`
   - Deploy ID iniziale: `0Afg5000004EeMfCAK` (Failed - required fields blocking)
3. **Required fields identified as blockers**:
   - TechSpec_Operator: Account__c, Category__c, Parameter__c, Value__c (4 campi)
   - Visit_Operator: Contact__c, Visit_Report__c, Account__c, Subject__c, Visit_DateTime__c, Visit_Type__c (6 campi)
4. Script `remove_blocking_fls.py`: rimossi campi required dai permset
5. Deploy finale: `0Afg5000004EdAUCA0` ✅ **Succeeded**

**Post-patch status**:
- **Quote_Operator**: 30/30 fields (100%) ✅
- **Visit_Operator**: 5/11 fields (45%) ⚠️ - 6 campi required non deployabili via Permission Set
- **TechSpec_Operator**: 4/8 fields (50%) ⚠️ - 4 campi required non deployabili via Permission Set

**Blockers identificati (10 campi required)**:
- Salesforce **NON permette** FLS su campi `required=true` tramite Permission Sets
- FLS per campi required deve essere gestita tramite **Profile** (non Permission Set)
- Lista completa: `raw/security/fls_blocking_fields.json`

**Remediation Plan**: `raw/security/remediation_plan.md`
- **Opzione A (CONSIGLIATA)**: Creare Custom Profile con FLS su tutti i campi (inclusi required)
- Opzione B (non consigliata): Convertire required=false + Validation Rules

**File di riferimento**:
- Audit RunFlow: `raw/security/audit_runflow.md`
- Audit FLS: `raw/security/audit_fls.md`
- FLS Diff: `raw/security/fls_diff.md`, `raw/security/fls_diff.json`
- Expected fields: `raw/security/expected_fields.json`
- Current FLS: `raw/security/current_fls_in_org.json`
- Blocking fields: `raw/security/fls_blocking_fields.json`
- Remediation plan: `raw/security/remediation_plan.md`
- Deploy logs:
  - `raw/security/deploy_runflow_permset.log`
  - `raw/security/deploy_permsets_fls_patch.log`
  - `raw/security/patch_fls_output.log`

---

### Audit 3: Required Fields FLS - Verifica Reale (2026-02-20 17:45)

**Obiettivo**: Verificare se la mancanza di FieldPermissions su campi required blocca davvero gli operatori o è solo un limite di deploy.

**Metodo di test**:
- Creato test user con profilo Standard User + Permission Sets (Visit_Operator, TechSpec_Operator, Elco_Run_Flows)
- Test Apex con `Security.stripInaccessible(AccessType.CREATABLE, ...)` + DML sotto `System.runAs(testUser)`
- Test su 3 oggetti custom con 10 campi required totali

**Risultati test**:
| Oggetto | Campi Required Testati | Insert Success | Campi Rimossi da stripInaccessible | Esito |
|---------|------------------------|----------------|-------------------------------------|-------|
| Visit_Report__c | Account__c, Subject__c, Visit_DateTime__c, Visit_Type__c (4) | ✅ SÌ | NESSUNO | **PASS** |
| Visit_Attendee__c | Visit_Report__c, Contact__c (2) | ✅ SÌ | NESSUNO | **PASS** |
| Account_Tech_Spec__c | Account__c, Category__c, Parameter__c, Value__c (4) | ✅ SÌ | NESSUNO | **PASS** |

**Test eseguiti**: 3/3 passed (100% success rate)
**Campi required bloccati da FLS**: 0/10

**CONCLUSIONE FINALE**: ✅ **NO IMPACT**
- L'assenza di FieldPermissions su campi required è un **limite di Metadata API**, NON un problema di runtime security
- Gli operatori con Permission Sets appropriati **POSSONO** creare/modificare record con campi required
- **NESSUNA REMEDIATION NECESSARIA**

**Soluzione applicata**:
1. Aggiornato `scripts/expected_fields.py` per escludere campi required dall'audit FLS (`exclude_required=True`)
2. Rigenerato FLS diff → **100% coverage** su tutti i permission sets (per campi deployabili)

**FLS Coverage finale (campi deployabili)**:
| Permission Set | Expected | Deployed | Coverage |
|----------------|----------|----------|----------|
| Quote_Operator | 30 | 30 | **100%** ✅ |
| Visit_Operator | 5 | 5 | **100%** ✅ |
| TechSpec_Operator | 4 | 4 | **100%** ✅ |

**Test user creato**:
- Username: elco.operator.test.20260220163243@example.com
- User ID: 005g50000042WHdAAM
- Profile: Standard User

**Test class deployata**:
- Class: `RequiredFlsSecurityTest.cls`
- Deploy ID: 0Afg5000004EgzZCAS
- Test methods: 3 (testVisitReportRequiredFields, testVisitAttendeeRequiredFields, testAccountTechSpecRequiredFields)

**File di riferimento**:
- Remediation summary: `raw/security_required_fls/remediation_summary.md`
- Test report: `raw/security_required_fls/required_fls_report.json`
- Test execution log: `raw/security_required_fls/required_fls_security_test.log`
- Test results: `raw/security_required_fls/test_results_full.json`
- Expected fields (updated): `raw/security/expected_fields.json`
- FLS diff (clean): `raw/security/fls_diff.md`

**Status**: ✅ **CHIUSO - NESSUNA AZIONE RICHIESTA**

---

## CRIF Mock Integration (2026-02-20 16:51)

### Componenti deployati
- **External Credential**: `CRIF_MOCK_EXT`
  - Deploy ID: `0Afg5000004EZzhCAG`
  - Comando: `sf project deploy start --source-dir force-app/main/default/externalCredentials --target-org elco-dev`
  - Path: `elco-salesforce/force-app/main/default/externalCredentials/CRIF_MOCK_EXT.externalCredential-meta.xml`
- **Named Credential**: `CRIF_MOCK`
  - Deploy ID: `0Afg5000004Ea4XCAS`
  - Comando: `sf project deploy start --source-dir force-app/main/default/namedCredentials --target-org elco-dev`
  - Path: `elco-salesforce/force-app/main/default/namedCredentials/CRIF_MOCK.namedCredential-meta.xml`
  - URL: `https://crif-mock-137745841582.europe-west8.run.app`
- **Permission Set**: `CRIF_MOCK_Access`
  - Deploy ID: `0Afg5000004Ea69CAC`
  - Comando deploy: `sf project deploy start --source-dir force-app/main/default/permissionsets/CRIF_MOCK_Access.permissionset-meta.xml --target-org elco-dev`
  - Comando assign: `sf org assign permset --name CRIF_MOCK_Access --target-org elco-dev`
  - Assegnato a: `giuseppe.villani101020.b5bd075bbc5f@agentforce.com`
- **Apex Classes** (Deploy ID: `0Afg5000004Eba5CAC`):
  - `CrifMockClient.cls` (88% coverage)
  - `CrifMockSearchInvocable.cls` (100% coverage)
  - `CrifMockClientTest.cls` (6 test methods, 100% pass rate)
  - Comando: `sf project deploy start --source-dir force-app/main/default/classes --target-org elco-dev`

### Credenziali (UI fallback obbligatorio)
- **Tentati endpoint API** (tutti falliti):
  1. `POST /services/data/v60.0/named-credentials/credential/` → 404
  2. `GET /services/data/v60.0/named-credentials/external-credentials` → 404
  3. `POST /services/data/v60.0/named-credentials/external-credentials/CRIF_MOCK_EXT/principals` (v60 e v65) → 404
  4. Tooling API `ExternalCredentialParameter` → no write support per valori segreti
- **Documentazione fallback UI**: `scripts/CRIF_CREDENTIALS_UI_FALLBACK.md` (click-by-click manual steps)
- **Credenziali demo**:
  - Username: `test-user`
  - Password: `test-pass`
  - Da configurare via: Setup > Named Credentials > External Credentials > CRIF_MOCK_EXT > Principals > New

### Test execution
- **Unit tests**: 6/6 passed
  - Comando: `sf apex run test --class-names CrifMockClientTest --result-format human --code-coverage --target-org elco-dev`
  - Pass rate: 100%
  - Org wide coverage: 90%
- **Smoke test**: fallito come previsto (credenziali non configurate)
  - Script: `scripts/crif_mock_smoketest.apex`
  - Comando: `sf apex run --file scripts/crif_mock_smoketest.apex --target-org elco-dev`
  - Errore atteso: `"Field CRIF_MOCK_EXT.Username does not exist"`
  - Causa: principals non popolati (richiede UI manual step)

### Flow action disponibile
- **Nome**: "CRIF Mock - Prospecting Search by VAT"
- **Category**: CRIF Integration
- **Input** (solo `piva` required): `piva`, `includeDataPacketList`, `dataPacketListCsv`, `page`, `size`, `acceptLanguage`
- **Output**: `tokenHttpStatus`, `searchHttpStatus`, `tokenJson`, `searchJson`, `error`, `vat11`
- **Usabile da Flow**: sì, 100% invocable action (nessuna UI richiesta)

### CRIF Mock endpoints
- Base URL: `https://crif-mock-137745841582.europe-west8.run.app`
- Token: `POST /oauth2/token` (password grant, x-www-form-urlencoded)
- Search: `POST /margo/v1/prospecting/search?page=0&size=15` (JSON, Bearer token)

## Next best steps (P1)
1. **[ACTION REQUIRED]** Configurare credenziali CRIF via UI (step manuale obbligatorio, vedi `scripts/CRIF_CREDENTIALS_UI_FALLBACK.md`)
2. [PARTIAL] Integrazione CRIF: metadata deployati, credenziali da configurare manualmente.
3. Flows applicativi (`CRIF_*`, `Quote_*`, `Visit_*`, `TechSpec_*`) e wizard logico.
4. [DONE] Permission set/profili progetto baseline (`Quote_Operator`, `Visit_Operator`, `TechSpec_Operator`, `Setup_Admin_Elco`, `CRIF_MOCK_Access`).
5. UX: Account 360 FlexiPage con tab e quick actions richieste.
6. Layout assignment e quick action placement.

## Evidenze raw
- Deploy settings quotes: `elco-salesforce/raw/deploy_settings_quotes.json`
- Deploy P0: `elco-salesforce/raw/deploy_p0.json`
- Check entities: `elco-salesforce/raw/check_entities_custom.json`, `elco-salesforce/raw/check_entities_standard_quotes.json`
- Describe: `elco-salesforce/raw/describe_account.json`, `elco-salesforce/raw/describe_quote.json`, `elco-salesforce/raw/describe_qli.json`
- Price book/product/PBE: `elco-salesforce/raw/standard_pricebook_post.json`, `elco-salesforce/raw/product_pcb_custom_post.json`, `elco-salesforce/raw/pbe_post.json`
- Dependency checks: `elco-salesforce/raw/check_picklist_dependencies.txt`
- Security baseline P1: `elco-salesforce/raw/security/deploy_permsets.log`, `elco-salesforce/raw/security/assign_permsets.log`, `elco-salesforce/raw/security/org_display.json`
- Verify assegnazioni P1: `elco-salesforce/raw/security/verify_permsets.log`
