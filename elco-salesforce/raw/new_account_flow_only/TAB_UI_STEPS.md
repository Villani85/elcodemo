# Custom Tab "Nuovo Account (CRIF)" - Manual UI Steps

**Obiettivo**: Creare un Custom Tab che punta alla Lightning App Page "New_Account_CRIF"

## Prerequisito
La Lightning App Page "New_Account_CRIF" deve essere stata creata prima (vedi APP_PAGE_UI_STEPS.md)

## Passi Manuali

### 1. Accedi a Tab Settings
- Naviga a: **Setup** → **User Interface** → **Tabs**
- Nella sezione **Lightning Page Tabs**, click: **New**

### 2. Seleziona Lightning Page
- **Lightning Page**: Cerca e seleziona `New_Account_CRIF` dal dropdown
  - (Se non appare nella lista, verifica che la App Page sia stata creata e salvata)

### 3. Configura Tab Properties
- **Tab Label**: `Nuovo Account (CRIF)`
- **Tab Name**: `New_Account_CRIF` (auto-popolato)
- **Tab Style**: 
  - Cerca: `Gears` o `Custom48` 
  - Oppure scegli un'icona a piacere (es. "Custom" con numero, oppure "Standard" icon)
- **Description**: `Tab per creare nuovo Account da Partita IVA con integrazione CRIF`

### 4. Seleziona Visibilità
- **Default On**: Seleziona (se vuoi che il tab sia visibile di default in tutte le app)
- Oppure: Deseleziona e configura la visibilità per Profile/App specifici

### 5. Salva
- Click: **Save**

### 6. Aggiungi il Tab alle App
1. Naviga a: **Setup** → **Apps** → **App Manager**
2. Trova la tua app Lightning (es. "Sales", "Service", o app custom)
3. Click: **Edit** (dropdown) → **Edit**
4. Nella sezione **Navigation Items** o **Selected Items**:
   - Trova `Nuovo Account (CRIF)` nella lista **Available Items**
   - Aggiungi alla lista **Selected Items**
   - Riordina se necessario
5. Click: **Save**

### 7. Verifica
1. Refresh la pagina o logout/login
2. Naviga all'app dove hai aggiunto il tab
3. Dovresti vedere il tab **"Nuovo Account (CRIF)"** nella navigation bar
4. Cliccando sul tab si apre la App Page con il flow CRIF_NEW_da_PIVA

## Alternative: Quick Action nel Global Publisher

Se preferisci non usare un tab dedicato, puoi usare la Global Action nel pulsante "+":
- Vedi: `GPL_UI_STEPS.md`
- L'utente clicca sul "+" e seleziona "Nuovo Account da P.IVA (CRIF)"

## Tempo Stimato
5-10 minuti

