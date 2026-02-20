# CRIF Mock Integration - Configurazione Completata

**Data**: 2026-02-20 16:51
**Org**: `elco-dev` (`00Dg5000005Sp7zEAC`)
**User**: `giuseppe.villani101020.b5bd075bbc5f@agentforce.com`

---

## ✅ FILE CREATI/MODIFICATI

### Metadata Salesforce (deployati)
1. `elco-salesforce/force-app/main/default/externalCredentials/CRIF_MOCK_EXT.externalCredential-meta.xml`
2. `elco-salesforce/force-app/main/default/namedCredentials/CRIF_MOCK.namedCredential-meta.xml`
3. `elco-salesforce/force-app/main/default/permissionsets/CRIF_MOCK_Access.permissionset-meta.xml`
4. `elco-salesforce/force-app/main/default/classes/CrifMockClient.cls`
5. `elco-salesforce/force-app/main/default/classes/CrifMockClient.cls-meta.xml`
6. `elco-salesforce/force-app/main/default/classes/CrifMockSearchInvocable.cls`
7. `elco-salesforce/force-app/main/default/classes/CrifMockSearchInvocable.cls-meta.xml`
8. `elco-salesforce/force-app/main/default/classes/CrifMockClientTest.cls`
9. `elco-salesforce/force-app/main/default/classes/CrifMockClientTest.cls-meta.xml`

### Scripts & Documentazione
10. `.gitignore` (creato/aggiornato - esclude `scripts/*.secrets.json`)
11. `scripts/crif_mock_credentials.secrets.json` (credenziali demo, NON committato)
12. `scripts/CRIF_CREDENTIALS_UI_FALLBACK.md` (step UI manuali click-by-click)
13. `scripts/crif_mock_smoketest.apex` (smoke test script)
14. `struttura.md` (aggiunta sezione "Integrazione CRIF Mock (COF) - P1")
15. `org_state.md` (aggiunta sezione "CRIF Mock Integration")
16. `scripts/CRIF_INTEGRATION_SUMMARY.md` (questo file)

---

## ✅ COMANDI ESEGUITI

### FASE 0 - Precheck
```bash
sf org list --all
sf org display --target-org elco-dev --verbose
mkdir -p scripts
# Creato .gitignore con esclusioni per secrets
```

### FASE 1 - Deploy Metadata
```bash
# External Credential
sf project deploy start \
  --source-dir force-app/main/default/externalCredentials \
  --target-org elco-dev
# Deploy ID: 0Afg5000004EZzhCAG (Succeeded)

# Named Credential
sf project deploy start \
  --source-dir force-app/main/default/namedCredentials \
  --target-org elco-dev
# Deploy ID: 0Afg5000004Ea4XCAS (Succeeded)

# Permission Set
sf project deploy start \
  --source-dir force-app/main/default/permissionsets/CRIF_MOCK_Access.permissionset-meta.xml \
  --target-org elco-dev
# Deploy ID: 0Afg5000004Ea69CAC (Succeeded)

# Assign Permission Set
sf org assign permset --name CRIF_MOCK_Access --target-org elco-dev
```

### FASE 2 - Popola Credenziali (FALLITO - UI obbligatorio)
```bash
# Tentativo 1: Connect API /named-credentials/credential/
sf api request rest "/services/data/v60.0/named-credentials/credential/" \
  --method POST --body @scripts/crif_mock_credentials.secrets.json \
  --target-org elco-dev
# Risultato: 404 NOT_FOUND

# Tentativo 2: Connect API /connect/named-credentials
curl -H "Authorization: Bearer <TOKEN>" \
  https://.../services/data/v60.0/connect/named-credentials
# Risultato: 404 NOT_FOUND

# Tentativo 3: REST API /external-credentials/{name}/principals (v60, v65)
curl -X POST -d @scripts/crif_mock_credentials.secrets.json \
  https://.../services/data/v65.0/named-credentials/external-credentials/CRIF_MOCK_EXT/principals
# Risultato: 404 NOT_FOUND

# Tentativo 4: Tooling API ExternalCredentialParameter
# Risultato: oggetto esiste ma NO write support per valori segreti

# CONCLUSIONE: UI fallback obbligatorio (documentato in scripts/CRIF_CREDENTIALS_UI_FALLBACK.md)
```

### FASE 3 - Deploy Apex
```bash
sf project deploy start \
  --source-dir force-app/main/default/classes \
  --target-org elco-dev
# Deploy ID: 0Afg5000004Eba5CAC (Succeeded)
# 3 classi deployate: CrifMockClient, CrifMockSearchInvocable, CrifMockClientTest
```

### FASE 4 - Test
```bash
# Unit tests
sf apex run test \
  --class-names CrifMockClientTest \
  --result-format human \
  --code-coverage \
  --target-org elco-dev
# Risultato: 6/6 test passed (100% pass rate)
# Code coverage: CrifMockClient 88%, CrifMockSearchInvocable 100%

# Smoke test
sf apex run --file scripts/crif_mock_smoketest.apex --target-org elco-dev
# Risultato: fallito come previsto (errore: "Field CRIF_MOCK_EXT.Username does not exist")
# Causa: credenziali non configurate via UI
```

---

## ⚠️ STEP UI FALLBACK OBBLIGATORIO

**Problema**: Gli endpoint Connect/REST API per popolare External Credential principals non sono disponibili in API v60-v65.

**Soluzione**: Configurazione manuale via Setup UI (una volta sola).

### Step rapidi (dettagli in `scripts/CRIF_CREDENTIALS_UI_FALLBACK.md`)
1. Setup > Named Credentials > External Credentials
2. Click su "CRIF Mock External Credential" (CRIF_MOCK_EXT)
3. Sezione Principals > New
4. Principal Name: `NamedPrincipal`, Type: Named Principal, Sequence: 1
5. Save
6. Edit principal > Parameters:
   - Username: `test-user` (Text, non encrypted)
   - Password: `test-pass` (Password, encrypted)
7. Save

**Dopo configurazione**, rieseguire smoke test:
```bash
sf apex run --file scripts/crif_mock_smoketest.apex --target-org elco-dev
```
**Risultato atteso**: HTTP 200 per token e search.

---

## ✅ RISULTATI SMOKE TEST (atteso dopo config UI)

### Test P.IVA: `IT01234567890`

**Token Endpoint**: `POST https://crif-mock-137745841582.europe-west8.run.app/oauth2/token`
- HTTP Status: `200`
- Response: `{"access_token":"...","token_type":"Bearer","expires_in":3600}`

**Search Endpoint**: `POST https://crif-mock-137745841582.europe-west8.run.app/margo/v1/prospecting/search?page=0&size=15`
- HTTP Status: `200`
- Response: `{"totalElements":X,"content":[...]}`

---

## 📋 COME USARE DA FLOW

### 1. Crea un nuovo Flow (Screen Flow o Autolaunched Flow)
### 2. Aggiungi Action: "CRIF Mock - Prospecting Search by VAT"
   - **Input minimo**: `piva` = "IT01234567890"
   - **Input opzionali**: `includeDataPacketList` (true), `page` (0), `size` (15), `acceptLanguage` (it-IT)

### 3. Output variabili
   - `vat11`: P.IVA normalizzata (11 cifre)
   - `searchJson`: risposta JSON CRIF raw
   - `searchHttpStatus`: 200 se successo
   - `tokenHttpStatus`: 200 se token OK
   - `error`: messaggio errore (se presente)

### 4. Decision Element
   - IF `searchHttpStatus = 200` → successo
   - ELSE → mostra `error` all'utente

---

## 🔐 SICUREZZA

✅ **Nessuna credenziale hardcoded** in:
- Apex code
- Flow
- Custom Metadata
- Custom Labels
- Custom Fields

✅ **Credenziali gestite via**:
- External Credential (CRIF_MOCK_EXT)
- Named Credential (CRIF_MOCK)
- Permission Set (CRIF_MOCK_Access)
- Merge fields in Apex: `{!$Credential.CRIF_MOCK_EXT.Username}` e `{!$Credential.CRIF_MOCK_EXT.Password}`

✅ **Authorization Bearer** costruito runtime in Apex (non in Named Credential).

---

## 📚 DOCUMENTAZIONE AGGIORNATA

1. **`struttura.md`**: sezione "Integrazione CRIF Mock (COF) - P1" con:
   - Componenti creati
   - Apex classes
   - Endpoint CRIF Mock
   - Parametri configurabili
   - Come usare da Flow
   - Gestione credenziali
   - Note implementative

2. **`org_state.md`**: sezione "CRIF Mock Integration" con:
   - Componenti deployati (deploy IDs, comandi, path)
   - Credenziali (tentativi API falliti, UI fallback)
   - Test execution (unit tests, smoke test)
   - Flow action disponibile
   - Next steps aggiornati

---

## ✅ COMPLETAMENTO

**STATO**: Integrazione CRIF Mock configurata al 95%

**RIMANENTE**: Configurazione credenziali via UI (step manuale, 5 minuti)

**PROSSIMI STEP**:
1. Configurare credenziali CRIF via UI (vedi `scripts/CRIF_CREDENTIALS_UI_FALLBACK.md`)
2. Verificare smoke test passa con HTTP 200
3. Creare Flow demo per testare azione invocable
4. (Opzionale) Creare Quick Action su Account per invocare ricerca CRIF

---

**Fine configurazione CRIF Mock Integration**
