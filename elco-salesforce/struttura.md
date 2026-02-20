# Elco Salesforce Project Structure

**Project**: elco-salesforce
**Type**: Salesforce DX Project
**Last Updated**: 2026-02-20

---

## Directory Structure

```
elco-salesforce/
├── force-app/
│   └── main/
│       └── default/
│           ├── flexipages/               # Lightning Record Pages
│           │   └── Account_360.flexipage-meta.xml  # Account 360 page (manual setup required)
│           ├── layouts/                  # Page Layouts
│           │   ├── Account-Account Layout.layout-meta.xml
│           │   ├── Opportunity-Opportunity Layout.layout-meta.xml
│           │   ├── Quote-Quote Layout.layout-meta.xml
│           │   ├── QuoteLineItem-Quote Line Item Layout.layout-meta.xml
│           │   └── Visit_Report__c-Report Visita Layout.layout-meta.xml
│           ├── objects/                  # Custom Objects & Fields
│           ├── quickActions/             # Quick Actions (defined separately)
│           └── [other metadata types]
├── scripts/
│   ├── apex/
│   │   └── demo_seed.apex               # P6: Demo dataset creation script
│   ├── select_layouts.py                # P5: Deterministic layout selection
│   ├── patch_layout_actions.py          # P5: Add Quick Actions to layouts
│   ├── patch_layout_fields.py           # P5: Add field sections to layouts
│   ├── normalize_layout_platform_actions.py  # P5 fix: Normalize platformActionList (remove IDs, merge duplicates)
│   └── patch_required_actions_account_oppty.py  # P5 fix: Add Quick Actions to Account/Opportunity with sortOrder
├── raw/
│   ├── p5/                              # P5 Implementation Artifacts
│   │   ├── org_info.txt                 # Org details (API v65.0)
│   │   ├── selected_layouts.txt         # Selected layout mapping
│   │   ├── layout_action_patch_report.md    # Action patching results
│   │   ├── layout_field_patch_report.md     # Field patching results
│   │   ├── deploy_layouts.log           # Deployment output
│   │   ├── postcheck_deployment_status.txt  # Deployment summary
│   │   ├── ACTIVATION_UI_STEPS.md       # Manual FlexiPage setup guide
│   │   └── P5_SUMMARY.md                # Comprehensive P5 report
│   ├── p5_fix/                          # P5 Fix - Account/Opportunity Layout Deployment
│   │   ├── org_display.json             # Org details
│   │   ├── api_version.txt              # API version 65.0
│   │   ├── layout_sha1_before.txt       # Layout checksums before patch
│   │   ├── layout_sha1_after.txt        # Layout checksums after patch
│   │   ├── normalize_console.log        # Normalization console output
│   │   ├── normalize_report.md          # Normalization results
│   │   ├── action_patch_console.log     # Patch console output
│   │   ├── action_patch_report.md       # Patch results
│   │   ├── deploy_two_layouts_v2.log    # Deployment output (SUCCEEDED)
│   │   ├── deploy_errors.txt            # Initial deployment errors
│   │   └── verify_actions_present.txt   # Post-deploy verification (all OK)
│   └── p6/                              # P6 Demo Pack Artifacts
│       ├── demo_seed.log                # Demo seed script execution log
│       ├── DEMO_RUNBOOK.md              # Demo walkthrough guide
│       └── P6_DOC_UPDATE.md             # Documentation update summary
├── org_state.md                         # Org state documentation
├── struttura.md                         # This file - project structure
├── sfdx-project.json                    # SFDX project configuration
└── [other project files]
```

---

## Metadata Types

### FlexiPages (Lightning Record Pages)
**Location**: `force-app/main/default/flexipages/`

| API Name | Label | Object | Status | Notes |
|----------|-------|--------|--------|-------|
| Account_360 | Account 360 | Account | ⚠️ Manual setup required | 4-tab layout (see ACTIVATION_UI_STEPS.md) |

**Account_360 Structure**:
- **Template**: Header and Three Regions
- **Header**: Highlights Panel
- **Main Region**: Tabbed layout
  - Tab 1: "Dati Finanziari & CRIF" → Record Detail
  - Tab 2: "Specifiche Tecniche" → Related List (Account_Tech_Spec__c)
  - Tab 3: "Amministrazione & Zucchetti" → Record Detail
  - Tab 4: "Tableau" → Rich Text (placeholder)
- **Activation**: Org Default (Desktop + Phone)

### Layouts
**Location**: `force-app/main/default/layouts/`

#### Enhanced Layouts (P5)
| Object | Layout Name | Quick Actions | Custom Sections | Status |
|--------|-------------|---------------|-----------------|--------|
| Account | Account Layout | 5 | 5 (pre-existing) | ⚠️ Deploy failed |
| Opportunity | Opportunity Layout | 1 | 0 | ⚠️ Deploy failed |
| Quote | Quote Layout | 1 | 1 (pre-existing) | ✅ Deployed |
| QuoteLineItem | Quote Line Item Layout | 0 | 1 (pre-existing) | ✅ Deployed |
| Visit_Report__c | Report Visita Layout | 1 | 1 (pre-existing) | ✅ Deployed |

**Custom Field Sections**:
- **Account**: CRIF, CRIF - Tecnico, Prerequisiti Offerta, Amministrazione / Zucchetti, Tableau
- **Quote**: Offerta (Quote)
- **QuoteLineItem**: Riga Offerta
- **Visit_Report__c**: Follow-up

### Quick Actions
**Added to Layouts** (platformActionList with actionListContext='Record'):

#### Account Layout Actions
1. Account.CRIF_Aggiorna_Dati
2. Account.CRIF_Storico
3. Account.Storico_Offerte
4. Account.Gestisci_Specifiche_Tecniche
5. Account.Crea_Report_Visita

#### Opportunity Layout Actions
1. Opportunity.Crea_Offerta

#### Quote Layout Actions
1. Quote.Aggiungi_Riga_Offerta ✅

#### Visit_Report__c Layout Actions
1. Visit_Report__c.Invia_Followup ✅

---

## Scripts

### P5 Implementation Scripts
**Location**: `scripts/`

#### select_layouts.py
- **Purpose**: Deterministic layout selection for 5 objects
- **Input**: Org metadata (via `sf project retrieve`)
- **Output**: `raw/p5/selected_layouts.txt`
- **Logic**:
  - Prefers specific layout names (e.g., "Account-Account Layout")
  - Filters out PersonAccount layouts for Account object
  - Falls back to first available layout if preferred not found

#### patch_layout_actions.py
- **Purpose**: Add Quick Actions to layout platformActionList
- **Input**: `raw/p5/selected_layouts.txt`, layout files
- **Output**: Modified layout files, `raw/p5/layout_action_patch_report.md`
- **Key Features**:
  - Finds/creates platformActionList with `actionListContext='Record'`
  - Skips duplicate actions
  - Maintains proper XML namespace
  - Inserts before quickActionList element

#### patch_layout_fields.py
- **Purpose**: Add custom field sections to layouts
- **Input**: `raw/p5/selected_layouts.txt`, layout files
- **Output**: Modified layout files, `raw/p5/layout_field_patch_report.md`
- **Key Features**:
  - Creates layoutSections with proper structure
  - Distributes fields across columns (1 or 2 column layouts)
  - Skips existing fields
  - Inserts before relatedLists element
  - Uses explicit XML namespace: `{http://soap.sforce.com/2006/04/metadata}`

### P5 Fix Implementation Scripts
**Location**: `scripts/`

#### normalize_layout_platform_actions.py
- **Purpose**: Normalize platformActionList elements to eliminate duplicate IDs for Account/Opportunity layouts
- **Input**: Layout files from `force-app/main/default/layouts/`
- **Output**: Modified layout files, `raw/p5_fix/normalize_report.md`
- **Key Features**:
  - Removes all `<platformActionListId>` elements (internal Salesforce tracking IDs)
  - Merges duplicate `<platformActionList>` blocks with `actionListContext='Record'`
  - Deduplicates platformActionListItems by `actionName|actionType` key
  - Prepares layouts for clean deployment

#### patch_required_actions_account_oppty.py
- **Purpose**: Add required Quick Actions to Account and Opportunity layouts with proper sortOrder
- **Input**: Layout files (post-normalization)
- **Output**: Modified layout files, `raw/p5_fix/action_patch_report.md`
- **Actions Added**:
  - Account (5): CRIF_Aggiorna_Dati, CRIF_Storico, Storico_Offerte, Gestisci_Specifiche_Tecniche, Crea_Report_Visita
  - Opportunity (1): Crea_Offerta
- **Key Features**:
  - Finds/creates single platformActionList with `actionListContext='Record'`
  - Adds `<sortOrder>` element to each platformActionListItem (REQUIRED for deployment)
  - Skips duplicate actions based on `actionName|actionType` key
  - Automatically increments sortOrder from max existing value

### P6 Implementation Scripts
**Location**: `scripts/apex/`

#### apex/demo_seed.apex
- **Purpose**: Create comprehensive demo dataset for quote-to-cash flow
- **Objects Created**:
  - 1 Account (with prerequisiti offerta defaults)
  - 2 Contacts (one with email, one without)
  - 1 Opportunity (30-day CloseDate)
  - 1 Quote (linked to Standard Pricebook)
  - 1 Visit_Report__c (7 days ago)
  - 2 Visit_Attendee__c (linking contacts to visit)
- **Execution**: `sf apex run --target-org elco-dev --file scripts/apex/demo_seed.apex`
- **Error Handling**: Try/catch for optional fields (Partita_IVA__c) and conditional QuoteLineItem creation

---

## Custom Objects

### Account_Tech_Spec__c
- **Purpose**: Account technical specifications
- **Relationship**: Lookup to Account (Account__c field)
- **Usage**: Related list in Account_360 "Specifiche Tecniche" tab

### Visit_Report__c
- **Purpose**: Customer visit reports
- **Custom Fields**:
  - FollowUp_Sent__c (Checkbox)
  - FollowUp_Sent_On__c (Date/Time)
- **Layout Sections**: Follow-up
- **Quick Actions**: Invia_Followup

---

## Implementation Phases

### P5 - UX/Account 360 + Layouts + Action Placement
**Date**: 2026-02-20
**Status**: ✅ Complete (except Account_360 FlexiPage manual activation)

**Completed**:
- ✅ Layout selection (5 layouts)
- ✅ Quick Action patching scripts
- ✅ Field section patching script
- ✅ **All 5 layouts deployed successfully** (3/5 initially, then 2/2 via P5 fix)
- ✅ FlexiPage metadata creation
- ✅ Manual UI documentation

**P5 Fix - Account/Opportunity Layout Deployment** (2026-02-20):
- ✅ Fresh layout retrieval from org
- ✅ Normalization script (`normalize_layout_platform_actions.py`)
- ✅ Patch script with sortOrder support (`patch_required_actions_account_oppty.py`)
- ✅ Deployment SUCCESS (Deploy ID: 0Afg5000004FRX3CAO)
- ✅ Post-deploy verification: All 6 Quick Actions confirmed present in org layouts

**Remaining Manual Step**:
- ⚠️ Account_360 FlexiPage manual activation via Lightning App Builder

**Artifacts**: See `raw/p5/` and `raw/p5_fix/` directories

---

### P6 - Demo Pack
**Date**: 2026-02-20
**Status**: ✅ Complete

**Completed**:
- ✅ Demo seed script creation (`scripts/apex/demo_seed.apex`)
- ✅ Demo runbook creation (`raw/p6/DEMO_RUNBOOK.md`)
- ✅ Documentation updates (org_state.md, struttura.md)

**Artifacts**: See `raw/p6/` directory

---

## Technical Notes

### API Version
- **Current**: 65.0
- **Set in**: `sfdx-project.json`
- **Used by**: All metadata operations

### XML Namespace
All Salesforce metadata uses namespace: `http://soap.sforce.com/2006/04/metadata`

**Example**:
```xml
<Layout xmlns="http://soap.sforce.com/2006/04/metadata">
    <layoutSections>
        <customLabel>true</customLabel>
        <label>CRIF</label>
        <layoutColumns>
            <layoutItems>
                <behavior>Edit</behavior>
                <field>Partita_IVA__c</field>
            </layoutItems>
        </layoutColumns>
    </layoutSections>
</Layout>
```

### platformActionList Structure
**Lightning Experience Actions** use `actionListContext='Record'`:
```xml
<platformActionList>
    <actionListContext>Record</actionListContext>
    <platformActionListItems>
        <actionName>Account.CRIF_Aggiorna_Dati</actionName>
        <actionType>QuickAction</actionType>
        <sortOrder>27</sortOrder>
    </platformActionListItems>
</platformActionList>
```

### Known Issues

1. **FlexiPage Deployment**: Metadata API does not support deploying tabbed FlexiPages in this org configuration
   - **Workaround**: Manual setup via Lightning App Builder (documented in ACTIVATION_UI_STEPS.md)

2. **Duplicate PlatformActionListId**: Account and Opportunity layouts rejected with duplicate detection errors
   - **Error IDs**: 0Jog50000040ZoiCAE (Account), 0Jog50000040Zp2CAE (Opportunity)
   - **Likely Cause**: Actions already exist from prior deployment attempts
   - **Resolution**: Verify via org UI, manual addition if needed

3. **Windows Console Encoding**: Python scripts use ASCII markers ([OK]/[ERROR]) to avoid Unicode errors

---

## Future Enhancements

- Automate FlexiPage activation (pending Salesforce API support)
- Add pre-deployment validation for duplicate PlatformActionListId
- Implement rollback mechanism for failed deployments
- Add integration tests for layout patches

---

**Last Updated**: 2026-02-20 (P5 Implementation)
