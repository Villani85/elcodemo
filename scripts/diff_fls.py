#!/usr/bin/env python3
"""Calculate diff between expected and current FLS."""
import json
from pathlib import Path

def main():
    base_path = Path(__file__).parent.parent / 'raw' / 'security'

    # Load expected
    with open(base_path / 'expected_fields.json') as f:
        expected = json.load(f)

    # Load current
    with open(base_path / 'current_fls_in_org.json') as f:
        current_raw = json.load(f)

    # Normalize current to field names only
    current = {}
    for ps_name, fields in current_raw.items():
        current[ps_name] = set(fp['field'] for fp in fields)

    # Calculate diff
    diff = {}
    for ps_name in expected.keys():
        expected_set = set(expected[ps_name])
        current_set = current.get(ps_name, set())

        missing = expected_set - current_set
        extra = current_set - expected_set

        diff[ps_name] = {
            'expected_count': len(expected_set),
            'current_count': len(current_set),
            'missing_count': len(missing),
            'extra_count': len(extra),
            'missing_fields': sorted(list(missing)),
            'extra_fields': sorted(list(extra))
        }

    # Save JSON
    output_json = base_path / 'fls_diff.json'
    with open(output_json, 'w') as f:
        json.dump(diff, f, indent=2)

    print(f"Saved to {output_json}")

    # Generate markdown report
    output_md = base_path / 'fls_diff.md'
    with open(output_md, 'w', encoding='utf-8') as f:
        f.write("# FLS Diff Report - Expected vs Current\n\n")
        f.write("**Generated**: 2026-02-20 17:10\n\n")
        f.write("---\n\n")

        for ps_name, data in diff.items():
            f.write(f"## {ps_name}\n\n")
            f.write(f"- **Expected**: {data['expected_count']} fields\n")
            f.write(f"- **Current**: {data['current_count']} fields\n")
            f.write(f"- **Missing**: {data['missing_count']} fields\n")
            f.write(f"- **Extra**: {data['extra_count']} fields\n\n")

            if data['missing_fields']:
                f.write("### [MISSING] Fields Expected but NOT in org\n\n")
                for field in data['missing_fields']:
                    f.write(f"- `{field}`\n")
                f.write("\n")

            if data['extra_fields']:
                f.write("### [EXTRA] Fields In org but NOT expected\n\n")
                for field in data['extra_fields']:
                    f.write(f"- `{field}`\n")
                f.write("\n")

            if not data['missing_fields'] and not data['extra_fields']:
                f.write("[OK] **Perfect match!**\n\n")

            f.write("---\n\n")

    print(f"Saved to {output_md}")

    # Print summary to console
    print("\n=== FLS DIFF SUMMARY ===\n")
    for ps_name, data in diff.items():
        status = "[OK]" if data['missing_count'] == 0 else f"[MISSING: {data['missing_count']}]"
        print(f"{ps_name}: {status} ({data['current_count']}/{data['expected_count']} fields)")

    print("\nDetails in raw/security/fls_diff.md")

if __name__ == '__main__':
    main()
