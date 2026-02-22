# App Page "Nuovo Account (CRIF)" - Manual UI Steps

**Obiettivo**: Creare una Lightning App Page che esegue il flow CRIF_NEW_da_PIVA

## Motivo
Il deployment programmatico della FlexiPage ha fallito. Possibili cause:
- Il componente `flowruntime:interview` potrebbe non essere disponibile o richiede properties specifiche
- Restrizioni sulla creazione di App Pages via Metadata API

## Passi Manuali

### 1. Apri Lightning App Builder
- Naviga a: **Setup** → **User Interface** → **Lightning App Builder**
- Click: **New**

### 2. Seleziona Template
- Choose: **App Page**
- Click: **Next**

### 3. Configura Proprietà Page
- **Label**: `Nuovo Account (CRIF)`
- **API Name**: `New_Account_CRIF` (auto-popolato)
- Click: **Next**

### 4. Seleziona Template Layout
- Choose: **One Region** (o template preferito)
- Click: **Finish**

### 5. Aggiungi Componente Flow
1. Nella palette dei componenti a sinistra, cerca: **Flow**
2. Drag & drop il componente **Flow** nella regione main
3. Nelle proprietà del componente (pannello destro):
   - **Flow**: Seleziona `CRIF_NEW_da_PIVA` dal dropdown
   - **Flow Layout**: `Two Column` (opzionale, per layout migliore)
   - **Show Header**: Deseleziona (opzionale, per aspetto pulito)
   - **Show Footer**: Seleziona (per bottoni Next/Finish)

### 6. Salva
- Click: **Save**

### 7. Attiva (opzionale ma consigliato)
- Click: **Activation...**
- **Lightning Experience**:
  - Click: **Assign as App Default**
  - Seleziona le app dove vuoi che sia disponibile
- Click: **Save**
- Click: **Back** per tornare all'App Builder

### 8. Verifica
1. Esci dall'App Builder
2. Naviga a: **App Launcher** (9 puntini) → cerca la tua app
3. Dovresti vedere "Nuovo Account (CRIF)" disponibile come tab/page

## Prossimi Passi
Dopo aver creato la App Page, procedi con la creazione del Custom Tab (vedi TAB_UI_STEPS.md)

## Tempo Stimato
10-15 minuti

