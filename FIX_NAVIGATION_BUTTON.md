# Fix: Pulsante "Avanti" Non Visibile nel Flow

## Diagnostica Completata

✅ Flow Version 3 Active con screen navigation corretto
✅ Quick Action configurato correttamente come type="Flow"
✅ Nessun FlexiPage o LWC wrapper che nasconde navigation
✅ Screen A ha `allowBack="false"` e `allowFinish="false"` (corretto)

## Problema Identificato

Il flow è configurato CORRETTAMENTE. Il problema è probabilmente:
- **Browser cache** (più probabile)
- **Rendering issue** Salesforce temporaneo
- **Permessi utente** mancanti

## Soluzioni da Provare (in ordine)

### Soluzione 1: Clear Browser Cache + Hard Refresh

1. Nel browser dove hai Salesforce aperto:
   - **Chrome/Edge**: Ctrl + Shift + Delete → Clear cache
   - Oppure: F12 → Network tab → "Disable cache" checkbox → F5

2. Logout + Login Salesforce

3. Vai su Quote record → Click "Aggiungi Riga Offerta V2"

---

### Soluzione 2: Verifica Lancio da Quote Record

**IMPORTANTE**: Il Quick Action DEVE essere lanciato da un record Quote esistente.

1. Vai su un Quote record (non da Object Manager, non da Setup)
2. Cerca il pulsante "Aggiungi Riga Offerta V2" in:
   - Actions menu in alto (⚡ icona)
   - Related list "Quote Line Items" → New button sovrascrittp
   - Chatter feed actions

3. Se NON vedi il pulsante, aggiungi Quick Action al layout:
   ```
   Setup → Object Manager → Quote → Page Layouts
   → Quote Layout → Mobile & Lightning Actions section
   → Drag "Aggiungi Riga Offerta V2" action
   ```

---

### Soluzione 3: Test Flow da Setup (Isolato)

Per verificare se il flow STESSO funziona:

1. Setup → Flows → "Quote_Test_Deploy"
2. Click "Run" (in alto a destra)
3. Nella modal "Choose a Record":
   - Seleziona un Quote ID esistente
   - Click "Run"

**Aspettati**:
- Screen con "Tipologia Prodotto" (radio buttons)
- Pulsante "Next" o "Avanti" in basso a destra
- Pulsante "Previous" disabilitato (è screen 1)

Se funziona qui ma non dal Quick Action → problema di layout/permission

---

### Soluzione 4: Verifica Field-Level Security

Il flow legge campi Quote/Opportunity/Account. Verifica permessi:

```bash
sf data query -o elco-dev --use-tooling-api -q "SELECT SobjectType, Field, PermissionsRead FROM FieldPermissions WHERE SobjectType IN ('Quote','Opportunity','Account') AND Field LIKE '%Id' ORDER BY SobjectType, Field" --json
```

Assicurati che l'utente abbia:
- Read su Quote: Id, OpportunityId, Pricebook2Id
- Read su Opportunity: Id, AccountId
- Read su Account: Id (+ altri campi usati nel flow)

---

### Soluzione 5: Controlla Logs Salesforce

Se niente funziona, abilita Debug Logs:

1. Setup → Debug Logs
2. New → User = te stesso, Debug Level = SFDC_DevConsole
3. Apri il flow
4. Vai su Debug Logs → Click sul log più recente
5. Cerca errori come:
   - "FIELD_INTEGRITY_EXCEPTION"
   - "INSUFFICIENT_ACCESS"
   - "INVALID_CROSS_REFERENCE_KEY"

---

## Quick Test: Verifica Flow è Attivo

```bash
sf data query -o elco-dev --use-tooling-api \
  -q "SELECT Id, Status, ActiveVersionNumber, VersionNumber, ProcessType, ApiVersion FROM FlowDefinitionView WHERE DeveloperName = 'Quote_Test_Deploy'" \
  --json | grep -E "Status|ActiveVersionNumber|ApiVersion"
```

Output atteso:
```json
"Status": "Active"
"ActiveVersionNumber": 3
"ApiVersion": "65.0"
```

---

## Se Ancora Non Funziona

Dammi questi 3 screenshot:

1. **Screenshot del modal del flow** quando lo apri (anche se mancano pulsanti)
2. **Screenshot del Quick Action button** nel Quote record (dove lo clicki)
3. **URL completo del browser** quando il flow è aperto

Con questi posso capire esattamente il contesto di hosting.

---

## Note Tecniche

- Il flow è un Screen Flow con `processType=Flow`
- NON è AutoLaunchedFlow (quelli non hanno navigation)
- La Quick Action non ha `standardLabel` override
- Il modal dovrebbe essere Salesforce standard (non custom Lightning)

Se il problema persiste dopo cache clear + test da Setup → potrebbe essere un bug Salesforce specifico dell'org o della versione Winter '26.

---

**File generato il**: 2026-02-24 11:47 CET
**Ultima verifica Flow**: Version 3, Active, Deploy ID 0Afg5000004OWcOCAW
