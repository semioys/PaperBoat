<#
.SYNOPSIS
    Generates port/fonts/hd_standard.bin, the HD dialogue font.

.DESCRIPTION
    Renders the Latin glyphs of the standard message font at 64x64 from an
    OFL-licensed font (default: port/fonts/Montserrat-Regular.ttf, emboldened),
    fitted to the game's own advance widths (src/msg_data.c) and cell metrics
    (baseline at row 12 of 16, 9 px cap height, 1 px halo). Nothing is taken
    from the game's glyph art.

    Each texel is a palette index with the same meaning the game's text
    palettes use: 0 transparent, 1 body, 2..5 edge ramp, 6 outer halo.
    Symbols and button icons (note, heart, star, arrows, buttons) are left out,
    so the game keeps drawing its own art for them.

    Windows only (System.Drawing / GDI+). Run from the repository root:
        powershell -ExecutionPolicy Bypass -File tools/switch/gen_hd_font.ps1
#>
param(
    [string]$FontPath = "port/fonts/Montserrat-Regular.ttf",
    [string]$Output = "port/fonts/hd_standard.bin",
    [string]$Preview = "",
    [float]$Embolden = 3.0,
    [int]$HaloRadius = 3,
    # Horizontal scale applied to every glyph (Montserrat is wide for the game's widths).
    [float]$Condense = 0.84,
    # HD texels a glyph may extend into the inter-letter gap (4 = one game pixel).
    [int]$Overflow = 2
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$Cell = 64
$Scale = 4                  # HD texels per game pixel
$Baseline = 13 * $Scale     # bottom edge of the game's baseline row (row 12)
$CapHeight = 9 * $Scale
$LeftBearing = 1 * $Scale
$GlyphCount = 162           # 16x16 glyphs in the standard sheet

# ---------------------------------------------------------------- code -> text
$chars = @{}
$chars[0x01] = "!"; $chars[0x02] = '"'; $chars[0x03] = "#"; $chars[0x04] = "$"
$chars[0x05] = "%"; $chars[0x06] = "&"; $chars[0x07] = "'"; $chars[0x08] = "("
$chars[0x09] = ")"; $chars[0x0A] = [string][char]0x00D7; $chars[0x0B] = "+"; $chars[0x0C] = ","
$chars[0x0D] = "-"; $chars[0x0E] = "."; $chars[0x0F] = "/"
for ($i = 0; $i -lt 10; $i++) { $chars[0x10 + $i] = [string][char](0x30 + $i) }
$chars[0x1A] = ":"; $chars[0x1B] = ";"; $chars[0x1C] = "<"; $chars[0x1D] = "="
$chars[0x1E] = ">"; $chars[0x1F] = "?"; $chars[0x20] = "@"
for ($i = 0; $i -lt 26; $i++) { $chars[0x21 + $i] = [string][char](0x41 + $i) }
$chars[0x3B] = "["; $chars[0x3C] = [string][char]0x00A5; $chars[0x3D] = "]"; $chars[0x3E] = "^"
$chars[0x3F] = "_"; $chars[0x40] = "``"
for ($i = 0; $i -lt 26; $i++) { $chars[0x41 + $i] = [string][char](0x61 + $i) }
$chars[0x5B] = "{"; $chars[0x5C] = "|"; $chars[0x5D] = "}"; $chars[0x5E] = "~"
$chars[0x5F] = [string][char]0x00B0
$latin1 = @(0xC0, 0xC1, 0xC2, 0xC4, 0xC7, 0xC8, 0xC9, 0xCA, 0xCB, 0xCC, 0xCD, 0xCE, 0xCF, 0xD1,
    0xD2, 0xD3, 0xD4, 0xD6, 0xD9, 0xDA, 0xDB, 0xDC, 0xDF,
    0xE0, 0xE1, 0xE2, 0xE4, 0xE7, 0xE8, 0xE9, 0xEA, 0xEB, 0xEC, 0xED, 0xEE, 0xEF, 0xF1,
    0xF2, 0xF3, 0xF4, 0xF6, 0xF9, 0xFA, 0xFB, 0xFC, 0xA1, 0xBF, 0xAA)
for ($i = 0; $i -lt $latin1.Count; $i++) { $chars[0x60 + $i] = [string][char]$latin1[$i] }
$chars[0xA2] = [string][char]0x201C; $chars[0xA3] = [string][char]0x201D
$chars[0xA4] = [string][char]0x2018; $chars[0xA5] = [string][char]0x2019

# ------------------------------------------------- advance widths (msg_data.c)
$enums = Get-Content "include/enums.h" -Raw
$start = $enums.IndexOf("MSG_CHAR_NOTE                   = 0x00")
$end = $enums.IndexOf("#endif", $start)
$codes = @{}
foreach ($m in [regex]::Matches($enums.Substring($start, $end - $start), "(MSG_CHAR_\w+)\s*=\s*0x([0-9A-Fa-f]+)")) {
    $codes[$m.Groups[1].Value] = [Convert]::ToInt32($m.Groups[2].Value, 16)
}
$msgData = Get-Content "src/msg_data.c" -Raw
$tStart = $msgData.IndexOf("u8 MsgCharWidthNormal[] = {")
$tEnd = $msgData.IndexOf("};", $tStart)
$widths = @{}
foreach ($m in [regex]::Matches($msgData.Substring($tStart, $tEnd - $tStart), "\[(MSG_CHAR_\w+)\]\s+(\d+)")) {
    if ($codes.ContainsKey($m.Groups[1].Value)) { $widths[$codes[$m.Groups[1].Value]] = [int]$m.Groups[2].Value }
}
Write-Host "advance widths: $($widths.Count) entries"

# ------------------------------------------------------------------- font
$collection = New-Object System.Drawing.Text.PrivateFontCollection
$collection.AddFontFile((Resolve-Path $FontPath).Path)
$family = $collection.Families[0]
$format = [System.Drawing.StringFormat]::GenericTypographic

function New-GlyphPath([string]$text, [float]$em) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddString($text, $family, [int][System.Drawing.FontStyle]::Regular, $em, (New-Object System.Drawing.PointF 0, 0), $format)
    return $path
}

# Em size giving the target cap height (stroke included), and the baseline offset.
$probe = New-GlyphPath "H" 100
$b = $probe.GetBounds()
$em = 100 * ($CapHeight - $Embolden) / $b.Height
$probe = New-GlyphPath "H" $em
$hBounds = $probe.GetBounds()
$originY = $Baseline - ($hBounds.Bottom + $Embolden / 2)

$pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::White), $Embolden
$pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

function Get-Coverage([string]$text, [int]$advance) {
    $path = New-GlyphPath $text $em
    $bounds = $path.GetBounds()
    # Montserrat is wider than the game's advance widths. Condense the whole
    # font by the same factor (keeps letters in proportion to each other) and
    # only squeeze further what still doesn't fit. The emboldening stroke is
    # added after scaling, so stems keep the same thickness on every glyph.
    $avail = [Math]::Max(4, $advance * $Scale - 2 * $Scale + $Overflow)
    $sx = $Condense
    if ($bounds.Width * $sx + $Embolden -gt $avail) {
        # Very wide letters (m, w, W, @) may take another half pixel of the gap
        # rather than being squeezed out of proportion.
        $avail += 2
        $sx = [Math]::Min($Condense, [Math]::Max(0.3, ($avail - $Embolden) / $bounds.Width))
    }
    $inkLeft = $bounds.Left
    if ($env:HDFONT_REPORT) {
        Write-Host ("{0} adv={1} avail={2} sx={3:N2} rel={4:N2}" -f $text, $advance, $avail, $sx, ($sx / $Condense))
    }

    $matrix = New-Object System.Drawing.Drawing2D.Matrix
    $matrix.Translate($LeftBearing + $Embolden / 2, $originY)
    $matrix.Scale($sx, 1.0)
    $matrix.Translate(-$inkLeft, 0)
    $path.Transform($matrix)

    $bmp = New-Object System.Drawing.Bitmap $Cell, $Cell, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.FillPath([System.Drawing.Brushes]::White, $path)
    $g.DrawPath($pen, $path)
    $g.Dispose()

    $rect = New-Object System.Drawing.Rectangle 0, 0, $Cell, $Cell
    $data = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, $bmp.PixelFormat)
    $raw = New-Object byte[] ($data.Stride * $Cell)
    [System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $raw, 0, $raw.Length)
    $bmp.UnlockBits($data)
    $bmp.Dispose()
    $cov = New-Object byte[] ($Cell * $Cell)
    for ($y = 0; $y -lt $Cell; $y++) {
        for ($x = 0; $x -lt $Cell; $x++) { $cov[$y * $Cell + $x] = $raw[$y * $data.Stride + $x * 4 + 3] }
    }
    return , $cov
}

function Convert-ToIndices([byte[]]$cov) {
    $idx = New-Object byte[] ($Cell * $Cell)
    $r2 = $HaloRadius * $HaloRadius
    for ($y = 0; $y -lt $Cell; $y++) {
        for ($x = 0; $x -lt $Cell; $x++) {
            $c = $cov[$y * $Cell + $x]
            if ($c -ge 200) { $idx[$y * $Cell + $x] = 1; continue }
            if ($c -ge 160) { $idx[$y * $Cell + $x] = 2; continue }
            if ($c -ge 120) { $idx[$y * $Cell + $x] = 3; continue }
            if ($c -ge 80) { $idx[$y * $Cell + $x] = 4; continue }
            if ($c -ge 40) { $idx[$y * $Cell + $x] = 5; continue }
            $halo = $false
            for ($dy = -$HaloRadius; $dy -le $HaloRadius -and -not $halo; $dy++) {
                $yy = $y + $dy
                if ($yy -lt 0 -or $yy -ge $Cell) { continue }
                for ($dx = -$HaloRadius; $dx -le $HaloRadius; $dx++) {
                    $xx = $x + $dx
                    if ($xx -lt 0 -or $xx -ge $Cell -or ($dx * $dx + $dy * $dy) -gt $r2) { continue }
                    if ($cov[$yy * $Cell + $xx] -ge 100) { $halo = $true; break }
                }
            }
            if ($halo) { $idx[$y * $Cell + $x] = 6 }
        }
    }
    return , $idx
}

# ------------------------------------------------------------------- build
$present = New-Object byte[] $GlyphCount
$glyphData = New-Object System.Collections.Generic.List[byte[]]
foreach ($code in 0..($GlyphCount - 1)) {
    if (-not $chars.ContainsKey($code)) { continue }
    $advance = 10
    if ($widths.ContainsKey($code) -and $widths[$code] -gt 0) { $advance = $widths[$code] }
    $cov = Get-Coverage $chars[$code] $advance
    $present[$code] = 1
    $glyphData.Add((Convert-ToIndices $cov))
}

# ------------------------------------------------------- Switch button icons
# Simple original shapes in the text colour (index 1) with the label cut out
# in the background colour (index 6), so they adapt to every text palette.
# The order is the icon id used by HDFont.cpp (HdIcon enum).
$iconNames = @("A", "B", "X", "Y", "L", "R", "ZL", "ZR", "PLUS", "MINUS",
    "RS_UP", "RS_DOWN", "RS_LEFT", "RS_RIGHT", "LS_UP", "LS_DOWN", "LS_LEFT", "LS_RIGHT",
    "DPAD_UP", "DPAD_DOWN", "DPAD_LEFT", "DPAD_RIGHT")

$IconLeft = 4.0; $IconCenterY = 34.0; $IconDiameter = 40.0

function Get-PathCoverage([System.Drawing.Drawing2D.GraphicsPath]$path, [float]$stroke) {
    $bmp = New-Object System.Drawing.Bitmap $Cell, $Cell, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.FillPath([System.Drawing.Brushes]::White, $path)
    if ($stroke -gt 0) {
        $p = New-Object System.Drawing.Pen ([System.Drawing.Color]::White), $stroke
        $p.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
        $g.DrawPath($p, $path)
    }
    $g.Dispose()
    $rect = New-Object System.Drawing.Rectangle 0, 0, $Cell, $Cell
    $data = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, $bmp.PixelFormat)
    $raw = New-Object byte[] ($data.Stride * $Cell)
    [System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $raw, 0, $raw.Length)
    $bmp.UnlockBits($data)
    $bmp.Dispose()
    $cov = New-Object byte[] ($Cell * $Cell)
    for ($y = 0; $y -lt $Cell; $y++) {
        for ($x = 0; $x -lt $Cell; $x++) { $cov[$y * $Cell + $x] = $raw[$y * $data.Stride + $x * 4 + 3] }
    }
    return , $cov
}

function Add-CenteredText([System.Drawing.Drawing2D.GraphicsPath]$path, [string]$text, [float]$height,
    [float]$cx, [float]$cy, [float]$maxWidth) {
    $t = New-GlyphPath $text 100
    $tb = $t.GetBounds()
    $s = $height / $tb.Height
    if ($tb.Width * $s -gt $maxWidth) { $s = $maxWidth / $tb.Width }
    $m = New-Object System.Drawing.Drawing2D.Matrix
    $m.Translate($cx, $cy)
    $m.Scale($s, $s)
    $m.Translate( - ($tb.Left + $tb.Width / 2), - ($tb.Top + $tb.Height / 2))
    $t.Transform($m)
    $path.AddPath($t, $false)
}

function Add-Arrow([System.Drawing.Drawing2D.GraphicsPath]$path, [string]$dir, [float]$cx, [float]$cy, [float]$size) {
    $h = $size / 2
    switch ($dir) {
        "UP" { $pts = @(@($cx, ($cy - $h)), @(($cx + $h), ($cy + $h * 0.6)), @(($cx - $h), ($cy + $h * 0.6))) }
        "DOWN" { $pts = @(@($cx, ($cy + $h)), @(($cx - $h), ($cy - $h * 0.6)), @(($cx + $h), ($cy - $h * 0.6))) }
        "LEFT" { $pts = @(@(($cx - $h), $cy), @(($cx + $h * 0.6), ($cy - $h)), @(($cx + $h * 0.6), ($cy + $h))) }
        "RIGHT" { $pts = @(@(($cx + $h), $cy), @(($cx - $h * 0.6), ($cy + $h)), @(($cx - $h * 0.6), ($cy - $h))) }
    }
    $points = New-Object 'System.Drawing.PointF[]' 3
    for ($i = 0; $i -lt 3; $i++) { $points[$i] = New-Object System.Drawing.PointF ([float]$pts[$i][0]), ([float]$pts[$i][1]) }
    $path.AddPolygon($points)
}

function Add-RoundRect([System.Drawing.Drawing2D.GraphicsPath]$path, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
    $d = 2 * $r
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
}

function New-Icon([string]$name) {
    $body = New-Object System.Drawing.Drawing2D.GraphicsPath
    $cut = New-Object System.Drawing.Drawing2D.GraphicsPath
    $cx = $IconLeft + $IconDiameter / 2
    $cy = $IconCenterY
    if (@("A", "B", "X", "Y", "PLUS", "MINUS") -contains $name) {
        $body.AddEllipse($IconLeft, $cy - $IconDiameter / 2, $IconDiameter, $IconDiameter)
        if ($name -eq "PLUS") {
            $body2 = $null
            $cut.AddRectangle((New-Object System.Drawing.RectangleF ($cx - 3), ($cy - 12), 6, 24))
            $cut.AddRectangle((New-Object System.Drawing.RectangleF ($cx - 12), ($cy - 3), 24, 6))
        } elseif ($name -eq "MINUS") {
            $cut.AddRectangle((New-Object System.Drawing.RectangleF ($cx - 12), ($cy - 3), 24, 6))
        } else {
            Add-CenteredText $cut $name 22 $cx $cy 24
        }
    } elseif (@("L", "R", "ZL", "ZR") -contains $name) {
        Add-RoundRect $body $IconLeft ($cy - 15) 44 30 13
        Add-CenteredText $cut $name 18 ($IconLeft + 22) $cy 34
    } elseif ($name.StartsWith("RS_") -or $name.StartsWith("LS_")) {
        # Stick: a disc with the stick letter and an arrow towards the direction.
        $body.AddEllipse($IconLeft, $cy - $IconDiameter / 2, $IconDiameter, $IconDiameter)
        $dir = $name.Substring(3)
        $ox = 0; $oy = 0
        switch ($dir) { "UP" { $oy = -1 } "DOWN" { $oy = 1 } "LEFT" { $ox = -1 } "RIGHT" { $ox = 1 } }
        Add-Arrow $cut $dir ($cx + $ox * 10) ($cy + $oy * 10) 13
        $letter = "R"
        if ($name.StartsWith("LS_")) { $letter = "L" }
        Add-CenteredText $cut $letter 13 ($cx - $ox * 5) ($cy - $oy * 5) 12
    } else {
        # D-pad: a cross with an arrow cut into the pressed arm.
        $arm = 14.0
        $body.AddRectangle((New-Object System.Drawing.RectangleF ($cx - $arm / 2), ($cy - 20), $arm, 40))
        $body.AddRectangle((New-Object System.Drawing.RectangleF ($cx - 20), ($cy - $arm / 2), 40, $arm))
        $dir = $name.Substring(5)
        $ox = 0; $oy = 0
        switch ($dir) { "UP" { $oy = -1 } "DOWN" { $oy = 1 } "LEFT" { $ox = -1 } "RIGHT" { $ox = 1 } }
        Add-Arrow $cut $dir ($cx + $ox * 12) ($cy + $oy * 12) 10
    }
    $body.FillMode = [System.Drawing.Drawing2D.FillMode]::Winding
    $cut.FillMode = [System.Drawing.Drawing2D.FillMode]::Alternate
    $bodyCov = Get-PathCoverage $body 0
    $cutCov = Get-PathCoverage $cut 1.5
    $idx = Convert-ToIndices $bodyCov
    for ($i = 0; $i -lt $idx.Length; $i++) {
        if ($bodyCov[$i] -lt 128) { continue }
        if ($cutCov[$i] -ge 128) { $idx[$i] = 6 }
        elseif ($cutCov[$i] -ge 40) { $idx[$i] = 5 }
    }
    return , $idx
}

$iconData = New-Object System.Collections.Generic.List[byte[]]
foreach ($name in $iconNames) { $iconData.Add((New-Icon $name)) }

$stream = [System.IO.File]::Create((Join-Path (Get-Location) $Output))
$writer = New-Object System.IO.BinaryWriter $stream
$writer.Write([System.Text.Encoding]::ASCII.GetBytes("PBHF"))
$writer.Write([uint16]2)
$writer.Write([uint16]$Cell)
$writer.Write([uint16]$GlyphCount)
$writer.Write([uint16]$iconData.Count)
$writer.Write($present)
foreach ($glyph in $glyphData) { $writer.Write($glyph) }
foreach ($icon in $iconData) { $writer.Write($icon) }
$writer.Close()
Write-Host "wrote $Output ($($glyphData.Count) glyphs, $($iconData.Count) icons, $Cell x $Cell)"
foreach ($icon in $iconData) { $glyphData.Add($icon) } # icons appear at the end of the preview

# ------------------------------------------------------------------- preview
if ($Preview -ne "") {
    # Dark text on a cream bubble, roughly like the game's dialogue palette.
    $colors = @(
        [System.Drawing.Color]::FromArgb(255, 222, 222, 213), [System.Drawing.Color]::FromArgb(255, 41, 41, 32),
        [System.Drawing.Color]::FromArgb(255, 106, 106, 98), [System.Drawing.Color]::FromArgb(255, 139, 139, 131),
        [System.Drawing.Color]::FromArgb(255, 164, 164, 156), [System.Drawing.Color]::FromArgb(255, 189, 189, 180),
        [System.Drawing.Color]::FromArgb(255, 213, 213, 205))
    $cols = 16
    $rows = [Math]::Ceiling($glyphData.Count / $cols)
    $sheet = New-Object System.Drawing.Bitmap ($cols * $Cell), ($rows * $Cell)
    $n = 0
    foreach ($glyph in $glyphData) {
        $ox = ($n % $cols) * $Cell; $oy = [Math]::Floor($n / $cols) * $Cell
        for ($y = 0; $y -lt $Cell; $y++) {
            for ($x = 0; $x -lt $Cell; $x++) { $sheet.SetPixel($ox + $x, $oy + $y, $colors[$glyph[$y * $Cell + $x]]) }
        }
        $n++
    }
    $sheet.Save($Preview, [System.Drawing.Imaging.ImageFormat]::Png)
    $sheet.Dispose()
    Write-Host "preview: $Preview"
}
