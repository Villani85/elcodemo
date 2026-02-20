#!/usr/bin/env python3
"""Remove blocking FLS from permission sets."""
import xml.etree.ElementTree as ET
import json
from pathlib import Path

NS = {'sf': 'http://soap.sforce.com/2006/04/metadata'}
ET.register_namespace('', 'http://soap.sforce.com/2006/04/metadata')

def remove_fields(permset_file, blocking_fields):
    """Remove specified fields from permission set."""
    if not blocking_fields:
        return

    tree = ET.parse(permset_file)
    root = tree.getroot()

    removed_count = 0
    for fp in root.findall('sf:fieldPermissions', NS):
        field_elem = fp.find('sf:field', NS)
        if field_elem is not None and field_elem.text in blocking_fields:
            root.remove(fp)
            removed_count += 1
            print(f"  REMOVED: {field_elem.text}")

    if removed_count > 0:
        tree.write(permset_file, encoding='UTF-8', xml_declaration=True)
        print(f"Updated {permset_file.name}: {removed_count} blocking fields removed\n")

def main():
    base_path = Path(__file__).parent.parent
    blocking_path = base_path / 'raw' / 'security' / 'fls_blocking_fields.json'

    with open(blocking_path) as f:
        blocking = json.load(f)

    permsets_dir = base_path / 'elco-salesforce' / 'force-app' / 'main' / 'default' / 'permissionsets'

    for ps_name, fields in blocking.items():
        permset_file = permsets_dir / f'{ps_name}.permissionset-meta.xml'

        if not permset_file.exists():
            print(f"WARNING: {permset_file} not found")
            continue

        print(f"=== Removing blocking fields from {ps_name} ===")
        remove_fields(permset_file, fields)

    print("=== Blocking fields removed ===")

if __name__ == '__main__':
    main()
