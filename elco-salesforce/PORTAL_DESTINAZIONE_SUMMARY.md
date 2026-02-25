# Portal Destinazione - Quick Summary

## ✅ Deploy Completato

**3 Deploy Phases** - Tutti SUCCESS ✅

| Phase | Components | Deploy ID | Status |
|-------|------------|-----------|--------|
| 1 | Field + ValidationRule + PermissionSet | 0AfgK00000GlZ7ZSAV | ✅ |
| 2a | QuickAction | 0AfgK00000GlZ9BSAV | ✅ |
| 2b | ListView | 0AfgK00000GlZIrSAN | ✅ |

---

## 📦 Cosa è stato fatto

### 1. Campo Custom: Destinazione__c
- Lookup ad Account
- Label: "Destinazione"
- Rappresenta: Asilo, Biblioteca, Caserma, Municipio, ecc.

### 2. Validation Rule: VR_Destinazione_Obbligatoria_RI
- Destinazione obbligatoria per RecordType "Richiesta di Intervento"
- Messaggio errore: "Seleziona una destinazione (servizio o struttura comunale)."

### 3. PermissionSet: PS_TestMoro_Case_Destinazione
- FLS: Case.Destinazione__c (read + edit)
- Object: Account (read) - per lookup
- Object: Case (create + read + edit)

### 4. QuickAction aggiornata
- ❌ Rimosso: AccountId
- ✅ Aggiunto: Destinazione__c

### 5. ListView aggiornata
- ✅ Colonna Destinazione visibile

---

## 🔧 Comandi Deploy Eseguiti

```bash
# Phase 1
cd "D:\Elco Demo\elco-salesforce"
sf project deploy start -o orgfarm-packaging \
  --manifest manifest/portal_destinazione_phase1.xml --wait 10

# Phase 2 (QuickAction + ListView)
sf project deploy start -o orgfarm-packaging \
  -m QuickAction:NewCommunityCase_RI --wait 10

sf project deploy start -o orgfarm-packaging \
  -m ListView:Case.Portal_Richieste_Intervento --wait 10
```

---

## ⚙️ POST-DEPLOY TODO (UI)

### 1. Assegnare PermissionSet
```
Setup → Permission Sets → PS_TestMoro_Case_Destinazione →
Manage Assignments → Add [utenti Community]
```

### 2. Creare Account Destinazione
```
Account → New:
- Asilo Comunale
- Biblioteca Civica
- Caserma Carabinieri
- Municipio
```

### 3. Configurare Sharing Account
```
Setup → Digital Experiences → Sharing Sets → New:
Target: Case
Account Access: Read/Write
Criteria: Type = 'Community Service'
```

---

## 🧪 Test

### Portal Test URL
https://orgfarm-c5ba1be235-dev-ed.develop.my.site.com/testMoro/s/contactsupport

### Test 1: Form senza Destinazione
1. Compila Subject + Description (NO Destinazione)
2. Submit
3. **Verifica**: ❌ Errore validation

### Test 2: Form con Destinazione
1. Seleziona Destinazione (es. Asilo)
2. Compila Subject + Description
3. Submit
4. **Verifica**: ✅ Case creato

### Test 3: Lista
https://orgfarm-c5ba1be235-dev-ed.develop.my.site.com/testMoro/s/case

**Verifica**: Colonna Destinazione visibile ✅

---

## 📄 Files Modificati

**Creati**:
- `objects/Case/fields/Destinazione__c.field-meta.xml`
- `objects/Case/validationRules/VR_Destinazione_Obbligatoria_RI.validationRule-meta.xml`
- `permissionsets/PS_TestMoro_Case_Destinazione.permissionset-meta.xml`
- `manifest/portal_destinazione_phase1.xml`
- `manifest/portal_destinazione_phase2.xml`

**Modificati**:
- `quickActions/NewCommunityCase_RI.quickAction-meta.xml`
- `objects/Case/listViews/Portal_Richieste_Intervento.listView-meta.xml`

---

## 🎯 Commit Command

```bash
git add force-app/main/default/objects/Case/fields/Destinazione__c.field-meta.xml
git add force-app/main/default/objects/Case/validationRules/VR_Destinazione_Obbligatoria_RI.validationRule-meta.xml
git add force-app/main/default/permissionsets/PS_TestMoro_Case_Destinazione.permissionset-meta.xml
git add force-app/main/default/quickActions/NewCommunityCase_RI.quickAction-meta.xml
git add force-app/main/default/objects/Case/listViews/Portal_Richieste_Intervento.listView-meta.xml
git add manifest/portal_destinazione_phase1.xml
git add manifest/portal_destinazione_phase2.xml
git add PORTAL_DESTINAZIONE_REQUIRED_DEPLOY.md
git add PORTAL_DESTINAZIONE_SUMMARY.md

git commit -m "feat(portal): Destinazione obbligatoria per Richieste di Intervento

- Campo custom Destinazione__c (Lookup Account)
- Validation Rule per obbligatorietà (solo RecordType RI)
- PermissionSet per FLS e Account read
- QuickAction aggiornata con campo Destinazione
- ListView mostra colonna Destinazione

Deploy IDs:
- Phase 1: 0AfgK00000GlZ7ZSAV (Field+VR+PS)
- Phase 2a: 0AfgK00000GlZ9BSAV (QuickAction)
- Phase 2b: 0AfgK00000GlZIrSAN (ListView)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

**Documentazione completa**: `PORTAL_DESTINAZIONE_REQUIRED_DEPLOY.md`
