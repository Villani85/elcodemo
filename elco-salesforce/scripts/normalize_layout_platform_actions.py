#!/usr/bin/env python3
"""
Normalize platformActionList elements in layouts to eliminate duplicate IDs.
Removes platformActionListId elements and merges duplicate actionListContext='Record' blocks.
"""
import xml.etree.ElementTree as ET
import os

# Salesforce metadata namespace
NS = {'m': 'http://soap.sforce.com/2006/04/metadata'}
ET.register_namespace('', NS['m'])

LAYOUT_FILES = [
    "force-app/main/default/layouts/Account-Account Layout.layout-meta.xml",
    "force-app/main/default/layouts/Opportunity-Opportunity Layout.layout-meta.xml"
]

def normalize_layout(layout_file):
    """
    Normalize a layout file by:
    1. Removing all platformActionListId elements
    2. Merging duplicate platformActionList blocks with actionListContext='Record'
    3. Deduplicating platformActionListItems by actionName|actionType

    Returns dict with stats.
    """
    tree = ET.parse(layout_file)
    root = tree.getroot()

    stats = {
        'file': layout_file,
        'platformActionListId_removed': 0,
        'recordActionLists_before': 0,
        'recordActionLists_after': 0,
        'items_before': 0,
        'items_after': 0,
        'merge_performed': False
    }

    # Step 1: Remove all platformActionListId elements
    for pal in root.findall('.//m:platformActionList', NS):
        pal_id_elem = pal.find('m:platformActionListId', NS)
        if pal_id_elem is not None:
            pal.remove(pal_id_elem)
            stats['platformActionListId_removed'] += 1

    # Step 2: Find all platformActionList with actionListContext='Record'
    record_pals = []
    for pal in root.findall('.//m:platformActionList', NS):
        context = pal.find('m:actionListContext', NS)
        if context is not None and context.text == 'Record':
            record_pals.append(pal)

    stats['recordActionLists_before'] = len(record_pals)

    # Count items before merge
    for pal in record_pals:
        items = pal.findall('m:platformActionListItems', NS)
        stats['items_before'] += len(items)

    # Step 3: If multiple Record platformActionLists, merge into first one
    if len(record_pals) > 1:
        primary = record_pals[0]
        stats['merge_performed'] = True

        # Collect all items from secondary lists
        for secondary in record_pals[1:]:
            items = secondary.findall('m:platformActionListItems', NS)
            for item in items:
                # Move item to primary
                primary.append(item)
            # Remove secondary from root
            root.remove(secondary)

    # Step 4: Deduplicate items in all remaining platformActionLists with actionListContext='Record'
    record_pals = []
    for pal in root.findall('.//m:platformActionList', NS):
        context = pal.find('m:actionListContext', NS)
        if context is not None and context.text == 'Record':
            record_pals.append(pal)

    for pal in record_pals:
        items = pal.findall('m:platformActionListItems', NS)
        seen = set()
        to_remove = []

        for item in items:
            action_name = item.find('m:actionName', NS)
            action_type = item.find('m:actionType', NS)

            if action_name is not None and action_type is not None:
                # Use actionName|actionType as unique key
                key = f"{action_name.text}|{action_type.text}"
                if key in seen:
                    to_remove.append(item)
                else:
                    seen.add(key)

        for item in to_remove:
            pal.remove(item)

    # Count after
    stats['recordActionLists_after'] = len(record_pals)
    for pal in record_pals:
        items = pal.findall('m:platformActionListItems', NS)
        stats['items_after'] += len(items)

    # Write back
    tree.write(layout_file, encoding='utf-8', xml_declaration=True)

    return stats

def main():
    report_lines = []
    report_lines.append("# Platform Action List Normalization Report\\n\\n")

    total_id_removed = 0
    total_merges = 0

    for layout_file in LAYOUT_FILES:
        if not os.path.exists(layout_file):
            print(f"[SKIP] {layout_file}: File not found")
            report_lines.append(f"## {os.path.basename(layout_file)}\\n")
            report_lines.append(f"- Status: NOT FOUND\\n\\n")
            continue

        stats = normalize_layout(layout_file)
        total_id_removed += stats['platformActionListId_removed']
        if stats['merge_performed']:
            total_merges += 1

        print(f"[OK] {os.path.basename(layout_file)}:")
        print(f"  - platformActionListId removed: {stats['platformActionListId_removed']}")
        print(f"  - recordActionLists: {stats['recordActionLists_before']} -> {stats['recordActionLists_after']}")
        print(f"  - items: {stats['items_before']} -> {stats['items_after']}")
        print(f"  - merge performed: {stats['merge_performed']}")

        report_lines.append(f"## {os.path.basename(layout_file)}\\n")
        report_lines.append(f"- File: `{layout_file}`\\n")
        report_lines.append(f"- platformActionListId removed: {stats['platformActionListId_removed']}\\n")
        report_lines.append(f"- recordActionLists: {stats['recordActionLists_before']} -> {stats['recordActionLists_after']}\\n")
        report_lines.append(f"- Items: {stats['items_before']} -> {stats['items_after']}\\n")
        report_lines.append(f"- Merge performed: {stats['merge_performed']}\\n")
        report_lines.append(f"- Status: [OK] Normalized\\n\\n")

    # Summary
    report_lines.append(f"## Summary\\n")
    report_lines.append(f"- Total platformActionListId removed: {total_id_removed}\\n")
    report_lines.append(f"- Total merges performed: {total_merges}\\n")
    report_lines.append(f"\\n**Result**: Layouts normalized and ready for patching.\\n")

    with open("raw/p5_fix/normalize_report.md", "w") as f:
        f.writelines(report_lines)

    print(f"\\n[OK] Report saved to raw/p5_fix/normalize_report.md")

if __name__ == '__main__':
    main()
