# Portal testMoro - Patch Summary

## 📝 File Modificati

### 1. **NEW**: QuickAction NewCommunityCase_RI
`force-app/main/default/quickActions/NewCommunityCase_RI.quickAction-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<QuickAction xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Nuova Richiesta di Intervento</label>
    <optionsCreateFeedItem>true</optionsCreateFeedItem>
    <quickActionLayout>
        <layoutSectionStyle>TwoColumnsLeftToRight</layoutSectionStyle>
        <quickActionLayoutColumns>
            <quickActionLayoutItems>
                <emptySpace>false</emptySpace>
                <field>AccountId</field>          <!-- DESTINAZIONE -->
                <uiBehavior>Edit</uiBehavior>
            </quickActionLayoutItems>
            <quickActionLayoutItems>
                <emptySpace>false</emptySpace>
                <field>Subject</field>
                <uiBehavior>Required</uiBehavior>  <!-- REQUIRED -->
            </quickActionLayoutItems>
            <quickActionLayoutItems>
                <emptySpace>false</emptySpace>
                <field>Description</field>
                <uiBehavior>Edit</uiBehavior>
            </quickActionLayoutItems>
        </quickActionLayoutColumns>
        <quickActionLayoutColumns/>
    </quickActionLayout>
    <targetObject>Case</targetObject>
    <!-- targetRecordType da configurare post-deploy nella UI -->
    <type>Create</type>
</QuickAction>
```

---

### 2. **NEW**: ListView Portal_Richieste_Intervento
`force-app/main/default/objects/Case/listViews/Portal_Richieste_Intervento.listView-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ListView xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Portal_Richieste_Intervento</fullName>
    <columns>CASES.CASE_NUMBER</columns>
    <columns>CASES.SUBJECT</columns>
    <columns>ACCOUNT.NAME</columns>         <!-- DESTINAZIONE -->
    <columns>CASES.STATUS</columns>
    <columns>CASES.CREATED_DATE</columns>
    <filterScope>Mine</filterScope>         <!-- SOLO I MIEI -->
    <label>Le mie richieste</label>
    <language>it</language>
</ListView>
```

---

### 3. **MODIFIED**: contactSupport.json
`force-app/main/default/experiences/testMoro1/views/contactSupport.json`

```diff
  "componentAttributes" : {
    ...
-   "headerSubtitle" : "Dicci come possiamo aiutarti.",
+   "headerSubtitle" : "Indica il servizio e descrivi il problema.",
-   "headerTitle" : "Apri una richiesta",
+   "headerTitle" : "Nuova Richiesta di Intervento",
    ...
-   "quickActionName" : "NewCommunityCase",
+   "quickActionName" : "NewCommunityCase_RI",
  }
```

---

### 4. **MODIFIED**: caseList.json
`force-app/main/default/experiences/testMoro1/views/caseList.json`

```diff
  "componentAttributes" : {
    ...
-   "filterName" : "{!filterId}",
+   "filterName" : "Portal_Richieste_Intervento",
    ...
-   "scope" : "{!objectName}",
+   "scope" : "Case",
    ...
  }
```

---

## 🚀 Comandi CLI

### Deploy completo
```bash
cd "D:\Elco Demo\elco-salesforce"

# Validate
sf project deploy start -o orgfarm-packaging \
  --manifest manifest/portal_ticket_coerente.xml \
  --dry-run --wait 10

# Deploy
sf project deploy start -o orgfarm-packaging \
  --manifest manifest/portal_ticket_coerente.xml \
  --wait 10
```

### Commit
```bash
git add force-app/main/default/quickActions/NewCommunityCase_RI.quickAction-meta.xml
git add force-app/main/default/objects/Case/listViews/Portal_Richieste_Intervento.listView-meta.xml
git add force-app/main/default/experiences/testMoro1/views/contactSupport.json
git add force-app/main/default/experiences/testMoro1/views/caseList.json
git add manifest/portal_ticket_coerente.xml

git commit -m "feat(portal): testMoro ticket coerente - solo Richiesta di Intervento

Deploy ID: 0AfgK00000GlXCNSA3

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## ⚙️ Post-Deploy (UI)

### Step 1: Assegnare RecordType alla QuickAction
Setup > Object Manager > Case > Buttons, Links, and Actions > **NewCommunityCase_RI**
- Edit > Record Type to Create: **"Richiesta di Intervento"**

### Step 2: Profile RecordType Visibility
Setup > Users > Profiles > **[Community Profile]** > Object Settings > Cases
- Available Record Types: solo **"Richiesta di Intervento"**
- Default: **"Richiesta di Intervento"**

---

## ✅ Test

1. Portal login → "Nuova richiesta"
2. Form mostra: Account (Destinazione), Subject*, Description
3. Crea Case → verifica RecordType = "Richiesta di Intervento"
4. "Le mie richieste" → mostra solo Case dell'utente con colonne corrette

---

**Deploy Status**: ✅ SUCCESS (0AfgK00000GlXCNSA3)
**Documentazione completa**: `PORTAL_TICKET_COERENTE_DEPLOY.md`
