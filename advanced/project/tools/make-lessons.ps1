<#
  Maakt de voorbeeldontwerpen (.htd) van het leerpad: Nederlands in project\lessen,
  Engels, Frans en Duits in project\lessen\en, \fr en \de, en de afbeeldingen in
  project\lessen\afbeeldingen. De teksten staan in make-lessons-text.json (UTF-8);
  dit script zelf blijft ASCII.

  Een .htd-bestand is een ini-bestand (zie THtmlTableDesigner.SaveToHTD):
    [Table]       algemene instellingen
    [ColWidths]   kolombreedtes in pixels
    [RowHeights]  rijhoogtes in pixels
    [Cell_<kolom>_<rij>]  per cel: tekst en opmaak
    [TextBlocks]  aantal vrije tekstblokken
  Kleuren zijn Windows-kleuren (BGR); hieronder geef je ze als #RRGGBB.
  Uitlijning: 0 links, 1 midden, 2 rechts. Stijl: 1 vet, 2 cursief, 4 onderlijnd.

  Gebruik:
      powershell -ExecutionPolicy Bypass -File project\tools\make-lessons.ps1
#>
$ErrorActionPreference = 'Stop'
$Project = Split-Path $PSScriptRoot -Parent
$Out = Join-Path $Project 'lessen'
New-Item -ItemType Directory -Force $Out | Out-Null
$Utf8 = New-Object System.Text.UTF8Encoding($false)

function Col([string]$Hex) {
  $h = $Hex.TrimStart('#')
  $r = [Convert]::ToInt32($h.Substring(0, 2), 16)
  $g = [Convert]::ToInt32($h.Substring(2, 2), 16)
  $b = [Convert]::ToInt32($h.Substring(4, 2), 16)
  return ($b -shl 16) + ($g -shl 8) + $r
}

# Nieuw ontwerp: kolombreedtes en rijhoogtes in pixels
function New-Design([int[]]$ColWidths, [int[]]$RowHeights) {
  $d = @{ W = $ColWidths; H = $RowHeights; Cells = @{}; Blocks = @() }
  for ($c = 0; $c -lt $ColWidths.Count; $c++) {
    for ($r = 0; $r -lt $RowHeights.Count; $r++) {
      $d.Cells["$c,$r"] = [ordered]@{
        Text = ''; BgColor = (Col '#FFFFFF'); FontColor = 0; Align = 0; FontSize = 10; FontStyles = 0
        ColSpan = 1; RowSpan = 1; Merged = 0; MasterCol = -1; MasterRow = -1; BorderStyle = 1
        ShowImage = 0; ImageFile = ''; ImageAlign = 0; ImageSizeMode = 0
        IsLink = 0; LinkURL = ''; LinkText = ''; ImageIsLink = 0; ImageLinkURL = ''
      }
    }
  }
  return $d
}

# Tekst in een rij zetten, vanaf kolom 0
function Set-Row($d, [int]$Row, [string[]]$Texts) {
  for ($c = 0; $c -lt $Texts.Count; $c++) { $d.Cells["$c,$Row"].Text = $Texts[$c] }
}

# Opmaak voor een rechthoek cellen
function Set-Style($d, [int]$C1, [int]$R1, [int]$C2, [int]$R2, [hashtable]$Props) {
  for ($c = $C1; $c -le $C2; $c++) {
    for ($r = $R1; $r -le $R2; $r++) {
      foreach ($k in $Props.Keys) { $d.Cells["$c,$r"][$k] = $Props[$k] }
    }
  }
}

# Cellen samenvoegen zoals de designer het doet (MergeCells)
function Merge-Cells($d, [int]$C1, [int]$R1, [int]$C2, [int]$R2) {
  $m = $d.Cells["$C1,$R1"]
  $m.ColSpan = $C2 - $C1 + 1; $m.RowSpan = $R2 - $R1 + 1
  for ($c = $C1; $c -le $C2; $c++) {
    for ($r = $R1; $r -le $R2; $r++) {
      if (($c -eq $C1) -and ($r -eq $R1)) { continue }
      $x = $d.Cells["$c,$r"]
      $x.Text = ''; $x.Merged = 1; $x.MasterCol = $C1; $x.MasterRow = $R1
    }
  }
}

# Vrij tekstblok; Left/Top/Right/Bottom in schermpixels van de designer.
# Met de standaardinstellingen begint de tabel (cel A1) op x = 161 en y = 42 + TableOffsetY.
# Links: @(@{ Text = 'stuk tekst'; URL = 'https://...' })
function Add-Block($d, [int]$L, [int]$T, [int]$R, [int]$B, [string]$Text, [hashtable]$Props, $Links = @()) {
  $tb = [ordered]@{
    Left = $L; Top = $T; Right = $R; Bottom = $B; Text = $Text; Links = @($Links)
    Alignment = 0; FontSize = 10; FontColor = 0; FontStyles = 0; LineHeight = 15
    BgColor = (Col '#FFFFFF'); Transparent = 1; BorderColor = (Col '#808080'); BorderWidth = 1
    BorderStyle = 0; BorderRadius = 0; Padding = 4
  }
  if ($Props) { foreach ($k in $Props.Keys) { $tb[$k] = $Props[$k] } }
  $d.Blocks += $tb
}

# Afbeelding in een cel; het pad is relatief t.o.v. de map van het ontwerp
function Set-Image($d, [int]$C, [int]$R, [string]$File, [int]$Align = 1, [string]$LinkURL = '') {
  $x = $d.Cells["$C,$R"]
  $x.ShowImage = 1; $x.ImageFile = "$($script:ImgPrefix)$File"; $x.ImageAlign = $Align
  if ($LinkURL) { $x.ImageIsLink = 1; $x.ImageLinkURL = $LinkURL }
}

# Teksthyperlink: de hele celtekst wordt de link
function Set-Link($d, [int]$C, [int]$R, [string]$URL) {
  $x = $d.Cells["$C,$R"]
  $x.IsLink = 1; $x.LinkURL = $URL; $x.LinkText = $x.Text
}

function Save-Design($d, [string]$Name) {
  $sb = New-Object System.Text.StringBuilder
  $cols = $d.W.Count; $rows = $d.H.Count
  [void]$sb.AppendLine('[Table]')
  $t = [ordered]@{
    Cols = $cols; Rows = $rows; DefaultColWidth = 95; DefaultRowHeight = 26
    GridColor = 12632256; GridLineWidth = 1; ShowGrid = 1; ShowLayoutGrid = 0; LayoutGridSize = 10
    LayoutGridColor = 0; SelectionColor = 255; HtmlBgColor = (Col '#FFFFFF'); AutoStretchTable = 0
    AutoFitTable = 0; CellAfronding = 0; ShowHeaders = 1; HeaderHeight = 22; HeaderWidth = 32
    HeaderColor = 536870912; HeaderFontColor = 0; PageEnabled = 1; PageWidth = 794; PageHeight = 1123
    PageMarginX = 20; PageMarginY = 20; TableOffsetX = 76; TableOffsetY = 76; ShowPageRulers = 1
    RulerSize = 20; RulerStep = 50; PixelsPerMM = '3,77952755905512'
    ExportTableBgColor = (Col '#FFFFFF'); ExportTableBorderColor = 0; ExportTableBorderWidth = 1
    ExportTableBorderRadius = 0; ExportTableBorderStyle = 1; ExportCellBorderColor = 0
    ExportCellBorderRadius = 0; ExportCellPadding = 4
  }
  if ($d.Table) { foreach ($k in $d.Table.Keys) { $t[$k] = $d.Table[$k] } }
  foreach ($k in $t.Keys) { [void]$sb.AppendLine("$k=$($t[$k])") }
  [void]$sb.AppendLine(); [void]$sb.AppendLine('[ColWidths]')
  for ($c = 0; $c -lt $cols; $c++) { [void]$sb.AppendLine("$c=$($d.W[$c])") }
  [void]$sb.AppendLine(); [void]$sb.AppendLine('[RowHeights]')
  for ($r = 0; $r -lt $rows; $r++) { [void]$sb.AppendLine("$r=$($d.H[$r])") }
  for ($c = 0; $c -lt $cols; $c++) {
    for ($r = 0; $r -lt $rows; $r++) {
      $x = $d.Cells["$c,$r"]
      [void]$sb.AppendLine(); [void]$sb.AppendLine("[Cell_${c}_$r]")
      [void]$sb.AppendLine("Text=$($x.Text)")
      [void]$sb.AppendLine('BackupText='); [void]$sb.AppendLine('BackupValid=0'); [void]$sb.AppendLine('HintText=')
      foreach ($k in 'BgColor', 'FontColor', 'Align', 'FontSize', 'FontStyles') { [void]$sb.AppendLine("$k=$($x[$k])") }
      [void]$sb.AppendLine('Border=1'); [void]$sb.AppendLine("BorderStyle=$($x.BorderStyle)")
      foreach ($k in 'ColSpan', 'RowSpan', 'Merged', 'MasterCol', 'MasterRow') { [void]$sb.AppendLine("$k=$($x[$k])") }
      foreach ($k in 'ShowImage', 'ImageFile', 'ImageAlign') { [void]$sb.AppendLine("$k=$($x[$k])") }
      [void]$sb.AppendLine('ImageStretch=0'); [void]$sb.AppendLine("ImageSizeMode=$($x.ImageSizeMode)")
      foreach ($k in 'IsLink', 'LinkURL', 'LinkText', 'ImageIsLink', 'ImageLinkURL') { [void]$sb.AppendLine("$k=$($x[$k])") }
    }
  }
  [void]$sb.AppendLine(); [void]$sb.AppendLine('[TextBlocks]'); [void]$sb.AppendLine("Count=$($d.Blocks.Count)")
  for ($i = 0; $i -lt $d.Blocks.Count; $i++) {
    $b = $d.Blocks[$i]; $s = "TextBlock_$i"
    [void]$sb.AppendLine(); [void]$sb.AppendLine("[$s]")
    foreach ($k in 'Left', 'Top', 'Right', 'Bottom') { [void]$sb.AppendLine("$k=$($b[$k])") }
    # regeleinde in de tekst = \n in het bestand
    [void]$sb.AppendLine('Text=' + $b.Text.Replace('\', '\\').Replace("`n", '\n'))
    [void]$sb.AppendLine('IsLink=0'); [void]$sb.AppendLine('LinkURL='); [void]$sb.AppendLine('LinkStart=-1'); [void]$sb.AppendLine('LinkLength=0')
    [void]$sb.AppendLine("LinkCount=$($b.Links.Count)")
    [void]$sb.AppendLine('StyleRunCount=0'); [void]$sb.AppendLine('ColorRunCount=0')
    foreach ($k in 'Alignment', 'FontSize', 'FontColor', 'FontStyles', 'LineHeight', 'BgColor', 'Transparent',
                   'BorderColor', 'BorderWidth', 'BorderStyle', 'BorderRadius', 'Padding') { [void]$sb.AppendLine("$k=$($b[$k])") }
    [void]$sb.AppendLine('WordWrap=1')
    for ($l = 0; $l -lt $b.Links.Count; $l++) {
      # link = het eerste voorkomen van een stuk tekst in het blok. De designer telt in
      # bytes (UTF-8) en een regeleinde onder Windows als 2 tekens (CR LF).
      $lk = $b.Links[$l]; $full = $b.Text.Replace("`n", "`r`n")
      $start = $Utf8.GetByteCount($full.Substring(0, $full.IndexOf($lk.Text)))
      [void]$sb.AppendLine(); [void]$sb.AppendLine("[${s}_Link_$l]")
      [void]$sb.AppendLine("StartPos=$start")
      [void]$sb.AppendLine("Length=$($Utf8.GetByteCount($lk.Text))"); [void]$sb.AppendLine("URL=$($lk.URL)")
    }
  }
  $f = Join-Path $script:LangOut $Name
  [IO.File]::WriteAllText($f, $sb.ToString().Replace("`r`n", "`n").Replace("`n", "`r`n"), $Utf8)
  Write-Host "Gemaakt: $f"
}

$Blauw = Col '#1F4E79'; $Wit = Col '#FFFFFF'; $Licht = Col '#EAF1FB'; $Kop = Col '#DCE6F2'
$Geel = Col '#FFF2CC'; $Grijs = Col '#E7E6E6'; $Groen = Col '#E2EFDA'


# ---------------- Afbeeldingen voor les 5 tot 8 (lessen\afbeeldingen) ----------------
Add-Type -AssemblyName System.Drawing
$ImgDir = Join-Path $Out 'afbeeldingen'
New-Item -ItemType Directory -Force $ImgDir | Out-Null

function New-Picture([string]$Name, [int]$Size, [scriptblock]$Paint) {
  $bmp = New-Object System.Drawing.Bitmap($Size, $Size)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAliasGridFit'
  $g.Clear([System.Drawing.Color]::Transparent)
  & $Paint $g
  $g.Dispose()
  $bmp.Save((Join-Path $ImgDir $Name), [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  Write-Host "Gemaakt: afbeeldingen\$Name"
}
function Brush([string]$Hex) { New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($Hex)) }
function Pen([string]$Hex, [float]$W) {
  $p = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml($Hex), $W)
  $p.StartCap = 'Round'; $p.EndCap = 'Round'; return $p
}
function Leaf($g, [float]$X, [float]$Y) {
  $m = $g.Transform; $g.TranslateTransform($X, $Y); $g.RotateTransform(-30)
  $g.FillEllipse((Brush '#4E9A2E'), 0, -7, 30, 14); $g.DrawLine((Pen '#2F6B1A' 1.5), 2, 0, 26, 0)
  $g.Transform = $m
}

New-Picture 'appel.png' 128 {
  param($g)
  $g.FillEllipse((Brush '#C62828'), 14, 30, 54, 86)
  $g.FillEllipse((Brush '#C62828'), 60, 30, 54, 86)
  $g.FillEllipse((Brush '#E53935'), 22, 36, 84, 72)
  $g.FillEllipse((Brush '#FF8A80'), 34, 46, 16, 26)
  $g.DrawLine((Pen '#6D4C41' 5), 64, 40, 70, 14)
  Leaf $g 70 22
}
New-Picture 'peer.png' 128 {
  param($g)
  $g.FillEllipse((Brush '#9CCC65'), 22, 50, 84, 72)
  $g.FillEllipse((Brush '#9CCC65'), 40, 20, 48, 62)
  $g.FillEllipse((Brush '#C5E1A5'), 38, 62, 16, 28)
  $g.DrawLine((Pen '#6D4C41' 5), 64, 24, 60, 6)
  Leaf $g 62 14
}
New-Picture 'banaan.png' 128 {
  param($g)
  # halve maan: buitenboog heen, binnenboog terug; daarna schuin gedraaid
  $g.TranslateTransform(64, 64); $g.RotateTransform(-35); $g.TranslateTransform(-64, -64)
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $p.AddArc(8, -20, 112, 120, 15, 150)
  $p.AddArc(22, -42, 84, 112, 160, -140)
  $p.CloseFigure()
  $g.FillPath((Brush '#FDD835'), $p)
  $g.DrawPath((Pen '#F9A825' 3), $p)
  $g.DrawLine((Pen '#5D4037' 6), 112, 72, 118, 64)
  $g.FillEllipse((Brush '#5D4037'), 12, 66, 7, 7)
}
# eenvoudige ronde knoppen met een letter (voor afbeeldingslinks)
function Badge([string]$Name, [string]$Hex, [string]$Letter) {
  New-Picture $Name 48 {
    param($g)
    $g.FillEllipse((Brush $Hex), 2, 2, 44, 44)
    $f = New-Object System.Drawing.Font('Segoe UI', 20, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $sf = New-Object System.Drawing.StringFormat; $sf.Alignment = 'Center'; $sf.LineAlignment = 'Center'
    $g.DrawString($Letter, $f, (Brush '#FFFFFF'), (New-Object System.Drawing.RectangleF(2, 3, 44, 44)), $sf)
  }.GetNewClosure()
}
Badge 'knop-w.png' '#5B6770' 'W'
Badge 'knop-k.png' '#E8762C' 'K'
Badge 'knop-l.png' '#2E7D32' 'L'
Badge 'knop-h.png' '#1F4E79' 'H'

$Oranje = Col '#E8762C'; $Zalm = Col '#FCE4D6'; $Bruin = Col '#843C0C'; $Room = Col '#FFF8F0'

# ---------------- De lessen, in elke taal ----------------
# Teksten: make-lessons-text.json (UTF-8). Nederlands in lessen\, de andere talen in lessen\<taal>\.
$Texts = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'make-lessons-text.json'), $Utf8) | ConvertFrom-Json

# alle rijen van een les invullen; een rij kan korter zijn dan de tabel
function Set-Rows($d, $Rows) { for ($r = 0; $r -lt $Rows.Count; $r++) { Set-Row $d $r @($Rows[$r]) } }

foreach ($Lang in 'nl', 'en', 'fr', 'de') {
  $T = $Texts.$Lang
  if ($Lang -eq 'nl') { $script:LangOut = $Out; $script:ImgPrefix = 'afbeeldingen/' }
  else { $script:LangOut = Join-Path $Out $Lang; $script:ImgPrefix = '../afbeeldingen/' }
  New-Item -ItemType Directory -Force $script:LangOut | Out-Null

  # ---------------- Les 1: je eerste tabel (zonder opmaak) ----------------
  $d = New-Design @(150, 80, 90) @(28, 28, 28, 28, 28)
  Set-Rows $d $T.les01
  Save-Design $d 'les01-boodschappen.htd'

  # ---------------- Les 2: cellen opmaken ----------------
  $d = New-Design @(150, 80, 90) @(30, 28, 28, 28, 28, 30)
  Set-Rows $d $T.les01
  Set-Row $d 5 @($T.les02total)
  Set-Style $d 0 0 2 0 @{ BgColor = $Blauw; FontColor = $Wit; FontStyles = 1; Align = 1; FontSize = 11 }
  Set-Style $d 1 1 1 4 @{ Align = 1 }
  Set-Style $d 2 1 2 5 @{ Align = 2 }
  Set-Style $d 0 2 2 2 @{ BgColor = $Licht }
  Set-Style $d 0 4 2 4 @{ BgColor = $Licht }
  Set-Style $d 0 5 2 5 @{ FontStyles = 1; BgColor = $Kop }
  Save-Design $d 'les02-opmaak.htd'

  # ---------------- Les 3: cellen samenvoegen (lessenrooster) ----------------
  $d = New-Design @(60, 110, 110, 110, 110, 150) @(38, 30, 30, 30, 30, 30, 30, 30)
  Set-Rows $d $T.les03
  Set-Style $d 0 0 5 0 @{ BgColor = $Blauw; FontColor = $Wit; FontStyles = 1; FontSize = 14; Align = 1 }
  Set-Style $d 0 1 5 1 @{ BgColor = $Kop; FontStyles = 1; Align = 1 }
  Set-Style $d 0 2 0 7 @{ BgColor = $Kop; Align = 1 }
  Set-Style $d 1 2 5 7 @{ Align = 1 }
  Set-Style $d 1 5 5 5 @{ BgColor = $Geel; FontStyles = 2 }
  Set-Style $d 2 3 3 3 @{ BgColor = $Groen }
  Set-Style $d 3 6 3 6 @{ BgColor = $Grijs; FontStyles = 2 }
  Merge-Cells $d 0 0 5 0      # titel over de hele breedte
  Merge-Cells $d 2 3 2 4      # Informatica: twee lesuren
  Merge-Cells $d 3 3 3 4      # Sport: twee lesuren
  Merge-Cells $d 1 5 5 5      # Middagpauze over alle dagen
  Merge-Cells $d 3 6 3 7      # woensdagmiddag vrij
  Save-Design $d 'les03-lessenrooster.htd'

  # ---------------- Les 4: randen en afgeronde hoeken (prijslijst) ----------------
  $d = New-Design @(150, 80, 80, 80) @(40, 30, 30, 30, 30, 30)
  $d.Table = @{ ExportTableBorderColor = $Bruin; ExportTableBorderWidth = 3; ExportTableBorderRadius = 14
                GridColor = (Col '#F4B183'); ExportTableBgColor = $Room }
  Set-Rows $d $T.les04
  Set-Style $d 0 0 3 5 @{ BgColor = $Room }
  Set-Style $d 0 0 3 0 @{ BgColor = $Oranje; FontColor = $Wit; FontStyles = 1; FontSize = 16; Align = 1 }
  Set-Style $d 0 1 3 1 @{ BgColor = $Zalm; FontStyles = 1; Align = 1 }
  Set-Style $d 0 2 0 5 @{ FontStyles = 1 }
  Set-Style $d 1 2 3 5 @{ Align = 1 }
  Set-Style $d 0 2 3 5 @{ BorderStyle = 3 }
  Set-Style $d 1 5 3 5 @{ FontStyles = 2 }
  Merge-Cells $d 0 0 3 0
  Merge-Cells $d 1 5 3 5
  Save-Design $d 'les04-prijslijst.htd'

  # ---------------- Les 5: afbeeldingen (productfiche) ----------------
  $d = New-Design @(150, 100, 190) @(40, 34, 34, 34, 34)
  $d.Table = @{ ExportTableBorderColor = (Col '#548235'); ExportTableBorderWidth = 2; ExportTableBorderRadius = 10
                GridColor = (Col '#C5E0B4') }
  Set-Rows $d $T.les05
  Set-Style $d 0 0 2 0 @{ BgColor = (Col '#548235'); FontColor = $Wit; FontStyles = 1; FontSize = 14; Align = 1 }
  Set-Style $d 1 1 1 4 @{ BgColor = $Groen; FontStyles = 1 }
  Set-Image $d 0 1 'appel.png'
  Merge-Cells $d 0 0 2 0
  Merge-Cells $d 0 1 0 4
  Save-Design $d 'les05-productfiche.htd'

  # ---------------- Les 6: hyperlinks (favoriete websites) ----------------
  $d = New-Design @(70, 190, 280) @(36, 30, 56, 56, 56, 56)
  $d.Table = @{ ExportTableBorderColor = $Blauw; ExportTableBorderWidth = 2; ExportTableBorderRadius = 10 }
  Set-Rows $d $T.les06
  $Sites = @($T.les06urls) + @('https://www.lazarus-ide.org', 'https://github.com/willem750-win/AdvancedHtmlDesigner')
  $Knoppen = @('knop-w.png', 'knop-k.png', 'knop-l.png', 'knop-h.png')
  for ($i = 0; $i -lt 4; $i++) {
    Set-Link $d 1 ($i + 2) $Sites[$i]
    Set-Image $d 0 ($i + 2) $Knoppen[$i] 1 $Sites[$i]
  }
  Set-Style $d 0 0 2 0 @{ BgColor = $Blauw; FontColor = $Wit; FontStyles = 1; FontSize = 14; Align = 1 }
  Set-Style $d 0 1 2 1 @{ BgColor = $Kop; FontStyles = 1 }
  Set-Style $d 0 3 2 3 @{ BgColor = $Licht }
  Set-Style $d 0 5 2 5 @{ BgColor = $Licht }
  Merge-Cells $d 0 0 2 0
  Save-Design $d 'les06-websites.htd'

  # ---------------- Les 7: tekstblokken (uitnodiging) ----------------
  $d = New-Design @(90, 260) @(30, 30, 30, 30, 30, 30)
  $d.Table = @{ TableOffsetY = 190; ExportTableBorderColor = $Oranje; ExportTableBorderWidth = 2; ExportTableBorderRadius = 10
                HtmlBgColor = $Room; ExportTableBgColor = $Wit }
  Set-Rows $d $T.les07
  Set-Style $d 0 0 1 0 @{ BgColor = $Oranje; FontColor = $Wit; FontStyles = 1 }
  Set-Style $d 0 1 0 5 @{ Align = 1; BgColor = $Zalm }
  $B = $T.les07blocks
  Add-Block $d 161 118 511 163 $B[0] @{ FontSize = 20; FontStyles = 1; FontColor = $Oranje; Alignment = 2; LineHeight = 40 }
  Add-Block $d 161 163 511 205 $B[1] @{ FontSize = 11; Alignment = 2; FontStyles = 2; LineHeight = 20 }
  Add-Block $d 161 432 511 492 $B[2] @{
    FontSize = 10; Alignment = 2; LineHeight = 18; Transparent = 0; BgColor = $Zalm; BorderStyle = 2; BorderColor = $Oranje
    BorderRadius = 8; Padding = 8 } @(@{ Text = $B[3]; URL = 'https://example.com' })
  Save-Design $d 'les07-uitnodiging.htd'

  # ---------------- Les 8: van ontwerp naar website (fruitwinkel) ----------------
  $d = New-Design @(140, 150, 200) @(30, 136, 136, 136)
  $d.Table = @{ TableOffsetY = 160; ExportTableBorderColor = (Col '#548235'); ExportTableBorderWidth = 2
                ExportTableBorderRadius = 12; GridColor = (Col '#C5E0B4'); HtmlBgColor = (Col '#F4F9F1') }
  Set-Rows $d $T.les08
  $Fruit = @('appel.png', 'peer.png', 'banaan.png')
  for ($i = 0; $i -lt 3; $i++) {
    Set-Image $d 0 ($i + 1) $Fruit[$i]
    Set-Link $d 1 ($i + 1) $T.les08urls[$i]
  }
  Set-Style $d 0 0 2 0 @{ BgColor = (Col '#548235'); FontColor = $Wit; FontStyles = 1; Align = 1 }
  Set-Style $d 1 1 2 3 @{ FontSize = 12; Align = 1 }
  Set-Style $d 0 2 2 2 @{ BgColor = $Groen }
  $B = $T.les08blocks
  Add-Block $d 161 118 651 163 $B[0] @{ FontSize = 20; FontStyles = 1; FontColor = (Col '#548235'); Alignment = 2; LineHeight = 40 }
  Add-Block $d 161 652 651 700 $B[1] @{ FontSize = 10; Alignment = 2; FontStyles = 2; LineHeight = 18 }
  Save-Design $d 'les08-fruitwinkel.htd'
}
