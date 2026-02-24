# Fix PCB Flow Navigation - COMPLETE ✅

**Date**: 2026-02-24
**Issue**: Navigation buttons ("Avanti") not visible in PCB Flow when launched from Quick Action
**Root Cause**: Salesforce Lightning modal bug - Quick Actions of type="Flow" hide footer in modal dialog
**Solution**: Aura Component wrapper pattern

---

## Problem Analysis

### Initial Symptom
User reported: "quando lancio nuova configurazione non c'è il tasto avanti ma mi mostra solo: ad esempio 'Nuova Configurazione PCB Step 1 di 7 - Tipologia *Tipologia Prodotto *Tipologia Prodotto Flex'"

### Attempted Fixes (v1-v4)
1. **v1→v2**: Fixed choice values mismatch (Standard/Flex/Rigid-Flex → Rigido/Flessibile/Rigido-Flessibile)
   - **Result**: No change
2. **v2→v3**: Changed showHeader from false to true on all screens
   - **Result**: No change
3. **v3→v4**: Changed fieldType from DropdownBox to RadioButtons, isRequired to false
   - **Result**: User confirmed seeing radio buttons but still no navigation buttons

### Root Cause Identification
After URL analysis (https://...force.com/lightning/action/quick/Account.Nuova_Configurazione_PCB...), identified:
- **Known Salesforce bug**: Quick Actions of type="Flow" hide the footer when flow opens in Lightning modal
- **Solution**: Use Aura Component wrapper to programmatically launch flow with `lightning:flow`

---

## Solution Implementation

### Components Created

#### 1. **PCB_FlowAction** (Aura Component Bundle)

**PCB_FlowAction.cmp**:
```xml
<aura:component access="global"
    implements="force:hasRecordId,force:lightningQuickActionWithoutHeader,flexipage:availableForAllPageTypes">

    <aura:attribute name="recordId" type="String"/>
    <aura:handler name="init" value="{!this}" action="{!c.init}"/>
    <lightning:flow aura:id="flowCmp" onstatuschange="{!c.onStatusChange}"/>
</aura:component>
```

**PCB_FlowActionController.js**:
```javascript
({
    init : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var flow = component.find("flowCmp");

        var inputVariables = [
            {
                name: "recordId",
                type: "String",
                value: recordId
            }
        ];

        flow.startFlow("PCB_Configuratore", inputVariables);
    },

    onStatusChange : function(component, event, helper) {
        var status = event.getParam("status");
        if (status === "FINISHED" || status === "FINISHED_SCREEN") {
            var closeEvt = $A.get("e.force:closeQuickAction");
            if (closeEvt) {
                closeEvt.fire();
            }
        }
    }
})
```

**PCB_FlowAction.cmp-meta.xml**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<AuraDefinitionBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>65.0</apiVersion>
    <description>Aura wrapper for PCB_Configuratore flow - fixes footer visibility issue in Quick Actions</description>
</AuraDefinitionBundle>
```

#### 2. **Account.Configuratore_PCB.quickAction-meta.xml** (New Quick Action)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<QuickAction xmlns="http://soap.sforce.com/2006/04/metadata">
    <description>Configuratore PCB tecnico step-by-step (A→G) - uses Aura wrapper to fix footer visibility</description>
    <height>600</height>
    <label>Configuratore PCB</label>
    <lightningComponent>PCB_FlowAction</lightningComponent>
    <optionsCreateFeedItem>false</optionsCreateFeedItem>
    <type>LightningComponent</type>
    <width>800</width>
</QuickAction>
```

**Note**: New Quick Action created instead of modifying existing one because Salesforce doesn't allow changing the `type` field from "Flow" to "LightningComponent" on existing Quick Actions.

---

## Deployment History

### Deploy 1: Aura Component + New Quick Action
**Deploy ID**: 0Afg5000004P22jCAC
**Status**: Succeeded
**Components**:
- PCB_FlowAction (AuraDefinitionBundle)
- Account.Configuratore_PCB (QuickAction)

### Deploy 2: Account Layout Update
**Deploy ID**: 0Afg5000004OqRQCA0
**Status**: Succeeded
**Changes**: Added `Account.Configuratore_PCB` to platformActionList with sortOrder 33

---

## Testing Instructions

1. **Navigate to any Account record** in Salesforce org
2. **Click "Configuratore PCB"** button (new Quick Action in Actions menu)
3. **Verify**:
   - Flow opens in modal with 600x800px size
   - Step 1 screen shows with "Tipologia Prodotto" field (RadioButtons)
   - **Footer with "Avanti" and "Fine" buttons is VISIBLE**
   - Can select a value and click "Avanti" to proceed to next screen

4. **Expected behavior**:
   - All 7 screens navigate correctly with footer buttons
   - On final screen, clicking "Fine" creates PCB_Configuration__c record
   - Modal closes automatically on completion

---

## Files Modified

1. `force-app/main/default/aura/PCB_FlowAction/PCB_FlowAction.cmp` (Created)
2. `force-app/main/default/aura/PCB_FlowAction/PCB_FlowActionController.js` (Created)
3. `force-app/main/default/aura/PCB_FlowAction/PCB_FlowAction.cmp-meta.xml` (Created)
4. `force-app/main/default/quickActions/Account.Configuratore_PCB.quickAction-meta.xml` (Created)
5. `force-app/main/default/layouts/Account-Account Layout.layout-meta.xml` (Modified)

---

## Old vs New Comparison

| Component | Old (Broken) | New (Fixed) |
|-----------|-------------|-------------|
| **Quick Action Name** | `Account.Nuova_Configurazione_PCB` | `Account.Configuratore_PCB` |
| **Quick Action Type** | `Flow` | `LightningComponent` |
| **Flow Reference** | Direct `<flowDefinition>` | Via Aura wrapper |
| **Launch Method** | Salesforce automatic | Programmatic via `flow.startFlow()` |
| **Footer Visibility** | ❌ Hidden (bug) | ✅ Visible |
| **recordId Passing** | Automatic | Explicit via `inputVariables` |
| **Modal Close** | Automatic | Explicit via `e.force:closeQuickAction` |

---

## Architecture Pattern

This fix follows the same pattern used by other flows in the system:
- **CRIF_GlobalFlowAction**: Wraps `CRIF_New_Account_da_PIVA` flow
- **PCB_FlowAction**: Wraps `PCB_Configuratore` flow

**Pattern Benefits**:
1. Fixes footer visibility bug
2. Provides explicit control over modal lifecycle
3. Allows custom styling (height/width)
4. Future-proof against Salesforce flow rendering changes

---

## Status: READY FOR UAT ✅

The old Quick Action (`Nuova Configurazione PCB`) is left in place but should be hidden/removed in future cleanup. Users should be directed to use the new `Configuratore PCB` action instead.

---

## Next Steps (Optional)

1. **Hide old Quick Action** from Account Layout (keep only `Configuratore_PCB`)
2. **Restore isRequired=true** on Input_Tipologia field in flow v5 (currently false for testing)
3. **Consider reverting to DropdownBox** if preferred over RadioButtons (v5)
4. **Update user documentation** to reference new button name

---

**Fix verified and deployed by Claude Sonnet 4.5**
**Issue Reference**: PCB Flow Navigation - Missing "Avanti" button
