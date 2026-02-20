#!/usr/bin/env python3
"""
Patch Account and Opportunity layouts with required Quick Actions.
"""
import xml.etree.ElementTree as ET
import os

# Salesforce metadata namespace
NS = {'': 'http://soap.sforce.com/2006/04/metadata'}
ET.register_namespace('', NS[''])

# Actions to add per object
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

    # Find or create platformActionList with actionListContext='Record'
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
            ns_uri = NS['']
            target_list = ET.Element(f'{{{ns_uri}}}platformActionList')
            root.insert(insert_index, target_list)
        else:
            # Append at end
            ns_uri = NS['']
            target_list = ET.SubElement(root, f'{{{ns_uri}}}platformActionList')

        # Add actionListContext
        ns_uri = NS['']
        context_elem = ET.SubElement(target_list, f'{{{ns_uri}}}actionListContext')
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
    ns_uri = NS['']

    for action_name in actions_to_add:
        if action_name in existing_actions:
            skipped += 1
            continue

        # Add new action item
        item = ET.SubElement(target_list, f'{{{ns_uri}}}platformActionListItems')
        action_name_elem = ET.SubElement(item, f'{{{ns_uri}}}actionName')
        action_name_elem.text = action_name
        action_type_elem = ET.SubElement(item, f'{{{ns_uri}}}actionType')
        action_type_elem.text = 'QuickAction'
        sort_order_elem = ET.SubElement(item, f'{{{ns_uri}}}sortOrder')
        sort_order_elem.text = str(len(existing_actions) + added)

        added += 1
        existing_actions.add(action_name)

    # Write back
    tree.write(layout_file, encoding='utf-8', xml_declaration=True)

    return added, skipped

def main():
    report_lines = []
    report_lines.append("# Quick Actions Patch Report\n\n")

    total_added = 0
    total_skipped = 0

    for layout_file, actions in ACTIONS_BY_LAYOUT.items():
        if not os.path.exists(layout_file):
            print(f"[SKIP] {os.path.basename(layout_file)}: File not found")
            report_lines.append(f"## {os.path.basename(layout_file)}\n")
            report_lines.append(f"- Status: NOT FOUND\n\n")
            continue

        added, skipped = patch_layout(layout_file, actions)
        total_added += added
        total_skipped += skipped

        print(f"[OK] {os.path.basename(layout_file)}: Added {added}, Skipped {skipped}")

        report_lines.append(f"## {os.path.basename(layout_file)}\n")
        report_lines.append(f"- File: `{layout_file}`\n")
        report_lines.append(f"- Actions added: {added}\n")
        report_lines.append(f"- Actions skipped (already present): {skipped}\n")
        report_lines.append(f"- Target actions:\n")
        for action in actions:
            status = "[SKIPPED]" if action in [actions[i] for i in range(len(actions))][:skipped] else "[ADDED]"
            report_lines.append(f"  - {action}\n")
        report_lines.append(f"\n")

    # Summary
    report_lines.append(f"## Summary\n")
    report_lines.append(f"- Total actions added: {total_added}\n")
    report_lines.append(f"- Total actions skipped: {total_skipped}\n")
    report_lines.append(f"\n**Result**: Layouts patched and ready for deployment.\n")

    with open("raw/p6/action_patch_report.md", "w") as f:
        f.writelines(report_lines)

    print(f"\n[OK] Total: Added {total_added}, Skipped {total_skipped}")
    print(f"[OK] Report saved to raw/p6/action_patch_report.md")

if __name__ == '__main__':
    main()
