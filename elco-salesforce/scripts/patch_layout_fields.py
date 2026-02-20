#!/usr/bin/env python3
"""
Patch layouts to add custom field sections.
"""
import xml.etree.ElementTree as ET
import os

# Namespace for Salesforce metadata XML
NS = {'': 'http://soap.sforce.com/2006/04/metadata'}
ET.register_namespace('', NS[''])

# Field sections to add per object
FIELD_SECTIONS_BY_OBJECT = {
    'Account': [
        {
            'label': 'CRIF',
            'columns': 2,
            'fields': [
                'Partita_IVA__c',
                'CRIF_Last_Status__c',
                'CRIF_Last_Refresh__c',
                'CRIF_Stato_Attivita__c',
                'CRIF_Fatturato__c',
                'CRIF_Fatturato_Anno__c',
                'CRIF_Numero_Dipendenti__c',
                'CRIF_EBITDA__c',
                'CRIF_Valore_Credito__c',
                'CRIF_Company_Id__c',
                'CRIF_VAT_Normalized__c',
                'CRIF_Real_Estate_Lease_Score__c',
                'CRIF_Factoring_Score__c',
                'CRIF_DnB_Rating__c',
                'CRIF_Has_Delinquency_Notices__c',
                'CRIF_Has_Negative_Notices__c',
                'CRIF_Has_Bankruptcy_Notices__c',
            ]
        },
        {
            'label': 'CRIF - Tecnico',
            'columns': 1,
            'fields': [
                'CRIF_Last_Http_Status__c',
                'CRIF_Correlation_Id__c',
                'CRIF_Last_Error__c',
                'CRIF_Last_Request_Timestamp__c',
                'CRIF_Last_Response_Timestamp__c',
                'CRIF_Last_Duration_ms__c',
                'CRIF_Last_Raw_JSON__c',
            ]
        },
        {
            'label': 'Prerequisiti Offerta',
            'columns': 2,
            'fields': [
                'Tolleranze_Default__c',
                'Solder_Default__c',
                'Silkscreen_Default__c',
                'Finish_Default__c',
                'Spessore_Default__c',
                'ERP_Customer_Code__c',
                'Prerequisiti_Note__c',
            ]
        },
        {
            'label': 'Amministrazione / Zucchetti',
            'columns': 2,
            'fields': [
                'Admin_Fatturato_Effettivo__c',
                'Admin_Last_Status__c',
                'Admin_Last_Refresh__c',
            ]
        },
        {
            'label': 'Tableau',
            'columns': 2,
            'fields': [
                'Tableau_Customer_Key__c',
                'Tableau_Last_Data_Refresh__c',
            ]
        },
    ],
    'Quote': [
        {
            'label': 'Offerta (Quote)',
            'columns': 2,
            'fields': [
                'Inside_Sales__c',
                'Num_Circuiti__c',
                'Giorni_Consegna__c',
                'Servizio__c',
                'Servizio_90_10__c',
                'Trasporto__c',
                'Anagrafica_Contatto__c',
                'Purchase_Order__c',
                'Customer_Code_Snapshot__c',
                'Note_Special_Needs__c',
            ]
        },
    ],
    'QuoteLineItem': [
        {
            'label': 'Riga Offerta',
            'columns': 2,
            'fields': [
                'Tipologia_Prodotto__c',
                'Materiale__c',
                'Materiale_Custom_Value__c',
                'Spessore_Complessivo__c',
                'Spessore_Custom_Value__c',
                'Spessore_Rame_Esterni__c',
                'Rame_Custom_Value__c',
                'Finish__c',
                'Solder_Specifico__c',
                'Silkscreen_Specifico__c',
                'Dimensioni_Array__c',
                'Internal_Circuit_Code__c',
                'Customer_Circuit_Code__c',
            ]
        },
    ],
    'Visit_Report__c': [
        {
            'label': 'Follow-up',
            'columns': 2,
            'fields': [
                'FollowUp_Sent__c',
                'FollowUp_Sent_On__c',
            ]
        },
    ],
    'Opportunity': [],  # No custom fields to add
}

def find_or_create_section(root, section_label, columns=2):
    """
    Find existing section by label or create new one.

    Args:
        root: XML root element
        section_label: Section label to find/create
        columns: Number of columns (1 or 2)

    Returns:
        layoutSections element
    """
    # Find existing section
    for section in root.findall('.//layoutSections', NS):
        label_elem = section.find('label', NS)
        if label_elem is not None and label_elem.text == section_label:
            return section

    # Find insertion point before relatedLists
    related_lists = root.find('.//relatedLists', NS)
    if related_lists is not None:
        parent_list = list(root)
        insert_index = parent_list.index(related_lists)
    else:
        # Insert at end
        insert_index = len(root)

    # Create new section with proper namespace
    ns_uri = NS['']
    section = ET.Element(f'{{{ns_uri}}}layoutSections')

    # Add customLabel
    custom_label = ET.SubElement(section, f'{{{ns_uri}}}customLabel')
    custom_label.text = 'true'

    # Add detailHeading
    detail_heading = ET.SubElement(section, f'{{{ns_uri}}}detailHeading')
    detail_heading.text = 'true'

    # Add editHeading
    edit_heading = ET.SubElement(section, f'{{{ns_uri}}}editHeading')
    edit_heading.text = 'true'

    # Add label
    label = ET.SubElement(section, f'{{{ns_uri}}}label')
    label.text = section_label

    # Add layoutColumns
    for _ in range(columns):
        ET.SubElement(section, f'{{{ns_uri}}}layoutColumns')

    # Add style
    style = ET.SubElement(section, f'{{{ns_uri}}}style')
    if columns == 1:
        style.text = 'OneColumn'
    else:
        style.text = 'TwoColumnsTopToBottom'

    # Insert into tree
    root.insert(insert_index, section)

    return section

def get_fields_in_section(section):
    """
    Get set of field names already in section.

    Args:
        section: layoutSections element

    Returns:
        Set of field names
    """
    fields = set()
    for column in section.findall('layoutColumns', NS):
        for item in column.findall('layoutItems', NS):
            field_elem = item.find('field', NS)
            if field_elem is not None:
                fields.add(field_elem.text)
    return fields

def add_field_to_section(section, field_name, column_index=0):
    """
    Add a field to a section.

    Args:
        section: layoutSections element
        field_name: Field API name
        column_index: Column index (0 or 1)
    """
    columns = section.findall('layoutColumns', NS)

    # Debug: check if columns were created but not found
    if len(columns) == 0:
        # Try without namespace
        columns_no_ns = section.findall('layoutColumns')
        if len(columns_no_ns) > 0:
            print(f"WARNING: Found {len(columns_no_ns)} columns without namespace for field {field_name}")
            columns = columns_no_ns

    if len(columns) <= column_index:
        raise ValueError(f"Section does not have column {column_index}, found {len(columns)} columns")

    column = columns[column_index]

    # Create layoutItem with proper namespace
    ns_uri = NS['']
    item = ET.SubElement(column, f'{{{ns_uri}}}layoutItems')

    # Add behavior
    behavior = ET.SubElement(item, f'{{{ns_uri}}}behavior')
    behavior.text = 'Edit'

    # Add field
    field = ET.SubElement(item, f'{{{ns_uri}}}field')
    field.text = field_name

def patch_layout(layout_file, object_name):
    """
    Patch a layout file to add field sections.

    Args:
        layout_file: Path to layout XML file
        object_name: Object name

    Returns:
        Dict with stats (sections_created, fields_added, fields_skipped)
    """
    sections_to_add = FIELD_SECTIONS_BY_OBJECT.get(object_name, [])
    if not sections_to_add:
        return {'sections_created': 0, 'fields_added': 0, 'fields_skipped': 0}

    # Parse XML
    tree = ET.parse(layout_file)
    root = tree.getroot()

    stats = {'sections_created': 0, 'fields_added': 0, 'fields_skipped': 0}

    # Get count of existing sections before patching
    existing_section_labels = set()
    for section in root.findall('.//layoutSections', NS):
        label_elem = section.find('label', NS)
        if label_elem is not None:
            existing_section_labels.add(label_elem.text)

    for section_def in sections_to_add:
        section_label = section_def['label']
        columns = section_def.get('columns', 2)
        fields = section_def['fields']

        # Track if this is a new section
        is_new = section_label not in existing_section_labels

        # Find or create section
        section = find_or_create_section(root, section_label, columns)

        if is_new:
            stats['sections_created'] += 1
            existing_section_labels.add(section_label)

        # Get existing fields
        existing_fields = get_fields_in_section(section)

        # Add missing fields
        for i, field_name in enumerate(fields):
            if field_name in existing_fields:
                stats['fields_skipped'] += 1
                continue

            # Add to alternating columns
            column_index = i % columns
            add_field_to_section(section, field_name, column_index)
            stats['fields_added'] += 1

    # Write back
    tree.write(layout_file, encoding='utf-8', xml_declaration=True)

    return stats

def main():
    # Read selected layouts
    selected_layouts = {}
    with open('raw/p5/selected_layouts.txt', 'r') as f:
        for line in f:
            obj, layout_name = line.strip().split('=')
            selected_layouts[obj] = layout_name

    # Map object names to file names
    layout_files = {
        obj: f"force-app/main/default/layouts/{layout_name}.layout-meta.xml"
        for obj, layout_name in selected_layouts.items()
    }

    # Patch each layout
    report_lines = []
    report_lines.append("# Layout Field Patch Report\n\n")
    total_sections = 0
    total_added = 0
    total_skipped = 0

    for obj, layout_file in layout_files.items():
        if not os.path.exists(layout_file):
            print(f"[SKIP] {obj}: Layout file not found")
            report_lines.append(f"## {obj}\n")
            report_lines.append(f"- Status: NOT FOUND\n\n")
            continue

        stats = patch_layout(layout_file, obj)
        total_sections += stats['sections_created']
        total_added += stats['fields_added']
        total_skipped += stats['fields_skipped']

        print(f"[OK] {obj}: Sections={stats['sections_created']}, Added={stats['fields_added']}, Skipped={stats['fields_skipped']}")

        report_lines.append(f"## {obj}\n")
        report_lines.append(f"- File: {layout_file}\n")
        report_lines.append(f"- Sections created: {stats['sections_created']}\n")
        report_lines.append(f"- Fields added: {stats['fields_added']}\n")
        report_lines.append(f"- Fields skipped (already present): {stats['fields_skipped']}\n\n")

    # Write report
    report_lines.append(f"## Summary\n")
    report_lines.append(f"- Total sections created: {total_sections}\n")
    report_lines.append(f"- Total fields added: {total_added}\n")
    report_lines.append(f"- Total fields skipped: {total_skipped}\n")

    with open('raw/p5/layout_field_patch_report.md', 'w') as f:
        f.writelines(report_lines)

    print(f"\n[OK] Total: Sections={total_sections}, Added={total_added}, Skipped={total_skipped}")
    print(f"[OK] Report saved to raw/p5/layout_field_patch_report.md")

if __name__ == '__main__':
    main()
