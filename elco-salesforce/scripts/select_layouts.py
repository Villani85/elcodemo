#!/usr/bin/env python3
"""
Select Quote and Visit_Report__c layouts deterministically from org metadata.
"""
import json
import os

# Load layout list
with open("raw/p5_cli_finish/layout_list.json", "r") as f:
    data = json.load(f)

layouts = data.get("result", [])

# Find Quote layout
quote_layout = None
quote_candidates = [l for l in layouts if l["fullName"].startswith("Quote-")]

# Prefer "Quote-Quote Layout"
for l in quote_candidates:
    if l["fullName"] == "Quote-Quote Layout":
        quote_layout = l["fullName"]
        break

# Fallback to first Quote layout
if not quote_layout and quote_candidates:
    quote_layout = quote_candidates[0]["fullName"]

# Find Visit_Report__c layout
visit_layout = None
visit_candidates = [l for l in layouts if l["fullName"].startswith("Visit_Report__c-")]

if visit_candidates:
    visit_layout = visit_candidates[0]["fullName"]

# Write selected layouts
output_lines = []
if quote_layout:
    output_lines.append(f"Quote={quote_layout}")
    print(f"[OK] Selected Quote layout: {quote_layout}")
else:
    print("[ERROR] No Quote layout found")
    exit(1)

if visit_layout:
    output_lines.append(f"Visit_Report__c={visit_layout}")
    print(f"[OK] Selected Visit_Report__c layout: {visit_layout}")
else:
    print("[ERROR] No Visit_Report__c layout found")
    exit(1)

with open("raw/p5_cli_finish/selected_layouts.txt", "w") as f:
    f.write("\n".join(output_lines) + "\n")

print(f"[OK] Selected layouts saved to raw/p5_cli_finish/selected_layouts.txt")
