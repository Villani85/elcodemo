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

**Status**: Mostly Complete (Manual UI steps required)

#### Layouts Enhanced
| Object | Layout Name | Quick Actions | Field Sections | Deploy Status |
|--------|-------------|---------------|----------------|---------------|
| Account | Account Layout | 5 actions | 5 sections (pre-existing) | ⚠️ Failed (duplicate detection) |
| Opportunity | Opportunity Layout | 1 action | 0 sections | ⚠️ Failed (duplicate detection) |
| Quote | Quote Layout | 1 action | 1 section (pre-existing) | ✅ Deployed |
| QuoteLineItem | Quote Line Item Layout | 0 actions | 1 section (pre-existing) | ✅ Deployed |
| Visit_Report__c | Report Visita Layout | 1 action | 1 section (pre-existing) | ✅ Deployed |

#### Quick Actions Added
**Account** (deployment failed - likely already exist):
- Account.CRIF_Aggiorna_Dati
- Account.CRIF_Storico
- Account.Storico_Offerte
- Account.Gestisci_Specifiche_Tecniche
- Account.Crea_Report_Visita

**Opportunity** (deployment failed - likely already exist):
- Opportunity.Crea_Offerta

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

#### Artifacts
- Deployment logs: `raw/p5/deploy_layouts.log`
- Summary report: `raw/p5/P5_SUMMARY.md`
- Manual UI steps: `raw/p5/ACTIVATION_UI_STEPS.md`
- Scripts: `scripts/select_layouts.py`, `scripts/patch_layout_actions.py`, `scripts/patch_layout_fields.py`

---

## Outstanding Items

1. **Account & Opportunity Quick Actions**: Verify via org UI if actions are present despite deployment failures
2. **Account_360 FlexiPage**: Execute manual setup per `raw/p5/ACTIVATION_UI_STEPS.md`
3. **Duplicate detection investigation**: Determine why Account/Opportunity layouts rejected Quick Actions

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
