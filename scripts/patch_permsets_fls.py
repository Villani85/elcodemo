#!/usr/bin/env python3
"""Patch permission sets with missing FLS."""
import xml.etree.ElementTree as ET
import json
from pathlib import Path
import shutil

NS = {'sf': 'http://soap.sforce.com/2006/04/metadata'}
ET.register_namespace('', 'http://soap.sforce.com/2006/04/metadata')

def patch_permset(permset_file, missing_fields):
    """Add missing fieldPermissions to a permission set XML."""
    if not missing_fields:
        print(f"No missing fields for {permset_file.name}, skipping")
        return

    # Backup
    backup_file = permset_file.with_suffix('.permissionset-meta.xml.bak')
    shutil.copy2(permset_file, backup_file)
    print(f"Created backup: {backup_file}")

    # Parse XML
    tree = ET.parse(permset_file)
    root = tree.getroot()

    # Get existing fields
    existing_fields = set()
    for fp in root.findall('sf:fieldPermissions', NS):
        field_elem = fp.find('sf:field', NS)
        if field_elem is not None:
            existing_fields.add(field_elem.text)

    # Add missing fields
    added_count = 0
    for field in sorted(missing_fields):
        if field in existing_fields:
            print(f"  SKIP (already exists): {field}")
            continue

        # Create fieldPermissions element
        fp_elem = ET.Element('{http://soap.sforce.com/2006/04/metadata}fieldPermissions')

        # editable
        edit_elem = ET.SubElement(fp_elem, '{http://soap.sforce.com/2006/04/metadata}editable')
        edit_elem.text = 'true'

        # field
        field_elem = ET.SubElement(fp_elem, '{http://soap.sforce.com/2006/04/metadata}field')
        field_elem.text = field

        # readable
        read_elem = ET.SubElement(fp_elem, '{http://soap.sforce.com/2006/04/metadata}readable')
        read_elem.text = 'true'

        # Insert before closing </PermissionSet>
        # Find position to insert (after last fieldPermissions or at beginning)
        insert_pos = 0
        for i, child in enumerate(root):
            if child.tag == '{http://soap.sforce.com/2006/04/metadata}fieldPermissions':
                insert_pos = i + 1

        root.insert(insert_pos, fp_elem)
        added_count += 1
        print(f"  ADDED: {field}")

    # Write back
    tree.write(permset_file, encoding='UTF-8', xml_declaration=True)
    print(f"Patched {permset_file.name}: {added_count} fields added\n")

def main():
    base_path = Path(__file__).parent.parent
    diff_path = base_path / 'raw' / 'security' / 'fls_diff.json'

    # Load diff
    with open(diff_path) as f:
        diff = json.load(f)

    # Patch each permission set
    permsets_dir = base_path / 'elco-salesforce' / 'force-app' / 'main' / 'default' / 'permissionsets'

    for ps_name, data in diff.items():
        permset_file = permsets_dir / f'{ps_name}.permissionset-meta.xml'

        if not permset_file.exists():
            print(f"WARNING: {permset_file} not found, skipping")
            continue

        missing_fields = data['missing_fields']
        if not missing_fields:
            print(f"{ps_name}: No missing fields, OK")
            continue

        print(f"\n=== Patching {ps_name} ===")
        print(f"Missing fields: {len(missing_fields)}")
        patch_permset(permset_file, missing_fields)

    print("\n=== Patch Complete ===")
    print("Next: deploy updated permission sets")

if __name__ == '__main__':
    main()
