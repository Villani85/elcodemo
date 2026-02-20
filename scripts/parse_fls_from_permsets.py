#!/usr/bin/env python3
"""Parse FieldPermissions from PermissionSet XML files."""
import xml.etree.ElementTree as ET
import json
import sys
from pathlib import Path

# Namespace for Salesforce metadata
NS = {'sf': 'http://soap.sforce.com/2006/04/metadata'}

def parse_permset_fls(xml_path):
    """Parse fieldPermissions from a PermissionSet XML file."""
    tree = ET.parse(xml_path)
    root = tree.getroot()

    fields = []
    for fp in root.findall('sf:fieldPermissions', NS):
        field_elem = fp.find('sf:field', NS)
        readable_elem = fp.find('sf:readable', NS)
        editable_elem = fp.find('sf:editable', NS)

        if field_elem is not None:
            field_name = field_elem.text
            readable = readable_elem.text.lower() == 'true' if readable_elem is not None else False
            editable = editable_elem.text.lower() == 'true' if editable_elem is not None else False

            fields.append({
                'field': field_name,
                'readable': readable,
                'editable': editable
            })

    return sorted(fields, key=lambda x: x['field'])

def main():
    base_path = Path(__file__).parent.parent / 'elco-salesforce' / 'force-app' / 'main' / 'default' / 'permissionsets'

    permsets = {
        'Quote_Operator': base_path / 'Quote_Operator.permissionset-meta.xml',
        'Visit_Operator': base_path / 'Visit_Operator.permissionset-meta.xml',
        'TechSpec_Operator': base_path / 'TechSpec_Operator.permissionset-meta.xml'
    }

    result = {}
    for name, path in permsets.items():
        if path.exists():
            result[name] = parse_permset_fls(path)
        else:
            result[name] = []
            print(f"WARNING: {path} not found", file=sys.stderr)

    # Save JSON
    output_path = Path(__file__).parent.parent / 'raw' / 'security' / 'current_fls_in_org.json'
    with open(output_path, 'w') as f:
        json.dump(result, f, indent=2)

    print(f"Saved to {output_path}")

    # Print summary
    print("\n=== FLS Summary (from org metadata) ===")
    for name, fields in result.items():
        print(f"\n{name}: {len(fields)} field permissions")
        for fp in fields[:10]:  # Show first 10
            r = 'R' if fp['readable'] else '-'
            e = 'E' if fp['editable'] else '-'
            print(f"  {r}{e} {fp['field']}")
        if len(fields) > 10:
            print(f"  ... and {len(fields) - 10} more")

if __name__ == '__main__':
    main()
