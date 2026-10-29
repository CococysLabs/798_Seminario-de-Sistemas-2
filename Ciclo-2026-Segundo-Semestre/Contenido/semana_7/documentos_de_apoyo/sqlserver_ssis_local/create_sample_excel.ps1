$ErrorActionPreference = "Stop"

function Get-ExcelColumnName {
    param([int]$Number)

    $name = ""
    while ($Number -gt 0) {
        $mod = ($Number - 1) % 26
        $name = [char](65 + $mod) + $name
        $Number = [math]::Floor(($Number - $mod) / 26)
    }

    return $name
}

function New-InlineStringCell {
    param(
        [int]$Column,
        [int]$Row,
        [string]$Value
    )

    $ref = "$(Get-ExcelColumnName $Column)$Row"
    $escaped = [System.Security.SecurityElement]::Escape([string]$Value)
    return "<c r=`"$ref`" t=`"inlineStr`"><is><t>$escaped</t></is></c>"
}

function New-NumberCell {
    param(
        [int]$Column,
        [int]$Row,
        [decimal]$Value,
        [int]$Style = 0
    )

    $ref = "$(Get-ExcelColumnName $Column)$Row"
    return "<c r=`"$ref`" s=`"$Style`"><v>$Value</v></c>"
}

function New-DateCell {
    param(
        [int]$Column,
        [int]$Row,
        [datetime]$Value
    )

    $ref = "$(Get-ExcelColumnName $Column)$Row"
    $excelEpoch = Get-Date "1899-12-30"
    $serial = [math]::Round(($Value - $excelEpoch).TotalDays, 5)
    return "<c r=`"$ref`" s=`"1`"><v>$serial</v></c>"
}

function New-WorksheetXml {
    param(
        [string]$Dimension,
        [string[]]$RowsXml
    )

    return @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <dimension ref="$Dimension"/>
  <sheetViews>
    <sheetView workbookViewId="0"/>
  </sheetViews>
  <sheetFormatPr defaultRowHeight="15"/>
  <sheetData>
$(($RowsXml -join "`n"))
  </sheetData>
</worksheet>
"@
}

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourcesDir = Join-Path $baseDir "sources"
$outputPath = Join-Path $sourcesDir "ventas_cubo_ejemplo.xlsx"
$buildDir = Join-Path $baseDir ".xlsx_build"

New-Item -ItemType Directory -Force -Path $sourcesDir | Out-Null
if (Test-Path $buildDir) {
    Remove-Item -Recurse -Force $buildDir
}

New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $buildDir "_rels") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $buildDir "docProps") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $buildDir "xl") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $buildDir "xl\_rels") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $buildDir "xl\worksheets") | Out-Null

$headers = @(
    "VentaID",
    "Fecha",
    "Anio",
    "Mes",
    "Trimestre",
    "ProductoID",
    "Producto",
    "Categoria",
    "Marca",
    "ClienteID",
    "Cliente",
    "SegmentoCliente",
    "Ciudad",
    "Pais",
    "Canal",
    "Cantidad",
    "PrecioUnitario",
    "CostoUnitario",
    "DescuentoPct",
    "MontoVenta",
    "MontoCosto",
    "Utilidad"
)

$products = @(
    @{ Id = "P001"; Name = "Laptop Pro 14"; Category = "Laptops"; Marca = "TechPro"; Price = 1250; Cost = 930 },
    @{ Id = "P002"; Name = "Mouse Inalambrico"; Category = "Accesorios"; Marca = "ClickMax"; Price = 25; Cost = 11 },
    @{ Id = "P003"; Name = "Monitor 27"; Category = "Monitores"; Marca = "Vision"; Price = 280; Cost = 210 },
    @{ Id = "P004"; Name = "Teclado Mecanico"; Category = "Accesorios"; Marca = "ClickMax"; Price = 70; Cost = 38 },
    @{ Id = "P005"; Name = "Dock USB-C"; Category = "Perifericos"; Marca = "Connect"; Price = 95; Cost = 54 },
    @{ Id = "P006"; Name = "SSD 1TB"; Category = "Almacenamiento"; Marca = "FlashCore"; Price = 120; Cost = 74 }
)

$clients = @(
    @{ Id = "C001"; Name = "Ana Lopez"; Segment = "Retail"; City = "Guatemala"; Country = "Guatemala"; Channel = "Tienda" },
    @{ Id = "C002"; Name = "Carlos Perez"; Segment = "Retail"; City = "Mixco"; Country = "Guatemala"; Channel = "Web" },
    @{ Id = "C003"; Name = "Innova, S.A."; Segment = "Corporativo"; City = "Guatemala"; Country = "Guatemala"; Channel = "Ejecutivo" },
    @{ Id = "C004"; Name = "Maria Garcia"; Segment = "Retail"; City = "Antigua"; Country = "Guatemala"; Channel = "Web" },
    @{ Id = "C005"; Name = "Soluciones BI"; Segment = "PYME"; City = "Quetzaltenango"; Country = "Guatemala"; Channel = "Ejecutivo" },
    @{ Id = "C006"; Name = "Diego Morales"; Segment = "Retail"; City = "Villa Nueva"; Country = "Guatemala"; Channel = "Tienda" }
)

$rowsXml = @()
$headerCells = for ($i = 0; $i -lt $headers.Count; $i++) { New-InlineStringCell -Column ($i + 1) -Row 1 -Value $headers[$i] }
$rowsXml += ('    <row r="1">{0}</row>' -f ($headerCells -join ""))

$row = 2
$ventaId = 1001
$startDate = Get-Date "2025-01-03"

for ($day = 0; $day -lt 90; $day++) {
    $fecha = $startDate.AddDays($day)

    for ($i = 0; $i -lt $products.Count; $i++) {
        $product = $products[$i]
        $client = $clients[($day + $i) % $clients.Count]
        $cantidad = (($day + $i) % 4) + 1
        $descuento = switch (($day + $i) % 5) {
            0 { 0.00 }
            1 { 0.05 }
            2 { 0.10 }
            3 { 0.00 }
            default { 0.15 }
        }

        $montoVenta = [math]::Round($cantidad * $product.Price * (1 - $descuento), 2)
        $montoCosto = [math]::Round($cantidad * $product.Cost, 2)
        $utilidad = [math]::Round($montoVenta - $montoCosto, 2)
        $trimestre = "T$([math]::Ceiling($fecha.Month / 3))"

        $cells = @(
            (New-NumberCell -Column 1 -Row $row -Value $ventaId),
            (New-DateCell -Column 2 -Row $row -Value $fecha),
            (New-NumberCell -Column 3 -Row $row -Value $fecha.Year),
            (New-InlineStringCell -Column 4 -Row $row -Value $fecha.ToString("MMMM")),
            (New-InlineStringCell -Column 5 -Row $row -Value $trimestre),
            (New-InlineStringCell -Column 6 -Row $row -Value $product.Id),
            (New-InlineStringCell -Column 7 -Row $row -Value $product.Name),
            (New-InlineStringCell -Column 8 -Row $row -Value $product.Category),
            (New-InlineStringCell -Column 9 -Row $row -Value $product.Marca),
            (New-InlineStringCell -Column 10 -Row $row -Value $client.Id),
            (New-InlineStringCell -Column 11 -Row $row -Value $client.Name),
            (New-InlineStringCell -Column 12 -Row $row -Value $client.Segment),
            (New-InlineStringCell -Column 13 -Row $row -Value $client.City),
            (New-InlineStringCell -Column 14 -Row $row -Value $client.Country),
            (New-InlineStringCell -Column 15 -Row $row -Value $client.Channel),
            (New-NumberCell -Column 16 -Row $row -Value $cantidad),
            (New-NumberCell -Column 17 -Row $row -Value $product.Price -Style 2),
            (New-NumberCell -Column 18 -Row $row -Value $product.Cost -Style 2),
            (New-NumberCell -Column 19 -Row $row -Value $descuento -Style 3),
            (New-NumberCell -Column 20 -Row $row -Value $montoVenta -Style 2),
            (New-NumberCell -Column 21 -Row $row -Value $montoCosto -Style 2),
            (New-NumberCell -Column 22 -Row $row -Value $utilidad -Style 2)
        )

        $rowsXml += ('    <row r="{0}">{1}</row>' -f $row, ($cells -join ""))
        $ventaId++
        $row++
    }
}

$modeloRows = @(
    ('    <row r="1">{0}</row>' -f (New-InlineStringCell -Column 1 -Row 1 -Value "FactVentas")),
    ('    <row r="2">{0}</row>' -f (New-InlineStringCell -Column 1 -Row 2 -Value "FechaKey, ProductoKey, ClienteKey, Cantidad, MontoVenta, MontoCosto, Utilidad")),
    ('    <row r="4">{0}</row>' -f (New-InlineStringCell -Column 1 -Row 4 -Value "DimFecha")),
    ('    <row r="5">{0}</row>' -f (New-InlineStringCell -Column 1 -Row 5 -Value "FechaKey, Fecha, Anio, Mes, Trimestre")),
    ('    <row r="7">{0}</row>' -f (New-InlineStringCell -Column 1 -Row 7 -Value "DimProducto")),
    ('    <row r="8">{0}</row>' -f (New-InlineStringCell -Column 1 -Row 8 -Value "ProductoKey, ProductoID, Producto, Categoria, Marca")),
    ('    <row r="10">{0}</row>' -f (New-InlineStringCell -Column 1 -Row 10 -Value "DimCliente")),
    ('    <row r="11">{0}</row>' -f (New-InlineStringCell -Column 1 -Row 11 -Value "ClienteKey, ClienteID, Cliente, SegmentoCliente, Ciudad, Pais, Canal"))
)

$sheet1Xml = New-WorksheetXml -Dimension "A1:V$($row - 1)" -RowsXml $rowsXml
$sheet2Xml = New-WorksheetXml -Dimension "A1:A11" -RowsXml $modeloRows

$contentTypes = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
  <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
  <Override PartName="/xl/worksheets/sheet2.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
  <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
</Types>
"@

$rootRels = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>
"@

$appXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
  <Application>Microsoft Excel</Application>
  <DocSecurity>0</DocSecurity>
  <ScaleCrop>false</ScaleCrop>
  <HeadingPairs>
    <vt:vector size="2" baseType="variant">
      <vt:variant><vt:lpstr>Worksheets</vt:lpstr></vt:variant>
      <vt:variant><vt:i4>2</vt:i4></vt:variant>
    </vt:vector>
  </HeadingPairs>
  <TitlesOfParts>
    <vt:vector size="2" baseType="lpstr">
      <vt:lpstr>VentasRaw</vt:lpstr>
      <vt:lpstr>ModeloSugerido</vt:lpstr>
    </vt:vector>
  </TitlesOfParts>
</Properties>
"@

$created = (Get-Date).ToUniversalTime().ToString("s") + "Z"
$coreXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:creator>Codex</dc:creator>
  <cp:lastModifiedBy>Codex</cp:lastModifiedBy>
  <dcterms:created xsi:type="dcterms:W3CDTF">$created</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">$created</dcterms:modified>
  <dc:title>Ventas cubo ejemplo</dc:title>
</cp:coreProperties>
"@

$workbookXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheets>
    <sheet name="VentasRaw" sheetId="1" r:id="rId1"/>
    <sheet name="ModeloSugerido" sheetId="2" r:id="rId2"/>
  </sheets>
</workbook>
"@

$workbookRels = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet2.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>
"@

$stylesXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <numFmts count="2">
    <numFmt numFmtId="164" formatCode="yyyy-mm-dd"/>
    <numFmt numFmtId="165" formatCode="#,##0.00"/>
  </numFmts>
  <fonts count="1">
    <font>
      <sz val="11"/>
      <name val="Calibri"/>
      <family val="2"/>
    </font>
  </fonts>
  <fills count="2">
    <fill><patternFill patternType="none"/></fill>
    <fill><patternFill patternType="gray125"/></fill>
  </fills>
  <borders count="1">
    <border><left/><right/><top/><bottom/><diagonal/></border>
  </borders>
  <cellStyleXfs count="1">
    <xf numFmtId="0" fontId="0" fillId="0" borderId="0"/>
  </cellStyleXfs>
  <cellXfs count="4">
    <xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>
    <xf numFmtId="164" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/>
    <xf numFmtId="165" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/>
    <xf numFmtId="10" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/>
  </cellXfs>
  <cellStyles count="1">
    <cellStyle name="Normal" xfId="0" builtinId="0"/>
  </cellStyles>
</styleSheet>
"@

$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Join-Path $buildDir "[Content_Types].xml"), $contentTypes, $utf8)
[System.IO.File]::WriteAllText((Join-Path $buildDir "_rels\.rels"), $rootRels, $utf8)
[System.IO.File]::WriteAllText((Join-Path $buildDir "docProps\app.xml"), $appXml, $utf8)
[System.IO.File]::WriteAllText((Join-Path $buildDir "docProps\core.xml"), $coreXml, $utf8)
[System.IO.File]::WriteAllText((Join-Path $buildDir "xl\workbook.xml"), $workbookXml, $utf8)
[System.IO.File]::WriteAllText((Join-Path $buildDir "xl\_rels\workbook.xml.rels"), $workbookRels, $utf8)
[System.IO.File]::WriteAllText((Join-Path $buildDir "xl\styles.xml"), $stylesXml, $utf8)
[System.IO.File]::WriteAllText((Join-Path $buildDir "xl\worksheets\sheet1.xml"), $sheet1Xml, $utf8)
[System.IO.File]::WriteAllText((Join-Path $buildDir "xl\worksheets\sheet2.xml"), $sheet2Xml, $utf8)

if (Test-Path $outputPath) {
    Remove-Item -Force $outputPath
}

$zipPath = Join-Path $sourcesDir "ventas_cubo_ejemplo.zip"
if (Test-Path $zipPath) {
    Remove-Item -Force $zipPath
}

Compress-Archive -Path (Join-Path $buildDir "*") -DestinationPath $zipPath
Move-Item -Force $zipPath $outputPath
Remove-Item -Recurse -Force $buildDir

Write-Output "Excel generado en: $outputPath"
