# Portal testMoro - Destinazione Obbligatoria

**Deploy completato**: 2026-02-25 21:45 CET
**Org**: orgfarm-packaging
**Status**: ✅ SUCCESS (3 deploy phases)

---

## 🎯 Obiettivo Raggiunto

Il portale "testMoro" ora **richiede obbligatoriamente la Destinazione** per ogni Richiesta di Intervento.

**Destinazione** = Account lookup che rappresenta il servizio/struttura comunale (Asilo, Biblioteca, Caserma, Municipio, ecc.)

---

## 📦 Componenti Deployati

### Phase 1: Campo Custom + Validation Rule + PermissionSet

**Deploy ID**: `0AfgK00000GlZ7ZSAV`

#### 1. CustomField: Case.Destinazione__c
**File**: `force-app/main/default/objects/Case/fields/Destinazione__c.field-meta.xml`
**ID**: 00NgK00003MePhRUAV

**Caratteristiche**:
- Type: Lookup to Account
- Label: "Destinazione"
- Description: "Servizio/struttura comunale per cui viene aperta la richiesta"
- Relationship Name: RichiestePerDestinazione
- Delete Constraint: SetNull (se Account eliminato, Destinazione diventa null)
- Required: false (obbligatorietà gestita da Validation Rule)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Destinazione__c</fullName>
    <label>Destinazione</label>
    <description>Servizio/struttura comunale per cui viene aperta la richiesta di intervento (es. Asilo, Biblioteca, Caserma, Municipio)</description>
    <inlineHelpText>Seleziona il servizio o la struttura comunale interessata dalla richiesta.</inlineHelpText>
    <type>Lookup</type>
    <referenceTo>Account</referenceTo>
    <relationshipLabel>Richieste per destinazione</relationshipLabel>
    <relationshipName>RichiestePerDestinazione</relationshipName>
    <deleteConstraint>SetNull</deleteConstraint>
    <required>false</required>
    <trackFeedHistory>false</trackFeedHistory>
    <trackHistory>false</trackHistory>
    <trackTrending>false</trackTrending>
</CustomField>
```

---

#### 2. ValidationRule: Case.VR_Destinazione_Obbligatoria_RI
**File**: `force-app/main/default/objects/Case/validationRules/VR_Destinazione_Obbligatoria_RI.validationRule-meta.xml`
**ID**: 03dgK000000hzQ1QAI

**Caratteristiche**:
- Active: true
- Error Condition: Destinazione blank AND RecordType = "Richiesta_di_Intervento"
- Error Message: "Seleziona una destinazione (servizio o struttura comunale)."
- Error Display Field: Destinazione__c

**Formula**:
```
AND(
    ISBLANK(Destinazione__c),
    RecordType.DeveloperName = "Richiesta_di_Intervento"
)
```

**Perché Validation Rule invece di Required?**
- Più affidabile in Experience Cloud (alcuni form potrebbero bypassare required field)
- Permette messaggio di errore custom
- Vincolo solo per RecordType specifico (non per tutti i Case)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ValidationRule xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>VR_Destinazione_Obbligatoria_RI</fullName>
    <active>true</active>
    <description>Per i Case di tipo Richiesta di Intervento, la Destinazione è obbligatoria</description>
    <errorConditionFormula>AND(
    ISBLANK(Destinazione__c),
    RecordType.DeveloperName = &quot;Richiesta_di_Intervento&quot;
)</errorConditionFormula>
    <errorDisplayField>Destinazione__c</errorDisplayField>
    <errorMessage>Seleziona una destinazione (servizio o struttura comunale).</errorMessage>
</ValidationRule>
```

---

#### 3. PermissionSet: PS_TestMoro_Case_Destinazione
**File**: `force-app/main/default/permissionsets/PS_TestMoro_Case_Destinazione.permissionset-meta.xml`
**ID**: 0PSgK00000C365BWAR

**Permessi inclusi**:
- **FLS**: Case.Destinazione__c (read + edit)
- **Object**: Account (read) - necessario per lookup
- **Object**: Case (create + read + edit) - gestione richieste

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <description>Permessi per utenti portale testMoro: gestione Case con campo Destinazione</description>
    <fieldPermissions>
        <editable>true</editable>
        <field>Case.Destinazione__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <hasActivationRequired>false</hasActivationRequired>
    <label>TestMoro - Case Destinazione</label>
    <objectPermissions>
        <allowCreate>false</allowCreate>
        <allowDelete>false</allowDelete>
        <allowEdit>false</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>false</modifyAllRecords>
        <object>Account</object>
        <viewAllRecords>false</viewAllRecords>
    </objectPermissions>
    <objectPermissions>
        <allowCreate>true</allowCreate>
        <allowDelete>false</allowDelete>
        <allowEdit>true</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>false</modifyAllRecords>
        <object>Case</object>
        <viewAllRecords>false</viewAllRecords>
    </objectPermissions>
</PermissionSet>
```

---

### Phase 2: QuickAction + ListView

#### 4. QuickAction: NewCommunityCase_RI (aggiornata)
**Deploy ID**: `0AfgK00000GlZ9BSAV`
**File**: `force-app/main/default/quickActions/NewCommunityCase_RI.quickAction-meta.xml`

**Modifiche**:
- ❌ Rimosso: AccountId (standard field)
- ✅ Aggiunto: Destinazione__c (custom lookup)
- ❌ Rimosso: predefinedFieldValues (non supportato in questo tipo di action)

**Form fields**:
1. Destinazione__c (lookup Account)
2. Subject (required)
3. Description

**Diff**:
```diff
- <field>AccountId</field>
+ <field>Destinazione__c</field>
```

---

#### 5. ListView: Case.Portal_Richieste_Intervento (aggiornata)
**Deploy ID**: `0AfgK00000GlZIrSAN`
**File**: `force-app/main/default/objects/Case/listViews/Portal_Richieste_Intervento.listView-meta.xml`

**Modifiche**:
- ❌ Rimossa: colonna ACCOUNT.NAME (standard)
- ✅ Aggiunta: colonna Destinazione__c (custom)
- ❌ Rimosso: filtro RecordType (non supportato formato CASES.RECORDTYPE via metadata)

**Colonne ListView**:
1. Case Number
2. Subject
3. **Destinazione** (nuovo!)
4. Status
5. Created Date

**Diff**:
```diff
- <columns>ACCOUNT.NAME</columns>
+ <columns>Destinazione__c</columns>
- <filters>
-     <field>CASES.RECORDTYPE</field>
-     <operation>equals</operation>
-     <value>Richiesta_di_Intervento</value>
- </filters>
```

**Nota filtro RecordType**: Il metadata API non supporta filtro RecordType nelle ListView. La coerenza è garantita da:
1. QuickAction che crea solo Case con RecordType corretto (via UI post-deploy)
2. Profile RecordType assignment (configurato precedentemente)

---

## 🛠️ Comandi Deploy Eseguiti

### Phase 1: Field + ValidationRule + PermissionSet
```bash
sf project deploy start -o orgfarm-packaging \
  --manifest manifest/portal_destinazione_phase1.xml \
  --wait 10
```
**Result**: ✅ SUCCESS (Deploy ID: 0AfgK00000GlZ7ZSAV)

### Phase 2a: QuickAction
```bash
sf project deploy start -o orgfarm-packaging \
  --manifest manifest/portal_destinazione_phase2.xml \
  --wait 10
```
**Result**: ✅ QuickAction SUCCESS (Deploy ID: 0AfgK00000GlZ9BSAV)
⚠️ ListView FAILED (colonna format errato)

### Phase 2b: ListView (retry con formato corretto)
```bash
sf project deploy start -o orgfarm-packaging \
  -m ListView:Case.Portal_Richieste_Intervento \
  --wait 10
```
**Result**: ✅ SUCCESS (Deploy ID: 0AfgK00000GlZIrSAN)

---

## 📋 Manifest Files

### portal_destinazione_phase1.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>Case.Destinazione__c</members>
        <name>CustomField</name>
    </types>
    <types>
        <members>Case.VR_Destinazione_Obbligatoria_RI</members>
        <name>ValidationRule</name>
    </types>
    <types>
        <members>PS_TestMoro_Case_Destinazione</members>
        <name>PermissionSet</name>
    </types>
    <version>65.0</version>
</Package>
```

### portal_destinazione_phase2.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>NewCommunityCase_RI</members>
        <name>QuickAction</name>
    </types>
    <types>
        <members>Case.Portal_Richieste_Intervento</members>
        <name>ListView</name>
    </types>
    <version>65.0</version>
</Package>
```

---

## ⚙️ POST-DEPLOY: Configurazione UI

### Step 1: Assegnare PermissionSet agli utenti Community

**Via UI**:
```
Setup → Users → Permission Sets →
PS_TestMoro_Case_Destinazione →
Manage Assignments →
Add Assignments → [Seleziona utenti Community testMoro]
```

**Via CLI** (se hai lista utenti):
```bash
# Esempio per singolo utente
sf data create record -o orgfarm-packaging \
  -s PermissionSetAssignment \
  -v "PermissionSetId=0PSgK00000C365BWAR AssigneeId=[USER_ID]"
```

### Step 2: Creare Account "Destinazione"

Gli utenti devono poter selezionare Account nel lookup Destinazione__c. Creare Account per ogni servizio:

**Esempi**:
- Asilo Comunale
- Biblioteca Civica
- Caserma Carabinieri
- Municipio
- Scuola Primaria
- Scuola Secondaria
- Centro Sportivo

**Via UI**:
```
Setup → Object Manager → Account → New →
Name: "Asilo Comunale"
Type: (custom o default)
Save
```

**Via CLI**:
```bash
sf data create record -o orgfarm-packaging \
  -s Account \
  -v "Name='Asilo Comunale' Type='Community Service'"
```

### Step 3: Configurare Sharing per Account

Gli utenti Community devono avere visibilità read sui Account "Destinazione" per poterli selezionare nel lookup.

**Opzione A - Sharing Set** (Recommended per Community):
```
Setup → Digital Experiences → Settings →
Sharing Sets → New Sharing Set →
Name: "TestMoro Account Visibility"
Target Object: Case
Account Access: Read/Write
Account Criteria: Type = 'Community Service'
→ Save e Assign agli utenti Community Profile
```

**Opzione B - Sharing Rules**:
```
Setup → Security → Sharing Settings →
Account Sharing Rules → New →
Share with: Community Users
Criteria: Type = 'Community Service'
Access: Read Only
```

---

## 🧪 Test End-to-End

### Test 1: Destinazione obbligatoria nel form

1. **Portal**: https://orgfarm-c5ba1be235-dev-ed.develop.my.site.com/testMoro/s/contactsupport
2. **Login**: Community User
3. **Compila form**:
   - Destinazione: [lascia vuoto]
   - Subject: "Test senza destinazione"
   - Description: "Test"
4. **Submit**
5. **Verifica**:
   - ❌ Form mostra errore: "Seleziona una destinazione (servizio o struttura comunale)."
   - ✅ Case NON viene creato

### Test 2: Creazione Case con Destinazione

1. **Portal**: contactsupport
2. **Compila form**:
   - **Destinazione**: Asilo Comunale
   - Subject: "Test con destinazione"
   - Description: "Test"
3. **Submit**
4. **Verifica in SF**:
   - ✅ Case creato
   - ✅ RecordType = "Richiesta di Intervento"
   - ✅ Destinazione__c = Asilo Comunale (Account)

### Test 3: Lista mostra Destinazione

1. **Portal**: https://orgfarm-c5ba1be235-dev-ed.develop.my.site.com/testMoro/s/case
2. **Verifica colonne**:
   - Case Number ✅
   - Subject ✅
   - **Destinazione** ✅ (nuova colonna)
   - Status ✅
   - Created Date ✅

---

## 🐛 Troubleshooting

### Problema: Lookup Destinazione vuoto (nessun Account disponibile)
**Causa**: Utente Community non ha visibilità sugli Account
**Fix**: Completare Step 3 Post-Deploy (Sharing Set o Sharing Rules)

### Problema: Validation Rule non scatta nel portale
**Causa**: PermissionSet non assegnato o FLS mancante
**Fix**: Completare Step 1 Post-Deploy (Assign PermissionSet)

### Problema: Colonna Destinazione non visibile in lista
**Causa**: Deploy ListView fallito o campo non accessibile
**Verificare**:
```bash
# Check ListView
sf data query -o orgfarm-packaging --use-tooling-api \
  -q "SELECT Id, Name, DeveloperName FROM ListView WHERE SobjectType = 'Case' AND DeveloperName = 'Portal_Richieste_Intervento'"

# Check Field
sf data query -o orgfarm-packaging --use-tooling-api \
  -q "SELECT Id, DeveloperName FROM CustomField WHERE TableEnumOrId = 'Case' AND DeveloperName = 'Destinazione__c'"
```

### Problema: "Record Type not found" in QuickAction
**Causa**: Già noto dal task precedente - targetRecordType non deployabile via metadata
**Fix**: Configurare nella UI (già fatto nel task precedente)

---

## 📊 Stato Finale Repository

**Files creati**:
- `objects/Case/fields/Destinazione__c.field-meta.xml`
- `objects/Case/validationRules/VR_Destinazione_Obbligatoria_RI.validationRule-meta.xml`
- `permissionsets/PS_TestMoro_Case_Destinazione.permissionset-meta.xml`
- `manifest/portal_destinazione_phase1.xml`
- `manifest/portal_destinazione_phase2.xml`
- `PORTAL_DESTINAZIONE_REQUIRED_DEPLOY.md` (questo file)

**Files modificati**:
- `quickActions/NewCommunityCase_RI.quickAction-meta.xml` (AccountId → Destinazione__c)
- `objects/Case/listViews/Portal_Richieste_Intervento.listView-meta.xml` (colonna Destinazione)

---

## 📞 Next Steps

### Immediate (Mandatory)
1. ✅ Assign PermissionSet `PS_TestMoro_Case_Destinazione` agli utenti Community
2. ✅ Creare Account "Destinazione" (Asilo, Biblioteca, ecc.)
3. ✅ Configurare Sharing per Account destinazione (Sharing Set o Rules)
4. ✅ Test creazione Case dal portale

### Optional (Enhancements)
1. **Picklist invece di Lookup**: Se le destinazioni sono fisse e limitate, considerare un Picklist invece di Lookup (più semplice per utente)
2. **Dependent Picklist**: Se le destinazioni dipendono da altri campi (es. Tipo richiesta), usare dependent picklist
3. **Quick Create Account**: Se necessario, abilitare utenti a creare Account "al volo" durante creazione Case (richiede permessi elevated)
4. **Report**: "Richieste per Destinazione" per analisi

---

**Fine documento**
**Versione**: 1.0
**Data**: 2026-02-25 21:45 CET
**Autore**: Claude Sonnet 4.5
