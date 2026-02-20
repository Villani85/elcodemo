#!/usr/bin/env python3
"""Generate CRIF_Operator and CRIF_Admin permission sets."""
import json
import xml.etree.ElementTree as ET
from pathlib import Path

NS = 'http://soap.sforce.com/2006/04/metadata'
ET.register_namespace('', NS)

def create_permission_set_xml(ps_name, is_admin=False):
    """Create permission set metadata XML."""
    root = ET.Element('PermissionSet', xmlns=NS)

    # label
    label = ET.SubElement(root, 'label')
    label.text = 'CRIF - Admin Access' if is_admin else 'CRIF - Operator Access'

    # hasActivationRequired
    has_activation = ET.SubElement(root, 'hasActivationRequired')
    has_activation.text = 'false'

    # External Credential Principal Access
    ext_cred_access = ET.SubElement(root, 'externalCredentialPrincipalAccesses')
    enabled = ET.SubElement(ext_cred_access, 'enabled')
    enabled.text = 'true'
    ext_cred_principal = ET.SubElement(ext_cred_access, 'externalCredentialPrincipal')
    ext_cred_principal.text = 'CRIF_MOCK_EXT-NamedPrincipal'

    # Object permissions - Account
    obj_perm = ET.SubElement(root, 'objectPermissions')
    allow_create = ET.SubElement(obj_perm, 'allowCreate')
    allow_create.text = 'false'
    allow_delete = ET.SubElement(obj_perm, 'allowDelete')
    allow_delete.text = 'false'
    allow_edit = ET.SubElement(obj_perm, 'allowEdit')
    allow_edit.text = 'true'
    allow_read = ET.SubElement(obj_perm, 'allowRead')
    allow_read.text = 'true'
    modify_all = ET.SubElement(obj_perm, 'modifyAllRecords')
    modify_all.text = 'false'
    object_elem = ET.SubElement(obj_perm, 'object')
    object_elem.text = 'Account'
    view_all = ET.SubElement(obj_perm, 'viewAllRecords')
    view_all.text = 'false'

    return root

def add_field_permission(root, field_api, editable=True, readable=True):
    """Add field permission to permission set."""
    field_perm = ET.SubElement(root, 'fieldPermissions')
    editable_elem = ET.SubElement(field_perm, 'editable')
    editable_elem.text = str(editable).lower()
    field = ET.SubElement(field_perm, 'field')
    field.text = f'Account.{field_api}'
    readable_elem = ET.SubElement(field_perm, 'readable')
    readable_elem.text = str(readable).lower()

def main():
    base_path = Path(__file__).parent.parent

    # Read describe to know which fields exist
    describe_path = base_path / 'raw' / 'crif_p1' / 'describe_account.json'
    with open(describe_path) as f:
        describe_data = json.load(f)

    existing_fields = {f['name'] for f in describe_data['result']['fields']}

    # Read manifest to know our field list
    manifest_path = base_path / 'scripts' / 'crif_account_fields_manifest.json'
    with open(manifest_path) as f:
        manifest = json.load(f)

    # Define field permissions for Operator
    operator_fields = {
        # CRIF Business fields (editable)
        'CRIF_Stato_Attivita__c': True,
        'CRIF_Fatturato__c': True,
        'CRIF_Fatturato_Anno__c': True,
        'CRIF_Numero_Dipendenti__c': True,
        'CRIF_EBITDA__c': True,
        'CRIF_Valore_Credito__c': True,
        'CRIF_Last_Status__c': True,
        'CRIF_Last_Refresh__c': True,
        'CRIF_VAT_Normalized__c': True,
        'CRIF_Company_Id__c': True,
        'CRIF_Real_Estate_Lease_Score__c': True,
        'CRIF_Factoring_Score__c': True,
        'CRIF_DnB_Rating__c': True,
        'CRIF_Has_Delinquency_Notices__c': True,
        'CRIF_Has_Negative_Notices__c': True,
        'CRIF_Has_Bankruptcy_Notices__c': True,

        # CRIF Technical fields (read-only)
        'CRIF_Last_Http_Status__c': False,
        'CRIF_Correlation_Id__c': False,
        'CRIF_Last_Error__c': False,
        'CRIF_Last_Request_Timestamp__c': False,
        'CRIF_Last_Response_Timestamp__c': False,
        'CRIF_Last_Duration_ms__c': False,
        # CRIF_Last_Raw_JSON__c is NOT included for Operator

        # Admin fields (read-only for operator)
        'Admin_Last_Status__c': False,
        'Admin_Last_Refresh__c': False,
        'Admin_Fatturato_Effettivo__c': False,

        # Tableau fields
        'Tableau_Customer_Key__c': True,
        'Tableau_Last_Data_Refresh__c': False,

        # ERP field (if exists)
        'ERP_Customer_Code__c': True,

        # Partita IVA (if created)
        'Partita_IVA__c': True,
    }

    # Admin has all operator fields + Raw JSON + editable admin fields
    admin_fields = operator_fields.copy()
    admin_fields['CRIF_Last_Raw_JSON__c'] = True  # Admin can see Raw JSON
    admin_fields['Admin_Last_Status__c'] = True  # Admin can edit
    admin_fields['Admin_Last_Refresh__c'] = True
    admin_fields['Admin_Fatturato_Effettivo__c'] = True
    admin_fields['Tableau_Last_Data_Refresh__c'] = True

    # Create CRIF_Operator
    print("Generating CRIF_Operator...")
    operator_root = create_permission_set_xml('CRIF_Operator', is_admin=False)
    for field_api, editable in sorted(operator_fields.items()):
        if field_api in existing_fields:
            add_field_permission(operator_root, field_api, editable=editable)
            print(f"  {field_api}: editable={editable}")
        else:
            print(f"  SKIPPED {field_api} (not in org)")

    operator_file = base_path / 'force-app' / 'main' / 'default' / 'permissionsets' / 'CRIF_Operator.permissionset-meta.xml'
    operator_tree = ET.ElementTree(operator_root)
    ET.indent(operator_tree, space='    ')
    operator_tree.write(operator_file, encoding='UTF-8', xml_declaration=True)
    print(f"Saved to {operator_file}\n")

    # Create CRIF_Admin
    print("Generating CRIF_Admin...")
    admin_root = create_permission_set_xml('CRIF_Admin', is_admin=True)
    for field_api, editable in sorted(admin_fields.items()):
        if field_api in existing_fields:
            add_field_permission(admin_root, field_api, editable=editable)
            print(f"  {field_api}: editable={editable}")
        else:
            print(f"  SKIPPED {field_api} (not in org)")

    admin_file = base_path / 'force-app' / 'main' / 'default' / 'permissionsets' / 'CRIF_Admin.permissionset-meta.xml'
    admin_tree = ET.ElementTree(admin_root)
    ET.indent(admin_tree, space='    ')
    admin_tree.write(admin_file, encoding='UTF-8', xml_declaration=True)
    print(f"Saved to {admin_file}\n")

    print("=== Permission sets generated ===")

if __name__ == '__main__':
    main()
