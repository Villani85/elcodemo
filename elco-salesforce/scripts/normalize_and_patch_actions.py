#!/usr/bin/env python3
"""
Normalize and patch Quote and Visit_Report__c layouts with Quick Actions.
"""
import xml.etree.ElementTree as ET
import os

NS = {'m': 'http://soap.sforce.com/2006/04/metadata'}
ET.register_namespace('', NS['m'])

ACTIONS_BY_LAYOUT = {
    "Quote-Quote Layout": ["Quote.Aggiungi_Riga_Offerta"],
    "Visit_Report__c-Report Visita Layout": ["Visit_Report__c.Invia_Followup"]
}

def normalize_and_patch_layout(layout_file, actions_to_add):
    tree = ET.parse(layout_file)
    root = tree.getroot()
    
    stats = {
        'file': os.path.basename(layout_file),
        'platformActionListId_removed': 0,
        'recordActionLists_before': 0,
        'recordActionLists_after': 0,
        'items_before': 0,
        'items_after': 0,
        'merge_performed': False,
        'actions_added': 0,
        'actions_skipped': 0
    }
    
    # Remove all platformActionListId
    for pal in root.findall('.//m:platformActionList', NS):
        pal_id_elem = pal.find('m:platformActionListId', NS)
        if pal_id_elem is not None:
            pal.remove(pal_id_elem)
            stats['platformActionListId_removed'] += 1
    
    # Find Record platformActionLists
    record_pals = []
    for pal in root.findall('.//m:platformActionList', NS):
        context = pal.find('m:actionListContext', NS)
        if context is not None and context.text == 'Record':
            record_pals.append(pal)
    
    stats['recordActionLists_before'] = len(record_pals)
    
    for pal in record_pals:
        stats['items_before'] += len(pal.findall('m:platformActionListItems', NS))
    
    # Merge if multiple
    if len(record_pals) > 1:
        primary = record_pals[0]
        stats['merge_performed'] = True
        for secondary in record_pals[1:]:
            for item in secondary.findall('m:platformActionListItems', NS):
                primary.append(item)
            root.remove(secondary)
    
    # Get or create target list
    record_pals = [p for p in root.findall('.//m:platformActionList', NS) 
                   if p.find('m:actionListContext', NS) is not None 
                   and p.find('m:actionListContext', NS).text == 'Record']
    
    if record_pals:
        target_list = record_pals[0]
    else:
        ns_uri = NS['m']
        target_list = ET.Element(f'{{{ns_uri}}}platformActionList')
        root.append(target_list)
        context_elem = ET.SubElement(target_list, f'{{{ns_uri}}}actionListContext')
        context_elem.text = 'Record'
    
    # Deduplicate
    items = target_list.findall('m:platformActionListItems', NS)
    seen = set()
    to_remove = []
    
    for item in items:
        action_name = item.find('m:actionName', NS)
        action_type = item.find('m:actionType', NS)
        if action_name is not None and action_type is not None:
            key = f"{action_name.text}|{action_type.text}"
            if key in seen:
                to_remove.append(item)
            else:
                seen.add(key)
    
    for item in to_remove:
        target_list.remove(item)
    
    # Get max sortOrder
    max_sort_order = 0
    for item in target_list.findall('m:platformActionListItems', NS):
        sort_order_elem = item.find('m:sortOrder', NS)
        if sort_order_elem is not None:
            try:
                max_sort_order = max(max_sort_order, int(sort_order_elem.text))
            except:
                pass
    
    # Add actions
    ns_uri = NS['m']
    for action_name in actions_to_add:
        key = f"{action_name}|QuickAction"
        if key in seen:
            stats['actions_skipped'] += 1
            continue
        
        item = ET.SubElement(target_list, f'{{{ns_uri}}}platformActionListItems')
        action_name_elem = ET.SubElement(item, f'{{{ns_uri}}}actionName')
        action_name_elem.text = action_name
        action_type_elem = ET.SubElement(item, f'{{{ns_uri}}}actionType')
        action_type_elem.text = 'QuickAction'
        sort_order_elem = ET.SubElement(item, f'{{{ns_uri}}}sortOrder')
        sort_order_elem.text = str(max_sort_order + stats['actions_added'] + 1)
        
        stats['actions_added'] += 1
        seen.add(key)
    
    # Count after
    record_pals = [p for p in root.findall('.//m:platformActionList', NS) 
                   if p.find('m:actionListContext', NS) is not None 
                   and p.find('m:actionListContext', NS).text == 'Record']
    stats['recordActionLists_after'] = len(record_pals)
    for pal in record_pals:
        stats['items_after'] += len(pal.findall('m:platformActionListItems', NS))
    
    tree.write(layout_file, encoding='utf-8', xml_declaration=True)
    return stats

def main():
    report_lines = []
    report_lines.append("# Quick Actions Normalize & Patch Report\n\n")
    
    total_added = 0
    total_skipped = 0
    
    for layout_name, actions in ACTIONS_BY_LAYOUT.items():
        layout_file = f"force-app/main/default/layouts/{layout_name}.layout-meta.xml"
        
        if not os.path.exists(layout_file):
            print(f"[SKIP] {layout_name}: File not found")
            continue
        
        stats = normalize_and_patch_layout(layout_file, actions)
        total_added += stats['actions_added']
        total_skipped += stats['actions_skipped']
        
        print(f"[OK] {layout_name}:")
        print(f"  - platformActionListId removed: {stats['platformActionListId_removed']}")
        print(f"  - recordActionLists: {stats['recordActionLists_before']} -> {stats['recordActionLists_after']}")
        print(f"  - items: {stats['items_before']} -> {stats['items_after']}")
        print(f"  - merge performed: {stats['merge_performed']}")
        print(f"  - actions added: {stats['actions_added']}")
        print(f"  - actions skipped: {stats['actions_skipped']}")
        
        report_lines.append(f"## {layout_name}\n")
        report_lines.append(f"- platformActionListId removed: {stats['platformActionListId_removed']}\n")
        report_lines.append(f"- recordActionLists: {stats['recordActionLists_before']} -> {stats['recordActionLists_after']}\n")
        report_lines.append(f"- Items: {stats['items_before']} -> {stats['items_after']}\n")
        report_lines.append(f"- Actions added: {stats['actions_added']}\n")
        report_lines.append(f"- Actions skipped: {stats['actions_skipped']}\n\n")
    
    report_lines.append(f"## Summary\n")
    report_lines.append(f"- Total actions added: {total_added}\n")
    report_lines.append(f"- Total actions skipped: {total_skipped}\n")
    
    with open("raw/p5_cli_finish/action_patch_report.md", "w") as f:
        f.writelines(report_lines)
    
    print(f"\n[OK] Total: Added {total_added}, Skipped {total_skipped}")
    print(f"[OK] Report saved to raw/p5_cli_finish/action_patch_report.md")

if __name__ == '__main__':
    main()
