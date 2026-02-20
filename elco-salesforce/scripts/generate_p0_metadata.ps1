$ErrorActionPreference = 'Stop'

Set-Location "$PSScriptRoot\.."

function Escape-Xml([string]$value) {
  return [System.Security.SecurityElement]::Escape($value)
}

function Write-File([string]$path, [string]$content) {
  $dir = Split-Path -Parent $path
  if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
  Set-Content -Path $path -Value $content -Encoding utf8
}

function New-TextFieldXml([string]$fullName,[string]$label,[int]$length,[bool]$required=$false) {
  $req = if ($required) { "`n  <required>true</required>" } else { "" }
  return @"
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>$fullName</fullName>
  <label>$label</label>
  <type>Text</type>
  <length>$length</length>$req
</CustomField>
"@
}

function New-LongTextFieldXml([string]$fullName,[string]$label,[int]$length=32768,[int]$visibleLines=3,[bool]$required=$false) {
  $req = if ($required) { "`n  <required>true</required>" } else { "" }
  return @"
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>$fullName</fullName>
  <label>$label</label>
  <type>LongTextArea</type>
  <length>$length</length>
  <visibleLines>$visibleLines</visibleLines>$req
</CustomField>
"@
}

function New-CheckboxFieldXml([string]$fullName,[string]$label,[string]$defaultValue='false') {
  return @"
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>$fullName</fullName>
  <label>$label</label>
  <type>Checkbox</type>
  <defaultValue>$defaultValue</defaultValue>
</CustomField>
"@
}

function New-NumberFieldXml([string]$fullName,[string]$label,[int]$precision,[int]$scale,[bool]$required=$false) {
  $req = if ($required) { "`n  <required>true</required>" } else { "" }
  return @"
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>$fullName</fullName>
  <label>$label</label>
  <type>Number</type>
  <precision>$precision</precision>
  <scale>$scale</scale>$req
</CustomField>
"@
}

function New-DateTimeFieldXml([string]$fullName,[string]$label,[bool]$required=$false) {
  $req = if ($required) { "`n  <required>true</required>" } else { "" }
  return @"
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>$fullName</fullName>
  <label>$label</label>
  <type>DateTime</type>$req
</CustomField>
"@
}

function New-LookupFieldXml([string]$fullName,[string]$label,[string]$referenceTo,[string]$relationshipName,$relationshipLabel,[bool]$required=$false) {
  $relNameXml = if ($relationshipName) { "`n  <relationshipName>$relationshipName</relationshipName>" } else { "" }
  $relLabelXml = if ($relationshipLabel) { "`n  <relationshipLabel>$relationshipLabel</relationshipLabel>" } else { "" }
  $req = if ($required) { "`n  <required>true</required>" } else { "" }
  return @"
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>$fullName</fullName>
  <label>$label</label>
  <type>Lookup</type>
  <referenceTo>$referenceTo</referenceTo>$relNameXml$relLabelXml$req
</CustomField>
"@
}

function New-MasterDetailFieldXml([string]$fullName,[string]$label,[string]$referenceTo,[string]$relationshipName,[string]$relationshipLabel) {
  return @"
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>$fullName</fullName>
  <label>$label</label>
  <type>MasterDetail</type>
  <referenceTo>$referenceTo</referenceTo>
  <relationshipName>$relationshipName</relationshipName>
  <relationshipLabel>$relationshipLabel</relationshipLabel>
  <reparentableMasterDetail>false</reparentableMasterDetail>
  <writeRequiresMasterRead>false</writeRequiresMasterRead>
</CustomField>
"@
}

function New-PicklistFieldXml([string]$fullName,[string]$label,[string[]]$values,[bool]$required=$false,[string]$controllingField=$null,[System.Collections.Specialized.OrderedDictionary]$valueSettingsMap=$null) {
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.AppendLine('<?xml version="1.0" encoding="UTF-8"?>')
  [void]$sb.AppendLine('<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">')
  [void]$sb.AppendLine("  <fullName>$fullName</fullName>")
  [void]$sb.AppendLine("  <label>$label</label>")
  [void]$sb.AppendLine('  <type>Picklist</type>')
  if ($required) { [void]$sb.AppendLine('  <required>true</required>') }
  [void]$sb.AppendLine('  <valueSet>')
  if ($controllingField) {
    [void]$sb.AppendLine("    <controllingField>$controllingField</controllingField>")
  }
  [void]$sb.AppendLine('    <restricted>true</restricted>')
  [void]$sb.AppendLine('    <valueSetDefinition>')
  [void]$sb.AppendLine('      <sorted>false</sorted>')
  foreach ($v in $values) {
    $esc = Escape-Xml $v
    [void]$sb.AppendLine("      <value><fullName>$esc</fullName><default>false</default><label>$esc</label></value>")
  }
  [void]$sb.AppendLine('    </valueSetDefinition>')
  if ($valueSettingsMap) {
    foreach ($key in $valueSettingsMap.Keys) {
      $k = Escape-Xml ([string]$key)
      foreach ($val in @($valueSettingsMap[$key])) {
        $v = Escape-Xml ([string]$val)
        [void]$sb.AppendLine("    <valueSettings><controllingFieldValue>$k</controllingFieldValue><valueName>$v</valueName></valueSettings>")
      }
    }
  }
  [void]$sb.AppendLine('  </valueSet>')
  [void]$sb.AppendLine('</CustomField>')
  return $sb.ToString()
}

# Custom Objects
Write-File 'force-app/main/default/objects/Account_Tech_Spec__c/Account_Tech_Spec__c.object-meta.xml' @"
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
  <label>Specifica Tecnica</label>
  <pluralLabel>Specifiche Tecniche</pluralLabel>
  <nameField>
    <label>Specifica Tecnica Number</label>
    <type>AutoNumber</type>
    <displayFormat>TS-{000000}</displayFormat>
  </nameField>
  <deploymentStatus>Deployed</deploymentStatus>
  <sharingModel>ReadWrite</sharingModel>
</CustomObject>
"@

Write-File 'force-app/main/default/objects/Visit_Report__c/Visit_Report__c.object-meta.xml' @"
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
  <label>Report Visita</label>
  <pluralLabel>Report Visite</pluralLabel>
  <nameField>
    <label>Report Visita Number</label>
    <type>AutoNumber</type>
    <displayFormat>VR-{000000}</displayFormat>
  </nameField>
  <deploymentStatus>Deployed</deploymentStatus>
  <sharingModel>ReadWrite</sharingModel>
</CustomObject>
"@

Write-File 'force-app/main/default/objects/Visit_Attendee__c/Visit_Attendee__c.object-meta.xml' @"
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
  <label>Partecipante Visita</label>
  <pluralLabel>Partecipanti Visita</pluralLabel>
  <nameField>
    <label>Partecipante Number</label>
    <type>AutoNumber</type>
    <displayFormat>VA-{000000}</displayFormat>
  </nameField>
  <deploymentStatus>Deployed</deploymentStatus>
  <sharingModel>ReadWrite</sharingModel>
</CustomObject>
"@

# Account_Tech_Spec__c fields
Write-File 'force-app/main/default/objects/Account_Tech_Spec__c/fields/Account__c.field-meta.xml' (New-LookupFieldXml -fullName 'Account__c' -label 'Account' -referenceTo 'Account' -relationshipName 'TechSpecs' -relationshipLabel 'Specifiche Tecniche' -required $true)

$techCategories = @(
  'Materiali',
  'Dimensioni & Tolleranze',
  'Confezionamento / Imballo',
  'Etichettatura',
  'Documentazione',
  'Qualità & Certificazioni',
  'Note Commerciali / Preferenze'
)
Write-File 'force-app/main/default/objects/Account_Tech_Spec__c/fields/Category__c.field-meta.xml' (New-PicklistFieldXml -fullName 'Category__c' -label 'Categoria' -values $techCategories -required $true)

$techParameters = @(
  'Materiale principale','Materiale alternativo','Tg richiesto','Halogen free','UL requirement',
  'Dimensione max (mm)','Dimensione min (mm)','Tolleranza dimensionale','Spessore target','Tolleranza spessore','Peso max',
  'Confezione primaria','Confezione secondaria','Materiale busta','Materiale scatola','Numero pezzi per busta','Numero pezzi per scatola','Riempitivo','Separazione pezzi','Palletizzazione','Filmatura',
  'Etichetta interna','Etichetta esterna','Barcode','QR code','Etichetta cliente',
  'Packing list','Certificato conformità','Certificato materiali','Report test','Altro documento',
  'ISO richiesto','RoHS','REACH','ITAR','Altro requisito qualità',
  'Lotto minimo','Lead time preferito','Incoterm','Trasporto preferito','Note aggiuntive'
)

$techValueMap = [ordered]@{
  'Materiali' = @('Materiale principale','Materiale alternativo','Tg richiesto','Halogen free','UL requirement')
  'Dimensioni & Tolleranze' = @('Dimensione max (mm)','Dimensione min (mm)','Tolleranza dimensionale','Spessore target','Tolleranza spessore','Peso max')
  'Confezionamento / Imballo' = @('Confezione primaria','Confezione secondaria','Materiale busta','Materiale scatola','Numero pezzi per busta','Numero pezzi per scatola','Riempitivo','Separazione pezzi','Palletizzazione','Filmatura')
  'Etichettatura' = @('Etichetta interna','Etichetta esterna','Barcode','QR code','Etichetta cliente')
  'Documentazione' = @('Packing list','Certificato conformità','Certificato materiali','Report test','Altro documento')
  'Qualità & Certificazioni' = @('ISO richiesto','RoHS','REACH','ITAR','Altro requisito qualità')
  'Note Commerciali / Preferenze' = @('Lotto minimo','Lead time preferito','Incoterm','Trasporto preferito','Note aggiuntive')
}
Write-File 'force-app/main/default/objects/Account_Tech_Spec__c/fields/Parameter__c.field-meta.xml' (New-PicklistFieldXml -fullName 'Parameter__c' -label 'Parametro' -values $techParameters -required $true -controllingField 'Category__c' -valueSettingsMap $techValueMap)

Write-File 'force-app/main/default/objects/Account_Tech_Spec__c/fields/Value__c.field-meta.xml' (New-TextFieldXml -fullName 'Value__c' -label 'Valore' -length 255 -required $true)
Write-File 'force-app/main/default/objects/Account_Tech_Spec__c/fields/UoM__c.field-meta.xml' (New-PicklistFieldXml -fullName 'UoM__c' -label 'Unita di Misura' -values @('mm','cm','m','g','kg','pz','%','°C','n/a'))
Write-File 'force-app/main/default/objects/Account_Tech_Spec__c/fields/Source__c.field-meta.xml' (New-PicklistFieldXml -fullName 'Source__c' -label 'Fonte' -values @('Excel','Manuale','Import','Altro'))
Write-File 'force-app/main/default/objects/Account_Tech_Spec__c/fields/Notes__c.field-meta.xml' (New-LongTextFieldXml -fullName 'Notes__c' -label 'Note' -length 32768 -visibleLines 3)
Write-File 'force-app/main/default/objects/Account_Tech_Spec__c/fields/Is_Active__c.field-meta.xml' (New-CheckboxFieldXml -fullName 'Is_Active__c' -label 'Attivo' -defaultValue 'true')

# Visit_Report__c fields
Write-File 'force-app/main/default/objects/Visit_Report__c/fields/Account__c.field-meta.xml' (New-LookupFieldXml -fullName 'Account__c' -label 'Account' -referenceTo 'Account' -relationshipName 'VisitReports' -relationshipLabel 'Report Visite' -required $true)
Write-File 'force-app/main/default/objects/Visit_Report__c/fields/Subject__c.field-meta.xml' (New-TextFieldXml -fullName 'Subject__c' -label 'Oggetto' -length 120 -required $true)
Write-File 'force-app/main/default/objects/Visit_Report__c/fields/Visit_DateTime__c.field-meta.xml' (New-DateTimeFieldXml -fullName 'Visit_DateTime__c' -label 'Data Ora Visita' -required $true)
Write-File 'force-app/main/default/objects/Visit_Report__c/fields/Visit_Type__c.field-meta.xml' (New-PicklistFieldXml -fullName 'Visit_Type__c' -label 'Tipo Visita' -values @('Visita','Teams','Attività','Altro') -required $true)
Write-File 'force-app/main/default/objects/Visit_Report__c/fields/Summary__c.field-meta.xml' (New-LongTextFieldXml -fullName 'Summary__c' -label 'Riepilogo' -length 32768 -visibleLines 3)
Write-File 'force-app/main/default/objects/Visit_Report__c/fields/Next_Steps__c.field-meta.xml' (New-LongTextFieldXml -fullName 'Next_Steps__c' -label 'Prossimi Passi' -length 32768 -visibleLines 3)
Write-File 'force-app/main/default/objects/Visit_Report__c/fields/FollowUp_Sent__c.field-meta.xml' (New-CheckboxFieldXml -fullName 'FollowUp_Sent__c' -label 'Follow Up Inviato' -defaultValue 'false')
Write-File 'force-app/main/default/objects/Visit_Report__c/fields/FollowUp_Sent_On__c.field-meta.xml' (New-DateTimeFieldXml -fullName 'FollowUp_Sent_On__c' -label 'Follow Up Inviato Il')

# Visit_Attendee__c fields
Write-File 'force-app/main/default/objects/Visit_Attendee__c/fields/Visit_Report__c.field-meta.xml' (New-MasterDetailFieldXml -fullName 'Visit_Report__c' -label 'Report Visita' -referenceTo 'Visit_Report__c' -relationshipName 'Attendees' -relationshipLabel 'Partecipanti')
Write-File 'force-app/main/default/objects/Visit_Attendee__c/fields/Contact__c.field-meta.xml' (New-LookupFieldXml -fullName 'Contact__c' -label 'Contatto' -referenceTo 'Contact' -relationshipName 'VisitAttendees' -relationshipLabel 'Partecipazioni Visita' -required $true)
Write-File 'force-app/main/default/objects/Visit_Attendee__c/fields/Email_Sent__c.field-meta.xml' (New-CheckboxFieldXml -fullName 'Email_Sent__c' -label 'Email Inviata' -defaultValue 'false')

# Account fields
Write-File 'force-app/main/default/objects/Account/fields/Tolleranze_Default__c.field-meta.xml' (New-PicklistFieldXml -fullName 'Tolleranze_Default__c' -label 'Tolleranze Default' -values @('Standard','Stretta','Da Disegno / Custom'))
Write-File 'force-app/main/default/objects/Account/fields/Solder_Default__c.field-meta.xml' (New-PicklistFieldXml -fullName 'Solder_Default__c' -label 'Solder Default' -values @('Verde','Nero','Bianco','Rosso','Blu','Giallo','Trasparente','Nessuno','Custom'))
Write-File 'force-app/main/default/objects/Account/fields/Silkscreen_Default__c.field-meta.xml' (New-PicklistFieldXml -fullName 'Silkscreen_Default__c' -label 'Silkscreen Default' -values @('Bianco','Nero','Giallo','Nessuno','Custom'))
Write-File 'force-app/main/default/objects/Account/fields/Finish_Default__c.field-meta.xml' (New-PicklistFieldXml -fullName 'Finish_Default__c' -label 'Finish Default' -values @('HASL','HASL Lead Free','ENIG','ENEPIG','OSP','Immersion Silver','Immersion Tin','Hard Gold','Custom'))
Write-File 'force-app/main/default/objects/Account/fields/Spessore_Default__c.field-meta.xml' (New-PicklistFieldXml -fullName 'Spessore_Default__c' -label 'Spessore Default' -values @('0.4 mm','0.6 mm','0.8 mm','1.0 mm','1.2 mm','1.6 mm','2.0 mm','2.4 mm','3.2 mm','Custom'))
Write-File 'force-app/main/default/objects/Account/fields/Prerequisiti_Note__c.field-meta.xml' (New-LongTextFieldXml -fullName 'Prerequisiti_Note__c' -label 'Prerequisiti Note' -length 32768 -visibleLines 3)
Write-File 'force-app/main/default/objects/Account/fields/ERP_Customer_Code__c.field-meta.xml' (New-TextFieldXml -fullName 'ERP_Customer_Code__c' -label 'ERP Customer Code' -length 80)

# Quote fields
Write-File 'force-app/main/default/objects/Quote/fields/Inside_Sales__c.field-meta.xml' (New-LookupFieldXml -fullName 'Inside_Sales__c' -label 'Inside Sales' -referenceTo 'User' -relationshipName '' -relationshipLabel '' -required $false)
Write-File 'force-app/main/default/objects/Quote/fields/Num_Circuiti__c.field-meta.xml' (New-NumberFieldXml -fullName 'Num_Circuiti__c' -label 'Num Circuiti' -precision 10 -scale 0)
Write-File 'force-app/main/default/objects/Quote/fields/Giorni_Consegna__c.field-meta.xml' (New-NumberFieldXml -fullName 'Giorni_Consegna__c' -label 'Giorni Consegna' -precision 10 -scale 0)
Write-File 'force-app/main/default/objects/Quote/fields/Servizio__c.field-meta.xml' (New-PicklistFieldXml -fullName 'Servizio__c' -label 'Servizio' -values @('Normal','Fast','Guarantee'))
Write-File 'force-app/main/default/objects/Quote/fields/Servizio_90_10__c.field-meta.xml' (New-CheckboxFieldXml -fullName 'Servizio_90_10__c' -label 'Servizio 90 10' -defaultValue 'false')
Write-File 'force-app/main/default/objects/Quote/fields/Note_Special_Needs__c.field-meta.xml' (New-LongTextFieldXml -fullName 'Note_Special_Needs__c' -label 'Note Special Needs' -length 32768 -visibleLines 3)
Write-File 'force-app/main/default/objects/Quote/fields/Trasporto__c.field-meta.xml' (New-PicklistFieldXml -fullName 'Trasporto__c' -label 'Trasporto' -values @('A carico ELCO','A carico Cliente','Ritiro in sede','Altro'))
Write-File 'force-app/main/default/objects/Quote/fields/Anagrafica_Contatto__c.field-meta.xml' (New-LookupFieldXml -fullName 'Anagrafica_Contatto__c' -label 'Anagrafica Contatto' -referenceTo 'Contact' -relationshipName '' -relationshipLabel '' -required $false)
Write-File 'force-app/main/default/objects/Quote/fields/Purchase_Order__c.field-meta.xml' (New-TextFieldXml -fullName 'Purchase_Order__c' -label 'Purchase Order' -length 80)
Write-File 'force-app/main/default/objects/Quote/fields/Customer_Code_Snapshot__c.field-meta.xml' (New-TextFieldXml -fullName 'Customer_Code_Snapshot__c' -label 'Customer Code Snapshot' -length 80)

# QuoteLineItem fields
Write-File 'force-app/main/default/objects/QuoteLineItem/fields/Tipologia_Prodotto__c.field-meta.xml' (New-PicklistFieldXml -fullName 'Tipologia_Prodotto__c' -label 'Tipologia Prodotto' -values @('Rigido','Flessibile','Rigido-Flessibile'))

$materialValues = @('FR-4 Standard','FR-4 High Tg','Rogers','Alluminio (Metal Core)','CEM-1','CEM-3','Polyimide','Custom')
$materialMap = [ordered]@{
  'Rigido' = @('FR-4 Standard','FR-4 High Tg','Rogers','Alluminio (Metal Core)','CEM-1','CEM-3','Custom')
  'Flessibile' = @('Polyimide','Custom')
  'Rigido-Flessibile' = @('FR-4 Standard','FR-4 High Tg','Polyimide','Custom')
}
Write-File 'force-app/main/default/objects/QuoteLineItem/fields/Materiale__c.field-meta.xml' (New-PicklistFieldXml -fullName 'Materiale__c' -label 'Materiale' -values $materialValues -controllingField 'Tipologia_Prodotto__c' -valueSettingsMap $materialMap)

Write-File 'force-app/main/default/objects/QuoteLineItem/fields/Materiale_Custom_Value__c.field-meta.xml' (New-TextFieldXml -fullName 'Materiale_Custom_Value__c' -label 'Materiale Custom Value' -length 255)

$thicknessValues = @('0.4 mm','0.6 mm','0.8 mm','1.0 mm','1.2 mm','1.6 mm','2.0 mm','2.4 mm','3.2 mm','Custom')
$allStdPlusCustom = @('0.4 mm','0.6 mm','0.8 mm','1.0 mm','1.2 mm','1.6 mm','2.0 mm','2.4 mm','3.2 mm','Custom')
$thicknessMap = [ordered]@{
  'FR-4 Standard' = $allStdPlusCustom
  'FR-4 High Tg' = $allStdPlusCustom
  'Rogers' = @('0.8 mm','1.6 mm','Custom')
  'Alluminio (Metal Core)' = @('1.0 mm','1.6 mm','Custom')
  'Polyimide' = @('0.4 mm','0.6 mm','0.8 mm','1.0 mm','Custom')
  'CEM-1' = @('1.0 mm','1.6 mm','Custom')
  'CEM-3' = @('1.0 mm','1.6 mm','Custom')
  'Custom' = @('Custom')
}
Write-File 'force-app/main/default/objects/QuoteLineItem/fields/Spessore_Complessivo__c.field-meta.xml' (New-PicklistFieldXml -fullName 'Spessore_Complessivo__c' -label 'Spessore Complessivo' -values $thicknessValues -controllingField 'Materiale__c' -valueSettingsMap $thicknessMap)

Write-File 'force-app/main/default/objects/QuoteLineItem/fields/Spessore_Custom_Value__c.field-meta.xml' (New-TextFieldXml -fullName 'Spessore_Custom_Value__c' -label 'Spessore Custom Value' -length 255)
Write-File 'force-app/main/default/objects/QuoteLineItem/fields/Spessore_Rame_Esterni__c.field-meta.xml' (New-PicklistFieldXml -fullName 'Spessore_Rame_Esterni__c' -label 'Spessore Rame Esterni' -values @('0.5 oz (18 µm)','1 oz (35 µm)','2 oz (70 µm)','Custom'))
Write-File 'force-app/main/default/objects/QuoteLineItem/fields/Rame_Custom_Value__c.field-meta.xml' (New-TextFieldXml -fullName 'Rame_Custom_Value__c' -label 'Rame Custom Value' -length 255)
Write-File 'force-app/main/default/objects/QuoteLineItem/fields/Finish__c.field-meta.xml' (New-PicklistFieldXml -fullName 'Finish__c' -label 'Finish' -values @('HASL','HASL Lead Free','ENIG','ENEPIG','OSP','Immersion Silver','Immersion Tin','Hard Gold','Custom'))
Write-File 'force-app/main/default/objects/QuoteLineItem/fields/Solder_Specifico__c.field-meta.xml' (New-PicklistFieldXml -fullName 'Solder_Specifico__c' -label 'Solder Specifico' -values @('Verde','Nero','Bianco','Rosso','Blu','Giallo','Trasparente','Nessuno','Custom'))
Write-File 'force-app/main/default/objects/QuoteLineItem/fields/Silkscreen_Specifico__c.field-meta.xml' (New-PicklistFieldXml -fullName 'Silkscreen_Specifico__c' -label 'Silkscreen Specifico' -values @('Bianco','Nero','Giallo','Nessuno','Custom'))
Write-File 'force-app/main/default/objects/QuoteLineItem/fields/Dimensioni_Array__c.field-meta.xml' (New-TextFieldXml -fullName 'Dimensioni_Array__c' -label 'Dimensioni Array' -length 80)
Write-File 'force-app/main/default/objects/QuoteLineItem/fields/Internal_Circuit_Code__c.field-meta.xml' (New-TextFieldXml -fullName 'Internal_Circuit_Code__c' -label 'Internal Circuit Code' -length 80)
Write-File 'force-app/main/default/objects/QuoteLineItem/fields/Customer_Circuit_Code__c.field-meta.xml' (New-TextFieldXml -fullName 'Customer_Circuit_Code__c' -label 'Customer Circuit Code' -length 80)

$allFields = Get-ChildItem 'force-app/main/default/objects' -Recurse -Filter '*.field-meta.xml' | Measure-Object
"FIELD_FILES=$($allFields.Count)" | Set-Content 'raw/generated_field_file_count.txt' -Encoding utf8
Get-ChildItem 'force-app/main/default/objects' -Recurse -File | Select-Object FullName | Out-File 'raw/generated_metadata_files.txt' -Encoding utf8
Write-Host "Metadata generation complete. Field files: $($allFields.Count)"
