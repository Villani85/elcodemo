#!/usr/bin/env python3
"""
Patch layouts to add Quick Actions to Lightning Experience Actions section.
"""
import xml.etree.ElementTree as ET
import os
from pathlib import Path

# Namespace for Salesforce metadata XML
NS = {'': 'http://soap.sforce.com/2006/04/metadata'}
ET.register_namespace('', NS[''])

# Actions to add per object
ACTIONS_BY_OBJECT = {
    'Account': [
        'Account.CRIF_Aggiorna_Dati',
        'Account.CRIF_Storico',
        'Account.Storico_Offerte',
        'Account.Gestisci_Specifiche_Tecniche',
        'Account.Crea_Report_Visita',
    ],
    'Opportunity': [
        'Opportunity.Crea_Offerta',
    ],
    'Quote': [
        'Quote.Aggiungi_Riga_Offerta',
    ],
    'Visit_Report__c': [
        'Visit_Report__c.Invia_Followup',
    ],
    'QuoteLineItem': [],  # No actions for QuoteLineItem
}

def patch_layout(layout_file, object_name):
    """
    Patch a layout file to add quick actions.

    Args:
        layout_file: Path to layout XML file
        object_name: Object name (Account, Opportunity, etc.)

    Returns:
        Tuple of (added_count, skipped_count)
    """
    actions_to_add = ACTIONS_BY_OBJECT.get(object_name, [])
    if not actions_to_add:
        return 0, 0

    # Parse XML
    tree = ET.parse(layout_file)
    root = tree.getroot()

    # Find or create platformActionList with actionListContext "Record" (Lightning Experience)
    platform_action_lists = root.findall('.//platformActionList', NS)
    target_list = None
    for pal in platform_action_lists:
        context_elem = pal.find('actionListContext', NS)
        if context_elem is not None and context_elem.text == 'Record':
            target_list = pal
            break

    if target_list is None:
        # Create new platformActionList before quickActionList
        quick_action_list = root.find('.//quickActionList', NS)
        if quick_action_list is not None:
            # Insert before quickActionList
            parent_list = list(root)
            insert_index = parent_list.index(quick_action_list)
            target_list = ET.Element('platformActionList')
            root.insert(insert_index, target_list)
        else:
            # Append at end
            target_list = ET.SubElement(root, 'platformActionList')

        # Add actionListContext
        context_elem = ET.SubElement(target_list, 'actionListContext')
        context_elem.text = 'Record'

    # Get existing action names
    existing_actions = set()
    for item in target_list.findall('platformActionListItems', NS):
        action_name_elem = item.find('actionName', NS)
        if action_name_elem is not None:
            existing_actions.add(action_name_elem.text)

    # Add missing actions
    added = 0
    skipped = 0
    for action_name in actions_to_add:
        if action_name in existing_actions:
            skipped += 1
            continue

        # Add new action item
        item = ET.SubElement(target_list, 'platformActionListItems')
        action_name_elem = ET.SubElement(item, 'actionName')
        action_name_elem.text = action_name
        action_type_elem = ET.SubElement(item, 'actionType')
        action_type_elem.text = 'QuickAction'
        sortOrder_elem = ET.SubElement(item, 'sortOrder')
        sortOrder_elem.text = str(len(existing_actions) + added)

        added += 1
        existing_actions.add(action_name)

    # Write back
    tree.write(layout_file, encoding='utf-8', xml_declaration=True)

    return added, skipped

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
    report_lines.append("# Layout Action Patch Report\n")
    total_added = 0
    total_skipped = 0

    for obj, layout_file in layout_files.items():
        if not os.path.exists(layout_file):
            print(f"[SKIP] {obj}: Layout file not found: {layout_file}")
            report_lines.append(f"## {obj}\n")
            report_lines.append(f"- File: {layout_file}\n")
            report_lines.append(f"- Status: NOT FOUND\n\n")
            continue

        added, skipped = patch_layout(layout_file, obj)
        total_added += added
        total_skipped += skipped

        print(f"[OK] {obj}: Added {added}, Skipped {skipped}")
        report_lines.append(f"## {obj}\n")
        report_lines.append(f"- File: {layout_file}\n")
        report_lines.append(f"- Actions added: {added}\n")
        report_lines.append(f"- Actions skipped (already present): {skipped}\n")
        report_lines.append(f"- Target actions: {', '.join(ACTIONS_BY_OBJECT.get(obj, []))}\n\n")

    # Write report
    report_lines.append(f"## Summary\n")
    report_lines.append(f"- Total actions added: {total_added}\n")
    report_lines.append(f"- Total actions skipped: {total_skipped}\n")

    with open('raw/p5/layout_action_patch_report.md', 'w') as f:
        f.writelines(report_lines)

    print(f"\n[OK] Total: Added {total_added}, Skipped {total_skipped}")
    print(f"[OK] Report saved to raw/p5/layout_action_patch_report.md")

if __name__ == '__main__':
    main()
