# Elco Salesforce Org State

**Org**: elco-dev
**Username**: giuseppe.villani101020.b5bd075bbc5f@agentforce.com
**Instance**: orgfarm-ebbb80388b-dev-ed.develop.my.salesforce.com
**API Version**: 65.0
**Last Updated**: 2026-02-22

---

## Overview

This document tracks the current state of the Elco Salesforce org, including deployed metadata, customizations, and implementation phases.

---

## Deployment History

### CRIF Integration - Complete Implementation (2026-02-22)

**Status**: ✅ Complete and Tested

#### Componenti Deployati
| Component | Type | Deploy ID | Status |
|-----------|------|-----------|--------|
| CRIF_Mock | RemoteSiteSetting | 0Afg5000004Hzj7CAC | ✅ Created |
| CRIFSearchInvocable | ApexClass | 0Afg5000004I2AjCAK | ✅ Deployed (v4 - fix nested objects) |
| CRIFSearchInvocableTest | ApexClass | 0Afg5000004HzWDCA0 | ✅ Created (100% pass rate) |
| CRIF_NEW_da_PIVA | Flow | 0Afg5000004I2AjCAK | ✅ Deployed (v5 - fix address validation) |

#### Implementazione
**Flow**: Nuovo Account da P.IVA (CRIF)
- Screen input P.IVA con normalizzazione automatica (aggiunge IT + padding a 11 cifre)
- Chiamata Apex Invocable per integrazione CRIF API
- OAuth2 token retrieval (password grant flow)
- Search API call con bearer token
- Parsing risposta JSON con gestione oggetti nested
- Creazione Account con mappatura campi:
  - `Name` ← `companyDetails.businessName`
  - `Partita_IVA__c` ← input utente
  - `BillingStreet` ← `registeredOffice.address.streetName`
  - `BillingCity` ← `registeredOffice.address.town`
  - `BillingPostalCode` ← `registeredOffice.address.zipCode`
  - `BillingCountry` ← 'Italy' (hardcoded per validazione Salesforce)
  - `Phone` ← `contacts.phone` (se presente)
  - `Website` ← `contacts.website` (se presente)
- Success/Error screens con dettagli operazione

**API Mock**: https://crif-mock-137745841582.europe-west8.run.app
- Endpoint OAuth2: `/oauth2/token`
- Endpoint Search: `/margo/v1/prospecting/search`
- Credentials: `test-user` / `test-pass` (hardcoded in Apex - TODO: spostare in Custom Settings)

#### Fix Implementati
1. **Struttura API Response** (v2-v4):
   - Fix parsing campi nested: `companyDetails`, `registeredOffice`, `contacts`
   - Gestione varianti nome campi (businessName/name/companyName)
   - Estrazione stringhe da oggetti nested (email.email, address.streetName, etc.)

2. **Validazione Address** (v5):
   - Rimosso `BillingState` (richiedeva BillingCountry)
   - Aggiunto `BillingCountry='Italy'` per validazione Salesforce

#### Test
- P.IVA test: `IT01234567890` o `01234567890`
- Risultato atteso: "ACME S.p.A.", Via Roma 1, 00100 Roma, info@acme.it, acme@pec.it
- Status: ✅ Funzionante

---

### Flow Gestisci Specifiche Tecniche - Fix Category Picklist (2026-02-22)

**Status**: ✅ Fixed

#### Problema
Flow creava Account_Tech_Spec__c con campo `Category__c` (picklist ristretta) usando textbox libero, causando errore:
```
INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST: bad value for restricted picklist field
```

#### Fix Implementato
| Component | Change | Deploy ID |
|-----------|--------|-----------|
| Gestisci_Specifiche_Tecniche | Cambiato Input_Category da InputField (textbox) a DropdownBox con choices | 0Afg5000004I3htCAC |

**Choices Aggiunte**:
- Materiali
- Dimensioni & Tolleranze
- Confezionamento / Imballo
- Etichettatura
- Documentazione
- Qualità & Certificazioni
- Note Commerciali / Preferenze

#### Test
- Status: ✅ Ora l'utente può selezionare solo valori validi dalla picklist

---

### P5 - UX/Account 360 + Layouts + Action Placement (2026-02-20)

**Status**: ✅ Complete (Manual UI steps remain for Account_360 FlexiPage only)

#### Layouts Enhanced
| Object | Layout Name | Quick Actions | Field Sections | Deploy Status |
|--------|-------------|---------------|----------------|---------------|
| Account | Account Layout | 5 actions | 5 sections (pre-existing) | ✅ Deployed (P5 fix: 2026-02-20) |
| Opportunity | Opportunity Layout | 1 action | 0 sections | ✅ Deployed (P5 fix: 2026-02-20) |
| Quote | Quote Layout | 1 action | 1 section (pre-existing) | ✅ Deployed |
| QuoteLineItem | Quote Line Item Layout | 0 actions | 1 section (pre-existing) | ✅ Deployed |
| Visit_Report__c | Report Visita Layout | 1 action | 1 section (pre-existing) | ✅ Deployed |

#### Quick Actions Added
**Account** (✅ deployed - P5 fix 2026-02-20):
- Account.CRIF_Aggiorna_Dati ✅
- Account.CRIF_Storico ✅
- Account.Storico_Offerte ✅
- Account.Gestisci_Specifiche_Tecniche ✅
- Account.Crea_Report_Visita ✅

**Opportunity** (✅ deployed - P5 fix 2026-02-20):
- Opportunity.Crea_Offerta ✅

**Quote** (✅ deployed):
- Quote.Aggiungi_Riga_Offerta

**Visit_Report__c** (✅ deployed):
- Visit_Report__c.Invia_Followup

#### Field Sections (Already Present)
**Account**:
- CRIF (16 fields, 2 columns)
- CRIF - Tecnico (7 fields, 1 column)
- Prerequisiti Offerta (7 fields, 2 columns)
- Amministrazione / Zucchetti (3 fields, 2 columns)
- Tableau (2 fields, 2 columns)

**Quote**:
- Offerta (Quote) (10 fields, 2 columns)

**QuoteLineItem**:
- Riga Offerta (13 fields, 2 columns)

**Visit_Report__c**:
- Follow-up (2 fields, 2 columns)

#### FlexiPage - Account_360
**Status**: ⚠️ Manual Setup Required

- **Metadata file**: `force-app/main/default/flexipages/Account_360.flexipage-meta.xml`
- **Deployment**: Failed (metadata API limitation for tabbed layouts)
- **Fallback**: Manual UI setup documented in `raw/p5/ACTIVATION_UI_STEPS.md`
- **Structure**:
  - Header: Highlights Panel
  - Tab 1: Dati Finanziari & CRIF (Record Detail)
  - Tab 2: Specifiche Tecniche (Related List: Account_Tech_Spec__c)
  - Tab 3: Amministrazione & Zucchetti (Record Detail)
  - Tab 4: Tableau (Rich Text placeholder)
- **Activation Target**: Org Default (Desktop + Phone)

#### P5 Fix - Account/Opportunity Layout Deployment (2026-02-20)
**Issue**: Initial deployment failed with "duplicate PlatformActionListId" errors
**Solution**: Remove platformActionListId + add sortOrder to platformActionListItems

**Fix Strategy**:
1. Retrieve fresh layouts from org (source of truth)
2. Normalize XML:
   - Remove all `<platformActionListId>` elements (internal IDs, not versionable)
   - Merge duplicate `<platformActionList>` with `actionListContext='Record'`
   - Deduplicate platformActionListItems by `actionName|actionType`
3. Patch with required Quick Actions (including `<sortOrder>` field)
4. Deploy ONLY the 2 layouts via `--metadata` flags
5. Verify post-deploy (retrieve + check actionName presence)

**Deployment Result**: ✅ SUCCESS (Deploy ID: 0Afg5000004FRX3CAO)
- Account-Account Layout: Changed ✅
- Opportunity-Opportunity Layout: Changed ✅

**Verification**: All 6 required Quick Actions confirmed present in org layouts ✅

**Fix Artifacts**:
- Scripts: `scripts/normalize_layout_platform_actions.py`, `scripts/patch_required_actions_account_oppty.py`
- Deployment logs: `raw/p5_fix/deploy_two_layouts_v2.log`
- Verification: `raw/p5_fix/verify_actions_present.txt` (all OK)
- Reports: `raw/p5_fix/normalize_report.md`, `raw/p5_fix/action_patch_report.md`

#### Original P5 Artifacts
- Deployment logs: `raw/p5/deploy_layouts.log`
- Summary report: `raw/p5/P5_SUMMARY.md`
- Manual UI steps: `raw/p5/ACTIVATION_UI_STEPS.md`
- Scripts: `scripts/select_layouts.py`, `scripts/patch_layout_actions.py`, `scripts/patch_layout_fields.py`

---

### P6 - Demo Pack (2026-02-20)

**Status**: ✅ Complete

#### Demo Pack Created
**Demo Seed Script**: `scripts/apex/demo_seed.apex`
- Creates complete quote-to-cash demo dataset
- Objects created:
  - 1 Account: "DEMO - Cliente PCB" (with prerequisiti offerta defaults)
  - 2 Contacts: Mario Rossi, Laura Bianchi
  - 1 Opportunity: "DEMO - Offerta PCB Prototipo" (30-day CloseDate)
  - 1 Quote: "DEMO - Preventivo PCB" (linked to Standard Pricebook)
  - 1 Visit_Report__c: Customer visit 7 days ago
  - 2 Visit_Attendee__c: Contact linkage to visit
- Execution: `sf apex run --target-org elco-dev --file scripts/apex/demo_seed.apex`

**Demo Runbook**: `raw/p6/DEMO_RUNBOOK.md`
- Step-by-step UI walkthrough (10-15 minutes)
- Covers all Quick Actions across Account, Opportunity, Quote, Visit Report
- Includes Account_360 FlexiPage navigation (if activated)
- Cleanup instructions

#### Artifacts
- Demo seed log: `raw/p6/demo_seed.log`
- Demo runbook: `raw/p6/DEMO_RUNBOOK.md`
- Documentation update: `raw/p6/P6_DOC_UPDATE.md`

---

### New Account Flow - Creazione Account da P.IVA (Flow-only) (2026-02-20)

**Status**: ⚠️ Partially Complete (2/5 components deployed, 3/5 require manual UI)

#### Flow Created
**Flow Name**: CRIF_NEW_da_PIVA
- **Status**: ✅ Deployed and Active
- **Type**: Screen Flow
- **Purpose**: Create new Account from Partita IVA with CRIF integration
- **File**: `force-app/main/default/flows/CRIF_NEW_da_PIVA.flow-meta.xml`
- **Structure**: Placeholder with single screen for P.IVA input
- **Note**: Ready for full implementation (CRIF callout logic to be added)

#### Global QuickAction Created
**Action Name**: CRIF_New_Account_da_PIVA
- **Status**: ✅ Deployed
- **Type**: Global QuickAction (Flow type)
- **Label**: "Nuovo Account da P.IVA (CRIF)"
- **File**: `force-app/main/default/quickActions/CRIF_New_Account_da_PIVA.quickAction-meta.xml`
- **Flow Reference**: CRIF_NEW_da_PIVA

#### Entry Points Available

**Via Global Publisher Layout** (⚠️ Manual UI required):
- Add CRIF_New_Account_da_PIVA to Global Publisher Layout
- Accessible via global "+" button in Salesforce UI
- **Setup Guide**: `raw/new_account_flow_only/GPL_UI_STEPS.md` (5-10 min)

**Via Custom Tab** (⚠️ Manual UI required):
- Lightning App Page with Flow component → Custom Tab "Nuovo Account (CRIF)"
- **App Page Guide**: `raw/new_account_flow_only/APP_PAGE_UI_STEPS.md` (10-15 min)
- **Tab Guide**: `raw/new_account_flow_only/TAB_UI_STEPS.md` (5-10 min)

**Important Note**: This flow-based entry point does NOT replace the standard "New" button on Account object. It provides an alternative entry point specifically for CRIF-powered Account creation.

#### Deployment Summary
| Component | Status | Deployment Method | Notes |
|-----------|--------|-------------------|-------|
| CRIF_NEW_da_PIVA Flow | ✅ Deployed | Metadata API | Active placeholder |
| CRIF_New_Account_da_PIVA QuickAction | ✅ Deployed | Metadata API | Global action |
| Global Publisher Layout | ⚠️ Manual UI | UI-only | 5-10 min setup |
| New_Account_CRIF FlexiPage | ⚠️ Manual UI | UI-only | 10-15 min setup |
| New_Account_CRIF Tab | ⚠️ Manual UI | UI-only | 5-10 min setup |

**Total Setup Time**: 20-35 minutes (manual UI steps)

#### Artifacts
- Flow metadata: `force-app/main/default/flows/CRIF_NEW_da_PIVA.flow-meta.xml`
- QuickAction metadata: `force-app/main/default/quickActions/CRIF_New_Account_da_PIVA.quickAction-meta.xml`
- FlexiPage metadata (template): `force-app/main/default/flexipages/New_Account_CRIF.flexipage-meta.xml`
- Tab metadata (template): `force-app/main/default/tabs/New_Account_CRIF.tab-meta.xml`
- Publisher Layout UI steps: `raw/new_account_flow_only/GPL_UI_STEPS.md`
- App Page UI steps: `raw/new_account_flow_only/APP_PAGE_UI_STEPS.md`
- Tab UI steps: `raw/new_account_flow_only/TAB_UI_STEPS.md`
- Deployment logs: `raw/new_account_flow_only/deploy_flow.log`, `deploy_quickaction.log`
- Verification summary: `raw/new_account_flow_only/verify_summary.md`

---

## Outstanding Items

### P5 Outstanding
1. **Account_360 FlexiPage**: Execute manual setup per `raw/p5/ACTIVATION_UI_STEPS.md`
   - Status: ⚠️ Manual UI required (metadata API does not support tabbed FlexiPages)
   - This is the ONLY remaining manual step for P5

### P5 Complete
2. **Account & Opportunity Layout Deployment**: ✅ RESOLVED (P5 fix 2026-02-20)
   - Solution: Remove platformActionListId + add sortOrder fields
   - All 6 Quick Actions verified present in org layouts
   - See: `raw/p5_fix/` for fix artifacts

### P6 Status
3. **Demo Pack**: ✅ Created and tested (seed script + runbook in `raw/p6/`)
4. **Documentation**: ✅ Updated (org_state.md, struttura.md)

---

## Custom Objects

### Account_Tech_Spec__c
- Related to Account via `Account__c` lookup field
- Used in Account_360 FlexiPage "Specifiche Tecniche" tab

### Visit_Report__c
- Custom object for visit reports
- Layout includes Follow-up section with FollowUp_Sent__c and FollowUp_Sent_On__c fields
- Quick Action: Invia_Followup (✅ deployed)

---

## Notes

- All custom field sections were already present in org layouts (likely from previous P5 iterations)
- Metadata API v65.0 used for all deployments
- Windows console encoding issues resolved (changed to ASCII output markers)
- XML namespace issues resolved in patch scripts (explicit `{http://soap.sforce.com/2006/04/metadata}` namespacing)
