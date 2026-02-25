# Portal Ticket Coerente - Manifest Package

## 📦 Package Content

Questo manifest deploya la configurazione "Ticket Coerente" per il portale testMoro (Comune di Giussano).

**Target**: Solo ticket di tipo "Richiesta di Intervento" con UX coerente in italiano.

---

## Files nel Package

```
portal_ticket_coerente.xml
├── QuickAction: NewCommunityCase_RI
│   └── Crea Case con RecordType "Richiesta di Intervento"
│   └── Form: AccountId (Destinazione), Subject*, Description
│
├── ListView: Case.Portal_Richieste_Intervento
│   └── Vista "Le mie richieste" (Mine)
│   └── Columns: Case Number, Subject, Account, Status, Created
│
└── ExperienceBundle: testMoro1
    ├── views/contactSupport.json (quickActionName updated)
    └── views/caseList.json (filterName updated)
```

---

## Deploy Command

```bash
sf project deploy start -o orgfarm-packaging \
  --manifest manifest/portal_ticket_coerente.xml \
  --wait 10
```

---

## Post-Deploy Required

⚠️ **IMPORTANTE**: Dopo il deploy, configurare nella UI:

1. **QuickAction RecordType**:
   - Setup > Case > Buttons, Links, and Actions > NewCommunityCase_RI
   - Edit > Record Type to Create: "Richiesta di Intervento"

2. **Profile RecordType Assignment**:
   - Setup > Profiles > [Community Profile] > Cases
   - Available Record Types: solo "Richiesta di Intervento"

---

## Verificato

✅ Deploy ID: 0AfgK00000GlXCNSA3
✅ Data: 2026-02-25 21:09 CET
✅ Org: orgfarm-packaging
✅ Status: SUCCESS

---

**Full documentation**: `../PORTAL_TICKET_COERENTE_DEPLOY.md`
**Patches summary**: `../PORTAL_PATCHES_SUMMARY.md`
