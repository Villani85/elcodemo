#!/usr/bin/env python3
"""
Generate complete PCB Configurator Flow XML with all 4 profiles × 19 specs each.
This script generates the flow metadata XML programmatically with proper element grouping.
"""

# Define the 19 technical specifications for each PCB profile
# Format: (Category, Parameter, Value)

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


def escape_xml(text):
    """Escape special XML characters."""
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def get_x_location(profile_name):
    """Get X location based on profile to avoid overlapping in Flow Builder."""
    locations = {
        "Standard": 50,
        "HighTg": 182,
        "Automotive": 314,
        "Medical": 446,
    }
    return locations.get(profile_name, 50)


def get_profile_display_name(profile_key):
    """Get display-friendly profile name."""
    names = {
        "STANDARD": "Standard",
        "HIGH_TG": "HighTg",
        "AUTOMOTIVE": "Automotive",
        "MEDICAL": "Medical",
    }
    return names[profile_key]


def generate_complete_flow():
    """Generate the complete Flow XML with proper element grouping."""

    # Section 1: Flow header + metadata
    flow_xml = '''<?xml version="1.0" encoding="UTF-8"?>
<Flow xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>65.0</apiVersion>
    <description>PCB Complete Configurator - Creates full technical specification set with predefined values (19 specs per profile)</description>
    <interviewLabel>Configuratore PCB Completo {!$Flow.CurrentDateTime}</interviewLabel>
    <label>Gestisci Specifiche Tecniche</label>
    <processMetadataValues>
        <name>BuilderType</name>
        <value>
            <stringValue>LightningFlowBuilder</stringValue>
        </value>
    </processMetadataValues>
    <processMetadataValues>
        <name>CanvasMode</name>
        <value>
            <stringValue>AUTO_LAYOUT_CANVAS</stringValue>
        </value>
    </processMetadataValues>
    <processType>Flow</processType>
    <start>
        <locationX>50</locationX>
        <locationY>0</locationY>
        <connector>
            <targetReference>Screen_Select_PCB_Type</targetReference>
        </connector>
    </start>
    <status>Active</status>

    <!-- ===== VARIABLES ===== -->
    <variables>
        <name>recordId</name>
        <dataType>String</dataType>
        <isCollection>false</isCollection>
        <isInput>true</isInput>
        <isOutput>false</isOutput>
    </variables>

    <variables>
        <name>varPCBType</name>
        <dataType>String</dataType>
        <isCollection>false</isCollection>
        <isInput>false</isInput>
        <isOutput>false</isOutput>
    </variables>

    <variables>
        <name>colSpecs</name>
        <dataType>SObject</dataType>
        <isCollection>true</isCollection>
        <isInput>false</isInput>
        <isOutput>false</isOutput>
        <objectType>Account_Tech_Spec__c</objectType>
    </variables>

    <variables>
        <name>varTempSpec</name>
        <dataType>SObject</dataType>
        <isCollection>false</isCollection>
        <isInput>false</isInput>
        <isOutput>false</isOutput>
        <objectType>Account_Tech_Spec__c</objectType>
    </variables>

    <!-- ===== CHOICES ===== -->
    <choices>
        <name>PCB_Standard</name>
        <choiceText>PCB Standard (FR4, 1.6mm, HASL)</choiceText>
        <dataType>String</dataType>
        <value>
            <stringValue>STANDARD</stringValue>
        </value>
    </choices>
    <choices>
        <name>PCB_HighTg</name>
        <choiceText>PCB High-Tg (FR4 High-Tg, 1.6mm, ENIG)</choiceText>
        <dataType>String</dataType>
        <value>
            <stringValue>HIGH_TG</stringValue>
        </value>
    </choices>
    <choices>
        <name>PCB_Automotive</name>
        <choiceText>PCB Automotive (Halogen-Free, High-Tg, ENIG)</choiceText>
        <dataType>String</dataType>
        <value>
            <stringValue>AUTOMOTIVE</stringValue>
        </value>
    </choices>
    <choices>
        <name>PCB_Medical</name>
        <choiceText>PCB Medical (Halogen-Free, High-Tg, Gold Plating)</choiceText>
        <dataType>String</dataType>
        <value>
            <stringValue>MEDICAL</stringValue>
        </value>
    </choices>

    <!-- ===== SCREENS ===== -->
    <screens>
        <name>Screen_Select_PCB_Type</name>
        <label>Configuratore PCB Completo</label>
        <locationX>176</locationX>
        <locationY>134</locationY>
        <allowBack>true</allowBack>
        <allowFinish>true</allowFinish>
        <allowPause>false</allowPause>
        <connector>
            <targetReference>Assign_PCB_Type</targetReference>
        </connector>
        <fields>
            <name>Display_Header</name>
            <fieldText>&lt;p&gt;&lt;b style=&quot;font-size: 16px;&quot;&gt;Configuratore PCB Completo&lt;/b&gt;&lt;/p&gt;&lt;p&gt;&lt;br&gt;&lt;/p&gt;&lt;p&gt;Seleziona il tipo di PCB da configurare. Il sistema creerà automaticamente &lt;b&gt;tutte le specifiche tecniche necessarie&lt;/b&gt; con valori predefiniti ottimali per il tipo selezionato.&lt;/p&gt;&lt;p&gt;&lt;br&gt;&lt;/p&gt;&lt;p&gt;&lt;b&gt;Ogni configurazione include:&lt;/b&gt;&lt;/p&gt;&lt;ul&gt;&lt;li&gt;Materiali (3 specifiche)&lt;/li&gt;&lt;li&gt;Dimensioni e Tolleranze (4 specifiche)&lt;/li&gt;&lt;li&gt;Confezionamento (3 specifiche)&lt;/li&gt;&lt;li&gt;Etichettatura (2 specifiche)&lt;/li&gt;&lt;li&gt;Documentazione (3 specifiche)&lt;/li&gt;&lt;li&gt;Qualità e Certificazioni (2-3 specifiche)&lt;/li&gt;&lt;li&gt;Note Commerciali (2 specifiche)&lt;/li&gt;&lt;/ul&gt;&lt;p&gt;&lt;br&gt;&lt;/p&gt;&lt;p&gt;&lt;b&gt;Totale: 19 specifiche tecniche&lt;/b&gt; create automaticamente!&lt;/p&gt;</fieldText>
            <fieldType>DisplayText</fieldType>
        </fields>
        <fields>
            <name>Field_PCB_Type</name>
            <choiceReferences>PCB_Standard</choiceReferences>
            <choiceReferences>PCB_HighTg</choiceReferences>
            <choiceReferences>PCB_Automotive</choiceReferences>
            <choiceReferences>PCB_Medical</choiceReferences>
            <dataType>String</dataType>
            <fieldText>Tipo PCB</fieldText>
            <fieldType>RadioButtons</fieldType>
            <isRequired>true</isRequired>
        </fields>
        <showFooter>true</showFooter>
        <showHeader>false</showHeader>
    </screens>

    <screens>
        <name>Screen_Confirm_Config</name>
        <label>Conferma Configurazione</label>
        <locationX>176</locationX>
        <locationY>350</locationY>
        <allowBack>true</allowBack>
        <allowFinish>true</allowFinish>
        <allowPause>false</allowPause>
        <connector>
            <targetReference>Decision_PCB_Type</targetReference>
        </connector>
        <fields>
            <name>Display_Confirm</name>
            <fieldText>&lt;p&gt;&lt;b style=&quot;font-size: 14px;&quot;&gt;Conferma Configurazione&lt;/b&gt;&lt;/p&gt;&lt;p&gt;&lt;br&gt;&lt;/p&gt;&lt;p&gt;Stai per creare una configurazione PCB completa con &lt;b&gt;19 specifiche tecniche&lt;/b&gt; predefinite.&lt;/p&gt;&lt;p&gt;&lt;br&gt;&lt;/p&gt;&lt;p&gt;&lt;b&gt;Tipo selezionato:&lt;/b&gt; {!varPCBType}&lt;/p&gt;&lt;p&gt;&lt;br&gt;&lt;/p&gt;&lt;p&gt;Clicca &lt;b&gt;Next&lt;/b&gt; per procedere o &lt;b&gt;Previous&lt;/b&gt; per modificare.&lt;/p&gt;</fieldText>
            <fieldType>DisplayText</fieldType>
        </fields>
        <showFooter>true</showFooter>
        <showHeader>false</showHeader>
    </screens>

    <screens>
        <name>Screen_Success</name>
        <label>Configurazione Completata</label>
        <locationX>176</locationX>
        <locationY>2726</locationY>
        <allowBack>false</allowBack>
        <allowFinish>true</allowFinish>
        <allowPause>false</allowPause>
        <fields>
            <name>Display_Success</name>
            <fieldText>&lt;p&gt;&lt;b style=&quot;font-size: 16px; color: rgb(0, 138, 0);&quot;&gt;Configurazione PCB Completata!&lt;/b&gt;&lt;/p&gt;&lt;p&gt;&lt;br&gt;&lt;/p&gt;&lt;p&gt;Sono state create &lt;b&gt;19 specifiche tecniche complete&lt;/b&gt; per il tipo PCB selezionato: &lt;b&gt;{!varPCBType}&lt;/b&gt;&lt;/p&gt;&lt;p&gt;&lt;br&gt;&lt;/p&gt;&lt;p&gt;Puoi visualizzarle nella Related List &lt;b&gt;&quot;Account Technical Specifications&quot;&lt;/b&gt; dell&apos;Account.&lt;/p&gt;&lt;p&gt;&lt;br&gt;&lt;/p&gt;&lt;p&gt;&lt;b&gt;Prossimi passi:&lt;/b&gt;&lt;/p&gt;&lt;ul&gt;&lt;li&gt;Rivedi le specifiche create&lt;/li&gt;&lt;li&gt;Modifica eventuali valori se necessario&lt;/li&gt;&lt;li&gt;Procedi con la creazione dell&apos;offerta&lt;/li&gt;&lt;/ul&gt;</fieldText>
            <fieldType>DisplayText</fieldType>
        </fields>
        <showFooter>true</showFooter>
        <showHeader>false</showHeader>
    </screens>

    <!-- ===== DECISIONS ===== -->
    <decisions>
        <name>Decision_PCB_Type</name>
        <label>Route by PCB Type</label>
        <locationX>176</locationX>
        <locationY>458</locationY>
        <defaultConnectorLabel>Default</defaultConnectorLabel>
        <rules>
            <name>Route_Standard</name>
            <conditionLogic>and</conditionLogic>
            <conditions>
                <leftValueReference>varPCBType</leftValueReference>
                <operator>EqualTo</operator>
                <rightValue>
                    <stringValue>STANDARD</stringValue>
                </rightValue>
            </conditions>
            <connector>
                <targetReference>Build_Standard_Spec_01</targetReference>
            </connector>
            <label>Standard PCB</label>
        </rules>
        <rules>
            <name>Route_HighTg</name>
            <conditionLogic>and</conditionLogic>
            <conditions>
                <leftValueReference>varPCBType</leftValueReference>
                <operator>EqualTo</operator>
                <rightValue>
                    <stringValue>HIGH_TG</stringValue>
                </rightValue>
            </conditions>
            <connector>
                <targetReference>Build_HighTg_Spec_01</targetReference>
            </connector>
            <label>High-Tg PCB</label>
        </rules>
        <rules>
            <name>Route_Automotive</name>
            <conditionLogic>and</conditionLogic>
            <conditions>
                <leftValueReference>varPCBType</leftValueReference>
                <operator>EqualTo</operator>
                <rightValue>
                    <stringValue>AUTOMOTIVE</stringValue>
                </rightValue>
            </conditions>
            <connector>
                <targetReference>Build_Automotive_Spec_01</targetReference>
            </connector>
            <label>Automotive PCB</label>
        </rules>
        <rules>
            <name>Route_Medical</name>
            <conditionLogic>and</conditionLogic>
            <conditions>
                <leftValueReference>varPCBType</leftValueReference>
                <operator>EqualTo</operator>
                <rightValue>
                    <stringValue>MEDICAL</stringValue>
                </rightValue>
            </conditions>
            <connector>
                <targetReference>Build_Medical_Spec_01</targetReference>
            </connector>
            <label>Medical PCB</label>
        </rules>
    </decisions>

    <!-- ===== ASSIGNMENTS ===== -->
    <assignments>
        <name>Assign_PCB_Type</name>
        <label>Assign PCB Type</label>
        <locationX>176</locationX>
        <locationY>242</locationY>
        <assignmentItems>
            <assignToReference>varPCBType</assignToReference>
            <operator>Assign</operator>
            <value>
                <elementReference>Field_PCB_Type</elementReference>
            </value>
        </assignmentItems>
        <connector>
            <targetReference>Screen_Confirm_Config</targetReference>
        </connector>
    </assignments>
'''

    # Section 2: Generate all Assignment elements for all profiles
    for profile_key, specs in PCB_PROFILES.items():
        profile_name = get_profile_display_name(profile_key)
        flow_xml += f'\n    <!-- ===== {profile_key} PCB SPECS (19 assignments) ===== -->'

        for idx, (category, parameter, value) in enumerate(specs, start=1):
            element_name = f"Build_{profile_name}_Spec_{idx:02d}"
            y_location = 566 + (idx - 1) * 108

            # Determine next connector
            if idx < 19:
                next_element = f"Build_{profile_name}_Spec_{idx + 1:02d}"
            else:
                next_element = f"Create_All_{profile_name}_Specs"

            flow_xml += f'''
    <assignments>
        <name>{element_name}</name>
        <label>Build {profile_name} Spec {idx:02d}</label>
        <locationX>{get_x_location(profile_name)}</locationX>
        <locationY>{y_location}</locationY>
        <assignmentItems>
            <assignToReference>varTempSpec.Account__c</assignToReference>
            <operator>Assign</operator>
            <value>
                <elementReference>recordId</elementReference>
            </value>
        </assignmentItems>
        <assignmentItems>
            <assignToReference>varTempSpec.Category__c</assignToReference>
            <operator>Assign</operator>
            <value>
                <stringValue>{escape_xml(category)}</stringValue>
            </value>
        </assignmentItems>
        <assignmentItems>
            <assignToReference>varTempSpec.Parameter__c</assignToReference>
            <operator>Assign</operator>
            <value>
                <stringValue>{escape_xml(parameter)}</stringValue>
            </value>
        </assignmentItems>
        <assignmentItems>
            <assignToReference>varTempSpec.Value__c</assignToReference>
            <operator>Assign</operator>
            <value>
                <stringValue>{escape_xml(value)}</stringValue>
            </value>
        </assignmentItems>
        <assignmentItems>
            <assignToReference>varTempSpec.Source__c</assignToReference>
            <operator>Assign</operator>
            <value>
                <stringValue>Configuratore Automatico</stringValue>
            </value>
        </assignmentItems>
        <assignmentItems>
            <assignToReference>varTempSpec.Is_Active__c</assignToReference>
            <operator>Assign</operator>
            <value>
                <booleanValue>true</booleanValue>
            </value>
        </assignmentItems>
        <assignmentItems>
            <assignToReference>colSpecs</assignToReference>
            <operator>Add</operator>
            <value>
                <elementReference>varTempSpec</elementReference>
            </value>
        </assignmentItems>
        <connector>
            <targetReference>{next_element}</targetReference>
        </connector>
    </assignments>'''

    # Section 3: Generate all RecordCreate elements
    flow_xml += '\n\n    <!-- ===== RECORD CREATES ===== -->'
    for profile_key in PCB_PROFILES.keys():
        profile_name = get_profile_display_name(profile_key)
        y_location = 566 + 19 * 108  # After last assignment

        flow_xml += f'''
    <recordCreates>
        <name>Create_All_{profile_name}_Specs</name>
        <label>Create All {profile_name} PCB Specs</label>
        <locationX>{get_x_location(profile_name)}</locationX>
        <locationY>{y_location}</locationY>
        <connector>
            <targetReference>Screen_Success</targetReference>
        </connector>
        <inputReference>colSpecs</inputReference>
    </recordCreates>'''

    # Close Flow tag
    flow_xml += '\n\n</Flow>\n'

    return flow_xml


if __name__ == "__main__":
    flow_xml = generate_complete_flow()
    output_path = "Gestisci_Specifiche_Tecniche.flow-meta.xml"

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(flow_xml)

    print(f"[OK] Generated complete PCB configurator flow: {output_path}")
    print(f"Total specs: {sum(len(specs) for specs in PCB_PROFILES.values())} specs across {len(PCB_PROFILES)} profiles")
    print(f"File size: {len(flow_xml)} characters")
