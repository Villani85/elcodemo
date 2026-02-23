#!/usr/bin/env python3
"""
Test script for PCB Configurator Flow
This script verifies the data structure by creating test records directly via Salesforce REST API
"""

import json
import subprocess
import sys

# Test Account ID
TEST_ACCOUNT_ID = "001g500000CCQOjAAP"  # DEMO - Cliente PCB

# Define the 19 technical specifications for each PCB profile
PCB_PROFILES = {
    "STANDARD": [
        ("Materiali", "Materiale principale", "FR4 Standard"),
        ("Materiali", "Halogen free", "No"),
        ("Materiali", "Tg richiesto", "130-140°C"),
        ("Dimensioni & Tolleranze", "Dimensione max (mm)", "600 x 500"),
        ("Dimensioni & Tolleranze", "Spessore target", "1.6mm"),
        ("Dimensioni & Tolleranze", "Tolleranza spessore", "±10%"),
        ("Dimensioni & Tolleranze", "Tolleranza dimensionale", "IPC-A-600 Class 2"),
        ("Confezionamento / Imballo", "Confezione primaria", "Busta antistatica"),
        ("Confezionamento / Imballo", "Confezione secondaria", "Scatola di cartone"),
        ("Confezionamento / Imballo", "Numero pezzi per scatola", "50"),
        ("Etichettatura", "Barcode", "EAN-13"),
        ("Etichettatura", "Etichetta esterna", "Standard"),
        ("Documentazione", "Packing list", "Obbligatorio"),
        ("Documentazione", "Certificato materiali", "Su richiesta"),
        ("Documentazione", "Report test", "Su richiesta"),
        ("Qualità & Certificazioni", "RoHS", "Compliant"),
        ("Qualità & Certificazioni", "REACH", "Compliant"),
        ("Note Commerciali / Preferenze", "Lotto minimo", "100 pz"),
        ("Note Commerciali / Preferenze", "Lead time preferito", "4 settimane"),
    ],
    "HIGH_TG": [
        ("Materiali", "Materiale principale", "FR4 High-Tg (Tg 170°C)"),
        ("Materiali", "Halogen free", "No"),
        ("Materiali", "Tg richiesto", "170°C"),
        ("Dimensioni & Tolleranze", "Dimensione max (mm)", "600 x 500"),
        ("Dimensioni & Tolleranze", "Spessore target", "1.6mm"),
        ("Dimensioni & Tolleranze", "Tolleranza spessore", "±8%"),
        ("Dimensioni & Tolleranze", "Tolleranza dimensionale", "IPC-A-600 Class 2"),
        ("Confezionamento / Imballo", "Confezione primaria", "Busta antistatica"),
        ("Confezionamento / Imballo", "Confezione secondaria", "Scatola di cartone rinforzato"),
        ("Confezionamento / Imballo", "Numero pezzi per scatola", "30"),
        ("Etichettatura", "Barcode", "EAN-13"),
        ("Etichettatura", "Etichetta esterna", "High-Tg Label"),
        ("Documentazione", "Packing list", "Obbligatorio"),
        ("Documentazione", "Certificato materiali", "Obbligatorio"),
        ("Documentazione", "Report test", "Obbligatorio"),
        ("Qualità & Certificazioni", "RoHS", "Compliant"),
        ("Qualità & Certificazioni", "ISO richiesto", "ISO 9001:2015"),
        ("Note Commerciali / Preferenze", "Lotto minimo", "50 pz"),
        ("Note Commerciali / Preferenze", "Lead time preferito", "5 settimane"),
    ],
    "AUTOMOTIVE": [
        ("Materiali", "Materiale principale", "FR4 Halogen-Free High-Tg"),
        ("Materiali", "Halogen free", "Si"),
        ("Materiali", "Tg richiesto", "180°C"),
        ("Dimensioni & Tolleranze", "Dimensione max (mm)", "600 x 500"),
        ("Dimensioni & Tolleranze", "Spessore target", "1.6mm"),
        ("Dimensioni & Tolleranze", "Tolleranza spessore", "±5%"),
        ("Dimensioni & Tolleranze", "Tolleranza dimensionale", "IPC-A-600 Class 3"),
        ("Confezionamento / Imballo", "Confezione primaria", "Busta antistatica ESD"),
        ("Confezionamento / Imballo", "Confezione secondaria", "Scatola cartonata certificata"),
        ("Confezionamento / Imballo", "Numero pezzi per scatola", "25"),
        ("Etichettatura", "Barcode", "QR code + EAN-13"),
        ("Etichettatura", "Etichetta esterna", "Automotive Grade Label"),
        ("Documentazione", "Packing list", "Obbligatorio"),
        ("Documentazione", "Certificato conformità", "Obbligatorio (IATF 16949)"),
        ("Documentazione", "Report test", "Obbligatorio"),
        ("Qualità & Certificazioni", "RoHS", "Compliant"),
        ("Qualità & Certificazioni", "REACH", "Compliant"),
        ("Qualità & Certificazioni", "ISO richiesto", "IATF 16949"),
        ("Note Commerciali / Preferenze", "Lotto minimo", "100 pz"),
        ("Note Commerciali / Preferenze", "Lead time preferito", "6 settimane"),
    ],
    "MEDICAL": [
        ("Materiali", "Materiale principale", "FR4 Halogen-Free Medical Grade"),
        ("Materiali", "Halogen free", "Si"),
        ("Materiali", "Tg richiesto", "180°C"),
        ("Dimensioni & Tolleranze", "Dimensione max (mm)", "400 x 300"),
        ("Dimensioni & Tolleranze", "Spessore target", "1.6mm"),
        ("Dimensioni & Tolleranze", "Tolleranza spessore", "±5%"),
        ("Dimensioni & Tolleranze", "Tolleranza dimensionale", "IPC-A-600 Class 3"),
        ("Confezionamento / Imballo", "Confezione primaria", "Busta sterile sigillata"),
        ("Confezionamento / Imballo", "Confezione secondaria", "Scatola sterilizzabile"),
        ("Confezionamento / Imballo", "Numero pezzi per scatola", "20"),
        ("Etichettatura", "Barcode", "QR code + Traceability"),
        ("Etichettatura", "Etichetta esterna", "Medical Device Label"),
        ("Documentazione", "Packing list", "Obbligatorio"),
        ("Documentazione", "Certificato conformità", "Obbligatorio (ISO 13485)"),
        ("Documentazione", "Report test", "Obbligatorio + Traceability"),
        ("Qualità & Certificazioni", "RoHS", "Compliant"),
        ("Qualità & Certificazioni", "ISO richiesto", "ISO 13485"),
        ("Note Commerciali / Preferenze", "Lotto minimo", "50 pz"),
        ("Note Commerciali / Preferenze", "Lead time preferito", "8 settimane"),
    ],
}


def run_soql_query(query):
    """Execute SOQL query and return results."""
    cmd = ["sf", "data", "query", "-o", "elco-dev", "-q", query, "--json"]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"ERROR: Query failed: {result.stderr}")
        return None
    return json.loads(result.stdout)


def delete_existing_test_specs():
    """Delete existing test specs for the test account."""
    print(f"\n1. Cleaning up existing test specs for Account {TEST_ACCOUNT_ID}...")

    query = f"SELECT Id FROM Account_Tech_Spec__c WHERE Account__c = '{TEST_ACCOUNT_ID}' AND Source__c = 'TEST Script'"
    result = run_soql_query(query)

    if result and result["result"]["records"]:
        spec_ids = [rec["Id"] for rec in result["result"]["records"]]
        print(f"   Found {len(spec_ids)} existing test specs to delete...")

        for spec_id in spec_ids:
            cmd = ["sf", "data", "delete", "record", "-o", "elco-dev", "-s", "Account_Tech_Spec__c", "-i", spec_id]
            subprocess.run(cmd, capture_output=True)

        print(f"   [OK] Deleted {len(spec_ids)} existing test specs")
    else:
        print("   [OK] No existing test specs found")


def create_spec_record(account_id, category, parameter, value, profile_type):
    """Create a single Account_Tech_Spec__c record."""
    cmd = [
        "sf", "data", "create", "record", "-o", "elco-dev",
        "-s", "Account_Tech_Spec__c",
        "-v",
        f"Account__c={account_id} Category__c=\"{category}\" Parameter__c=\"{parameter}\" Value__c=\"{value}\" Source__c=\"TEST Script\" Is_Active__c=true Notes__c=\"Test Profile: {profile_type}\""
    ]

    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"   ERROR creating spec: {category} / {parameter}")
        print(f"   {result.stderr}")
        return None

    # Extract record ID from output
    try:
        output = json.loads(result.stdout)
        return output.get("result", {}).get("id")
    except:
        return None


def test_profile(profile_name, specs):
    """Test creating all 19 specs for a profile."""
    print(f"\n2. Testing {profile_name} Profile ({len(specs)} specs)...")

    created_ids = []
    for idx, (category, parameter, value) in enumerate(specs, 1):
        spec_id = create_spec_record(TEST_ACCOUNT_ID, category, parameter, value, profile_name)
        if spec_id:
            created_ids.append(spec_id)
            print(f"   [{idx:02d}/19] Created: {category} / {parameter} = {value}")
        else:
            print(f"   [{idx:02d}/19] FAILED: {category} / {parameter}")

    return created_ids


def verify_created_specs(expected_count):
    """Verify that all specs were created correctly."""
    print(f"\n3. Verifying created specs...")

    query = f"SELECT Id, Category__c, Parameter__c, Value__c, Source__c FROM Account_Tech_Spec__c WHERE Account__c = '{TEST_ACCOUNT_ID}' AND Source__c = 'TEST Script'"
    result = run_soql_query(query)

    if result and result["result"]["records"]:
        created = len(result["result"]["records"])
        print(f"   [OK] Found {created}/{expected_count} specs in database")

        # Group by category
        by_category = {}
        for rec in result["result"]["records"]:
            cat = rec.get("Category__c", "Unknown")
            by_category[cat] = by_category.get(cat, 0) + 1

        print(f"\n   Specs by Category:")
        for cat, count in sorted(by_category.items()):
            print(f"     - {cat}: {count} specs")

        return created == expected_count
    else:
        print(f"   [ERROR] No specs found in database!")
        return False


def main():
    print("=" * 80)
    print("PCB Configurator Flow - Data Structure Test")
    print("=" * 80)

    # Step 1: Clean up
    delete_existing_test_specs()

    # Step 2: Test ONE profile (let's test STANDARD to validate structure)
    profile_to_test = "STANDARD"
    specs = PCB_PROFILES[profile_to_test]
    created_ids = test_profile(profile_to_test, specs)

    print(f"\n   [OK] Created {len(created_ids)}/19 specs for {profile_to_test} profile")

    # Step 3: Verify
    success = verify_created_specs(19)

    if success:
        print("\n" + "=" * 80)
        print("[SUCCESS] Data structure test PASSED!")
        print("=" * 80)
        print(f"\nNext Steps:")
        print(f"1. Open Account: {TEST_ACCOUNT_ID} in Salesforce UI")
        print(f"2. Click 'Gestisci Specifiche Tecniche' Quick Action")
        print(f"3. Test all 4 PCB profiles:")
        print(f"   - STANDARD")
        print(f"   - HIGH-TG")
        print(f"   - AUTOMOTIVE")
        print(f"   - MEDICAL")
        print(f"4. Verify each creates exactly 19 specs with correct values")
        print("\n" + "=" * 80)
        return 0
    else:
        print("\n" + "=" * 80)
        print("[FAILED] Data structure test FAILED!")
        print("=" * 80)
        return 1


if __name__ == "__main__":
    sys.exit(main())
