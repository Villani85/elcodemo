# Elco Salesforce Org State

**Org**: elco-dev
**Username**: giuseppe.villani101020.b5bd075bbc5f@agentforce.com
**Instance**: orgfarm-ebbb80388b-dev-ed.develop.my.salesforce.com
**API Version**: 65.0
**Last Updated**: 2026-02-20

---

## Overview

This document tracks the current state of the Elco Salesforce org, including deployed metadata, customizations, and implementation phases.

---

## Deployment History

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
