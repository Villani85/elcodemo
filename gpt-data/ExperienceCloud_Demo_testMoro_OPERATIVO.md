# Piano Operativo (aggiornabile) – Demo Experience Cloud “testMoro”

**Org**: orgfarm-c5ba1be235-dev-ed (alias `orgfarm-packaging`)  
**Site/Template**: testMoro (UrlPathPrefix `testMoro`)  
**Data avvio**: 2026-02-25  

> Questo documento è una checklist operativa: lo aggiorniamo man mano che completiamo i task.

---

## Legenda stati
- ✅ DONE
- 🟡 IN PROGRESS
- ⛔ BLOCKED
- ⬜ NOT STARTED

---

## Checklist MVP Demo (ordine “safe-first”)

### 0) Baseline & sicurezza (prima di pubblicare)
| ID | Task | Output atteso | Stato | Note / Evidenze |
|---|------|---------------|------|-----------------|
| T0.1 | Verificare OWD esterni (Case/Account/Contact) | Conferma livelli External Access | ✅ |
| T0.2 | Verificare Sharing Sets del sito testMoro | Conferma mapping Case (minimo) | ✅ | SharingSet **Customer_Portal_Case_Sharing** (Case.ContactId ↔ User.ContactId, Edit).

### 1) Portale template: completamento wizard + pubblicazione
| ID | Task | Output atteso | Stato | Note / Evidenze |
|---|------|---------------|------|-----------------|
| T1.1 | Completare wizard communitySetup (testMoro) | Sito configurato (template standard) | ✅ |
| T1.2 | Portare Network testMoro da UnderConstruction a Live | Sito accessibile a utenti esterni | ✅ |

### 2) Accesso: no self-registration + utenti demo
| ID | Task | Output atteso | Stato | Note / Evidenze |
|---|------|---------------|------|-----------------|
| T2.1 | Disabilitare Self-Registration | Nessun link/flow di auto-registrazione | ✅ | `Network:testMoro` → `<selfRegistration>false</selfRegistration>` |
| T2.2 | Sistemare utente Luca (reset password + login test) | Luca riesce a loggarsi | ⬜ |

### 3) UI minimal (requisito cliente)
| ID | Task | Output atteso | Stato | Note / Evidenze |
|---|------|---------------|------|-----------------|
| T3.1 | Disabilitare/ rimuovere Global Search | Nessuna search bar nel portale | ✅ |
| T3.2 | Nascondere Knowledge | Nessun menu/pagina KB | ✅ |
| T3.3 | Disabilitare Topics / Q&A | Nessun Ask a question / topics | ✅ |

### 4) Dati: “Richiesta di Intervento”
| ID | Task | Output atteso | Stato | Note / Evidenze |
|---|------|---------------|------|-----------------|
| T4.1 | Creare campo Case `Tipo_Case__c` (picklist) | Valore “Richiesta di Intervento” disponibile | ✅ | Deploy `0AfgK00000GkimRSAR` (Tooling conferma il campo; in SOQL potrebbe richiedere propagazione). |
| T4.1b | Dare FLS su `Case.Tipo_Case__c` agli utenti esterni | Campo visibile/editabile in portale | ✅ | Permset **PS_TestMoro_Case_RDI** deploy `0AfgK00000GkqYfSAJ` e assegnato.
| T4.1c | Record Type “Richiesta di Intervento” su Case + layout + default profilo esterno | Utente esterno crea sempre RDI | ✅ | RecordType `Case.Richiesta_di_Intervento` (Id `012gK000003klyHQAQ`) + layout + profilo. Deploy `0AfgK00000GktWXSAZ`.
| T4.2 | Abilitare creazione "Nuova Richiesta" nel portale | New Case usa record type default + Origin=Web | ✅ | NavigationMenu item "Nuova richiesta" → `/createrecord/Case`. Deploy `0AfgK00000GlCe1SAF`. Publish `08PgK00000OwJcMUAV` (Complete). RecordType RDI + Origin=Web default verificati funzionanti. |
| T4.3 | Lista "Le mie richieste" filtrata (solo RDI aperti) | Lista pulita e coerente | ✅ | NavigationMenu item "Le mie richieste" → `/case` (SalesforceObject type). Deploy `0AfgK00000GlCe1SAF`. Publish `08PgK00000OwJcMUAV` (Complete). ListView `My_Richieste_di_Intervento` disponibile per selezione manuale. Limitazione: defaultListViewId non deployabile via metadata. |

### 5) Destinazioni (multi-sede)
| ID | Task | Output atteso | Stato | Note / Evidenze |
|---|------|---------------|------|-----------------|
| T5.1 | Creare modello demo Account parent/child (Cliente → Destinazioni) | 1 Cliente + 3 Destinazioni | ⬜ |
| T5.2 | Creare junction `Contact_Destinazione__c` | Associazione Contact↔Destinazione | ⬜ |

---

## Link utili (org-specific)
- Sito (live): `https://orgfarm-c5ba1be235-dev-ed.develop.my.site.com/testMoro`
- Setup All Sites: `https://orgfarm-c5ba1be235-dev-ed.develop.my.salesforce-setup.com/lightning/setup/SetupNetworks/home`
- Case → Record Types: `https://orgfarm-c5ba1be235-dev-ed.develop.my.salesforce-setup.com/lightning/setup/ObjectManager/Case/RecordTypes/view`
- Case → List Views (UI): `https://orgfarm-c5ba1be235-dev-ed.develop.lightning.force.com/lightning/o/Case/list`
