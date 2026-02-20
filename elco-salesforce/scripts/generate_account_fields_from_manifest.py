#!/usr/bin/env python3
"""Generate Account field metadata from manifest."""
import json
import xml.etree.ElementTree as ET
from pathlib import Path
import sys

NS = 'http://soap.sforce.com/2006/04/metadata'
ET.register_namespace('', NS)

def create_field_xml(field_def, api_version='65.0'):
    """Create field metadata XML."""
    root = ET.Element('CustomField', xmlns=NS)

    # fullName
    fullname = ET.SubElement(root, 'fullName')
    fullname.text = field_def['api']

    # label
    label = ET.SubElement(root, 'label')
    label.text = field_def['label']

    # type
    field_type = ET.SubElement(root, 'type')
    field_type.text = field_def['type']

    # Type-specific elements
    if field_def['type'] == 'Text':
        length = ET.SubElement(root, 'length')
        length.text = str(field_def.get('length', 255))

    elif field_def['type'] == 'LongTextArea':
        length = ET.SubElement(root, 'length')
        length.text = str(field_def.get('length', 32768))
        visible_lines = ET.SubElement(root, 'visibleLines')
        visible_lines.text = str(field_def.get('visibleLines', 3))

    elif field_def['type'] == 'Currency':
        precision = ET.SubElement(root, 'precision')
        precision.text = str(field_def.get('precision', 18))
        scale = ET.SubElement(root, 'scale')
        scale.text = str(field_def.get('scale', 2))

    elif field_def['type'] == 'Number':
        precision = ET.SubElement(root, 'precision')
        precision.text = str(field_def.get('precision', 18))
        scale = ET.SubElement(root, 'scale')
        scale.text = str(field_def.get('scale', 0))

    elif field_def['type'] == 'Checkbox':
        default_value = ET.SubElement(root, 'defaultValue')
        default_value.text = str(field_def.get('default', False)).lower()

    elif field_def['type'] == 'Picklist':
        value_set = ET.SubElement(root, 'valueSet')
        restricted = ET.SubElement(value_set, 'restricted')
        restricted.text = str(field_def.get('restricted', True)).lower()

        value_set_def = ET.SubElement(value_set, 'valueSetDefinition')
        for val in field_def.get('values', []):
            value_elem = ET.SubElement(value_set_def, 'value')
            full_name_val = ET.SubElement(value_elem, 'fullName')
            full_name_val.text = val
            default_elem = ET.SubElement(value_elem, 'default')
            default_elem.text = 'false'
            label_val = ET.SubElement(value_elem, 'label')
            label_val.text = val

    elif field_def['type'] == 'DateTime':
        pass  # DateTime doesn't need extra params

    return root

def main():
    base_path = Path(__file__).parent.parent

    # Read describe Account
    describe_path = base_path / 'raw' / 'crif_p1' / 'describe_account.json'
    with open(describe_path) as f:
        describe_data = json.load(f)

    existing_fields = {
        f['name']: f['type']
        for f in describe_data['result']['fields']
    }

    # Read VAT field choice
    vat_choice_path = base_path / 'raw' / 'crif_p1' / 'vat_field_choice.txt'
    vat_field_api = 'Partita_IVA__c'
    if vat_choice_path.exists():
        vat_line = open(vat_choice_path).read().strip()
        if 'VAT_FIELD_API=' in vat_line:
            vat_field_api = vat_line.split('=')[1].strip()

    print(f"VAT Field API: {vat_field_api}")

    # Read manifest
    manifest_path = base_path / 'scripts' / 'crif_account_fields_manifest.json'
    with open(manifest_path) as f:
        manifest = json.load(f)

    # Prepare report
    report = {
        'created': [],
        'updated': [],
        'skipped': [],
        'type_mismatches': []
    }

    fields_dir = base_path / 'force-app' / 'main' / 'default' / 'objects' / 'Account' / 'fields'
    fields_dir.mkdir(parents=True, exist_ok=True)

    for field_def in manifest['fields']:
        api_name = field_def['api']

        # Skip Partita_IVA__c if using standard VAT field
        if api_name == 'Partita_IVA__c' and vat_field_api != 'Partita_IVA__c':
            report['skipped'].append({
                'field': api_name,
                'reason': f'Using standard VAT field: {vat_field_api}'
            })
            print(f"  SKIPPED: {api_name} (using standard {vat_field_api})")
            continue

        # Check if field exists with different type
        if api_name in existing_fields:
            existing_type = existing_fields[api_name]
            manifest_type = field_def['type']

            # Type compatibility check (simplified)
            if existing_type.lower() != manifest_type.lower():
                report['type_mismatches'].append({
                    'field': api_name,
                    'existing_type': existing_type,
                    'manifest_type': manifest_type
                })
                print(f"  TYPE MISMATCH: {api_name} (org: {existing_type}, manifest: {manifest_type})")
                continue

        # Generate field XML
        field_xml = create_field_xml(field_def)

        # Write to file
        field_file = fields_dir / f'{api_name}.field-meta.xml'
        tree = ET.ElementTree(field_xml)
        ET.indent(tree, space='    ')
        tree.write(field_file, encoding='UTF-8', xml_declaration=True)

        if api_name in existing_fields:
            report['updated'].append(api_name)
            print(f"  UPDATED: {api_name}")
        else:
            report['created'].append(api_name)
            print(f"  CREATED: {api_name}")

    # Write report
    report_path = base_path / 'raw' / 'crif_p1' / 'field_generation_report.md'
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write('# Account Fields Generation Report\n\n')
        f.write(f'**VAT Field**: {vat_field_api}\n\n')

        f.write(f'## Created Fields ({len(report["created"])})\n\n')
        for field in report['created']:
            f.write(f'- {field}\n')

        f.write(f'\n## Updated Fields ({len(report["updated"])})\n\n')
        for field in report['updated']:
            f.write(f'- {field}\n')

        f.write(f'\n## Skipped Fields ({len(report["skipped"])})\n\n')
        for item in report['skipped']:
            f.write(f'- {item["field"]}: {item["reason"]}\n')

        f.write(f'\n## Type Mismatches ({len(report["type_mismatches"])})\n\n')
        for item in report['type_mismatches']:
            f.write(f'- **{item["field"]}**: org type `{item["existing_type"]}` != manifest type `{item["manifest_type"]}`\n')

    print(f'\n=== Report saved to {report_path} ===')
    print(f'Created: {len(report["created"])}')
    print(f'Updated: {len(report["updated"])}')
    print(f'Skipped: {len(report["skipped"])}')
    print(f'Type Mismatches: {len(report["type_mismatches"])}')

    # Exit with error if type mismatches
    if report['type_mismatches']:
        print('\nERROR: Type mismatches detected. Please resolve before deploying.')

        mismatch_path = base_path / 'raw' / 'crif_p1' / 'field_type_mismatches.md'
        with open(mismatch_path, 'w', encoding='utf-8') as f:
            f.write('# Field Type Mismatches\n\n')
            f.write('The following fields exist in the org with different types:\n\n')
            for item in report['type_mismatches']:
                f.write(f'- **{item["field"]}**\n')
                f.write(f'  - Org type: `{item["existing_type"]}`\n')
                f.write(f'  - Manifest type: `{item["manifest_type"]}`\n\n')

        print(f'Details written to {mismatch_path}')
        sys.exit(2)

if __name__ == '__main__':
    main()
