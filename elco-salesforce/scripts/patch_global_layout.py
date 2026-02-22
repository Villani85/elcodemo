#!/usr/bin/env python3
"""
Patch Global Publisher Layout to replace Flow Quick Action with LightningComponent Quick Action
"""
import xml.etree.ElementTree as ET
from pathlib import Path

# File path
LAYOUT_FILE = Path("force-app/main/default/layouts/Global-Global Layout.layout-meta.xml")

# Namespace
NS = {'m': 'http://soap.sforce.com/2006/04/metadata'}
ET.register_namespace('', NS['m'])

print("=" * 60)
print("PATCH GLOBAL PUBLISHER LAYOUT")
print("=" * 60)

# Read XML
tree = ET.parse(LAYOUT_FILE)
root = tree.getroot()

# Find platformActionList with Global context
platform_action_list = None
for pal in root.findall('.//m:platformActionList', NS):
    context = pal.find('./m:actionListContext', NS)
    if context is not None and context.text == 'Global':
        platform_action_list = pal
        break

if platform_action_list is None:
    print("ERROR: platformActionList with Global context not found!")
    exit(1)

print(f"\n[1] Found platformActionList with {len(platform_action_list.findall('.//m:platformActionListItems', NS))} items")

# Collect existing items (excluding CRIF actions)
items = []
for item in platform_action_list.findall('./m:platformActionListItems', NS):
    action_name_elem = item.find('./m:actionName', NS)
    if action_name_elem is not None:
        action_name = action_name_elem.text
        # Skip CRIF Flow action and old GA action if present
        if action_name in ['CRIF_New_Account_da_PIVA', 'CRIF_New_Account_da_PIVA_GA']:
            print(f"    - Removing old action: {action_name}")
            continue
        action_type = item.find('./m:actionType', NS).text
        items.append((action_name, action_type))

print(f"[2] Kept {len(items)} standard actions")

# Clear all items
for item in platform_action_list.findall('./m:platformActionListItems', NS):
    platform_action_list.remove(item)

# Create new item for CRIF_New_Account_da_PIVA_GA (sortOrder 0)
new_item = ET.SubElement(platform_action_list, 'platformActionListItems')
ET.SubElement(new_item, 'actionName').text = 'CRIF_New_Account_da_PIVA_GA'
ET.SubElement(new_item, 'actionType').text = 'QuickAction'
ET.SubElement(new_item, 'sortOrder').text = '0'

print(f"[3] Added new action: CRIF_New_Account_da_PIVA_GA (sortOrder: 0)")

# Re-add standard items with incremented sortOrder
for idx, (action_name, action_type) in enumerate(items, start=1):
    item = ET.SubElement(platform_action_list, 'platformActionListItems')
    ET.SubElement(item, 'actionName').text = action_name
    ET.SubElement(item, 'actionType').text = action_type
    ET.SubElement(item, 'sortOrder').text = str(idx)

print(f"[4] Re-added {len(items)} standard actions (sortOrder: 1-{len(items)})")

# Check quickActionList and remove any CRIF actions
quick_action_list = root.find('.//m:quickActionList', NS)
if quick_action_list is not None:
    removed_count = 0
    for item in list(quick_action_list.findall('./m:quickActionListItems', NS)):
        quick_action_name_elem = item.find('./m:quickActionName', NS)
        if quick_action_name_elem is not None:
            if quick_action_name_elem.text and quick_action_name_elem.text.startswith('CRIF_'):
                print(f"    - Removing from quickActionList: {quick_action_name_elem.text}")
                quick_action_list.remove(item)
                removed_count += 1
    print(f"[5] Cleaned quickActionList (removed {removed_count} CRIF actions)")
else:
    print("[5] quickActionList not found (OK)")

# Write XML
tree.write(LAYOUT_FILE, encoding='UTF-8', xml_declaration=True)

print(f"\n[6] File written: {LAYOUT_FILE}")
print("\n" + "=" * 60)
print("SUMMARY")
print("=" * 60)
print(f"Total platformActionList items: {len(items) + 1}")
print(f"First action: CRIF_New_Account_da_PIVA_GA (LightningComponent)")
print(f"quickActionList: Clean (no CRIF actions)")
print("=" * 60)
print("✓ PATCH COMPLETE")
