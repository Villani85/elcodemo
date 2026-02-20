#!/usr/bin/env python3
"""
Normalize platformActionList elements in layouts to eliminate duplicate IDs.
Removes platformActionListId elements and merges duplicate actionListContext='Record' blocks.
"""
import xml.etree.ElementTree as ET
import os

# Salesforce metadata namespace
NS = {'': 'http://soap.sforce.com/2006/04/metadata'}
ET.register_namespace('', NS[''])

LAYOUT_FILES = [
    "force-app/main/default/layouts/Account-Account Layout.layout-meta.xml",
    "force-app/main/default/layouts/Opportunity-Opportunity Layout.layout-meta.xml"
]

def normalize_layout(layout_file):
    """
    Normalize a layout file by:
    1. Removing all platformActionListId elements
    2. Merging duplicate platformActionList blocks with actionListContext='Record'
    3. Deduplicating platformActionListItems by actionName+actionType

    Returns dict with stats.
    """
    tree = ET.parse(layout_file)
    root = tree.getroot()

    stats = {
        'file': layout_file,
        'platformActionList_before': 0,
        'platformActionList_after': 0,
        'platformActionListId_removed': 0,
        'items_before': 0,
        'items_after': 0,
        'merges_performed': 0,
        'items_deduplicated': 0
    }

    # Find all platformActionList elements
    pal_elements = root.findall('.//platformActionList', NS)
    stats['platformActionList_before'] = len(pal_elements)

    # Step 1: Remove all platformActionListId elements
    for pal in pal_elements:
        pal_id_elem = pal.find('platformActionListId', NS)
        if pal_id_elem is not None:
            pal.remove(pal_id_elem)
            stats['platformActionListId_removed'] += 1

    # Step 2: Find all platformActionList with actionListContext='Record'
    record_pals = []
    for pal in pal_elements:
        context = pal.find('actionListContext', NS)
        if context is not None and context.text == 'Record':
            record_pals.append(pal)

    # Count items before
    for pal in pal_elements:
        items = pal.findall('platformActionListItems', NS)
        stats['items_before'] += len(items)

    # Step 3: If multiple Record platformActionLists, merge into first one
    if len(record_pals) > 1:
        primary = record_pals[0]

        # Collect all items from secondary lists
        for secondary in record_pals[1:]:
            items = secondary.findall('platformActionListItems', NS)
            for item in items:
                # Move item to primary
                primary.append(item)
            # Remove secondary from root
            root.remove(secondary)
            stats['merges_performed'] += 1

    # Step 4: Deduplicate items in all remaining platformActionLists
    # Salesforce doesn't allow duplicate actionName regardless of actionType
    pal_elements = root.findall('.//platformActionList', NS)
    for pal in pal_elements:
        items = pal.findall('platformActionListItems', NS)
        seen = set()
        to_remove = []

        for item in items:
            action_name = item.find('actionName', NS)

            if action_name is not None:
                # Use only actionName as key (not actionType)
                # Salesforce rejects duplicates based on actionName alone
                key = action_name.text
                if key in seen:
                    to_remove.append(item)
                else:
                    seen.add(key)

        for item in to_remove:
            pal.remove(item)

        stats['items_deduplicated'] = len(to_remove)

    # Count after
    pal_elements = root.findall('.//platformActionList', NS)
    stats['platformActionList_after'] = len(pal_elements)

    for pal in pal_elements:
        items = pal.findall('platformActionListItems', NS)
        stats['items_after'] += len(items)

    # Write back
    tree.write(layout_file, encoding='utf-8', xml_declaration=True)

    return stats

def main():
    report_lines = []
    report_lines.append("# Platform Action List Normalization Report\n\n")

    total_id_removed = 0
    total_merges = 0

    for layout_file in LAYOUT_FILES:
        if not os.path.exists(layout_file):
            print(f"[SKIP] {layout_file}: File not found")
            report_lines.append(f"## {layout_file}\n")
            report_lines.append(f"- Status: NOT FOUND\n\n")
            continue

        stats = normalize_layout(layout_file)
        total_id_removed += stats['platformActionListId_removed']
        total_merges += stats['merges_performed']

        print(f"[OK] {os.path.basename(layout_file)}:")
        print(f"  - platformActionList: {stats['platformActionList_before']} -> {stats['platformActionList_after']}")
        print(f"  - platformActionListId removed: {stats['platformActionListId_removed']}")
        print(f"  - Items: {stats['items_before']} -> {stats['items_after']}")
        print(f"  - Items deduplicated: {stats['items_deduplicated']}")
        print(f"  - Merges performed: {stats['merges_performed']}")

        report_lines.append(f"## {os.path.basename(layout_file)}\n")
        report_lines.append(f"- File: `{layout_file}`\n")
        report_lines.append(f"- platformActionList count: {stats['platformActionList_before']} -> {stats['platformActionList_after']}\n")
        report_lines.append(f"- platformActionListId elements removed: {stats['platformActionListId_removed']}\n")
        report_lines.append(f"- platformActionListItems count: {stats['items_before']} -> {stats['items_after']}\n")
        report_lines.append(f"- Duplicate items removed: {stats['items_deduplicated']}\n")
        report_lines.append(f"- Merges performed: {stats['merges_performed']}\n")
        report_lines.append(f"- Status: [OK] Normalized\n\n")

    # Summary
    report_lines.append(f"## Summary\n")
    report_lines.append(f"- Total platformActionListId removed: {total_id_removed}\n")
    report_lines.append(f"- Total merges performed: {total_merges}\n")
    report_lines.append(f"\n**Result**: Layouts normalized and ready for patching.\n")

    with open("raw/p6/normalize_actions_report.md", "w") as f:
        f.writelines(report_lines)

    print(f"\n[OK] Report saved to raw/p6/normalize_actions_report.md")

if __name__ == '__main__':
    main()
