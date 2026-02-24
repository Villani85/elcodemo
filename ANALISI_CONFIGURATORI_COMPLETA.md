# Analisi Completa Configuratori ELCO Salesforce

**Data Analisi**: 2026-02-24
**Org**: elco-dev (giuseppe.villani101020.b5bd075bbc5f@agentforce.com)
**Scope**: Verifica conformità ai requisiti tecnici documento "as-built / to-be"

---

## 📊 EXECUTIVE SUMMARY

### Stato Attuale vs. Requisiti

| Configuratore | Stato Implementazione | Conformità Spec | Gap Principali | Priorità Fix |
|---------------|----------------------|-----------------|----------------|--------------|
| **QLI (Quote LineItem)** | ⚠️ **PARZIALE** (30%) | ❌ **NON CONFORME** | Single-screen, no step A→G, no dipendenze flow, no Custom values, no default Account, no VR | 🔴 **ALTA** |
| **TechSpec (Account_Tech_Spec)** | ✅ **ENHANCED BATCH** (100%) | ⚠️ **DIVERSO DA SPEC** | Implementato batch configurator (superiore), manca CRUD manuale base | 🟡 **MEDIA** |

**Verdict**:
- **Configuratore QLI**: Richiede **REDESIGN COMPLETO** per conformità specifica (wizard A→G con 7 schermate)
- **Configuratore TechSpec**: Implementazione **SUPERIORE** alla spec base (batch 4 profili auto-generate), ma manca gestione manuale CRUD per singole specifiche

---

# 1️⃣ CONFIGURATORE QUOTELINEITEM — ANALISI DETTAGLIATA

## 1.1 Stato Attuale (AS-IS)

**Flow**: `Quote_Aggiungi_Riga_Offerta`
**ActiveVersionId**: 301g500000CGdGVAA1
**Quick Action**: Quote.Aggiungi_Riga_Offerta
**Type**: Screen Flow

### Architettura Attuale

```
Start → Get Quote → Screen (Single) → Increment Counter → Create QLI →
  → Set Loop Control → Decision (Loop?) → Success Screen
                                      ↓ (loop back to Screen Single)
```

### Elementi Flow

| Tipo | Count | Nomi |
|------|-------|------|
| Variables | 4 | recordId, addAnother, lineCounter, varQuote |
| Choices | 13 | Tipologia (3), Materiale (5), Spessore (5) - STATIC |
| Screens | 2 | Screen_Add_Line_Item, Screen_Success |
| RecordLookups | 1 | Get_Quote |
| RecordCreates | 1 | Create_QuoteLineItem |
| Assignments | 2 | Increment_Counter, Set_Loop_Control |
| Decisions | 1 | Check_Loop |
| **TOTAL** | **24** | |

### Campi Raccolti (Single Screen)

| Campo UI | Maps to QLI Field | Tipo Component | Required | Default | Problema |
|----------|-------------------|----------------|----------|---------|----------|
| Input_Quantity | Quantity | Number | ✅ Yes | 1.0 | ✅ OK |
| Input_Tipologia_Prodotto | Tipologia_Prodotto__c | Dropdown (static) | ✅ Yes | None | ⚠️ Static choices |
| Input_Materiale | Materiale__c | Dropdown (static) | ❌ No | None | ❌ Static, no filtering |
| Input_Spessore | Spessore_Complessivo__c | Dropdown (static) | ❌ No | None | ❌ Static, no filtering |
| Input_Dimensioni_Array | Dimensioni_Array__c | Text | ❌ No | None | ✅ OK |
| Input_Spessore_Rame | Spessore_Rame_Esterni__c | **Text (!)** | ❌ No | None | ❌ Dovrebbe essere Picklist |
| Input_Solder | Solder_Specifico__c | **Text (!)** | ❌ No | None | ❌ Dovrebbe essere Picklist |
| Input_Silkscreen | Silkscreen_Specifico__c | **Text (!)** | ❌ No | None | ❌ Dovrebbe essere Picklist |
| Input_Finish | Finish__c | **Text (!)** | ❌ No | None | ❌ Dovrebbe essere Picklist |
| Input_Customer_Code | Customer_Circuit_Code__c | Text | ❌ No | None | ✅ OK |
| Input_Add_Another | - | Boolean | ✅ Yes | false | ✅ OK |

**🔴 PROBLEMA CRITICO**: 4 campi picklist (Rame, Solder, Silkscreen, Finish) implementati come **Text free-input** invece di **Picklist UI components** → alto rischio errori utente (typo, valori non standard).

### Campi QuoteLineItem NON Raccolti

**Obbligatori secondo spec §2.4.1 - MANCANTI nel flow**:
- ❌ Tutti i campi marcati "required" nella spec NON sono required nel flow (eccetto Quantity e Tipologia)
- ❌ Nessun campo ha validation client-side

**Campi Custom Value (spec §2.4.4) - TUTTI MANCANTI**:
- ❌ `Materiale_Custom_Value__c` - campo esiste in org, NON gestito in flow
- ❌ `Spessore_Custom_Value__c` - campo esiste in org, NON gestito in flow
- ❌ `Rame_Custom_Value__c` - campo esiste in org, NON gestito in flow

**Campi Avanzati (spec §2.4.2) - CAMPI NON ESISTONO in org**:
- ❌ `Pista_Minima__c` - campo NON esiste
- ❌ `Foro_Minimo__c` - campo NON esiste
- ❌ `Isolamento_Minimo__c` - campo NON esiste
- ❌ `Aspect_Ratio__c` - campo NON esiste

**Campi Storico (spec §2.4.3)**:
- ✅ `Customer_Circuit_Code__c` - presente
- ❌ `Internal_Circuit_Code__c` - campo esiste in org, NON gestito in flow

---

## 1.2 Requisiti Spec (TO-BE)

### Wizard Step-by-Step A→G (spec §2.7)

| Step | Screen Name | Campi | Conditional Visibility | Dipendenze |
|------|-------------|-------|------------------------|------------|
| **A** | Tipologia prodotto | Tipologia_Prodotto__c (required) | No | - |
| **B** | Materiale | Materiale__c (required, filtered by Tipologia)<br>Materiale_Custom_Value__c (conditional) | Show Custom field if Materiale='Custom' | Tipologia → Materiale |
| **C** | Dimensioni + Spessore | Dimensioni_Array__c (required)<br>Spessore_Complessivo__c (required, filtered by Materiale)<br>Spessore_Custom_Value__c (conditional) | Show Custom field if Spessore='Custom' | Materiale → Spessore |
| **D** | Rame + Finish | Spessore_Rame_Esterni__c (required)<br>Rame_Custom_Value__c (conditional)<br>Finish__c (required) | Show Custom field if Rame='Custom' | - |
| **E** | Solder + Silkscreen | Solder_Specifico__c (required)<br>Silkscreen_Specifico__c (required) | No | - |
| **F** | Avanzati | Pista_Minima__c<br>Foro_Minimo__c<br>Isolamento_Minimo__c<br>Aspect_Ratio__c | ALL fields visible only if varShowAdvanced=true | - |
| **G** | Riepilogo + Multi-riga | Display all values<br>varAddAnother (checkbox) | No | - |

**Total Screens**: 7 (vs AS-IS: 2)

### Default da Account (spec §2.4.5)

Prima di mostrare Step A, flow deve:

```
Get Account (via Quote.AccountId)
Assignment "Set_Defaults_From_Account":
  IF Account.Spessore_Default__c != null THEN
    varQLI.Spessore_Complessivo__c = Account.Spessore_Default__c
  IF Account.Finish_Default__c != null THEN
    varQLI.Finish__c = Account.Finish_Default__c
  IF Account.Solder_Default__c != null THEN
    varQLI.Solder_Specifico__c = Account.Solder_Default__c
  IF Account.Silkscreen_Default__c != null THEN
    varQLI.Silkscreen_Specifico__c = Account.Silkscreen_Default__c
```

**Campi Account verified** (tutti esistono):
- ✅ `Spessore_Default__c` (Picklist)
- ✅ `Finish_Default__c` (Picklist)
- ✅ `Solder_Default__c` (Picklist)
- ✅ `Silkscreen_Default__c` (Picklist)

### Validation Rules (spec §2.6)

**3 VR obbligatorie** - NESSUNA IMPLEMENTATA:

**VR-QLI-01 - Materiale Custom**
```
Formula: ISPICKVAL(Materiale__c, 'Custom') && ISBLANK(Materiale_Custom_Value__c)
Message: "Se Materiale = Custom, compilare 'Materiale (Custom value)'."
```

**VR-QLI-02 - Spessore Custom**
```
Formula: ISPICKVAL(Spessore_Complessivo__c, 'Custom') && ISBLANK(Spessore_Custom_Value__c)
Message: "Se Spessore = Custom, compilare 'Spessore (Custom value)'."
```

**VR-QLI-03 - Rame Custom**
```
Formula: ISPICKVAL(Spessore_Rame_Esterni__c, 'Custom') && ISBLANK(Rame_Custom_Value__c)
Message: "Se Rame = Custom, compilare 'Rame (Custom value)'."
```

**Query Result**: 0 validation rules esistenti su QuoteLineItem ❌

### Reset Logic (spec §2.8)

**Quando cambia Tipologia** → Reset:
- `Materiale__c` = null
- `Materiale_Custom_Value__c` = null
- `Spessore_Complessivo__c` = null
- `Spessore_Custom_Value__c` = null

**Quando cambia Materiale** → Reset:
- `Spessore_Complessivo__c` = null
- `Spessore_Custom_Value__c` = null

**Implementazione richiesta**: Flag variables (varTipologiaChanged, varMaterialeChanged) + Decision elements

---

## 1.3 Data Model Verification

### Campi QuoteLineItem Custom (13 fields totali)

| Campo API Name | Type | Dependent? | Custom Value Field | Exists? | In Flow? |
|----------------|------|------------|-------------------|---------|----------|
| Tipologia_Prodotto__c | Picklist (restricted) | Controller | - | ✅ Yes | ✅ Yes |
| Materiale__c | Picklist (restricted) | ← Tipologia | Materiale_Custom_Value__c | ✅ Yes | ⚠️ Static |
| Materiale_Custom_Value__c | Text(255) | - | - | ✅ Yes | ❌ No |
| Spessore_Complessivo__c | Picklist (restricted) | ← Materiale | Spessore_Custom_Value__c | ✅ Yes | ⚠️ Static |
| Spessore_Custom_Value__c | Text(255) | - | - | ✅ Yes | ❌ No |
| Spessore_Rame_Esterni__c | Picklist (restricted) | - | Rame_Custom_Value__c | ✅ Yes | ❌ No (Text) |
| Rame_Custom_Value__c | Text(255) | - | - | ✅ Yes | ❌ No |
| Finish__c | Picklist (restricted) | - | - | ✅ Yes | ❌ No (Text) |
| Solder_Specifico__c | Picklist (restricted) | - | - | ✅ Yes | ❌ No (Text) |
| Silkscreen_Specifico__c | Picklist (restricted) | - | - | ✅ Yes | ❌ No (Text) |
| Dimensioni_Array__c | Text(80) | - | - | ✅ Yes | ✅ Yes |
| Customer_Circuit_Code__c | Text(80) | - | - | ✅ Yes | ✅ Yes |
| Internal_Circuit_Code__c | Text(80) | - | - | ✅ Yes | ❌ No |

**Conclusione**: ✅ Data model COMPLETO (tutti i campi spec esistono in org), ma ❌ Flow usage PARZIALE.

### Dependent Picklist Metadata

**Tipologia → Materiale**:
```
Rigido → FR-4 Standard, FR-4 High Tg, Rogers, Alluminio (Metal Core), CEM-1, CEM-3, Custom
Flessibile → Polyimide, Custom
Rigido-Flessibile → FR-4 Standard, FR-4 High Tg, Polyimide, Custom
```
✅ **Metadata dependency CORRETTA** - ma flow usa static choices (non sfrutta dependency)

**Materiale → Spessore**:
```
FR-4 Standard/High Tg → 0.4, 0.6, 0.8, 1.0, 1.2, 1.6, 2.0, 2.4, 3.2, Custom (10 valori)
Rogers → 0.8, 1.6, Custom (3 valori)
Alluminio → 1.0, 1.6, Custom (3 valori)
Polyimide → 0.4, 0.6, 0.8, 1.0, Custom (5 valori)
CEM-1/CEM-3 → 1.0, 1.6, Custom (3 valori)
Custom → Custom (1 valore)
```
✅ **Metadata dependency CORRETTA** - ma flow usa static choices (non sfrutta dependency)

### Product & PricebookEntry

**Product PCB_CUSTOM**:
- ID: 01tg50000031n1lAAA
- Name: PCB Custom
- ProductCode: PCB_CUSTOM
- IsActive: true
- ✅ **PRESENTE e ATTIVO**

**PricebookEntry (Standard PB)**:
- ID: 01ug5000000mmbpAAA
- Product2Id: 01tg50000031n1lAAA
- Pricebook2Id: 01sg50000028RoIAAU
- UnitPrice: 0.0
- ✅ **PRESENTE e CONFIGURATO**

**Flow Implementation**:
```xml
<field>PricebookEntryId</field>
<value><stringValue>01ug5000000mmbpAAA</stringValue></value>
```
⚠️ **HARDCODED** - Non conforme spec §2.3 (richiede dynamic lookup con fallback a Standard PB)

---

## 1.4 GAP ANALYSIS - QLI Configuratore

### ❌ Gap Critici (Bloccanti Go-Live)

| # | Gap | Impatto | Spec | Effort | Severity |
|---|-----|---------|------|--------|----------|
| **G1** | **Single screen invece di wizard A→G (7 screens)** | 🔴 ALTO | §2.7 | 5 giorni | CRITICAL |
| **G2** | **4 campi Picklist implementati come Text free-input** | 🔴 ALTO | §2.4.1 | 1 giorno | CRITICAL |
| **G3** | **Nessuna gestione Custom values (3 campi)** | 🔴 ALTO | §2.4.4 | 2 giorni | CRITICAL |
| **G4** | **Nessun default da Account (4 campi)** | 🔴 MEDIO | §2.4.5 | 1 giorno | HIGH |
| **G5** | **Validation Rules mancanti (3 VR)** | 🔴 ALTO | §2.6 | 1 giorno | CRITICAL |
| **G6** | **Dipendenze picklist non sfruttate (static choices)** | 🔴 ALTO | §2.5 | (in G1) | CRITICAL |
| **G7** | **Reset logic mancante** | 🟡 MEDIO | §2.8 | (in G1) | MEDIUM |
| **G8** | **Campi avanzati opzionali (Step F) - campi non esistono** | 🟡 BASSO | §2.7.6 | 0.5 giorni | LOW |
| **G9** | **PBE hardcoded invece di dynamic lookup** | 🟡 MEDIO | §2.3 | 1 giorno | MEDIUM |
| **G10** | **Internal_Circuit_Code__c non raccolto** | 🟢 BASSO | §2.4.3 | 5 min | LOW |
| **G11** | **Fault path error handling mancante** | 🟡 MEDIO | §2.9.3 | 1 giorno | MEDIUM |

**Total Critical Gaps**: 7 (G1-G7)
**Total Effort to Fix**: 10-12 giorni developer

### ✅ Conformità Parziali

| Feature | Status | Note |
|---------|--------|------|
| Multi-riga loop | ✅ OK | Funziona con varAddAnother, incrementa counter correttamente |
| Quote lookup | ✅ OK | Get_Quote recupera record e display nome |
| QuoteId assignment | ✅ OK | recordId mappato correttamente |
| Success screen | ✅ OK | Mostra count righe + link a Quote |
| Customer_Circuit_Code | ✅ OK | Campo raccolto e salvato |
| Basic flow structure | ✅ OK | Start/Screens/Decision/Create funziona |

---

## 1.5 Test di Accettazione - Risultati

**Test spec §2.10**:

| # | Test | AS-IS Result | TO-BE Expected | Pass? |
|---|------|--------------|----------------|-------|
| **T1** | Creazione 1 riga completa + default Account | ⚠️ Riga creata, ma NO default | Default Spessore/Finish/Solder/Silkscreen copiati | ❌ FAIL |
| **T2** | Multi-riga crea 2+ QLI e ricarica default | ⚠️ Multi-riga OK, ma default non esistono | Loop funziona, default ricaricati ogni iterazione | ⚠️ PARTIAL |
| **T3** | Picklist dipendenti: Tipologia=Flessibile limita Materiale | ❌ Mostra tutti i materiali (static) | Solo Polyimide e Custom visibili | ❌ FAIL |
| **T4** | Custom values: Spessore=Custom senza value blocca | ❌ Salva con null (no validation) | Validation Rule blocca + messaggio chiaro | ❌ FAIL |

**Success Rate**: 0/4 (0%) ❌ **NESSUN TEST PASSA**

---

## 1.6 Raccomandazioni - QLI Configuratore

### ⭐ OPZIONE 1: REDESIGN COMPLETO (RACCOMANDATO)

**Effort**: 10-12 giorni full-time developer
**Risk**: Medio (testing estensivo richiesto)
**Benefit**: 100% conformità spec, UX ottimale, error-proof

#### Implementation Roadmap

**Week 1 (Giorni 1-5)**:
1. **Day 1-2**: Creare structure wizard A→G (7 screens + navigation)
2. **Day 3**: Implementare Account default loading (Get Account + Assignment)
3. **Day 4**: Screen B-C con dynamic picklist dependencies (Tipologia→Materiale→Spessore)
4. **Day 5**: Custom value fields con conditional visibility (3 campi)

**Week 2 (Giorni 6-10)**:
5. **Day 6**: Reset logic (Decision + Assignment elements per change detection)
6. **Day 7**: Validation Rules (3 VR) + Fault paths
7. **Day 8**: Advanced fields (Step F) + PBE dynamic lookup
8. **Day 9**: Testing completo (T1-T4 + edge cases)
9. **Day 10**: Bug fixing + documentation

#### Deliverables

✅ Flow A→G (7 screens) con Back/Next navigation
✅ Get Account → Set defaults (4 campi)
✅ Dynamic picklist filtering (Tipologia→Materiale, Materiale→Spessore)
✅ Custom value conditional visibility (3 campi)
✅ Reset logic su driver change
✅ 3 Validation Rules (VR-QLI-01/02/03)
✅ PBE dynamic lookup con fallback
✅ Advanced fields (Step F) optional
✅ Fault path error handling
✅ Test T1-T4 PASSED (100%)

#### Acceptance Criteria

- ✅ Test T1: Default Account caricati all'inizio wizard
- ✅ Test T2: Multi-riga crea N QLI, default ricaricati ogni loop
- ✅ Test T3: Tipologia=Flessibile mostra SOLO Polyimide e Custom
- ✅ Test T4: Spessore=Custom senza value blocca con messaggio chiaro
- ✅ Backward navigation funziona senza data loss
- ✅ Custom values validati (sia client-side che VR)

---

### ⚠️ OPZIONE 2: INCREMENTAL FIX (Non Raccomandato)

**Effort**: 5-6 giorni
**Risk**: Basso
**Benefit**: Risolve gap G2-G5, mantiene single-screen

**Limiti**: NON risolve G1 (wizard), NON risolve G6 (dipendenze dinamiche)
**Conformità Finale**: ~60% (vs 100% Option 1)

---

# 2️⃣ CONFIGURATORE TECH SPEC — ANALISI DETTAGLIATA

## 2.1 Stato Attuale (AS-IS)

**Flow**: `Gestisci_Specifiche_Tecniche`
**ActiveVersionId**: 301g500000CVoDqAAL (Version 8)
**Quick Action**: Account.Gestisci_Specifiche_Tecniche
**Type**: Screen Flow
**Implementation Mode**: **BATCH CONFIGURATOR** (Enhanced)

### Architettura Attuale

```
Start → Screen_Select_PCB_Type (4 radio buttons) → Screen_Confirm →
  → Decision_Route_By_Type (4 branches) →
  → [76 Assignment elements build collection] →
  → RecordCreate (batch insert 19 specs) →
  → Screen_Success
```

### Elementi Flow (87 total)

| Tipo | Count | Details |
|------|-------|---------|
| Variables | 4 | recordId, varPCBType, colSpecs (collection), varTempSpec |
| Choices | 4 | PCB_Standard, PCB_HighTg, PCB_Automotive, PCB_Medical |
| Screens | 3 | Select type, Confirm, Success |
| Decisions | 1 | Route by type (4 rules: STANDARD/HIGH_TG/AUTOMOTIVE/MEDICAL) |
| Assignments | 77 | 1 type assignment + 76 spec builders (4 profiles × 19 each) |
| RecordCreates | 4 | One per profile, batch insert colSpecs collection |
| **TOTAL** | **93** | Complex batch configurator |

### PCB Profiles Implementati

| Profile | Specs Created | Key Specs | Conformità Spec §3.5 |
|---------|--------------|-----------|---------------------|
| **STANDARD** | 19 | FR4, 1.6mm, ±10%, IPC Class 2, Tg 130-140°C, Halogen: No | ✅ Enhanced mode |
| **HIGH-TG** | 19 | FR4 High-Tg (170°C), ±8%, IPC Class 2, RoHS + ISO 9001 | ✅ Enhanced mode |
| **AUTOMOTIVE** | 20 | Halogen-Free, Tg 180°C, IPC Class 3, IATF 16949, QR+EAN-13 | ✅ Enhanced mode |
| **MEDICAL** | 18 | Halogen-Free Medical, ISO 13485, board 400×300mm (smaller) | ✅ Enhanced mode |

**All specs auto-generated** with:
- `Account__c = recordId`
- `Is_Active__c = true`
- `Source__c = "Configuratore Automatico"`
- Category + Parameter + Value + UoM predefined

---

## 2.2 Requisiti Spec (TO-BE)

### Modalità BASE (spec §3.4) - ❌ MANCANTE

**CRUD manuale richiesto**:

```
Screen 1 - Lista:
  Get Records: Account_Tech_Spec__c (Is_Active=true)
  Data Table: Category, Parameter, Value, UoM, Source, Attivo
  Buttons: [Nuovo] [Modifica] [Disattiva]

Screen 2 - Form (Nuovo/Modifica):
  Category__c (picklist, required)
  Parameter__c (picklist dependent on Category, required)
  Value__c (text, required)
  UoM__c (picklist, optional)
  Source__c (picklist, optional)
  Notes__c (long text, optional)

Action Disattiva:
  Update: Is_Active__c = false (NO delete)
```

**Status AS-IS**: ❌ **NON IMPLEMENTATO** (solo Enhanced batch mode)

### Modalità ENHANCED (spec §3.5) - ✅ IMPLEMENTATO

**Batch configurator**: ✅ GIÀ IMPLEMENTATO con 4 profili PCB

**Gestione duplicati richiesta** (spec §3.5.2):
- Checkbox "Sovrascrivi valori esistenti"
- Se true: Update existing (same Category+Parameter)
- Se false: Skip (mark as "saltato")

**Status AS-IS**: ⚠️ **PARZIALE** - batch OK, manca duplicate detection

---

## 2.3 Data Model Verification - Account_Tech_Spec__c

### Campi Custom (11 totali)

| Campo API Name | Type | Required? | Dependent? | Exists? | In Enhanced Flow? |
|----------------|------|-----------|------------|---------|-------------------|
| Account__c | Lookup(Account) | ✅ Yes | - | ✅ Yes | ✅ Yes |
| Category__c | Picklist | ✅ Yes | Controller | ✅ Yes | ✅ Yes (hardcoded) |
| Parameter__c | Picklist | ✅ Yes | ← Category | ✅ Yes | ✅ Yes (hardcoded) |
| Value__c | Text(255) | ✅ Yes | - | ✅ Yes | ✅ Yes (hardcoded) |
| UoM__c | Picklist | ❌ No | - | ✅ Yes | ✅ Yes (hardcoded) |
| Source__c | Picklist | ❌ No | - | ✅ Yes | ✅ Yes (="Configuratore Automatico") |
| Notes__c | LongTextArea(32768) | ❌ No | - | ✅ Yes | ⚠️ Optional (rare use) |
| Is_Active__c | Checkbox | ❌ No | - | ✅ Yes | ✅ Yes (=true) |

✅ **Data model COMPLETO e CONFORME** spec §3.2

### Dependent Picklist - Category → Parameter

**7 Categories → 42 Parameters total**:

| Category | Params | Sample Parameters |
|----------|--------|-------------------|
| **Materiali** | 5 | Materiale principale, Materiale alternativo, Tg richiesto, Halogen free, UL requirement |
| **Dimensioni & Tolleranze** | 6 | Dimensione max/min, Tolleranza dimensionale/spessore, Spessore target, Peso max |
| **Confezionamento / Imballo** | 10 | Confezione primaria/secondaria, Materiale busta/scatola, Numero pezzi, Riempitivo, Separazione, Palletizzazione, Filmatura |
| **Etichettatura** | 5 | Etichetta interna/esterna, Barcode, QR code, Etichetta cliente |
| **Documentazione** | 5 | Packing list, Certificato conformità/materiali, Report test, Altro documento |
| **Qualità & Certificazioni** | 5 | ISO richiesto, RoHS, REACH, ITAR, Altro requisito qualità |
| **Note Commerciali / Preferenze** | 5 | Lotto minimo, Lead time preferito, Incoterm, Trasporto preferito, Note aggiuntive |

✅ **Dependency CORRETTA** - metadata conforme spec §3.2.3

---

## 2.4 GAP ANALYSIS - TechSpec Configuratore

### ❌ Gap vs Spec BASE (CRUD Manuale)

| # | Gap | Impatto | Spec | Effort | Severity |
|---|-----|---------|------|--------|----------|
| **G12** | **Nessuna modalità CRUD manuale** | 🟡 MEDIO | §3.4 | 3 giorni | MEDIUM |
| **G13** | **Nessuna lista specs esistenti + Edit in-flow** | 🟡 MEDIO | §3.4.2 | (in G12) | MEDIUM |
| **G14** | **Nessuna disattivazione singola in-flow** | 🟢 BASSO | §3.4.2 | (in G12) | LOW |
| **G15** | **Nessuna gestione duplicati (Enhanced)** | 🟡 MEDIO | §3.5.2 | 1 giorno | MEDIUM |
| **G16** | **Nessun checkbox "Sovrascrivi"** | 🟢 BASSO | §3.5.2 | (in G15) | LOW |

**Total Effort to Fix**: 3-4 giorni

**Workaround AS-IS** (accettabile?):
- Edit singola spec: ✅ Via Edit page standard (click nome spec in related list)
- Disattiva spec: ✅ Via Edit page (checkbox Is_Active)
- Lista specs: ✅ Via Related List "Specifiche Tecniche" su Account

### ✅ Conformità Enhanced Mode (SUPERIORE a spec base)

| Feature | Status | Spec §3.5 |
|---------|--------|-----------|
| Batch generation 4 profili | ✅ SUPERIORE | ✅ Richiesto |
| 19 specs per profilo | ✅ OK | ✅ Implied |
| Source tracking | ✅ OK | ✅ Richiesto |
| Is_Active flag | ✅ OK | ✅ Richiesto |
| Collection-based Create (1 DML) | ✅ EFFICIENT | ⚠️ Non specificato (best practice) |
| Error-proof (no manual input) | ✅ SUPERIORE | ⚠️ Non specificato (benefit) |

---

## 2.5 Raccomandazioni - TechSpec Configuratore

### ⭐ OPZIONE 1: DUE FLOW SEPARATI (RACCOMANDATO)

**Effort**: 3-4 giorni developer
**Risk**: Basso
**Benefit**: 100% conformità + mantieni enhanced

#### Implementation Plan

**Step 1**: Rinominare flow attuale (15 min)
- `Gestisci_Specifiche_Tecniche` → `TechSpec_Configuratore_Batch`
- Quick Action: "Configura PCB (Automatico)"

**Step 2**: Creare nuovo flow CRUD (3 giorni)
- Flow: `TechSpec_Gestione_Manuale`
- Screen 1: Data Table + Get Records (Is_Active=true)
- Screen 2: Form con Category→Parameter dependency
- Create/Update/Deactivate paths
- Fault handling

**Step 3**: Gestione duplicati Enhanced (1 giorno)
- Add checkbox `varOverwriteExisting` in Screen_Confirm
- Get existing specs before Create
- Decision: Skip/Update/Create based on checkbox
- Screen_Success: "create: X, update: Y, skip: Z"

**Step 4**: Quick Actions separate (30 min)
- Account.Configura_PCB_Automatico
- Account.Gestisci_Specifiche_Manuale

**Step 5**: Documentation (30 min)

#### Deliverables

✅ Flow CRUD manuale completo (nuovo)
✅ Flow Enhanced con duplicate mgmt (migliorato)
✅ 2 Quick Actions su Account
✅ User Guide (quando usare Auto vs Manuale)

---

### ⚠️ OPZIONE 3: MANTIENI SOLO ENHANCED (Accettabile con doc)

**Effort**: 1 giorno (solo duplicate mgmt)
**Risk**: Basso
**Benefit**: Zero disruption

**Changes**:
- Aggiungi gestione duplicati (Step 3 Option 1)
- Documenta limitazione: "No single-spec CRUD, use Edit page workaround"

**Limiti accettabili**:
- Edit singola: Via standard edit page (click related list)
- Disattiva singola: Via edit page checkbox
- Lista specs: Via related list

---

# 3️⃣ SUMMARY TABLES

## Configuratore QLI - Conformità Spec

| Requirement | AS-IS | TO-BE | Gap | Effort |
|-------------|-------|-------|-----|--------|
| Wizard A→G (7 screens) | ❌ 1 screen | 7 screens | 🔴 CRITICAL | 5 giorni |
| Picklist UI components | ⚠️ 4 Text | All Picklist | 🔴 CRITICAL | 1 giorno |
| Dynamic dependencies | ❌ Static | Dynamic filter | 🔴 CRITICAL | (in wizard) |
| Custom values (3 fields) | ❌ None | Conditional visibility | 🔴 CRITICAL | 2 giorni |
| Account defaults (4 fields) | ❌ None | Pre-filled | 🔴 HIGH | 1 giorno |
| Validation Rules (3 VR) | ❌ 0/3 | 3 VR | 🔴 HIGH | 1 giorno |
| Reset logic | ❌ None | On driver change | 🟡 MEDIUM | (in wizard) |
| Advanced fields (Step F) | ❌ None | Optional 4 fields | 🟢 LOW | (in wizard) |
| PBE dynamic lookup | ❌ Hardcoded | Get + fallback | 🟡 MEDIUM | 1 giorno |
| Multi-riga loop | ✅ OK | With reload | ✅ OK | 0 giorni |
| **CONFORMITÀ** | **30%** | **100%** | **70% gap** | **10-12 giorni** |

## Configuratore TechSpec - Conformità Spec

| Requirement | AS-IS | TO-BE | Gap | Effort |
|-------------|-------|-------|-----|--------|
| CRUD manuale (Base) | ❌ None | Full CRUD | 🟡 MEDIUM | 3 giorni |
| Batch configurator (Enhanced) | ✅ 4 profili | 4 profili | ✅ OK | 0 giorni |
| Duplicate management | ❌ None | Checkbox + logic | 🟡 MEDIUM | 1 giorno |
| Category→Parameter dependency | ✅ Metadata | Dynamic UI | ⚠️ Need in CRUD | (in CRUD) |
| Source tracking | ✅ OK | Auto-set | ✅ OK | 0 giorni |
| **CONFORMITÀ** | **60%** | **100%** | **40% gap** | **3-4 giorni** |

---

# 4️⃣ ROADMAP IMPLEMENTAZIONE

## Timeline Raccomandato

### 🔴 PRIORITY 1 - QLI Redesign (2 settimane)

**Week 1**:
- Day 1-2: Wizard structure A→G
- Day 3: Account defaults
- Day 4: Dynamic picklists
- Day 5: Custom values

**Week 2**:
- Day 6: Reset logic
- Day 7: Validation Rules
- Day 8: Advanced + PBE
- Day 9-10: Testing

### 🟡 PRIORITY 2 - TechSpec CRUD (1 settimana, può parallelizzare)

**Week 1**:
- Day 1-3: Nuovo flow CRUD
- Day 4: Duplicate mgmt Enhanced
- Day 5: QA + Documentation

## Effort Summary

| Work Package | Days | Dev | Parallel? |
|--------------|------|-----|-----------|
| QLI Redesign | 10 | Dev 1 | Sequential |
| TechSpec CRUD | 4 | Dev 2 | ✅ Yes |
| Testing | 2 | QA | Partial |
| **TOTAL (1 dev)** | **12** | - | Sequential |
| **TOTAL (2 dev)** | **10** | - | Parallel |

---

# 5️⃣ CONCLUSIONI

## Verdict Finale

### Configuratore QLI
**Status**: ❌ **NON CONFORME** (30% conformità)
**Raccomandazione**: 🔴 **REDESIGN COMPLETO OBBLIGATORIO**
**Effort**: 10-12 giorni full-time developer
**Go-Live**: ❌ **NO-GO** senza redesign

### Configuratore TechSpec
**Status**: ✅ **ENHANCED IMPLEMENTATO** (60% conformità spec completa)
**Raccomandazione**: 🟡 **AGGIUNGERE CRUD MANUALE** (raccomandato ma non bloccante)
**Effort**: 3-4 giorni developer
**Go-Live**: ✅ **GO with limitations** (doc workaround Edit page)

## Decision Matrix

| Scenario | Go-Live? | Condition |
|----------|----------|-----------|
| **QLI Redesign completo** | ✅ GO | Tests T1-T4 passed, VR active |
| **QLI AS-IS** | ❌ NO-GO | Non conforme, error-prone |
| **TechSpec 2 Flow** | ✅ GO | Full spec compliance |
| **TechSpec Enhanced only** | ✅ GO with doc | Document limitations |

---

**Report generato**: 2026-02-24
**Org**: elco-dev
**Versione**: 1.0 Final
**Prossima Revisione**: Post-implementation (2-3 settimane dopo fix)
