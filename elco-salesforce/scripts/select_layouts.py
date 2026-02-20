#!/usr/bin/env python3
"""
Select layouts deterministically for P5 deployment.
"""
import json
import sys

def select_layout_for_object(layouts, obj_name, preferred_names):
    """
    Select layout for an object using deterministic rules.

    Args:
        layouts: List of layout metadata items
        obj_name: Object name (e.g., "Account")
        preferred_names: List of preferred layout names in order

    Returns:
        Selected layout fullName or None
    """
    obj_layouts = [l for l in layouts if l.get('fullName', '').startswith(f"{obj_name}-")]

    if not obj_layouts:
        return None

    # Try preferred names first
    for pref in preferred_names:
        for layout in obj_layouts:
            if layout.get('fullName') == pref:
                return pref

    # Filter out PersonAccount layouts for Account
    if obj_name == "Account":
        obj_layouts = [l for l in obj_layouts if "PersonAccount" not in l.get('fullName', '')]

    # Return first remaining
    return obj_layouts[0].get('fullName') if obj_layouts else None

def main():
    # Read layout list
    with open('raw/p5/layout_list.json', 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Extract layouts from result
    layouts = data.get('result', [])

    # Selection rules
    selections = {
        'Account': select_layout_for_object(
            layouts,
            'Account',
            ['Account-Account Layout']
        ),
        'Opportunity': select_layout_for_object(
            layouts,
            'Opportunity',
            ['Opportunity-Opportunity Layout']
        ),
        'Quote': select_layout_for_object(
            layouts,
            'Quote',
            ['Quote-Quote Layout']
        ),
        'QuoteLineItem': select_layout_for_object(
            layouts,
            'QuoteLineItem',
            ['QuoteLineItem-Quote Line Item Layout']
        ),
        'Visit_Report__c': select_layout_for_object(
            layouts,
            'Visit_Report__c',
            []  # Just take first
        ),
    }

    # Write selections
    with open('raw/p5/selected_layouts.txt', 'w', encoding='utf-8') as f:
        for obj, layout in selections.items():
            if layout:
                f.write(f"{obj}={layout}\n")
                print(f"[OK] {obj}: {layout}")
            else:
                print(f"[ERROR] {obj}: No layout found!", file=sys.stderr)
                sys.exit(1)

    print(f"\n[OK] Selected {len(selections)} layouts")

if __name__ == '__main__':
    main()
