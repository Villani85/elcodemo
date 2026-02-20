# Audit Org State - ELCO / CRIF readiness

Data audit: 2026-02-20 15:07:40 +01:00  
Org target: `elco-dev` (`00Dg5000005Sp7zEAC`)

## Executive summary
- Audit eseguito in sola lettura (query/list/retrieve), senza deploy o modifiche configurative.
- Org trovata e connessa (Developer Edition), baseline Salesforce standard presente.
- Requisiti core progetto al momento non pronti: mancano Quote/QuoteLineItem, flow applicativi, credenziali integrazione e custom object richiesti.
- Vincolo `Integration_Log__c` rispettato: oggetto non presente.
- **Readiness stimata: 15%** rispetto al perimetro CRIF Margo flow-first + Quote/QLI wizard + Account 360.

## Org info
- Edition/Type: `Developer Edition` (`OrganizationType`) - evidenza `raw/organization_info.json`.
- Instance: `IND168` - evidenza `raw/organization_info.json`.
- Org Id: `00Dg5000005Sp7zEAC` - evidenza `raw/org_display.json`.
- Namespace org: `null` - evidenza `raw/organization_info.json`.
- My Domain: `orgfarm-ebbb80388b-dev-ed` - evidenza `retrieved/settings/MyDomain.settings-meta.xml`.
- Enhanced domains flag: `useEnhancedDomainsInSandbox=true` - evidenza `retrieved/settings/MyDomain.settings-meta.xml`.
- Lightning: runtime Lightning attivo, ma non forzato (`enableUsersAreLightningOnly=false`) - evidenza `retrieved/settings/LightningExperience.settings-meta.xml`.

## Feature & Settings check
- Quotes: **disabilitato** (`enableQuote=false`) - evidenza `retrieved/settings/Quote.settings-meta.xml`.
- Quotes without Opportunity: disabilitato (`enableQuotesWithoutOppEnabled=false`) - evidenza `retrieved/settings/Quote.settings-meta.xml`.
- Opportunity product prompt: disabilitato (`promptToAddProducts=false`) - evidenza `retrieved/settings/Opportunity.settings-meta.xml`.
- Standard Price Book: presente ma **inattivo** (`IsActive=false`) - evidenza `raw/standard_pricebook.json`.
- Email (amministrazione): `enableEnhancedEmailEnabled=true`, `enableHtmlEmail=false` - evidenza `retrieved/settings/EmailAdministration.settings-meta.xml`.
- Email deliverability level: non esplicitamente esposto nei metadata recuperati (controllo parziale con `EmailAdministration.settings`).
- Limiti org: baseline DE coerente (API giornaliere 15000, storage 5/20 MB) - evidenza `raw/org_limits.json`.

## Data model inventory + gap

### Checklist requisiti modello dati
| Requisito | Stato | Gap | Evidenza |
|---|---|---|---|
| Account, Contact, Opportunity | OK | Nessuno | `raw/entity_standard_check.json` |
| Quote, QuoteLineItem | KO | Oggetti non presenti (Quotes disabilitato) | `raw/entity_standard_check.json`, `retrieved/settings/Quote.settings-meta.xml` |
| Pricebook2, Product2 | OK | Nessuno | `raw/entity_standard_check.json` |
| Account_Tech_Spec__c | KO | Oggetto mancante | `raw/entity_custom_check.json` |
| Visit_Report__c | KO | Oggetto mancante | `raw/entity_custom_check.json` |
| Visit_Attendee__c | KO | Oggetto mancante | `raw/entity_custom_check.json` |
| Integration_Log__c assente | OK | Nessuno | `raw/entity_integration_log_check.json` |

### Snapshot campi
- `fields_snapshot` restituisce solo campi di `Account` (58 campi totali).
- Nessun campo su `Quote`, `QuoteLineItem` o sugli oggetti custom richiesti (perche non presenti).
- Presenti 7 campi custom standard-demo su Account (`SLA__c`, `CustomerPriority__c`, ecc.) non legati al progetto.
- Evidenza: `raw/fields_snapshot.json`.

## Integration readiness (CRIF flow-first)
- `NamedCredential`: nessun metadata e nessun record - `raw/md_namedcredential_list.json`, `raw/namedcredential_records.json`.
- `ExternalCredential`: nessun metadata e nessun record - `raw/md_externalcredential_list.json`, `raw/externalcredential_records.json`.
- `AuthProvider`: nessun metadata e nessun record - `raw/md_authprovider_list.json`, `raw/authprovider_records.json`.
- Mapping principal su permission set: non rilevato nel tenant (nessun entity match su credential principal; nessuna ext credential da mappare).
- Esito: **readiness integrazione = KO**.

## UX readiness (Account 360 + Quick Actions)
- FlexiPage totali: 12, tutti Utility Bar; nessuna Account record page dedicata.
- Query tooling Account FlexiPage: 0 record.
- Quick Actions totali: 21, tutte standard/baseline (NewTask, NewContact, SendEmail, ecc.).
- Quick Actions richieste progetto mancanti: `CRIF NEW`, `CRIF Aggiorna`, `Gestisci Specifiche`, `Crea Report Visita`, `Invia Follow-up`.
- Layout Account/Opportunity recuperati: action list standard, nessuna action CRIF/progetto.
- Evidenze: `raw/md_flexipage_list.json`, `raw/flexipage_account_check.json`, `raw/md_quickaction_list.json`, `raw/quickaction_required_check.txt`, `raw/layout_action_inventory.txt`, `retrieved/layouts/*`.

## Automation readiness (Flow)
- Metadata Flow: 0.
- Nessun flow con naming `CRIF*`, `Quote*`, `QLI*`, `Visit*`, `TechSpec*`.
- Retrieve mirato non applicabile (nessun flow trovato).
- Evidenze: `raw/md_flow_list.json`, `raw/flow_naming_check.txt`, `raw/retrieve_relevant_flows.txt`.

## Sicurezza / Permessi minimi
- Profili disponibili: 43 (baseline DE) - `raw/md_profile_list.json`.
- Permission Set disponibili: 3 (nessuno custom progetto) - `raw/md_permissionset_list.json`.
- Permission Set Licenses: 64 (55 Active, 9 Disabled) - `raw/psl.json`.
- Nessuna traccia di permission set dedicati al perimetro CRIF/Quote Wizard.

## Rischi / Blocchi
### P0
- Quotes disabilitato + assenza Quote/QuoteLineItem: impossibile implementare Quote/QLI wizard.
- Assenza External Credential + Named Credential + Auth Provider: integrazione CRIF non avviabile.
- Assenza oggetti `Account_Tech_Spec__c`, `Visit_Report__c`, `Visit_Attendee__c`.
- Nessun Flow applicativo presente.

### P1
- Nessuna Account 360 FlexiPage dedicata (tab/azioni progetto assenti).
- Quick Actions progetto non presenti.
- Standard Price Book inattivo.
- Permission set/profili progetto da definire.

### P2
- Chiarire e fissare email deliverability target per ambiente DEV/UAT.
- Allineare naming conventions e baseline metadata prima della build.

## Next best steps consigliati
1. **P0**: abilitare Quotes e verificare comparsa `Quote`/`QuoteLineItem`; attivare Standard Price Book.
2. **P0**: creare data model minimo (`Account_Tech_Spec__c`, `Visit_Report__c`, `Visit_Attendee__c`) con relazioni/lookup.
3. **P0**: configurare integrazione CRIF con `ExternalCredential` + `NamedCredential` (+ eventuale `AuthProvider`) e mapping permessi.
4. **P1**: implementare Flow-first backbone (`CRIF_*`, `Quote_*`, `Visit_*`, `TechSpec_*`) e testare path end-to-end.
5. **P1**: creare pagina Account 360 (FlexiPage) con tab e quick actions progetto.
6. **P1**: introdurre permission set di progetto e verificare accessi object/field/action.

## Allegati
- Root audit: `.`
- Report: `org_state.md`
- Raw outputs: `raw/`
- Retrieved metadata: `retrieved/`

### Raw files principali
- `raw/org_list.json`
- `raw/org_display.json`
- `raw/organization_info.json`
- `raw/org_limits.json`
- `raw/user_licenses.json`
- `raw/psl.json`
- `raw/md_customobject_list.json`
- `raw/md_flow_list.json`
- `raw/md_quickaction_list.json`
- `raw/md_layout_list.json`
- `raw/md_flexipage_list.json`
- `raw/entity_standard_check.json`
- `raw/entity_custom_check.json`
- `raw/entity_integration_log_check.json`
- `raw/fields_snapshot.json`
- `raw/standard_pricebook.json`
- `raw/md_namedcredential_list.json`
- `raw/md_externalcredential_list.json`
- `raw/md_authprovider_list.json`
- `raw/quickaction_required_check.txt`
- `raw/flow_naming_check.txt`
- `raw/layout_action_inventory.txt`

### Retrieved principali
- `retrieved/settings/Quote.settings-meta.xml`
- `retrieved/settings/Opportunity.settings-meta.xml`
- `retrieved/settings/LightningExperience.settings-meta.xml`
- `retrieved/settings/EmailAdministration.settings-meta.xml`
- `retrieved/settings/MyDomain.settings-meta.xml`
- `retrieved/settings/Security.settings-meta.xml`
- `retrieved/layouts/Account-Account Layout.layout-meta.xml`
- `retrieved/layouts/Opportunity-Opportunity Layout.layout-meta.xml`

## Note metodologiche
- File input di contesto (`struttura.md`, `Elco progetto.md`, `Crif.md`, `Offerta.md`) non trovati nella root iniziale; applicata checklist standard richiesta.
- Comandi eseguiti esclusivamente in modalita read-only (`list/query/retrieve`).
