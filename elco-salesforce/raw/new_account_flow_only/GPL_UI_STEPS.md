# Global Publisher Layout - Manual UI Steps

**Obiettivo**: Aggiungere la Global Action "CRIF_New_Account_da_PIVA" al Global Publisher Layout

## Motivo
Il metadata type `GlobalPublisherLayout` non è disponibile via Metadata API o non supporta il deployment programmatico in questa org configuration.

## Passi Manuali

### 1. Accedi a Setup
- Naviga a: **Setup** → **User Interface** → **Global Actions** → **Publisher Layouts**

### 2. Modifica il Global Publisher Layout
- Trova: **Global Layout** o **Global Publisher Layout**
- Click: **Edit**

### 3. Aggiungi la Global Action
1. Nella sezione "Quick Actions", troverai le azioni disponibili nella palette a sinistra
2. Cerca: **CRIF_New_Account_da_PIVA** oppure **Nuovo Account da P.IVA (CRIF)**
3. Drag & drop l'azione dalla palette al layout (Salesforce Actions section)
4. Posizionala dove preferisci (tipicamente all'inizio per visibilità)

### 4. Salva
- Click: **Save**

### 5. Verifica
1. Click sul pulsante **"+"** (New) nella barra di navigazione globale
2. Dovresti vedere: **"Nuovo Account da P.IVA (CRIF)"** tra le azioni disponibili
3. Cliccando sull'azione si apre il flow CRIF_NEW_da_PIVA

## Note
- Questa azione sarà visibile a tutti gli utenti con accesso al flow
- Per limitare la visibilità, usa i Profile/PermissionSet assignments
- L'azione è globale e non specifica per un oggetto

## Tempo Stimato
5-10 minuti

