# FLS Remediation Plan - Required Fields Blocking

**Data**: 2026-02-20 17:15
**Status**: PARTIAL - Solo campi non-required deployati via Permission Set

---

## Problema: Required Fields Blocking FLS

Salesforce **NON permette** di gestire Field-Level Security per campi `required=true` tramite Permission Sets.
I campi required possono essere gestiti SOLO tramite **Profile** (non Permission Set).

---

## Campi Bloccanti Identificati

### TechSpec_Operator (4 campi required)

- `Account_Tech_Spec__c.Account__c` (Lookup required)
- `Account_Tech_Spec__c.Category__c` (Picklist required)
- `Account_Tech_Spec__c.Parameter__c` (Picklist required)
- `Account_Tech_Spec__c.Value__c` (Text required)

### Visit_Operator (6 campi required)

- `Visit_Attendee__c.Contact__c` (Lookup required)
- `Visit_Attendee__c.Visit_Report__c` (MasterDetail required)
- `Visit_Report__c.Account__c` (Lookup required)
- `Visit_Report__c.Subject__c` (Text required)
- `Visit_Report__c.Visit_DateTime__c` (DateTime required)
- `Visit_Report__c.Visit_Type__c` (Picklist required)

---

## Campi Deployati con Successo (via Permission Set)

### TechSpec_Operator (4 campi)
- `Account_Tech_Spec__c.Is_Active__c` (Checkbox, non required) ✅
- `Account_Tech_Spec__c.Notes__c` (LongTextArea, non required) ✅
- `Account_Tech_Spec__c.Source__c` (Picklist, non required) ✅
- `Account_Tech_Spec__c.UoM__c` (Picklist, non required) ✅

### Visit_Operator (2 campi)
- `Visit_Attendee__c.Email_Sent__c` (Checkbox, non required) ✅
- `Visit_Report__c.FollowUp_Sent__c` (Checkbox, non required) ✅
- `Visit_Report__c.FollowUp_Sent_On__c` (DateTime, non required) ✅
- `Visit_Report__c.Next_Steps__c` (LongTextArea, non required) ✅
- `Visit_Report__c.Summary__c` (LongTextArea, non required) ✅

---

## Opzioni di Remediation

### **Opzione A (CONSIGLIATA): Gestire required fields via PROFILE**

**Quando usare**:
- I campi DEVONO rimanere required (business logic richiede il valore obbligatorio)
- Gli utenti operativi devono avere accesso controllato

**Implementazione**:
1. Creare/modificare un **Custom Profile** (es: `Elco_Sales_User`)
2. Nel Profile, abilitare **Object CRUD** + **FLS Read/Edit** per tutti i campi (inclusi required)
3. Assegnare il Profile agli utenti target
4. I Permission Sets restano per permessi addizionali (RunFlow, external credentials, etc.)

**Pro**:
- Nessuna modifica ai field metadata (required=true rimane)
- Controllo granulare completo via Profile
- Best practice Salesforce per utenti operativi

**Contro**:
- Richiede creazione/gestione di Custom Profile
- Gli utenti devono avere il Profile corretto (non solo Permission Set)

---

### **Opzione B (NON CONSIGLIATA): Convertire required=false + Validation Rule**

**Quando usare**:
- SOLO se si vuole gestire TUTTO tramite Permission Sets (no Profiles)
- Se i campi possono essere "logically required" ma non "field required"

**Implementazione**:
1. Modificare field metadata: `<required>false</required>`
2. Creare Validation Rule per simulare required:
   ```apex
   // Esempio per Visit_Report__c.Subject__c
   ISBLANK(Subject__c)
   ```
3. Error message: "Subject is required"
4. Deploy field + validation rule
5. Aggiungere FLS ai Permission Sets

**Pro**:
- Tutto gestibile via Permission Sets (no Profile FLS)
- Deployabile end-to-end via CLI

**Contro**:
- ❌ Modifica significativa al data model (required -> non-required)
- ❌ Validation Rules sono bypassabili in alcuni contesti (API, Bulk, Flows con "fast field updates")
- ❌ Non è best practice Salesforce
- ❌ Richiede test estensivi per garantire che "required" sia sempre enforced

---

## **Raccomandazione Finale: Opzione A (Profile-based FLS)**

### Step per implementare:

1. **Creare Custom Profile** (clonare da Standard User):
   ```bash
   # Via CLI (retrieve, modify, deploy)
   sf project retrieve start --metadata "Profile:Standard User" --target-org elco-dev
   # Rinominare in Elco_Sales_User.profile-meta.xml
   # Modificare XML per abilitare FLS su tutti gli oggetti/campi custom
   sf project deploy start --metadata "Profile:Elco_Sales_User" --target-org elco-dev
   ```

2. **Abilitare FLS nel Profile** per:
   - Account_Tech_Spec__c: tutti i campi (Account__c, Category__c, Parameter__c, Value__c, Is_Active__c, Notes__c, Source__c, UoM__c)
   - Visit_Report__c: tutti i campi (Account__c, Subject__c, Visit_DateTime__c, Visit_Type__c, FollowUp_Sent__c, FollowUp_Sent_On__c, Next_Steps__c, Summary__c)
   - Visit_Attendee__c: tutti i campi (Contact__c, Visit_Report__c, Email_Sent__c)

3. **Assegnare Profile agli utenti**:
   ```bash
   # Query per trovare il Profile ID
   sf data query --target-org elco-dev --query "SELECT Id, Name FROM Profile WHERE Name='Elco_Sales_User' LIMIT 1"

   # Aggiornare utente
   sf data update record --target-org elco-dev --sobject User --where "Username='giuseppe.villani101020.b5bd075bbc5f@agentforce.com'" --values "ProfileId=<profile_id>"
   ```

4. **Mantenere Permission Sets** per:
   - RunFlow (Elco_Run_Flows) ✅
   - External Credentials (CRIF_MOCK_Access) ✅
   - Setup/Admin perms (Setup_Admin_Elco) ✅

---

## Riepilogo Stato Finale

| Permission Set | FLS Deployate | FLS Bloccate (required) | Totale Expected | Coverage |
|----------------|---------------|-------------------------|-----------------|----------|
| Quote_Operator | 30 | 0 | 30 | **100%** ✅ |
| Visit_Operator | 5 | 6 | 11 | **45%** ⚠️ |
| TechSpec_Operator | 4 | 4 | 8 | **50%** ⚠️ |

**Azione richiesta**: Implementare Opzione A (Profile-based FLS) per coprire i campi required bloccanti.

---

## File di Riferimento

- **Blocking fields**: `raw/security/fls_blocking_fields.json`
- **Diff report**: `raw/security/fls_diff.md`
- **Deploy log**: `raw/security/deploy_permsets_fls_patch.log`
