#!/usr/bin/env python3
"""Calculate expected field permissions from local metadata."""
import xml.etree.ElementTree as ET
import json
from pathlib import Path

NS = {'sf': 'http://soap.sforce.com/2006/04/metadata'}

def get_custom_fields(obj_path, exclude_required=True):
    """Extract custom field fullNames from object fields directory.

    Args:
        obj_path: Path to object directory
        exclude_required: If True, exclude fields with required=true (cannot have FLS via Permission Set)
    """
    fields_dir = obj_path / 'fields'
    if not fields_dir.exists():
        return []

    custom_fields = []
    for field_file in fields_dir.glob('*.field-meta.xml'):
        try:
            tree = ET.parse(field_file)
            root = tree.getroot()
            fullname_elem = root.find('sf:fullName', NS)
            if fullname_elem is not None:
                fullname = fullname_elem.text
                # Only custom fields (ending with __c)
                if fullname and fullname.endswith('__c'):
                    # Check if required=true
                    if exclude_required:
                        required_elem = root.find('sf:required', NS)
                        is_required = required_elem is not None and required_elem.text == 'true'

                        # Also check for type=MasterDetail (always required)
                        type_elem = root.find('sf:type', NS)
                        is_master_detail = type_elem is not None and type_elem.text == 'MasterDetail'

                        if is_required or is_master_detail:
                            print(f"  EXCLUDED (required): {fullname}")
                            continue

                    custom_fields.append(fullname)
        except Exception as e:
            print(f"WARNING: Error parsing {field_file}: {e}")

    return sorted(custom_fields)

def main():
    base_path = Path(__file__).parent.parent / 'elco-salesforce' / 'force-app' / 'main' / 'default' / 'objects'

    # Map objects to fields
    account_fields = get_custom_fields(base_path / 'Account')
    quote_fields = get_custom_fields(base_path / 'Quote')
    qli_fields = get_custom_fields(base_path / 'QuoteLineItem')
    visit_report_fields = get_custom_fields(base_path / 'Visit_Report__c')
    visit_attendee_fields = get_custom_fields(base_path / 'Visit_Attendee__c')
    techspec_fields = get_custom_fields(base_path / 'Account_Tech_Spec__c')

    # Build expected FLS per permission set
    # Note: we prefix with Object.Field notation
    expected = {
        'Quote_Operator': (
            [f'Account.{f}' for f in account_fields] +
            [f'Quote.{f}' for f in quote_fields] +
            [f'QuoteLineItem.{f}' for f in qli_fields]
        ),
        'Visit_Operator': (
            [f'Visit_Report__c.{f}' for f in visit_report_fields] +
            [f'Visit_Attendee__c.{f}' for f in visit_attendee_fields]
        ),
        'TechSpec_Operator': (
            [f'Account_Tech_Spec__c.{f}' for f in techspec_fields]
        )
    }

    # Sort for consistency
    for k in expected:
        expected[k] = sorted(expected[k])

    # Save JSON
    output_path = Path(__file__).parent.parent / 'raw' / 'security' / 'expected_fields.json'
    with open(output_path, 'w') as f:
        json.dump(expected, f, indent=2)

    print(f"Saved to {output_path}")

    # Print summary
    print("\n=== Expected Fields Summary ===")
    for ps_name, fields in expected.items():
        print(f"\n{ps_name}: {len(fields)} expected fields")
        for field in fields[:10]:
            print(f"  - {field}")
        if len(fields) > 10:
            print(f"  ... and {len(fields) - 10} more")

if __name__ == '__main__':
    main()
