# FINAL ALIGNMENT REPORT
## Sistema Elco Salesforce - Esperienza Operatore Completa

**Data**: 2026-02-24
**Org**: elco-dev (giuseppe.villani101020.b5bd075bbc5f@agentforce.com)
**Autore**: Claude Sonnet 4.5

---

## 📋 EXECUTIVE SUMMARY

Il sistema è stato completamente allineato all'esperienza operatore richiesta con **3 entry point principali**:

### A) ENTRY POINT GLOBALE: "Nuovo Account da P.IVA" ✅
- **Cosa fa**: L'operatore lancia global action che chiede Partita IVA e crea Account con dati CRIF
- **Componenti**:
  - Global Action: `CRIF_New_Account_da_PIVA_GA` (LightningComponent - Aura wrapper)
  - Flow: `CRIF_NEW_da_PIVA` v6 Active
  - Global Layout: Include l'azione al sortOrder=0 (primo posto)
- **Status**: ✅ **COMPLETO E VERIFICATO**

### B) ENTRY POINT ACCOUNT: "CRIF - Aggiorna Dati" ✅ **MODIFICATO**
- **Cosa fa**: Da Account, lancia azione che:
  1. **Se Partita_IVA__c è vuoto**: Chiede P.IVA → Salva su Account → Refresh CRIF
  2. **Se Partita_IVA__c presente**: Refresh diretto CRIF
- **Componenti**:
  - Quick Action: `Account.CRIF_Aggiorna_Dati`
  - Flow: `CRIF_Aggiorna_Dati_Account` v5 Active (**AGGIORNATO IN QUESTO ALLINEAMENTO**)
- **Modifiche apportate**:
  - Aggiunto `recordLookup` Get_Account
  - Aggiunto `decision` Check_PIVA_Exists (verifica se ISBLANK)
  - Aggiunto `screen` Screen_Ask_PIVA (input P.IVA se manca)
  - Aggiunto `recordUpdate` Update_Account_PIVA (salva P.IVA)
  - Ristrutturato flow path: Start → Get_Account → Decision → (Ask PIVA se blank) → Confirm → Refresh
- **Deploy ID**: `0Afg5000004OxmDCAS`
- **Status**: ✅ **COMPLETO E DEPLOYATO**

### C) ENTRY POINT ACCOUNT: "Nuova Configurazione PCB" ✅
- **Cosa fa**: Da Account, lancia wizard PCB step-by-step (A→G) e crea record su custom object dedicato
- **Componenti**:
  - Quick Action: `Account.Nuova_Configurazione_PCB`
  - Flow: `PCB_Configuratore` v1 Active
  - Custom Object: `PCB_Configuration__c` con lookup Account__c
  - Validation Rules: 3 attive (Custom value required)
  - Field Dependencies: 2 (Tipologia→Materiale, Tipologia→Spessore)
- **Caratteristiche**:
  - Prefill da Account defaults (Spessore/Finish/Solder/Silkscreen)
  - Dipendenze picklist client-side con `dependentPicklistCmp`
  - Loop finale "Crea Altra Configurazione"
  - Output su PCB_Configuration__c (NON QuoteLineItem)
- **Status**: ✅ **COMPLETO E VERIFICATO** (implementato in P7)

---

## 🔍 INVENTARIO COMPONENTI VERIFICATI

### Global Actions (3)
| DeveloperName | MasterLabel | Type | Status |
|---------------|-------------|------|--------|
| CRIF_New_Account_da_PIVA_GA | Nuovo Account da P.IVA (CRIF) | LightningComponent | ✅ OK |
| CRIF_New_Account_da_PIVA | Nuovo Account da P.IVA (CRIF) | Flow | ✅ OK |
| CRIF_Crea_Account_da_PIVA | Crea Account da P.IVA (CRIF) | Flow | ✅ OK |

### Account Quick Actions (6)
| DeveloperName | MasterLabel | Type | Status |
|---------------|-------------|------|--------|
| CRIF_Aggiorna_Dati | Aggiorna Dati CRIF | Flow | ✅ UPDATED v5 |
| CRIF_Storico | Storico CRIF | Flow | ✅ OK |
| Nuova_Configurazione_PCB | Nuova Configurazione PCB | Flow | ✅ OK |
| Gestisci_Specifiche_Tecniche | Gestisci Specifiche Tecniche | Flow | ✅ OK |
| Crea_Report_Visita | Crea Report Visita | Flow | ✅ OK |
| Storico_Offerte | Storico Offerte | Flow | ✅ OK |

### Flows Attivi (4 core flows)
| DeveloperName | VersionNumber | Status | Note |
|---------------|---------------|--------|------|
| CRIF_NEW_da_PIVA | v6 | Active | ✅ Chiede P.IVA, crea Account, chiama CRIF |
| CRIF_Aggiorna_Dati_Account | v5 | Active | ✅ **MODIFICATO**: Controlla P.IVA, chiede se blank, salva, refresh |
| PCB_Configuratore | v1 | Active | ✅ Wizard A→G, crea PCB_Configuration__c |
| CRIF_Storico_Account | v1 | Active | ✅ Mostra storico chiamate CRIF |

### Custom Objects (1)
| API Name | Label | Relationship | Status |
|----------|-------|--------------|--------|
| PCB_Configuration__c | Configurazione PCB | Account__c (Lookup, Required, Restrict) | ✅ OK |

**Campi custom**: 18 (Account__c + 17 technical fields)
**Validation Rules**: 3 attive (VR_PCB_01/02/03 - Custom values required)
**Field Dependencies**: 2 (Materiale←Tipologia, Spessore←Tipologia)

### Permission Sets (5)
| Name | Label | RunFlow | Notes |
|------|-------|---------|-------|
| Elco_Run_Flows | Elco - Run Flows | ✅ true | ✅ OK - Operatori devono avere questo |
| PCB_Configurator_Operator | PCB Configurator Operator | ❌ false | ✅ OK - CRUD + FLS + flowAccess PCB_Configuratore |
| Quote_Operator | Quote Operator | ❌ false | ✅ OK - Legacy quote operations |
| CRIF_Operator | CRIF - Operator Access | ❌ false | ✅ OK - CRIF operations |
| CRIF_Admin | CRIF - Admin Access | ❌ false | ✅ OK - CRIF admin |

**IMPORTANTE**: Gli operatori devono avere assegnato `Elco_Run_Flows` per eseguire i flow.

### UI Components
| Component | Content | Status |
|-----------|---------|--------|
| Global-Global Layout | CRIF_New_Account_da_PIVA_GA a sortOrder=0 | ✅ OK |
| Account-Account Layout | 5 Quick Actions (CRIF, PCB, TechSpec, Visita, Storico) | ✅ OK |
| Account_360 FlexiPage | Related list PCB_Configurations__r + Tab "Configurazioni PCB" | ✅ OK |

---

## 🔧 MODIFICHE APPORTATE IN QUESTO ALLINEAMENTO

### 1. Flow CRIF_Aggiorna_Dati_Account v4 → v5

**Deploy ID**: `0Afg5000004OxmDCAS`
**Data**: 2026-02-24

#### Struttura PRIMA (v4):
```
Start → Screen_Confirm → Call_Core_Refresh → Check_Refresh_Success → Success/Error
```

**Problema**: Non controllava se Partita_IVA__c era blank, richiedeva sempre conferma senza chiedere P.IVA se mancava.

#### Struttura DOPO (v5):
```
Start → Get_Account → Check_PIVA_Exists
  ├─ PIVA Present → Screen_Confirm → Call_Core_Refresh → Success/Error
  └─ PIVA Missing → Screen_Ask_PIVA → Update_Account_PIVA → Screen_Confirm → Call_Core_Refresh → Success/Error
```

#### Componenti aggiunti:

**RecordLookup: Get_Account**
```xml
<recordLookups>
    <name>Get_Account</name>
    <locationX>176</locationX>
    <locationY>134</locationY>
    <filters>
        <field>Id</field>
        <operator>EqualTo</operator>
        <value><elementReference>recordId</elementReference></value>
    </filters>
    <object>Account</object>
    <storeOutputAutomatically>true</storeOutputAutomatically>
</recordLookups>
```

**Decision: Check_PIVA_Exists**
```xml
<decisions>
    <name>Check_PIVA_Exists</name>
    <rules>
        <name>PIVA_Present</name>
        <conditions>
            <leftValueReference>Get_Account.Partita_IVA__c</leftValueReference>
            <operator>IsNull</operator>
            <rightValue><booleanValue>false</booleanValue></rightValue>
        </conditions>
        <connector><targetReference>Screen_Confirm</targetReference></connector>
    </rules>
    <defaultConnector><targetReference>Screen_Ask_PIVA</targetReference></defaultConnector>
</decisions>
```

**Screen: Screen_Ask_PIVA**
```xml
<screens>
    <name>Screen_Ask_PIVA</name>
    <label>Inserisci Partita IVA</label>
    <fields>
        <name>Display_PIVA_Missing</name>
        <fieldText>L'Account non ha una Partita IVA associata. Inseriscila per continuare...</fieldText>
        <fieldType>DisplayText</fieldType>
    </fields>
    <fields>
        <name>Input_Missing_PIVA</name>
        <dataType>String</dataType>
        <fieldText>Partita IVA</fieldText>
        <fieldType>InputField</fieldType>
        <isRequired>true</isRequired>
    </fields>
</screens>
```

**RecordUpdate: Update_Account_PIVA**
```xml
<recordUpdates>
    <name>Update_Account_PIVA</name>
    <filters>
        <field>Id</field>
        <operator>EqualTo</operator>
        <value><elementReference>recordId</elementReference></value>
    </filters>
    <inputAssignments>
        <field>Partita_IVA__c</field>
        <value><elementReference>Input_Missing_PIVA</elementReference></value>
    </inputAssignments>
    <object>Account</object>
</recordUpdates>
```

---

## ✅ EVIDENZE QUERY (Org Truth)

### Quick Actions presenti
```bash
$ sf data query -o elco-dev --use-tooling-api -q "SELECT DeveloperName, MasterLabel, SobjectType, Type FROM QuickActionDefinition WHERE SobjectType='Account' OR SobjectType='Global' ORDER BY MasterLabel"
```

**Account Actions**: 6 trovate (CRIF_Aggiorna_Dati, CRIF_Storico, Nuova_Configurazione_PCB, Gestisci_Specifiche_Tecniche, Crea_Report_Visita, Storico_Offerte)
**Global Actions**: 3 trovate (CRIF_New_Account_da_PIVA_GA, CRIF_New_Account_da_PIVA, CRIF_Crea_Account_da_PIVA)

### Flows attivi
```bash
$ sf data query -o elco-dev --use-tooling-api -q "SELECT DeveloperName, ActiveVersion.VersionNumber, ActiveVersion.Status FROM FlowDefinition WHERE DeveloperName IN ('CRIF_NEW_da_PIVA','CRIF_Aggiorna_Dati_Account','PCB_Configuratore','CRIF_Storico_Account')"
```

**Risultato**:
- CRIF_NEW_da_PIVA: v6 Active ✅
- CRIF_Aggiorna_Dati_Account: v5 Active ✅ (**aggiornato da v4**)
- PCB_Configuratore: v1 Active ✅
- CRIF_Storico_Account: v1 Active ✅

### PCB_Configuration__c object
```bash
$ sf data query -o elco-dev --use-tooling-api -q "SELECT QualifiedApiName, Label FROM EntityDefinition WHERE QualifiedApiName='PCB_Configuration__c'"
```
**Risultato**: PCB_Configuration__c | Configurazione PCB ✅

### Validation Rules
```bash
$ sf data query -o elco-dev --use-tooling-api -q "SELECT ValidationName, Active FROM ValidationRule WHERE EntityDefinition.QualifiedApiName='PCB_Configuration__c'"
```
**Risultato**: 3 active (VR_PCB_01_Materiale_Custom, VR_PCB_02_Spessore_Custom, VR_PCB_03_Rame_Custom) ✅

### Account Lookup
```bash
$ sf data query -o elco-dev --use-tooling-api -q "SELECT QualifiedApiName, DataType, ReferenceTo, RelationshipName FROM EntityParticle WHERE EntityDefinition.QualifiedApiName='PCB_Configuration__c' AND QualifiedApiName='Account__c'"
```
**Risultato**: Account__c | reference | Account | Account__r ✅

### Permission Sets
```bash
$ sf data query -o elco-dev --use-tooling-api -q "SELECT Name, Label, PermissionsRunFlow FROM PermissionSet WHERE Name IN ('Elco_Run_Flows','PCB_Configurator_Operator')"
```
**Risultato**:
- Elco_Run_Flows: PermissionsRunFlow=true ✅
- PCB_Configurator_Operator: PermissionsRunFlow=false, ma ha objectPermissions + flowAccesses ✅

### Metadata Files Verificati

#### Global Layout
```bash
$ grep "CRIF_New_Account_da_PIVA_GA" force-app/main/default/layouts/Global-Global\ Layout.layout-meta.xml
```
**Risultato**: Action presente a sortOrder=0 (primo posto) ✅

#### Account Layout
```bash
$ grep -E "Nuova_Configurazione_PCB|CRIF_Aggiorna_Dati|CRIF_Storico|Gestisci_Specifiche|Crea_Report" force-app/main/default/layouts/Account-Account\ Layout.layout-meta.xml | wc -l
```
**Risultato**: 5 occorrenze ✅

#### Account_360 FlexiPage
```bash
$ grep "PCB_Configurations__r" force-app/main/default/flexipages/Account_360.flexipage-meta.xml
```
**Risultato**: Related list presente ✅

#### PCB_Configuratore Flow
```bash
$ grep "<object>PCB_Configuration__c" force-app/main/default/flows/PCB_Configuratore.flow-meta.xml
```
**Risultato**: Flow crea record su PCB_Configuration__c ✅

```bash
$ grep "Account__c" force-app/main/default/flows/PCB_Configuratore.flow-meta.xml
```
**Risultato**: Assegna Account__c = recordId ✅

#### PCB_Configurator_Operator PermSet
```bash
$ grep -A3 "objectPermissions" force-app/main/default/permissionsets/PCB_Configurator_Operator.permissionset-meta.xml
```
**Risultato**: allowCreate=true, allowEdit=true, allowRead=true ✅

```bash
$ grep -A2 "flowAccesses" force-app/main/default/permissionsets/PCB_Configurator_Operator.permissionset-meta.xml
```
**Risultato**: flow=PCB_Configuratore, enabled=true ✅

---

## 🧪 UAT CHECKLIST E RISULTATI

### TEST 1: Global Action "Nuovo Account da P.IVA" 🔲 **DA TESTARE MANUALMENTE**

**Precondizioni**:
- Login su org elco-dev
- Utente ha permset Elco_Run_Flows assegnato

**Steps**:
1. Da qualsiasi pagina, click su "+" (Global Actions) o menu azioni
2. Seleziona "Nuovo Account da P.IVA (CRIF)" (LightningComponent)
3. Inserisci Partita IVA (es: "12345678901")
4. Click "Avanti"

**Expected**:
- Flow CRIF_NEW_da_PIVA v6 si apre
- Chiede Partita IVA (screen)
- Crea Account con Nome/Ragione Sociale
- Popola campi CRIF (CRIF_Rating__c, CRIF_Score__c, etc.)
- Salva Partita_IVA__c su Account
- Mostra screen success

**Status**: 🔲 **DA ESEGUIRE MANUALMENTE** (componenti verificati in org)

---

### TEST 2: Account Action "CRIF - Aggiorna Dati" (P.IVA mancante) 🔲 **DA TESTARE MANUALMENTE**

**Precondizioni**:
- Account esistente senza Partita_IVA__c (blank)
- Utente ha permset Elco_Run_Flows assegnato

**Steps**:
1. Apri Account senza P.IVA
2. Click su Quick Action "Aggiorna Dati CRIF"
3. Flow v5 verifica che Partita_IVA__c è blank
4. Mostra screen "Partita IVA mancante"
5. Inserisci P.IVA (es: "98765432109")
6. Click "Avanti"
7. Screen conferma aggiornamento
8. Click "Avanti"

**Expected**:
- Flow salva Partita_IVA__c su Account (Update_Account_PIVA)
- Chiama CrifCoreRefreshInvocable con accountId
- Aggiorna campi CRIF (CRIF_Last_Check_Date__c, etc.)
- Mostra screen success "Dati CRIF aggiornati con successo"

**Status**: 🔲 **DA ESEGUIRE MANUALMENTE** (flow v5 deployato)

---

### TEST 3: Account Action "CRIF - Aggiorna Dati" (P.IVA presente) 🔲 **DA TESTARE MANUALMENTE**

**Precondizioni**:
- Account esistente con Partita_IVA__c compilata
- Utente ha permset Elco_Run_Flows assegnato

**Steps**:
1. Apri Account con P.IVA già presente
2. Click su Quick Action "Aggiorna Dati CRIF"
3. Flow v5 verifica che Partita_IVA__c è presente
4. Salta screen "Chiedi P.IVA" e va direttamente a Screen_Confirm

**Expected**:
- NON chiede P.IVA (decision path PIVA_Present)
- Mostra direttamente screen conferma
- Procede con refresh CRIF
- Mostra success

**Status**: 🔲 **DA ESEGUIRE MANUALMENTE** (flow v5 deployato)

---

### TEST 4: Account Action "Nuova Configurazione PCB" 🔲 **DA TESTARE MANUALMENTE**

**Precondizioni**:
- Account esistente con campi default popolati (Spessore_Default__c, Finish_Default__c, etc.)
- Utente ha permset Elco_Run_Flows + PCB_Configurator_Operator assegnati

**Steps**:
1. Apri Account
2. Click su Quick Action "Nuova Configurazione PCB"
3. Flow PCB_Configuratore v1 si apre
4. Screen A: Scegli Tipologia_Prodotto__c = "Rigido"
5. Screen B: Verifica prefill Materiale (dipendente da Tipologia), scegli "FR-4 Standard"
6. Screen C: Dimensioni + Spessore (dipendente da Tipologia), scegli "1.6mm"
7. Screen D: Rame + Finish (verifica prefill da Account.Finish_Default__c)
8. Screen E: Solder + Silkscreen (verifica prefill)
9. Screen F: Parametri tecnici (Pista/Foro/Isolamento/Aspect)
10. Screen G: Codici (Customer/Internal)
11. Salva

**Expected**:
- Wizard completo A→G funziona
- Prefill da Account defaults funziona
- Dependent picklist (Tipologia→Materiale, Tipologia→Spessore) funziona client-side con dependentPicklistCmp
- Crea record PCB_Configuration__c con Account__c = AccountId
- Screen success con loop "Crea Altra Configurazione?"

**Expected se Custom value**:
- Se scegli Materiale="Custom" senza compilare Materiale_Custom_Value__c → VR_PCB_01 blocca salvataggio
- Se scegli Spessore="Custom" senza compilare Spessore_Custom_Value__c → VR_PCB_02 blocca salvataggio
- Se scegli Rame="Custom" senza compilare Rame_Custom_Value__c → VR_PCB_03 blocca salvataggio

**Status**: 🔲 **DA ESEGUIRE MANUALMENTE** (flow v1 e object verificati)

---

### TEST 5: UI Visibilità (Account_360 + Related List) 🔲 **DA TESTARE MANUALMENTE**

**Steps**:
1. Apri Account che ha creato configurazioni PCB
2. Vai a tab "Configurazioni PCB" in Account_360 FlexiPage
3. Verifica che related list PCB_Configurations__r mostra i record

**Expected**:
- Tab "Configurazioni PCB" visibile in Account_360
- Related list mostra record PCB_Configuration__c filtrati per Account__c
- Columns: Name (PCB-00001), Tipologia_Prodotto__c, Materiale__c, Spessore_Complessivo__c, etc.

**Status**: 🔲 **DA ESEGUIRE MANUALMENTE** (flexipage verificato)

---

### TEST 6: Quick Actions visibili su Account 🔲 **DA TESTARE MANUALMENTE**

**Steps**:
1. Apri qualsiasi Account
2. Verifica Highlights Panel (top right) o Actions dropdown

**Expected**:
- Quick Actions visibili:
  - ✅ CRIF - Aggiorna Dati
  - ✅ Storico CRIF
  - ✅ Nuova Configurazione PCB
  - ✅ Gestisci Specifiche Tecniche
  - ✅ Crea Report Visita
  - (✅ Storico Offerte)

**Status**: 🔲 **DA ESEGUIRE MANUALMENTE** (layout verificato)

---

## 📊 COMPONENTI MODIFICATI/CREATI

| Data | Component | Action | Deploy ID | Versione |
|------|-----------|--------|-----------|----------|
| 2026-02-24 | CRIF_Aggiorna_Dati_Account.flow-meta.xml | Modified (v4→v5) | 0Afg5000004OxmDCAS | v5 Active |
| 2026-02-24 (P7) | PCB_Configuration__c.object-meta.xml | Created | 0Afg5000004OmndCAC | - |
| 2026-02-24 (P7) | PCB_Configuration__c 18 fields | Created | 0Afg5000004OmndCAC | - |
| 2026-02-24 (P7) | PCB_Configuration__c 3 VRs | Created | 0Afg5000004OmndCAC | - |
| 2026-02-24 (P7) | PCB_Configuratore.flow-meta.xml | Created | 0Afg5000004OiyVCAS | v1 Active |
| 2026-02-24 (P7) | Account.Nuova_Configurazione_PCB.quickAction | Created | 0Afg5000004OsUnCAK | - |
| 2026-02-24 (P7) | PCB_Configurator_Operator.permissionset | Created | 0Afg5000004OsUnCAK | - |
| 2026-02-24 (P7) | Account-Account Layout.layout-meta.xml | Updated | 0Afg5000004OmjgCAC | - |
| 2026-02-24 (P7) | Account_360.flexipage-meta.xml | Updated | 0Afg5000004OsGICA0 | - |

**Legacy components** (P1-P6, NOT modified in this alignment):
- CRIF_NEW_da_PIVA v6 (CRIF P2)
- CRIF_Storico_Account v1 (CRIF P2)
- Global-Global Layout (CRIF P2)
- Gestisci_Specifiche_Tecniche, Crea_Report_Visita (P4)
- Account_Tech_Spec__c, Visit_Report__c (P4)
- Elco_Run_Flows, CRIF_Operator, CRIF_Admin (CRIF P1/P2)

---

## 🎯 ESPERIENZA OPERATORE - FLOW COMPLETO

### Scenario A: Nuovo Cliente da Partita IVA (Global)

**Operatore**: Da homepage o qualsiasi pagina
**Azione**: Click "+" → "Nuovo Account da P.IVA (CRIF)"

**Flow**:
1. ➡️ Global Action `CRIF_New_Account_da_PIVA_GA` (Aura wrapper)
2. ➡️ Lancia Flow `CRIF_NEW_da_PIVA` v6
3. ➡️ Screen chiede Partita IVA
4. ➡️ Crea Account, popola Partita_IVA__c
5. ➡️ Chiama servizio CRIF (CrifCoreRefreshInvocable)
6. ➡️ Popola campi CRIF su Account
7. ➡️ Screen success con link ad Account creato

**Output**: Account creato con dati CRIF, pronto per lavorare

---

### Scenario B: Aggiornamento CRIF Account Esistente (con P.IVA mancante)

**Operatore**: Dentro Account senza P.IVA
**Azione**: Click Quick Action "CRIF - Aggiorna Dati"

**Flow**:
1. ➡️ Quick Action `Account.CRIF_Aggiorna_Dati`
2. ➡️ Lancia Flow `CRIF_Aggiorna_Dati_Account` v5
3. ➡️ RecordLookup: Get_Account
4. ➡️ Decision: Check_PIVA_Exists → **PIVA Missing** path
5. ➡️ Screen "Partita IVA mancante" chiede input
6. ➡️ RecordUpdate: Salva Partita_IVA__c su Account
7. ➡️ Screen conferma
8. ➡️ Call_Core_Refresh (CrifCoreRefreshInvocable)
9. ➡️ Aggiorna campi CRIF (CRIF_Last_Check_Date__c, CRIF_Rating__c, etc.)
10. ➡️ Screen success

**Output**: Account aggiornato con P.IVA e dati CRIF refresh

---

### Scenario C: Aggiornamento CRIF Account Esistente (con P.IVA presente)

**Operatore**: Dentro Account con P.IVA già popolata
**Azione**: Click Quick Action "CRIF - Aggiorna Dati"

**Flow**:
1. ➡️ Quick Action `Account.CRIF_Aggiorna_Dati`
2. ➡️ Lancia Flow `CRIF_Aggiorna_Dati_Account` v5
3. ➡️ RecordLookup: Get_Account
4. ➡️ Decision: Check_PIVA_Exists → **PIVA Present** path
5. ➡️ Screen conferma (SKIP chiedi P.IVA)
6. ➡️ Call_Core_Refresh (CrifCoreRefreshInvocable)
7. ➡️ Aggiorna campi CRIF
8. ➡️ Screen success

**Output**: Dati CRIF aggiornati senza ri-chiedere P.IVA

---

### Scenario D: Nuova Configurazione PCB Account-based

**Operatore**: Dentro Account
**Azione**: Click Quick Action "Nuova Configurazione PCB"

**Flow**:
1. ➡️ Quick Action `Account.Nuova_Configurazione_PCB`
2. ➡️ Lancia Flow `PCB_Configuratore` v1 (input: recordId = AccountId)
3. ➡️ RecordLookup: Get_Account (prefill defaults)
4. ➡️ **Screen A**: Tipologia Prodotto (Rigido/Flex/Rigido-Flex)
5. ➡️ **Screen B**: Materiale (dependent → Tipologia) + Custom value se "Custom"
6. ➡️ **Screen C**: Dimensioni Array + Spessore (dependent → Tipologia) + Custom value
7. ➡️ **Screen D**: Rame + Custom + Finish (prefill da Account.Finish_Default__c)
8. ➡️ **Screen E**: Solder (prefill da Account.Solder_Default__c) + Silkscreen (prefill)
9. ➡️ **Screen F**: Parametri tecnici (Pista/Foro/Isolamento/Aspect Ratio)
10. ➡️ **Screen G**: Codici (Customer Circuit Code + Internal Circuit Code)
11. ➡️ RecordCreate: Crea PCB_Configuration__c con Account__c = recordId
12. ➡️ Validation Rules check (se Custom values mancanti → errore)
13. ➡️ Screen success "Configurazione creata" + loop "Crea Altra?"

**Output**: Record PCB_Configuration__c creato, visibile in Account_360 related list

---

## 🔐 SECURITY MODEL - PERMISSION SETS ASSIGNMENT

### Per Operatori Standard

**Assegna**:
1. `Elco_Run_Flows` (obbligatorio per eseguire tutti i flow)
2. `PCB_Configurator_Operator` (se devono creare configurazioni PCB)
3. `CRIF_Operator` (se devono lanciare CRIF actions)

**Non assegnare**:
- `CRIF_Admin` (solo per admin che gestiscono credenziali)
- `CRIF_MOCK_Access` (solo per test/dev con mock CRIF)

### Per Admin/Power Users

**Assegna tutto**:
1. Elco_Run_Flows
2. PCB_Configurator_Operator
3. CRIF_Operator
4. CRIF_Admin
5. Quote_Operator (se gestiscono preventivi legacy)

---

## 🚨 LIMITAZIONI E NOTE TECNICHE

### 1. Named Credential CRIF_MOCK
**Stato**: Verificato esistente in org
**Nota**: Se credenziali vuote o endpoint non configurato, i flow CRIF falliranno con errore "Connection refused" o "401 Unauthorized"
**Azione manuale richiesta**: Configurare Named Credential CRIF_MOCK con endpoint produzione e certificati

### 2. FlexiPage Account_360 Multi-Tab
**Stato**: Tabbed layout deploiato via metadata
**Nota**: Se non visibile, verificare in Setup → Lightning App Builder → Account_360 → Attivazione
**Azione manuale se necessario**: Attivare FlexiPage come default per App/Profile

### 3. Global Layout Global Publisher
**Stato**: Include CRIF_New_Account_da_PIVA_GA al primo posto
**Nota**: Verificare che l'app Lightning corrente usi questo layout
**Azione manuale se necessario**: Setup → User Interface → Global Publisher Layouts → Assign to App

### 4. Flow Prefill da Account Defaults
**Stato**: PCB_Configuratore usa Get_Account per prefill
**Nota**: Se Account non ha Spessore_Default__c, Finish_Default__c, etc. popolati, i campi flow saranno blank
**Azione suggerita**: Popolare default values su Account quando si crea cliente PCB

### 5. Validation Rules Custom Values
**Stato**: VR_PCB_01/02/03 attive
**Nota**: Se operatore sceglie "Custom" senza compilare campo _Custom_Value__c, salvataggio fallisce con errore VR
**Comportamento atteso**: User-friendly error message su screen

---

## 📂 FILE REPOSITORY MODIFICATI

### File modificati in questo allineamento:
```
D:\Elco Demo\elco-salesforce\force-app\main\default\flows\CRIF_Aggiorna_Dati_Account.flow-meta.xml
```

### File verificati (nessuna modifica):
```
D:\Elco Demo\elco-salesforce\force-app\main\default\flows\CRIF_NEW_da_PIVA.flow-meta.xml
D:\Elco Demo\elco-salesforce\force-app\main\default\flows\PCB_Configuratore.flow-meta.xml
D:\Elco Demo\elco-salesforce\force-app\main\default\quickActions\Account.Nuova_Configurazione_PCB.quickAction-meta.xml
D:\Elco Demo\elco-salesforce\force-app\main\default\quickActions\CRIF_New_Account_da_PIVA_GA.quickAction-meta.xml
D:\Elco Demo\elco-salesforce\force-app\main\default\layouts\Global-Global Layout.layout-meta.xml
D:\Elco Demo\elco-salesforce\force-app\main\default\layouts\Account-Account Layout.layout-meta.xml
D:\Elco Demo\elco-salesforce\force-app\main\default\flexipages\Account_360.flexipage-meta.xml
D:\Elco Demo\elco-salesforce\force-app\main\default\objects\PCB_Configuration__c\*
D:\Elco Demo\elco-salesforce\force-app\main\default\permissionsets\PCB_Configurator_Operator.permissionset-meta.xml
D:\Elco Demo\elco-salesforce\force-app\main\default\permissionsets\Elco_Run_Flows.permissionset-meta.xml
```

---

## ✅ ALLINEAMENTO COMPLETATO

| Requisito | Status | Evidenza |
|-----------|--------|----------|
| A) Global Action "Nuovo Account da P.IVA" | ✅ COMPLETO | CRIF_New_Account_da_PIVA_GA presente in Global Layout sortOrder=0 |
| B) Account Action "CRIF - Aggiorna Dati" con logica P.IVA | ✅ COMPLETATO E DEPLOYATO | Flow v5 con decision PIVA check, Deploy ID 0Afg5000004OxmDCAS |
| C) Account Action "Nuova Configurazione PCB" | ✅ COMPLETO | Flow v1 crea PCB_Configuration__c, verified |
| D) UI Account_360 + Layout | ✅ COMPLETO | FlexiPage ha tab PCB, Layout ha 5 actions |
| E) Security (RunFlow + CRUD + FLS) | ✅ COMPLETO | Elco_Run_Flows + PCB_Configurator_Operator verified |
| F) Documentazione aggiornata | ✅ COMPLETO | Questo report + org_state.md + struttura.md |

**Prossimo passo**: **UAT manuale** (test 1-6) per confermare esperienza operatore end-to-end.

---

**Fine Report**
**Autore**: Claude Sonnet 4.5
**Data**: 2026-02-24
