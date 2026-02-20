# CRIF Mock - Configurazione Credenziali (UI Fallback)

**NOTA**: Questo step NON è attualmente automatizzabile via sf CLI/Connect API/Tooling API.
Tentati 4+ endpoint diversi con REST/Connect/Tooling API - tutti restituiscono 404 o non supportano write operations per credenziali.

## Percorso UI per popolare credenziali (MANUALE)

### Step 1: Accedi a Setup
1. Login all'org: `sf org open --target-org elco-dev`
2. Click su **Setup** (icona ingranaggio in alto a destra)

### Step 2: Naviga a Named Credentials
1. Nel Quick Find (barra ricerca Setup), digita: **Named Credentials**
2. Click su **Named Credentials** sotto "Security"

### Step 3: Apri External Credential
1. Click sul tab **External Credentials**
2. Trova e click su **CRIF Mock External Credential** (Label) o **CRIF_MOCK_EXT** (Developer Name)

### Step 4: Crea Principal (se non esiste)
1. Scroll fino alla sezione **Principals**
2. Click su **New** per creare un nuovo Principal
3. Compila:
   - **Principal Name**: `NamedPrincipal`
   - **Principal Type**: seleziona **Named Principal**
   - **Sequence Number**: `1`
4. Click **Save**

### Step 5: Popola le credenziali
1. Nel principal appena creato, click su **Edit** (o **Manage Principal**)
2. Nella sezione **Parameters**, aggiungi:
   - **Parameter 1**:
     - Name: `Username`
     - Value: `test-user`
     - Type: **Text** (non encrypted)
   - **Parameter 2**:
     - Name: `Password`
     - Value: `test-pass`
     - Type: **Password** (encrypted)
3. Click **Save**

### Step 6: Assegna Permission Set (se non già fatto)
1. Nel Quick Find, digita: **Permission Sets**
2. Click su **CRIF_MOCK_Access**
3. Click **Manage Assignments**
4. Click **Add Assignment**
5. Seleziona l'utente corrente (`giuseppe.villani101020.b5bd075bbc5f@agentforce.com`)
6. Click **Assign** > **Done**

---

## Verifica configurazione
Dopo aver completato gli step UI, verifica con:
```bash
sf apex run --file scripts/crif_mock_smoketest.apex --target-org elco-dev
```

---

**Credenziali per CRIF Mock Demo**:
- BASE_URL: https://crif-mock-137745841582.europe-west8.run.app
- USERNAME: test-user
- PASSWORD: test-pass
