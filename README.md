# Elco Salesforce - Demo Project

**Progetto Salesforce per gestione PCB (Printed Circuit Board) custom con integrazione CRIF**

🔗 **Repository**: https://github.com/Villani85/elcodemo
🏢 **Org Salesforce**: elco-dev (giuseppe.villani101020.b5bd075bbc5f@agentforce.com)
📦 **Tipo**: Salesforce DX Project (API v65.0)

---

## 📋 Panoramica

Sistema Salesforce completo per la gestione di:
- **Preventivi PCB** (Quote Management)
- **Specifiche Tecniche** personalizzate per cliente
- **Integrazione CRIF** per valutazione creditizia
- **Report Visite** clienti con follow-up automatico
- **Account 360** view con dati finanziari e tecnici

---

## 🏗️ Architettura

### Oggetti Custom
- **Account_Tech_Spec__c**: Specifiche tecniche PCB per Account
- **Visit_Report__c**: Report visite clienti
- **Visit_Attendee__c**: Partecipanti alle visite

### Oggetti Standard Estesi
- **Account**: +35 campi custom (CRIF, prerequisiti offerta, ERP)
- **Quote**: +10 campi custom (circuiti, consegna, servizi)
- **QuoteLineItem**: +13 campi custom (materiali, finiture, dimensioni)

### Automazioni (Flow-based)
- Flow CRIF per aggiornamento dati finanziari
- Flow Quote per creazione preventivi
- Flow Visit per gestione visite e follow-up
- Quick Actions su Account/Opportunity/Quote/Visit

---

## 📂 Struttura Progetto

```
elcodemo/
├── elco-salesforce/          # Progetto Salesforce DX principale
│   ├── force-app/main/default/
│   │   ├── classes/          # Apex (CRIF client, email invocables)
│   │   ├── flows/            # Screen Flows (10)
│   │   ├── quickActions/     # Quick Actions (11)
│   │   ├── objects/          # Custom Objects + Fields
│   │   ├── layouts/          # Page Layouts (5)
│   │   ├── flexipages/       # Lightning Pages (Account_360)
│   │   └── settings/         # QuoteSettings
│   ├── raw/                  # Artifacts implementazione (P1-P6)
│   └── scripts/              # Script Python/Apex utility
├── org_state.md             # ⭐ Stato org e fasi implementazione
├── struttura.md             # ⭐ Struttura progetto dettagliata
└── README.md                # Questo file

⭐ = File chiave da leggere per capire il progetto
```

---

## 📖 Documentazione Principale

### 1️⃣ **org_state.md** - Storia e Stato Org
Contiene:
- **P0**: Configuration Baseline (Settings, Objects, Fields)
- **P1-P6**: Fasi implementazione complete
  - P1: Security baseline
  - P2: CRIF Integration
  - P3: Quote Management
  - P4: TechSpec + Visit
  - P5: UX/Account 360
  - P6: Demo Pack
- Comandi eseguiti, Deploy ID, verifiche

### 2️⃣ **struttura.md** - Architettura Dettagliata
Contiene:
- Inventario metadata (78 custom fields, 10 flows, 11 actions, ecc.)
- Scope P0 vs componenti frozen
- Directory structure annotata
- Technical notes

### 3️⃣ **elco-salesforce/raw/** - Artifacts Implementazione
- `crif_p1/`, `crif_p2/`: CRIF integration artifacts
- `offerta_p3/`: Quote management artifacts
- `p4/`: TechSpec + Visit artifacts
- `p5/`, `p5_fix/`, `p5_cli_finish/`: UX/Layouts artifacts
- `p6/`: Demo pack (seed data, runbook)

---

## 🎯 Scope P0 vs Componenti Frozen

### ✅ P0 - Configuration Baseline (DEPLOYED)
**Deployed in org**:
- QuoteSettings (enableQuote=true)
- 4 Custom Objects (Account_Tech_Spec__c, Visit_Report__c, Visit_Attendee__c + Account)
- 78 Custom Fields
- Products & PricebookEntries (PCB Custom)

### 🚫 Componenti Frozen (NOT DEPLOYED)
**Esistono in repo ma NON deployati per vincolo P0**:
- **10 Flows**: CRIF, Quote, Visit, TechSpec automation
- **11 Quick Actions**: UI buttons per Account/Opportunity/Quote/Visit
- **2 FlexiPages**: Account_360, New_Account_CRIF
- **9 Apex Classes**: CRIF API client, test classes, email invocables

**Motivo**: P0 è configuration-only baseline. Le automazioni di processo (P1-P6) esistono nel repo per riferimento ma sono frozen.

---

## 🚀 Quick Start

### Setup Locale
```bash
# Clone repository
git clone https://github.com/Villani85/elcodemo.git
cd elcodemo

# Authenticate to org
sf org login web -a elco-dev

# Verify org
sf org display -o elco-dev

# (Optional) Deploy additional components from elco-salesforce/
cd elco-salesforce
sf project deploy start -o elco-dev --manifest package.xml
```

### Navigare la Documentazione
1. **Leggi prima**: `org_state.md` (overview completo)
2. **Approfondisci**: `struttura.md` (dettagli tecnici)
3. **Esplora artifacts**: `elco-salesforce/raw/p*/` (evidenze implementazione)

---

## 🔧 Tecnologie

- **Salesforce Platform**: Developer Edition (API v65.0)
- **Metadata Format**: Salesforce DX Source Format
- **Language**: Apex, Flow Builder, LWC
- **Integration**: CRIF Mock API (Named Credential)
- **Automation**: Flow-first approach (minimal Apex)

---

## 📝 Note Importanti

### Secrets & Credentials
- File `org_display.json` esclusi da git (contengono access token)
- Named Credential per CRIF configurata in org
- Permission Sets per controllo accesso Flow/CRIF

### Limitazioni Note
- **FlexiPage deployment**: Metadata API non supporta tabbed FlexiPages → setup manuale UI
- **GlobalPublisherLayout**: Non deployable via API → setup manuale UI

### Git Workflow
- Branch: `master`
- Commit convention: Prefissi semantici (P0:, security:, docs:, ecc.)
- Co-authored commits con Claude Sonnet 4.5

---

## 📊 Metriche Progetto

- **Custom Objects**: 4 (+ Account standard esteso)
- **Custom Fields**: 78 totali
- **Flows**: 10 (CRIF, Quote, Visit, TechSpec)
- **Quick Actions**: 11 (Account, Opportunity, Quote, Visit)
- **Apex Classes**: 9 (CRIF client, email, test)
- **Layouts**: 5 (Account, Opportunity, Quote, QuoteLineItem, Visit_Report)
- **Permission Sets**: 5 (Run_Flows, Quote_Operator, Visit_Operator, TechSpec_Operator, CRIF_Operator)

---

## 🤝 Contributing

Progetto demo/development. Per modifiche:
1. Leggi `CLAUDE.md` per istruzioni specifiche Claude
2. Segui convenzioni esistenti in `org_state.md`
3. Usa comandi deterministici e ripetibili
4. Documenta cambio in `org_state.md` con timestamp

---

## 📄 License

Progetto demo per scopi educativi/development.

---

**Ultima revisione**: 2026-02-21
**Autore**: Implementato con Claude Sonnet 4.5 (CODEX CLI)
**Org**: elco-dev (orgfarm-ebbb80388b-dev-ed.develop.my.salesforce.com)
