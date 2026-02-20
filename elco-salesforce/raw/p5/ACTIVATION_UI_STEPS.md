# Account_360 FlexiPage - Manual Activation Steps

## Issue
The Account_360 FlexiPage with tabbed layout cannot be fully deployed and activated via metadata API due to schema constraints. Manual UI configuration is required.

## Manual Steps to Create and Activate Account_360

### Step 1: Create Lightning Record Page

1. Navigate to **Setup** → **Lightning App Builder**
2. Click **New**
3. Select **Record Page**
4. Click **Next**

### Step 2: Configure Page Properties

1. **Label**: `Account 360`
2. **Object**: `Account`
3. **Layout**: Select **Header and Three Regions**
4. Click **Next**

### Step 3: Add Components to Header Region

1. In the header region, drag and drop:
   - **Highlights Panel** component

### Step 4: Create Tabbed Main Region

1. In the main left region, drag and drop:
   - **Tabs** component

### Step 5: Configure Tab 1 - Dati Finanziari & CRIF

1. Click on the **Tabs** component
2. In the first tab:
   - **Tab Label**: `Dati Finanziari & CRIF`
   - Drag **Record Detail** component into this tab

### Step 6: Configure Tab 2 - Specifiche Tecniche

1. Add a second tab:
   - **Tab Label**: `Specifiche Tecniche`
   - Drag **Related List - Single** component
   - Configure:
     - **Related List**: `Account Tech Spec (Account_Tech_Spec__c)`

### Step 7: Configure Tab 3 - Amministrazione & Zucchetti

1. Add a third tab:
   - **Tab Label**: `Amministrazione & Zucchetti`
   - Drag **Record Detail** component

### Step 8: Configure Tab 4 - Tableau

1. Add a fourth tab:
   - **Tab Label**: `Tableau`
   - Drag **Rich Text** component
   - Content:
     ```
     <b>Tableau Integration</b>
     <p>Integrare Tableau App/Link qui.</p>
     ```

### Step 9: Save the Page

1. Click **Save**

### Step 10: Activate as Org Default

1. Click **Activation**
2. Select **Org Default**
3. Click **Assign as Org Default**
4. Desktop: **✓** (check)
5. Phone: **✓** (check)
6. Click **Next**
7. Review and click **Save**

## Verification

1. Navigate to any Account record
2. Verify the page displays with tabs:
   - Dati Finanziari & CRIF (with record details + CRIF fields from layout)
   - Specifiche Tecniche (with Account_Tech_Spec__c related list)
   - Amministrazione & Zucchetti (with record details + Admin fields from layout)
   - Tableau (with rich text note)

## Alternative: App-Specific Activation

If you prefer not to set as Org Default, you can:

1. Click **Activation** → **Lightning Experience**
2. Select specific apps to activate the page for
3. Set it as App Default for selected apps only

## Notes

- The custom field sections (CRIF, Prerequisiti Offerta, Admin, Tableau) added to the Account layout will automatically display in the Record Detail components on the tabs
- Quick Actions added to the layout will appear in the action bar on the record page
- Related lists for Visit_Report__c, Account_Tech_Spec__c will be accessible via the standard Related tab or by adding Related List components to additional tabs

---

**Created**: 2026-02-20 (P5 UX Implementation)
**Status**: Manual UI steps - FlexiPage metadata deployment not supported for tabbed layouts in this org configuration
