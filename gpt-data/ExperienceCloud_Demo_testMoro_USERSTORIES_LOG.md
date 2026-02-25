# User Stories operative + Diario attività (Demo Experience Cloud “testMoro”)

**Org**: orgfarm-c5ba1be235-dev-ed (alias `orgfarm-packaging`)  
**Template/Site**: testMoro  
**Data avvio**: 2026-02-25  

---

## US4 – UI minimal (Search / Knowledge / Topics) ✅
- Evidenze: Deploy ExperienceBundle `0AfgK00000GklcDSAR`, Deploy NavigationMenu `0AfgK00000Gkg6ISAR`, Publish `08PgK00000OvMfqUAF`.

---

## US5 – Richiesta di Intervento (Record Type + filtri + Portale) ✅

### Obiettivo
- Usare **Record Type standard** per distinguere le Richieste di Intervento.
- Preparare un filtro "My" per mostrare solo richieste aperte.
- Integrare nel portale: menu navigazione + pagine lista/creazione Case.

### Azioni completate (CLI/metadata)

1) **Phase A-B**: Record Type + Layout + Default + Origin=Web ✅
- BusinessProcess `Case.Master`
- RecordType `Case.Richiesta_di_Intervento` (Id `012gK000003klyHQAQ`)
- Layout `Case-Richiesta di Intervento Layout`
- Profile `Customer Community User` aggiornato (recordType default + layout assignment)
- **Origin=Web default** impostato su RecordType (Apex fix + RecordType deploy)
- Deploy RecordType: `0AfgK00000GktWXSAZ` (initial), `0AfgK00000GkzIcSAJ` (Origin default)
- Apex fix: `0AfgK00000GkzLpSAJ` (QuoteRequestPdfEmailService wrapper method)

2) **Phase A-B**: List View "Le mie Richieste di Intervento" ✅
- Creato metadata `ListView:Case.My_Richieste_di_Intervento` (Id: `00BgK00000PWdnpUAD`)
- filterScope = Mine
- Filtri:
  - `Tipo_Case__c = Richiesta_di_Intervento`
  - `CASES.CLOSED = 0` (solo aperti)
- Deploy: `0AfgK00000GkvbZSAR` (Succeeded)

3) **Phase C-D-E-F**: NavigationMenu + Portale UX ✅
- NavigationMenu aggiornato con 3 voci:
  - **Home** → `/` (InternalLink)
  - **Le mie richieste** → `Case` (SalesforceObject, porta a `/case`)
  - **Nuova richiesta** → `/createrecord/Case` (InternalLink)
- Deploy NavigationMenu: `0AfgK00000GlCe1SAF` (Succeeded)
- Publish sito: Job `08PgK00000OwJcMUAV` (Status: Complete, Duration: 6s)
- URL Site: `https://orgfarm-c5ba1be235-dev-ed.develop.my.site.com/testMoro`

### Difficoltà / soluzioni

**1. ListView filtri RecordType**
- **Problema**: ListView metadata NON supporta filtri su `RecordType` / `RecordTypeId` (errore "Could not resolve list view column").
- **Soluzione**: Usato campo custom `Tipo_Case__c` + closed flag per filtro.

**2. Apex compilation blocking deployments**
- **Problema**: QuoteRequestPdfEmailJob chiamava metodo inesistente `sendEmailsForQuotes`, bloccando TUTTI i deploy (anche metadata non-Apex).
- **Soluzione**: Aggiunto wrapper method in QuoteRequestPdfEmailService. Deploy Apex: `0AfgK00000GkzLpSAJ`.

**3. Route custom non deployabili**
- **Problema**: Tentativi di creare route custom (`le-mie-richieste.json`, `nuova-richiesta.json`) falliti con errori circolari `pageAccess`.
- **Root cause**: ExperienceBundle Metadata API NON supporta creazione route nuove, solo modifica route esistenti create in UI.
- **Soluzione**: Usato route standard esistenti (`/case`, `/createrecord/Case`) nel NavigationMenu invece di creare route custom.

**4. defaultListViewId non riconosciuto**
- **Problema**: NavigationMenu con `<defaultListViewId>00BgK00000PWdnpUAD</defaultListViewId>` fallisce con "not associated with entity Case".
- **Soluzione**: Rimosso defaultListViewId, utente seleziona list view manualmente dal dropdown. Non ideale ma funzionale.

**5. Query parameters in InternalLink**
- **Problema**: Tentato `/case?filterName=My_Richieste_di_Intervento` fallisce con "invalid characters" (? non permesso).
- **Soluzione**: Usato path base `/case` senza query params.

### Limitazioni accettate

⚠️ **List view auto-selection**: ListView "My_Richieste_di_Intervento" esiste ma NON può essere impostata come default via metadata. Utente deve selezionarla manualmente dal dropdown nella pagina `/case`.

⚠️ **URL custom**: Non è stato possibile creare URL dedicati tipo `/le-mie-richieste` o `/nuova-richiesta` perché route custom non sono deployabili via metadata API. Usate route standard `/case` e `/createrecord/Case`.

### Verifica finale

✅ **NavigationMenu**: 3 voci presenti e funzionanti
✅ **RecordType RDI**: Verificato con Case test (Id: `500gK00000gNwSvQAK`, RecordTypeId: `012gK000003klyHQAQ`)
✅ **Origin=Web default**: Verificato con Case test (Origin: `Web`)
✅ **Publish completato**: Job `08PgK00000OwJcMUAV` Complete in 6 secondi

### Report dettagliato
- `D:\Elco Demo\gpt-data\APEX_FIX_AND_US5B_REPORT_20260225_1525.md` (Apex fix + Phase B)
- `D:\Elco Demo\gpt-data\US5_CDEF_EXECUTION_REPORT_20260225_1540.md` (Phases C-D-E-F)

---

## US6 – Destinazioni multi-sede + sharing per destinazione ⬜

---

## US7 – Dataset demo + test E2E ⬜
