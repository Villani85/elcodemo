# US4 - UI Minimalista testMoro Experience Cloud

**Progetto**: Portale Experience Cloud - testMoro
**Org**: orgfarm-c5ba1be235-dev-ed (Developer Edition)
**Alias CLI**: `orgfarm-packaging`
**Network Name**: testMoro
**NetworkId**: `0DBgK000000f3efWAA`
**ExperienceBundle**: testMoro1
**Obiettivo**: Rimuovere Search, Topics, Ask a Question, Knowledge/Trending widgets mantenendo template standard e Experience Builder modificabile
**Data creazione**: 2026-02-25
**Versione**: 1.0

---

## 🎯 Requisito Cliente

Il portale Experience Cloud deve essere **estremamente essenziale** e NON mostrare:

- ❌ Search bar (ricerca globale)
- ❌ Topics / pulsante "Ask a Question" (Q&A)
- ❌ Knowledge base / Trending articles e widget correlati

**Vincolo**: mantenere template standard e possibilità di editing con Experience Builder.

---

## 🔍 Diagnosi: Dove Sono Controllate Queste Feature

### 1. Search Bar (Global Search)

**Location**:
- **Experience Builder** → Header component → Settings
  - Component: `forceCommunity:searchComponent` o `ForceComm:Header`
  - Property: `showSearch` o visibility settings

**Metadata**:
- File: `force-app/main/default/experiences/testMoro1.site-meta.xml` o `.site` bundle
- Component: `<component instance>` con type `ForceComm:Header`
- Property XML: `<property name="showSearch">true</property>`

**Workspaces**:
- Administration Workspaces → Settings → General → Search Settings
- Path: `https://orgfarm-c5ba1be235-dev-ed.develop.my.salesforce-setup.com/lightning/setup/NetworkSettings/home?networkId=0DBgK000000f3efWAA`

---

### 2. Topics / Ask a Question (Q&A Feature)

**Location**:
- **Workspaces** → Features → Topics & Questions
  - Path: `https://orgfarm-c5ba1be235-dev-ed.develop.my.site.com/testMoro/s/_ui/networks/setup/NetworkManagementPage/page?address=00DgK00000F3UVZUA3/testMoro/Settings/Topics`
  - Toggle: "Enable Q&A in this community" e "Enable Topics"

**Metadata**:
- File: `force-app/main/default/networks/testMoro.network-meta.xml`
- Properties:
  ```xml
  <enableQuestion>true</enableQuestion>
  <enableTopics>true</enableTopics>
  <topicsLayout>TopicsAndQuestions</topicsLayout>
  ```

**Experience Builder**:
- Home page → rimuovere component `Community:TopicsAndQuestions` o `Community:FeaturedTopics`
- Tab bar → rimuovere "Topics" tab

---

### 3. Knowledge / Trending Articles Widget

**Location**:
- **Workspaces** → Features → Knowledge
  - Path: `https://orgfarm-c5ba1be235-dev-ed.develop.my.site.com/testMoro/s/_ui/networks/setup/NetworkManagementPage/page?address=00DgK00000F3UVZUA3/testMoro/Settings/KnowledgeSettings`
  - Toggle: "Enable Knowledge"

**Metadata**:
- File: `force-app/main/default/networks/testMoro.network-meta.xml`
- Property:
  ```xml
  <knowledgeArticlesEnabled>true</knowledgeArticlesEnabled>
  ```

**Experience Builder**:
- Home page → rimuovere component `Community:TrendingArticles` o `Community:KnowledgeArticles`
- Sidebar → rimuovere "Trending Topics" widget

---

## 🛠️ Piano di Intervento

### Approccio Raccomandato: **Livello A (UI/Workspaces) FIRST**, poi Livello B (metadata) per replicabilità

---

## 📋 Livello A: Solo Builder/Workspaces (UI)

### A.1 - Disabilitare Topics & Q&A (Workspaces)

**Step 1**: Accedi a Administration Workspaces

```
URL diretto:
https://orgfarm-c5ba1be235-dev-ed.develop.my.site.com/testMoro/s/_ui/networks/setup/NetworkManagementPage
```

**Step 2**: Naviga Features → Topics & Questions

```
Click: Administration (icona ingranaggio in alto a destra)
Click: Features → Topics
```

**Step 3**: Disabilita entrambi i toggle

```
Toggle OFF: "Enable Q&A in this community"
Toggle OFF: "Enable Topics"
Click: Save
```

**Verifica immediata**:
- Il tab "Topics" dovrebbe sparire dalla navigation bar
- Il pulsante "Ask a Question" non dovrebbe più essere visibile

---

### A.2 - Disabilitare Knowledge (Workspaces)

**Step 1**: Accedi a Administration Workspaces

```
URL diretto (come sopra)
```

**Step 2**: Naviga Features → Knowledge

```
Click: Administration → Features → Knowledge
```

**Step 3**: Disabilita Knowledge

```
Toggle OFF: "Enable Knowledge"
Click: Save
```

**Verifica immediata**:
- Widget "Trending Articles" dovrebbe sparire (se era dinamico)
- Possibili componenti hardcoded in pages potrebbero rimanere (vedi A.3)

---

### A.3 - Rimuovere Componenti UI Hardcoded (Experience Builder)

**Step 1**: Apri Experience Builder

```
URL diretto:
https://orgfarm-c5ba1be235-dev-ed.develop.my.site.com/testMoro/s/_ui/networks/forceCommunity/builder

Oppure:
Setup → All Sites → testMoro → Builder
```

**Step 2**: Naviga alla Home page

```
Click: Pages dropdown (in alto) → Home
```

**Step 3**: Rimuovi componenti Topics/Knowledge

**Componenti da cercare e rimuovere** (se presenti):
- `Trending Articles` o `Featured Articles`
- `Trending Topics`
- `Featured Topics`
- `Topics and Questions` component
- Qualsiasi component con icona 💬 (Questions) o 📚 (Knowledge)

**Come rimuovere**:
```
Click sul component nel canvas
Click icona trash 🗑️ nella toolbar
Oppure: Click destro → Remove Component
```

**Step 4**: Header - Nascondi Search Bar

```
Click: Header component (in alto)
Panel destro → Properties
Cerca: "Show Search" o "Search Visibility"
Toggle OFF o imposta "Hide"
```

**⚠️ Nota**: Se Header è locked/non modificabile (template constraint), potrebbe richiedere:
- Custom Header component (richiede dev)
- Override CSS (vedi Livello B)

**Step 5**: Rimuovi "Topics" tab dalla Navigation (se presente)

```
Click: Navigation menu component
Panel destro → Properties → Menu Items
Trova: "Topics" item
Click icona X o Remove
```

**Step 6**: Publish

```
Click: Publish button (in alto a destra)
Attendi conferma "Site published successfully"
```

**Verifica post-publish**:
- Apri site in incognito: `https://orgfarm-c5ba1be235-dev-ed.develop.my.site.com/testMoro`
- Controlla: Search bar, Topics tab, widget assenti

---

## 🔧 Livello B: Metadata/CLI/API (Replicabile)

### Prerequisiti

```bash
# Verifica autenticazione
sf org display -o orgfarm-packaging

# Output atteso:
# Org ID: 00DgK00000F3UVZUA3
# Instance URL: https://orgfarm-c5ba1be235-dev-ed.develop.my.salesforce.com
```

---

### B.1 - Retrieve Network Metadata (Baseline)

**Step 1**: Retrieve current Network configuration

```bash
# Crea directory temporanea per analyze
mkdir -p D:/Elco\ Demo/gpt-data/tmp_testMoro

# Retrieve Network metadata
sf project retrieve start \
  -o orgfarm-packaging \
  --metadata "Network:testMoro" \
  --target-metadata-dir D:/Elco\ Demo/gpt-data/tmp_testMoro

# Verifica file creato
ls D:/Elco\ Demo/gpt-data/tmp_testMoro/networks/testMoro.network-meta.xml
```

**Step 2**: Inspect current settings

```bash
# Apri file in editor
cat D:/Elco\ Demo/gpt-data/tmp_testMoro/networks/testMoro.network-meta.xml
```

**Cerca questi valori**:
```xml
<enableQuestion>true</enableQuestion>              <!-- Q&A -->
<enableTopics>true</enableTopics>                  <!-- Topics -->
<knowledgeArticlesEnabled>true</knowledgeArticlesEnabled> <!-- Knowledge -->
```

---

### B.2 - Modifica Network Metadata (Disable Features)

**Step 1**: Copia file in working directory (se non esiste structure)

```bash
# Se non hai già structure SFDX project in gpt-data
mkdir -p D:/Elco\ Demo/gpt-data/force-app/main/default/networks

cp D:/Elco\ Demo/gpt-data/tmp_testMoro/networks/testMoro.network-meta.xml \
   D:/Elco\ Demo/gpt-data/force-app/main/default/networks/
```

**Step 2**: Modifica file `testMoro.network-meta.xml`

**Cambia questi valori** (se presenti):

```xml
<!-- BEFORE -->
<enableQuestion>true</enableQuestion>
<enableTopics>true</enableTopics>
<knowledgeArticlesEnabled>true</knowledgeArticlesEnabled>

<!-- AFTER -->
<enableQuestion>false</enableQuestion>
<enableTopics>false</enableTopics>
<knowledgeArticlesEnabled>false</knowledgeArticlesEnabled>
```

**⚠️ Nota**: Se `<knowledgeArticlesEnabled>` non esiste, NON aggiungerlo (potrebbe non essere supportato in tutte le API versions).

---

### B.3 - Validate Deploy (Dry-Run)

**Step 1**: Validate ONLY (no actual deploy)

```bash
# Validate Network metadata changes
sf project deploy start \
  -o orgfarm-packaging \
  --metadata "Network:testMoro" \
  --dry-run \
  --source-dir D:/Elco\ Demo/gpt-data/force-app/main/default/networks

# Output atteso:
# Status: Succeeded
# Validating: Network.testMoro
# ✅ Success (dry-run only, no changes applied)
```

**Step 2**: Review validation result

```
Se validation FAILED:
- Leggi error message (es. "Field knowledgeArticlesEnabled not supported")
- Rimuovi field non supportato da XML
- Re-validate

Se validation SUCCEEDED:
- Procedi a B.4 per deploy reale
```

---

### B.4 - Deploy Network Metadata (Apply Changes)

**⚠️ BACKUP FIRST**: Salva il file retrieved originale

```bash
cp D:/Elco\ Demo/gpt-data/tmp_testMoro/networks/testMoro.network-meta.xml \
   D:/Elco\ Demo/gpt-data/tmp_testMoro/testMoro.network-meta.xml.BACKUP_$(date +%Y%m%d_%H%M%S)
```

**Step 1**: Deploy for real

```bash
# Deploy Network metadata (NO dry-run)
sf project deploy start \
  -o orgfarm-packaging \
  --metadata "Network:testMoro" \
  --source-dir D:/Elco\ Demo/gpt-data/force-app/main/default/networks

# Output atteso:
# Deploying: Network.testMoro
# Status: Succeeded
# Deploy ID: 0Afg5000004ABC123
```

**Step 2**: Verify deployment

```bash
# Query Network settings via Tooling API
sf data query \
  -o orgfarm-packaging \
  --use-tooling-api \
  -q "SELECT Id, Name, EnableTopics, EnableQuestion FROM Network WHERE Name = 'testMoro'"

# Output atteso:
# EnableTopics: false
# EnableQuestion: false
```

**Step 3**: Verify in UI

```
URL: https://orgfarm-c5ba1be235-dev-ed.develop.my.site.com/testMoro
Verifica: Topics tab assente, Ask a Question button assente
```

---

### B.5 - Hide Search Bar via CSS (Fallback se Header non modificabile)

**⚠️ Solo se A.3 Step 4 non funziona (Header locked)**

**Option 1: Custom Theme CSS** (preferito)

**Step 1**: Accedi a Workspaces → Settings → Theme

```
URL diretto:
https://orgfarm-c5ba1be235-dev-ed.develop.my.site.com/testMoro/s/_ui/networks/setup/NetworkManagementPage/page?address=00DgK00000F3UVZUA3/testMoro/Settings/Theme
```

**Step 2**: Naviga a "Custom CSS" section

```
Click: Branding → Custom CSS
```

**Step 3**: Aggiungi CSS per nascondere Search

```css
/* Hide global search bar in header */
.slds-global-header__item--search,
.forceCommunityGlobalNavigation .search-container,
.comm-header-search-container,
.forceCommunity-header search,
.searchBox {
  display: none !important;
}

/* Hide search icon in mobile */
.slds-context-bar__icon-action[title*="Search"],
.slds-button[title*="Search"] {
  display: none !important;
}
```

**Step 4**: Save e Publish

```
Click: Save
Torna in Builder → Publish
```

**Option 2: Static Resource CSS** (replicabile via metadata)

**Step 1**: Crea file CSS

```bash
# File: D:/Elco Demo/gpt-data/force-app/main/default/staticresources/testMoro_HideSearch.css
```

```css
/* testMoro - Hide Search Bar */
.slds-global-header__item--search,
.forceCommunityGlobalNavigation .search-container,
.comm-header-search-container {
  display: none !important;
}
```

**Step 2**: Crea Static Resource metadata

```xml
<!-- File: testMoro_HideSearch.resource-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<StaticResource xmlns="http://soap.sforce.com/2006/04/metadata">
    <cacheControl>Public</cacheControl>
    <contentType>text/css</contentType>
    <description>Hide Search Bar for testMoro Experience Cloud</description>
</StaticResource>
```

**Step 3**: Deploy Static Resource

```bash
sf project deploy start \
  -o orgfarm-packaging \
  --source-dir D:/Elco\ Demo/gpt-data/force-app/main/default/staticresources
```

**Step 4**: Link CSS in Experience Builder

```
Builder → Settings → Advanced → Head Markup
Aggiungi:
<link rel="stylesheet" href="{!$Resource.testMoro_HideSearch}" />
```

**⚠️ Rischio**: Custom CSS può essere sovrascritto da template updates. Monitorare dopo Salesforce releases.

---

### B.6 - Retrieve ExperienceBundle (Replicabile Full Setup)

**⚠️ Advanced**: Solo se vuoi replicare TUTTA la configurazione (pages, components, settings)

**Step 1**: Retrieve full ExperienceBundle

```bash
# Retrieve ExperienceBundle (include tutte le pages e components)
sf project retrieve start \
  -o orgfarm-packaging \
  --metadata "ExperienceBundle:testMoro1" \
  --target-metadata-dir D:/Elco\ Demo/gpt-data/tmp_testMoro

# ⚠️ Warning: Questo può creare 50+ files
```

**Step 2**: Analizza structure

```bash
# Struttura tipica:
# tmp_testMoro/
# ├── experiences/
# │   └── testMoro1/
# │       ├── site.json                     # Network config
# │       ├── pages/
# │       │   ├── home.json                 # Home page components
# │       │   └── ...
# │       ├── views/
# │       └── config/
# │           └── mainAppPage.json          # Main app settings
```

**Step 3**: Modifica `home.json` (rimuovi components)

**Cerca e rimuovi** questi component definitions:

```json
{
  "componentType": "Community:TrendingArticles",
  // ... rimuovi tutto il blocco
}

{
  "componentType": "Community:FeaturedTopics",
  // ... rimuovi tutto il blocco
}

{
  "componentType": "Community:TopicsAndQuestions",
  // ... rimuovi tutto il blocco
}
```

**Step 4**: Validate + Deploy ExperienceBundle

```bash
# ⚠️ CAUTION: ExperienceBundle deploy è complesso e può sovrascrivere tutto
# SEMPRE validare prima

sf project deploy start \
  -o orgfarm-packaging \
  --metadata "ExperienceBundle:testMoro1" \
  --dry-run \
  --source-dir D:/Elco\ Demo/gpt-data/force-app/main/default/experiences

# Se validation OK:
sf project deploy start \
  -o orgfarm-packaging \
  --metadata "ExperienceBundle:testMoro1" \
  --source-dir D:/Elco\ Demo/gpt-data/force-app/main/default/experiences
```

**⚠️ Rischi**:
- ExperienceBundle deploy può essere idempotente solo per cambiamenti espliciti
- Template updates (es. Salesforce releases) possono reintrodurre componenti
- Non tutti i template settings sono documentati nei JSON

**Raccomandazione**: Usa B.6 solo per documentazione/backup, preferisci A.3 (Builder UI) per modifiche reali.

---

## ✅ Checklist di Verifica

### Post-Implementazione Checklist

**UI Verification** (Test in incognito mode):

```
URL: https://orgfarm-c5ba1be235-dev-ed.develop.my.site.com/testMoro

✅ Search bar non visibile in header
✅ Tab "Topics" assente nella navigation bar
✅ Pulsante "Ask a Question" non presente
✅ Widget "Trending Articles" non visibile nella home
✅ Widget "Trending Topics" non visibile nella sidebar
✅ Nessun componente Knowledge/Q&A in altre pages
```

**Configuration Verification** (Workspaces):

```
Workspaces → Features → Topics & Questions
✅ "Enable Q&A in this community" = OFF
✅ "Enable Topics" = OFF

Workspaces → Features → Knowledge
✅ "Enable Knowledge" = OFF (se applicabile)
```

**Metadata Verification** (CLI):

```bash
# Query Network settings
sf data query \
  -o orgfarm-packaging \
  --use-tooling-api \
  -q "SELECT Id, Name, EnableTopics, EnableQuestion FROM Network WHERE Name = 'testMoro'"

# Output atteso:
# EnableTopics: false
# EnableQuestion: false
```

**Functionality Test**:

```
✅ Users possono ancora accedere al portale
✅ Case visibility funziona (Private + Sharing Set)
✅ Navigation funziona (altre tabs/pages)
✅ Mobile view: Search/Topics/Knowledge assenti anche su mobile
```

---

## ⚠️ Rischi ed Edge Cases

### 1. Template Updates Reintroducono Componenti

**Problema**: Salesforce release/template update potrebbe re-enable features o re-add components

**Mitigazione**:
- Documentare setup in questo file (replicabile)
- Dopo ogni Salesforce major release, verificare checklist sopra
- Se possibile, creare "locked" version del template (non sempre supportato)

**Recovery**:
- Re-eseguire Livello A (Workspaces toggle + Builder cleanup)
- Se metadata in source control, re-deploy da B.4

---

### 2. Header Search Bar Non Modificabile (Template Lock)

**Problema**: Alcuni template standard hanno Header component non editabile in Builder

**Sintomo**:
- Click su Header in Builder → Panel destro mostra "Locked" o properties read-only

**Soluzione**:
- Usare CSS override (vedi B.5)
- Oppure: creare Custom Header component (richiede dev + Aura/LWC)

**Verifica se Header è locked**:
```
Experience Builder → Click Header → Panel destro
Se mostra icona 🔒 o "This component is managed" → locked
```

---

### 3. Knowledge Feature Non Disabilitabile (Org-Level Setting)

**Problema**: Se Knowledge è abilitato a livello org (Setup → Knowledge Settings), potrebbe non essere completamente disabilitabile per singolo site

**Verifica**:
```
Setup → Feature Settings → Knowledge → Knowledge Settings
Se "Enable Knowledge" = ON a livello org
```

**Mitigazione**:
- Disabilita a livello Network (Workspaces → Knowledge → OFF)
- Rimuovi tutti i Knowledge components in Builder (A.3)
- Modifica permessi profilo Guest User per testMoro: rimuovi "Read" su KnowledgeArticleVersion

**Permessi Guest User**:
```
Setup → Users → Profiles → "testMoro Profile" → Object Settings → Knowledge__kav
Set: Read = OFF
```

---

### 4. Componenti "Ghost" Dopo Publish

**Problema**: Dopo publish, componenti rimossi in Builder potrebbero riapparire

**Causa comune**:
- Caching del browser/CDN
- Template default components re-added da async job
- Componenti in altre pages non controllate

**Troubleshooting**:
```
Step 1: Clear browser cache (incognito mode)
Step 2: Verifica TUTTE le pages in Builder (non solo Home):
  - Home
  - Topic Detail page (se esiste)
  - Search Results page (se esiste)
  - Article Detail page (se esiste)

Step 3: Re-publish dopo ogni modifica
Step 4: Attendi 2-5 minuti (CDN propagation)
```

---

### 5. Mobile View Differente da Desktop

**Problema**: Search bar/Topics visibili su mobile ma non su desktop (o viceversa)

**Soluzione**:
- Testare su mobile: Chrome DevTools → Device toolbar (Ctrl+Shift+M)
- In Builder, verificare breakpoints: Desktop / Tablet / Mobile views
- Rimuovere componenti per OGNI breakpoint (Builder ha views separate)

**Come testare mobile**:
```
Builder → Click responsive icon (phone/tablet) in top toolbar
Per ogni view (Desktop/Tablet/Phone):
  - Verificare componenti presenti
  - Rimuovere Search/Topics/Knowledge se presenti
```

---

### 6. Metadata API Version Incompatibility

**Problema**: Deploy Network metadata fallisce con "Unknown field: enableTopics"

**Causa**: API version < 40 non supporta alcuni campi

**Soluzione**:
- Verifica API version in `sfdx-project.json`: deve essere >= 40.0 (preferibilmente >= 55.0)
- Rimuovi campi non supportati dal XML se errore persiste
- Lista campi sicuri (API 55+):
  ```xml
  <enableQuestion>false</enableQuestion>
  <selfRegistration>false</selfRegistration>
  <status>Live</status>
  ```

**Verifica API version org**:
```bash
sf org display -o orgfarm-packaging --json | grep apiVersion
```

---

### 7. Permission Issues (Guest User Can Still See Features)

**Problema**: Features disabilitate ma Guest User vede ancora Search/Topics

**Causa**: Permission Set o Profile override

**Verifica**:
```
Setup → Users → Profiles → "testMoro Profile"
Controlla:
- "View Topics" = OFF
- "Create and Edit Topics" = OFF
- "Ask Questions" = OFF

Setup → Permission Sets → Cerca "testMoro"
Verifica nessun Permission Set assegna questi permessi
```

**Fix**:
```
Profile → System Permissions:
  ✅ View Topics: disabled
  ✅ Create Topics: disabled
  ✅ Edit Topics: disabled
  ✅ Manage Topics: disabled
```

---

## 🔁 Se Non Si Può Automatizzare: Fallback Manuale

Se Livello B (metadata/CLI) non funziona o è troppo complesso, usa questo processo UI-only **documentato e replicabile**.

---

### Manual Process: 10-Step UI Cleanup

**Prerequisites**:
- Accesso come System Admin
- Site testMoro già Live

**Total time**: ~10 minuti

---

#### Step 1: Disable Q&A and Topics (Workspaces)

```
URL: https://orgfarm-c5ba1be235-dev-ed.develop.my.site.com/testMoro/s/_ui/networks/setup/NetworkManagementPage

Click: Administration (gear icon, top right)
Click: Features → Topics
Toggle OFF: "Enable Q&A in this community"
Toggle OFF: "Enable Topics"
Click: Save
```

**Screenshot checkpoint**: Topics tab dovrebbe sparire dalla navigation immediatamente.

---

#### Step 2: Disable Knowledge (Workspaces)

```
URL: (stesso di Step 1)

Click: Features → Knowledge
Toggle OFF: "Enable Knowledge"
Click: Save
```

**Screenshot checkpoint**: Knowledge settings greyed out.

---

#### Step 3: Open Experience Builder

```
URL: https://orgfarm-c5ba1be235-dev-ed.develop.my.site.com/testMoro/s/_ui/networks/forceCommunity/builder

Oppure:
Setup → All Sites → testMoro (row) → Builder (button)
```

**Wait**: Builder loading (può richiedere 30-60 secondi).

---

#### Step 4: Navigate to Home Page

```
In Builder:
Click: Pages dropdown (top left) → Home
```

**Screenshot checkpoint**: Canvas mostra Home page layout.

---

#### Step 5: Remove "Trending Articles" Component (if present)

```
In Canvas:
Scroll alla sezione con "Trending Articles" (potrebbe essere in sidebar o main area)
Click: componente "Trending Articles"
Panel destro → Properties → Visibility
Toggle: "Visible" = OFF

Oppure (preferito):
Click: componente "Trending Articles"
Toolbar top → Click trash icon 🗑️ (Delete Component)
Confirm: "Remove Component" → Yes
```

**Screenshot checkpoint**: Component rimosso dal canvas.

---

#### Step 6: Remove "Trending Topics" Widget (if present)

```
Ripeti Step 5 per "Trending Topics" component (cerca in sidebar o footer)
```

---

#### Step 7: Remove "Featured Topics" / "Topics & Questions" (if present)

```
Ripeti Step 5 per qualsiasi componente con "Topics" o "Questions" nel nome
```

---

#### Step 8: Hide Search Bar in Header

```
In Canvas:
Click: Header component (top of page, usually full-width bar)
Panel destro → Properties
Cerca: "Show Search" o "Search" toggle
Toggle OFF: "Show Search"

Se toggle non presente (Header locked):
  → Annotare: "Header locked, richiede CSS override" (vedi Appendix A)
```

**Screenshot checkpoint**: Search bar non visibile nel canvas.

---

#### Step 9: Remove "Topics" Tab from Navigation Menu

```
In Canvas:
Click: Navigation menu component (usually below Header)
Panel destro → Properties → Menu Items (or Navigation Items)
Trova: "Topics" item nella lista
Click: X icon accanto a "Topics" → Remove
Click: Apply (se richiesto)
```

**Screenshot checkpoint**: "Topics" assente dalla lista Menu Items.

---

#### Step 10: Publish Site

```
Builder toolbar (top right):
Click: Publish button
Wait: "Publishing..." (può richiedere 1-2 minuti)
Confirm: "Site published successfully"
```

**Final verification**:
```
Open incognito browser:
URL: https://orgfarm-c5ba1be235-dev-ed.develop.my.site.com/testMoro

Check:
✅ Search bar assente
✅ Topics tab assente
✅ Trending Articles assente
✅ Ask a Question button assente
```

---

### Appendix A: CSS Override per Search Bar (Se Header Locked)

Se Step 8 non funziona (Header locked), usa questo workaround CSS:

**Step A.1**: Torna in Builder → Settings

```
Builder → Settings (gear icon, top right)
Click: Advanced Settings
```

**Step A.2**: Aggiungi Custom CSS

```
In "Custom CSS" section:
Paste:

.slds-global-header__item--search,
.forceCommunityGlobalNavigation .search-container,
.comm-header-search-container {
  display: none !important;
}
```

**Step A.3**: Save e Publish

```
Click: Save
Click: Publish
```

**Verify**: Search bar nascosta anche se Header non modificabile.

---

### Appendix B: Rollback (Se Qualcosa Va Storto)

**Option 1**: Restore via UI (immediate)

```
Workspaces → Features:
  - Topics: Toggle ON (per riabilitare)
  - Knowledge: Toggle ON (per riabilitare)

Builder:
  - Re-add components rimossi: Component library → Drag & drop
  - Header: Toggle ON "Show Search"
  - Publish
```

**Option 2**: Restore via Metadata (se deployed via B.4)

```bash
# Re-deploy backup file
sf project deploy start \
  -o orgfarm-packaging \
  --metadata "Network:testMoro" \
  --source-dir D:/Elco\ Demo/gpt-data/tmp_testMoro
```

---

## 📊 Summary: Approcci a Confronto

| Approccio | Pros | Cons | Replicabilità | Tempo |
|-----------|------|------|---------------|-------|
| **Livello A (UI)** | Immediato, visual, no CLI | Manuale, hard to replicate | ⭐⭐ Medio | 10 min |
| **Livello B (Metadata)** | Replicabile, version control, scriptable | Richiede CLI, learning curve | ⭐⭐⭐⭐⭐ Alto | 20 min (first time) |
| **Hybrid (A + B)** | Best of both worlds | Requires both skillsets | ⭐⭐⭐⭐ Alto | 15 min |

**Raccomandazione**: Usa **Hybrid approach**:
1. Disabilita features in Workspaces (A.1, A.2) → persistente
2. Cleanup UI in Builder (A.3) → visual confirmation
3. Backup metadata (B.1) → disaster recovery
4. (Opzionale) Deploy metadata (B.4) → replicabile in altri org

---

## 📝 Note Finali

### Replicabilità in Altre Org

Per replicare questo setup in un'altra org (es. staging → production):

**Approach 1: Metadata-driven (preferito)**
```bash
# Retrieve da source org
sf project retrieve start -o source-org --metadata "Network:testMoro"

# Deploy in target org
sf project deploy start -o target-org --metadata "Network:testMoro"

# Completare con Builder cleanup (A.3 Step 3-6)
```

**Approach 2: Change Sets**
```
Source Org Setup → Environments → Change Sets → New
Add: Network Settings (testMoro)
Upload → Deploy in target org
```

**Approach 3: Manual (fallback)**
- Seguire "Manual Process: 10-Step UI Cleanup" in target org
- Tempo stimato: 10 minuti per org

---

### Manutenzione e Monitoring

**Quarterly check** (dopo Salesforce releases):
```
1. Verificare checklist UI (pagina 8)
2. Se features riappaiono:
   - Re-run Workspaces toggle (A.1, A.2)
   - Re-cleanup Builder (A.3)
   - Re-deploy metadata se necessario (B.4)
3. Aggiornare questo documento con workarounds
```

**Logging**:
- Annotare data/ora ogni modifica in questo file (sezione "Change Log" sotto)
- Salvare screenshot before/after in `D:/Elco Demo/gpt-data/screenshots/testMoro_UI_cleanup/`

---

### Change Log

| Data | Author | Change | Method | Notes |
|------|--------|--------|--------|-------|
| 2026-02-25 | Claude Sonnet 4.5 | Documento creato | - | Baseline documentation |
| | | | | |

---

### Support e Troubleshooting

**Se blocchi**:
1. Verifica autenticazione: `sf org display -o orgfarm-packaging`
2. Verifica permessi: deve essere System Admin
3. Verifica site status: Workspaces → Settings → General → Status = "Live"
4. Se deploy fallisce: leggere error message, verificare API version compatibility
5. Se Builder non carica: cancellare cache browser, provare incognito

**Contatti**:
- Org Admin: (aggiungere email)
- Instance: orgfarm-c5ba1be235-dev-ed.develop.my.salesforce.com
- Support doc: https://help.salesforce.com/s/articleView?id=sf.networks_communities.htm

---

**Fine documento**

**Salvato come**: `D:\Elco Demo\gpt-data\US4_UI_MINIMAL_testMoro.md`
**Versione**: 1.0
**Last updated**: 2026-02-25
**Ready for implementation**: ✅ YES
