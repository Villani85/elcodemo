#!/usr/bin/env python3
"""
Patch Account and Opportunity layouts with required Quick Actions.
Ensures single platformActionList with actionListContext='Record' and adds missing actions.
"""
import xml.etree.ElementTree as ET
import os

# Salesforce metadata namespace
NS = {'m': 'http://soap.sforce.com/2006/04/metadata'}
ET.register_namespace('', NS['m'])

# Actions to add per layout
ACTIONS_BY_LAYOUT = {
    "force-app/main/default/layouts/Account-Account Layout.layout-meta.xml": [
        'Account.CRIF_Aggiorna_Dati',
        'Account.CRIF_Storico',
        'Account.Storico_Offerte',
        'Account.Gestisci_Specifiche_Tecniche',
        'Account.Crea_Report_Visita'
    ],
    "force-app/main/default/layouts/Opportunity-Opportunity Layout.layout-meta.xml": [
        'Opportunity.Crea_Offerta'
    ]
}

def patch_layout(layout_file, actions_to_add):
    """
    Patch a layout file with Quick Actions.

    Args:
        layout_file: Path to layout XML file
        actions_to_add: List of action names to add

    Returns:
        Tuple of (added_count, skipped_count)
    """
    if not actions_to_add:
        return 0, 0

    # Parse XML
    tree = ET.parse(layout_file)
    root = tree.getroot()

    # Find platformActionList with actionListContext='Record'
    target_list = None
    for pal in root.findall('.//m:platformActionList', NS):
        context_elem = pal.find('m:actionListContext', NS)
        if context_elem is not None and context_elem.text == 'Record':
            target_list = pal
            break

    if target_list is None:
        # Create new platformActionList at end of existing platformActionLists
        # Find last platformActionList to insert after it
        existing_pals = root.findall('.//m:platformActionList', NS)
        ns_uri = NS['m']
        target_list = ET.Element(f'{{{ns_uri}}}platformActionList')

        if existing_pals:
            # Insert after last platformActionList
            parent_list = list(root)
            last_pal = existing_pals[-1]
            insert_index = parent_list.index(last_pal) + 1
            root.insert(insert_index, target_list)
        else:
            # No platformActionLists exist, append at end
            root.append(target_list)

        # Add actionListContext
        context_elem = ET.SubElement(target_list, f'{{{ns_uri}}}actionListContext')
        context_elem.text = 'Record'

    # Get existing action names and types
    existing_actions = set()
    for item in target_list.findall('m:platformActionListItems', NS):
        action_name_elem = item.find('m:actionName', NS)
        action_type_elem = item.find('m:actionType', NS)
        if action_name_elem is not None and action_type_elem is not None:
            key = f"{action_name_elem.text}|{action_type_elem.text}"
            existing_actions.add(key)

    # Add missing actions
    added = 0
    skipped = 0
    ns_uri = NS['m']

    # Get current max sortOrder
    max_sort_order = 0
    for item in target_list.findall('m:platformActionListItems', NS):
        sort_order_elem = item.find('m:sortOrder', NS)
        if sort_order_elem is not None:
            try:
                max_sort_order = max(max_sort_order, int(sort_order_elem.text))
            except:
                pass

    for action_name in actions_to_add:
        key = f"{action_name}|QuickAction"
        if key in existing_actions:
            skipped += 1
            continue

        # Add new action item
        item = ET.SubElement(target_list, f'{{{ns_uri}}}platformActionListItems')
        action_name_elem = ET.SubElement(item, f'{{{ns_uri}}}actionName')
        action_name_elem.text = action_name
        action_type_elem = ET.SubElement(item, f'{{{ns_uri}}}actionType')
        action_type_elem.text = 'QuickAction'
        sort_order_elem = ET.SubElement(item, f'{{{ns_uri}}}sortOrder')
        sort_order_elem.text = str(max_sort_order + added + 1)

        added += 1
        existing_actions.add(key)

    # Write back
    tree.write(layout_file, encoding='utf-8', xml_declaration=True)

    return added, skipped

def main():
    report_lines = []
    report_lines.append("# Quick Actions Patch Report\\n\\n")

    total_added = 0
    total_skipped = 0

    for layout_file, actions in ACTIONS_BY_LAYOUT.items():
        if not os.path.exists(layout_file):
            print(f"[SKIP] {os.path.basename(layout_file)}: File not found")
            report_lines.append(f"## {os.path.basename(layout_file)}\\n")
            report_lines.append(f"- Status: NOT FOUND\\n\\n")
            continue

        added, skipped = patch_layout(layout_file, actions)
        total_added += added
        total_skipped += skipped

        print(f"[OK] {os.path.basename(layout_file)}: Added {added}, Skipped {skipped}")

        report_lines.append(f"## {os.path.basename(layout_file)}\\n")
        report_lines.append(f"- File: `{layout_file}`\\n")
        report_lines.append(f"- Actions added: {added}\\n")
        report_lines.append(f"- Actions skipped (already present): {skipped}\\n")
        report_lines.append(f"- Target actions:\\n")
        for action in actions:
            status = "[ADDED]" if added > 0 else "[SKIPPED]"
            report_lines.append(f"  - {action}\\n")
        report_lines.append(f"\\n")

    # Summary
    report_lines.append(f"## Summary\\n")
    report_lines.append(f"- Total actions added: {total_added}\\n")
    report_lines.append(f"- Total actions skipped: {total_skipped}\\n")
    report_lines.append(f"\\n**Result**: Layouts patched and ready for deployment.\\n")

    with open("raw/p5_fix/action_patch_report.md", "w") as f:
        f.writelines(report_lines)

    print(f"\\n[OK] Total: Added {total_added}, Skipped {total_skipped}")
    print(f"[OK] Report saved to raw/p5_fix/action_patch_report.md")

if __name__ == '__main__':
    main()
