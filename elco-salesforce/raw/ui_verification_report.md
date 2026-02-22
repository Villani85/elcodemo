# Verifica Configurazione UI - Org Salesforce

**Org**: elco-dev
**Data**: 2026-02-21
**Verificatore**: Claude via CLI

---

## ✅ COMPONENTI DEPLOYATI (Confermati via Metadata)

### 1. FlexiPage: Account_360
- **Status**: ✅ Deployata (Deploy ID: 0Afg5000004HD3NCAW)
- **Tipo**: RecordPage per Account
- **Struttura**: 3 tab
  - Tab 1: "Dati Finanziari & CRIF" (Record Detail)
  - Tab 2: "Specifiche Tecniche" (Related List: TechSpecs__r)
  - Tab 3: "Amministrazione & Zucchetti" (Record Detail)
- **Metadata**: Present in `force-app/main/default/flexipages/Account_360.flexipage-meta.xml`

**⚠️ DA VERIFICARE VIA UI**:
- [ ] È attivata come Org Default per Account?
- [ ] È assegnata ad App specifiche?
- [ ] I 3 tab sono visibili quando si apre un Account record?

**Come verificare**:
1. Vai su Setup → Lightning App Builder
2. Cerca "Account 360" nella lista
3. Verifica se appare come "Org Default" o "App Default"
4. Oppure: Apri qualsiasi Account record e verifica se vedi i 3 tab

---

### 2. FlexiPage: New_Account_CRIF
- **Status**: ✅ Deployata (Deploy ID: 0Afg5000004H0a5CAC)
- **Tipo**: AppPage
- **Contenuto**: Flow CRIF_NEW_da_PIVA
- **Metadata**: Present in `force-app/main/default/flexipages/New_Account_CRIF.flexipage-meta.xml`

**⚠️ DA VERIFICARE VIA UI**:
- [ ] È utilizzata dal CustomTab?

---

### 3. CustomTab: New_Account_CRIF
- **Status**: ✅ Deployato (Deploy ID: 0Afg5000004H9r0CAC)
- **Label**: "Nuovo Account (CRIF)"
- **FlexiPage**: New_Account_CRIF
- **Metadata**: Present in `force-app/main/default/tabs/New_Account_CRIF.tab-meta.xml`

**⚠️ DA VERIFICARE VIA UI**:
- [ ] È aggiunto alla Sales App (o altra App)?
- [ ] È visibile nella barra dei tab?

**Come verificare**:
1. Setup → App Manager
2. Trova "Sales" → Click freccia ▼ → Edit
3. Vai a "Navigation Items" o "Tabs"
4. Verifica se "Nuovo Account (CRIF)" è in "Selected Items"
5. Oppure: Apri Sales App e cerca il tab nella barra superiore

---

### 4. Global QuickAction: CRIF_New_Account_da_PIVA
- **Status**: ✅ Deployata (verificata in org)
- **Label**: "Nuovo Account da P.IVA (CRIF)"
- **Tipo**: Global Action (Flow)
- **Flow**: CRIF_NEW_da_PIVA

**⚠️ DA VERIFICARE VIA UI**:
- [ ] È aggiunta al Global Publisher Layout?
- [ ] È visibile nel menu "+" globale?

**Come verificare**:
1. Setup → Publisher Layouts
2. Edit "Global Layout"
3. Verifica se "CRIF_New_Account_da_PIVA" è nella sezione "Salesforce Actions"
4. Oppure: Click sul pulsante "+" in alto e cerca l'azione

---

## 🔍 VERIFICHE VIA CLI (Tentate)

### Apps Disponibili
✅ Trovate:
- **LightningSales** (Sales App)
- **LightningService** (Service Console)

### Limitazioni Query
Le seguenti query NON sono supportate via SOQL/Tooling API:
- ❌ AppTabMember (tab assignments nelle App)
- ❌ FlexiPageAssignment (attivazione FlexiPage)
- ❌ GlobalPublisherLayout content (azioni nel layout)

**Risultato**: La maggior parte delle configurazioni UI possono essere verificate SOLO via UI Salesforce.

---

## 📋 CHECKLIST VERIFICA MANUALE

Per completare la verifica, l'utente deve controllare nella UI:

### A. Account_360 FlexiPage
1. [ ] Setup → Lightning App Builder → Cerca "Account 360"
2. [ ] Verifica Activation status
3. [ ] Apri un Account record → Verifica 3 tab visibili

### B. CustomTab in App
1. [ ] Setup → App Manager → Sales → Edit
2. [ ] Navigation Items → Verifica se "Nuovo Account (CRIF)" è in Selected Items
3. [ ] Apri Sales App → Verifica tab visibile

### C. Global Action
1. [ ] Setup → Publisher Layouts → Global Layout → Edit
2. [ ] Verifica se "CRIF_New_Account_da_PIVA" è nel layout
3. [ ] Click "+" globale → Verifica azione visibile

---

## 🎯 AZIONI RACCOMANDATE

Basandomi sui deploy confermati e sulle verifiche tipiche:

**MOLTO PROBABILMENTE DA FARE**:
1. ✅ Account_360 FlexiPage → Probabilmente GIÀ attivata (creata via UI)
2. ❌ CustomTab → Probabilmente NON ancora aggiunto alle App
3. ❌ Global Action → Probabilmente NON ancora aggiunta al Publisher Layout

**Tempo stimato se da fare**: ~7 minuti (5 min GPL + 2 min Tab)

---

## 🆘 Come Procedere

**Opzione 1**: L'utente verifica manualmente nella UI seguendo le checklist sopra

**Opzione 2**: L'utente fornisce screenshot delle schermate chiave:
- Lightning App Builder (lista FlexiPages)
- App Manager → Sales → Navigation Items
- Publisher Layouts → Global Layout

**Opzione 3**: L'utente accede all'org e testa direttamente:
- Click "+" globale → cerca azione
- Apri Sales App → cerca tab
- Apri Account → cerca 3 tab

---

**Ultima verifica**: 2026-02-21 22:45 CET
**Prossimo passo**: Verifica manuale UI dall'utente
