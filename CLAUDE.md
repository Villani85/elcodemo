# Istruzioni per Claude - Progetto Elco Salesforce

**Questo file contiene istruzioni specifiche per Claude (AI) su come interpretare e lavorare con questo repository.**

---

## 🎯 Contesto Progetto

Questo è un progetto Salesforce DX per la gestione di preventivi PCB (Printed Circuit Board) custom con integrazione CRIF per valutazione creditizia clienti.

### Org Target
- **Alias**: `elco-dev`
- **Username**: giuseppe.villani101020.b5bd075bbc5f@agentforce.com
- **Instance**: orgfarm-ebbb80388b-dev-ed.develop.my.salesforce.com
- **API Version**: 65.0

---

## 📚 Documenti Chiave da Leggere

### Priorità di Lettura

1. **PRIMA** → `org_state.md`
   - Leggi per capire storia implementazione (P0-P6)
   - Contiene comandi eseguiti, Deploy ID, verifiche
   - Sezione P0 documenta scope configuration-only vs componenti frozen

2. **SECONDA** → `struttura.md`
   - Architettura dettagliata
   - Inventario completo metadata (78 fields, 10 flows, ecc.)
   - Note tecniche e limitazioni

3. **TERZA** → `elco-salesforce/raw/p*/`
   - Artifacts implementazione per fase
   - Reports, logs, verifiche specifiche

### File da NON Leggere (Frozen/Out-of-Scope)

❌ NON implementare o deployare:
- Flow in `elco-salesforce/force-app/main/default/flows/` (10 files)
- Quick Actions in `quickActions/` (11 files)
- FlexiPages in `flexipages/` (2 files)
- Apex Classes in `classes/` (9 files)

**Motivo**: Questi componenti esistono da fasi P1-P6 ma sono FROZEN per vincolo P0 configuration-only. Esistono nel repo solo come reference/documentation.

---

## 🔧 Convenzioni e Best Practices

### Comandi Salesforce CLI

**Sempre usare**:
```bash
sf org display -o elco-dev              # Info org
sf data query -o elco-dev -q "..."      # Query SOQL
sf project deploy start -o elco-dev ... # Deploy metadata
sf project retrieve start -o elco-dev ...# Retrieve metadata
```

**MAI usare**:
- `sfdx` (deprecated, usa `sf`)
- `force:source:*` (legacy, usa `project deploy/retrieve`)

### Git Workflow

**Commit Message Convention**:
```
<prefix>: <summary>

<description>

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Prefixes usati**:
- `P0:` - Configuration baseline
- `P1-P6:` - Implementation phases
- `security:` - Security fixes
- `docs:` - Documentation only
- `fix:` - Bug fixes

### Documentazione

**Quando modifichi metadata**:
1. Aggiorna `org_state.md` con nuova sezione timestampata
2. Aggiungi comandi eseguiti, Deploy ID, verifiche
3. Se cambia struttura, aggiorna anche `struttura.md`

**Format timestamp**: `2026-02-21 10:09 CET`

---

## 🚫 Vincoli P0 (IMPORTANTE)

Il progetto è attualmente in stato **P0 - Configuration Baseline**.

### ✅ Cosa PUOI fare:
- Modificare Settings (QuoteSettings, ecc.)
- Aggiungere/modificare Custom Objects e Fields
- Configurare Products e PricebookEntries
- Aggiungere Picklist values e Field Dependencies
- (Opzionale) Validation Rules solo se indispensabili

### ❌ Cosa NON PUOI fare:
- Deployare o modificare Flows
- Deployare o modificare Quick Actions
- Deployare o modificare FlexiPages
- Deployare o modificare Apex/LWC
- Implementare wizard "Offerta" o automazioni

**Se l'utente chiede di implementare Flow/Actions/Pages/Apex**:
Ricorda che sono frozen per P0. Proponi alternative configuration-only o chiedi conferma se vuole passare a fase post-P0.

---

## 📋 Task Comuni e Come Eseguirli

### Verificare Stato Org

```bash
# Auth check
sf org display -o elco-dev

# Check Quotes enabled
sf data query -o elco-dev --use-tooling-api \
  -q "SELECT QualifiedApiName FROM EntityDefinition WHERE QualifiedApiName IN ('Quote','QuoteLineItem')"

# Check Custom Objects
sf data query -o elco-dev --use-tooling-api \
  -q "SELECT QualifiedApiName, Label FROM EntityDefinition WHERE QualifiedApiName LIKE '%__c'"

# Check Products
sf data query -o elco-dev \
  -q "SELECT Id, Name, ProductCode FROM Product2 WHERE ProductCode = 'PCB_CUSTOM'"
```

### Deploy Metadata (Configuration Only)

```bash
# Deploy Settings
sf project deploy start -o elco-dev --metadata "Settings:Quote"

# Deploy Custom Fields
sf project deploy start -o elco-dev --metadata "CustomField:Account.FieldName__c"

# Deploy Custom Object
sf project deploy start -o elco-dev --metadata "CustomObject:Account_Tech_Spec__c"
```

### Retrieve Metadata per Verifica

```bash
# Retrieve specific metadata
sf project retrieve start -o elco-dev --metadata "Settings:Quote" --target-metadata-dir verify/

# Retrieve object definition
sf project retrieve start -o elco-dev --metadata "CustomObject:Account_Tech_Spec__c" --target-metadata-dir verify/
```

---

## 🗂️ Struttura Repository Spiegata

```
elcodemo/
├── org_state.md          # 📖 Storia implementazione + stato org
├── struttura.md          # 🏗️ Architettura + inventario metadata
├── README.md             # 📋 Overview progetto (per umani)
├── CLAUDE.md             # 🤖 Istruzioni per Claude (questo file)
│
├── elco-salesforce/      # 📦 Progetto Salesforce DX
│   ├── force-app/main/default/
│   │   ├── classes/      # 🚫 Apex (9 files) - FROZEN, non deployare
│   │   ├── flows/        # 🚫 Flows (10 files) - FROZEN, non deployare
│   │   ├── quickActions/ # 🚫 Quick Actions (11 files) - FROZEN, non deployare
│   │   ├── flexipages/   # 🚫 FlexiPages (2 files) - FROZEN, non deployare
│   │   ├── objects/      # ✅ Custom Objects + Fields - OK modificare
│   │   ├── layouts/      # ✅ Page Layouts - OK modificare (solo field sections)
│   │   └── settings/     # ✅ Settings - OK modificare/deployare
│   │
│   ├── raw/              # 📂 Artifacts implementazione
│   │   ├── p0/           # ❌ Non esiste - P0 fatto in /tmp/
│   │   ├── crif_p1/      # P1: CRIF fields + permission sets
│   │   ├── crif_p2/      # P2: CRIF flows + actions (FROZEN)
│   │   ├── offerta_p3/   # P3: Quote flows + actions (FROZEN)
│   │   ├── p4/           # P4: TechSpec + Visit (FROZEN)
│   │   ├── p5/           # P5: UX/Layouts
│   │   ├── p5_fix/       # P5 fix: Account/Opportunity layouts
│   │   ├── p5_cli_finish/# P5 CLI: Quote/Visit actions
│   │   ├── p6/           # P6: Demo pack
│   │   └── new_account_flow_only/ # New Account Flow (FROZEN)
│   │
│   ├── scripts/          # 🛠️ Script utility
│   │   ├── apex/         # Script Apex (demo_seed.apex)
│   │   └── *.py          # Script Python (patch, normalize, select)
│   │
│   └── sfdx-project.json # Configurazione SFDX
│
└── .gitignore            # Git ignore (org_display.json, secrets)
```

---

## 🔍 Come Interpretare org_state.md

### Struttura Sezioni

```markdown
# Elco Salesforce Org State - P0 Configuration Baseline

## P0 - Configuration Baseline ✅ COMPLETE
[Ultima fase implementata - LEGGERE PER PRIMA]

## FUORI PERIMETRO - STOP QUI
[32 componenti frozen - NON deployare]

## Previous Implementation Phases (P1-P6) - REFERENCE ONLY
[Storia precedente - leggere per contesto]

### P1 Security baseline
### CRIF P1
### CRIF P2
### OFFERTA P3
### P4 - TechSpec + Visite
### P5 - UX/Account 360
### P6 - Demo Pack
### New Account Flow
```

### Leggere le Sezioni

1. **Leggi P0 FIRST** → capire scope attuale
2. **Leggi FUORI PERIMETRO** → capire cosa NON fare
3. **Sfoglia P1-P6** → contesto storico (se necessario)

---

## 🎨 Pattern di Risposta Consigliati

### Quando l'utente chiede "fai X"

**Step 1**: Verifica scope
```
È configurazione (Settings/Objects/Fields)? → OK, procedi
È automazione (Flow/Action/Apex)? → STOP, è frozen P0
```

**Step 2**: Leggi stato corrente
```
Leggi org_state.md sezione P0
Verifica se esiste già in org (query/retrieve)
```

**Step 3**: Esegui in modo deterministico
```
Comandi ripetibili (sf project deploy...)
Salva output in /tmp/
Verifica post-deploy
```

**Step 4**: Documenta
```
Aggiorna org_state.md con nuova sezione
Includi: comandi, Deploy ID, verifiche
Commit con messaggio semantico
```

### Esempio di Risposta Ideale

```markdown
Verifico prima lo stato attuale dell'org...

[esegue query/retrieve]

Risultato: [componente] già presente/assente

[se necessario deploy]
Procedo con deploy...

[esegue deploy]

Deploy ID: 0Afg5000004ABC123
Status: Succeeded

Aggiorno documentazione...

[aggiorna org_state.md]

Fatto! ✅
```

---

## 🐛 Troubleshooting

### "Duplicate PlatformActionListId"
**Problema**: Layout deployment fallisce
**Soluzione**: Vedi `raw/p5_fix/P5_FIX_FINAL_REPORT.md` per strategia fix (remove IDs + add sortOrder)

### "FlexiPage deployment failed"
**Problema**: Metadata API non supporta tabbed FlexiPages
**Soluzione**: Setup manuale UI, vedi `raw/p5/ACTIVATION_UI_STEPS.md`

### "GitHub Push Protection"
**Problema**: Push bloccato per secrets (access token in org_display.json)
**Soluzione**: File già in .gitignore, usa bypass URL o rimuovi da history

### "Quote/QuoteLineItem not available"
**Problema**: Quotes non abilitate
**Soluzione**: Deploy QuoteSettings con enableQuote=true

---

## 📞 Contatti e Supporto

**Progetto gestito da**: CODEX CLI (Claude Sonnet 4.5)
**Org owner**: giuseppe.villani101020.b5bd075bbc5f@agentforce.com
**Repository**: https://github.com/Villani85/elcodemo

---

## ✅ Checklist Pre-Azione

Prima di eseguire qualsiasi operazione, verifica:

- [ ] Ho letto `org_state.md` sezione P0?
- [ ] Sto rispettando vincoli P0 (configuration-only)?
- [ ] Ho verificato stato attuale in org (query/retrieve)?
- [ ] Comando è deterministico e ripetibile?
- [ ] Aggiornerò `org_state.md` dopo?
- [ ] Farò commit con messaggio semantico?

---

**Ultima revisione**: 2026-02-21
**Versione**: 1.0
**Compatibile con**: Claude 3.5 Sonnet, Claude Opus, Claude via GitHub App
