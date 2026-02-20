# Audit - Run Flows Permission

**Data**: 2026-02-20 17:00
**Org ID**: 00Dg5000005Sp7zEAC
**Username**: giuseppe.villani101020.b5bd075bbc5f@agentforce.com
**User ID**: 005g5000003yeP3AAI
**API Version**: 65.0

---

## PermissionSet - PermissionsRunFlow Flags

| Permission Set Name | Label | PermissionsRunFlow |
|---------------------|-------|--------------------|
| CRIF_MOCK_Access | CRIF Mock Access | **FALSE** |
| Quote_Operator | Quote Operator | **FALSE** |
| Setup_Admin_Elco | Setup Admin Elco | **FALSE** |
| TechSpec_Operator | TechSpec Operator | **FALSE** |
| Visit_Operator | Visit Operator | **FALSE** |

**Risultato**: Nessun permission set ha `PermissionsRunFlow=true` in org.

---

## User Permission Set Assignments (RunFlow)

| PermissionSet Name | PermissionsRunFlow (assigned) |
|--------------------|-------------------------------|
| CRIF_MOCK_Access | FALSE |
| Quote_Operator | FALSE |
| Setup_Admin_Elco | FALSE |
| TechSpec_Operator | FALSE |
| Visit_Operator | FALSE |

**Risultato**: L'utente `giuseppe.villani101020.b5bd075bbc5f@agentforce.com` NON ha alcun permesso RunFlow.

---

## Conclusione Audit 1

❌ **PROBLEMA CONFERMATO**: Nessun permission set esistente concede `PermissionsRunFlow=true`.

**Azione richiesta**: Creare un nuovo permission set dedicato `Elco_Run_Flows` con il permesso corretto e assegnarlo all'utente.
