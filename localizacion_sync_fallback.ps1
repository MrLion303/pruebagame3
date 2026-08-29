param(
    [switch]$Watch
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$SkipDirs = @(
    ".git", ".svn", ".hg", ".localizacion", "datafiles",
    "build", "cache", "Temp", "temp", "output", "bin", "obj", "node_modules"
)

$LocRegex = [regex]'(?ms)\b(?:scr_loc|scr_loc_src|scr_locf)\s*\(\s*(("(?:\\.|[^"\\])*"))'

function Write-Utf8NoBom([string]$Path, [string]$Text) {
    [System.IO.File]::WriteAllText($Path, $Text, $script:Utf8NoBom)
}

function Get-GmlFiles {
    Get-ChildItem -Path $Root -Recurse -File -Filter "*.gml" | Where-Object {
        $full = $_.FullName
        $relative = $full.Substring($Root.Length).TrimStart([char[]]"\/")
        $parts = $relative -split '[\\/]'
        $blocked = $false

        if ($parts.Length -gt 1) {
            foreach ($part in $parts[0..($parts.Length - 2)]) {
                if ($SkipDirs -contains $part) {
                    $blocked = $true
                    break
                }
            }
        }

        -not $blocked
    } | Sort-Object FullName
}

function Decode-GmlLiteral([string]$Literal) {
    try {
        return ($Literal | ConvertFrom-Json)
    }
    catch {
        $body = $Literal.Substring(1, $Literal.Length - 2)
        $body = $body.Replace('\"', '"')
        $body = $body.Replace('\\', '\')
        $body = $body.Replace('\n', "`n")
        $body = $body.Replace('\r', "`r")
        $body = $body.Replace('\t', "`t")
        return $body
    }
}

function Read-JsonObject([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }

    try {
        $raw = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)

        # Eliminar BOM antiguo si existe.
        if ($raw.Length -gt 0 -and [int]$raw[0] -eq 0xFEFF) {
            $raw = $raw.Substring(1)
        }

        if ([string]::IsNullOrWhiteSpace($raw)) {
            return $null
        }

        return ($raw | ConvertFrom-Json)
    }
    catch {
        Write-Host "[LOCALIZACION] ADVERTENCIA: no pude leer $Path" -ForegroundColor Yellow
        return $null
    }
}

function Write-Json([string]$Path, $Data) {
    $dir = Split-Path -Parent $Path

    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $json = $Data | ConvertTo-Json -Depth 30
    Write-Utf8NoBom $Path ($json + [Environment]::NewLine)
}

function Get-OldValue($Object, [string]$Key, [string]$Default = "") {
    if ($null -eq $Object) {
        return $Default
    }

    $prop = $Object.PSObject.Properties[$Key]

    if ($null -eq $prop) {
        return $Default
    }

    if ($prop.Value -is [string]) {
        return [string]$prop.Value
    }

    return $Default
}

function Synchronize-Localization {
    $files = @(Get-GmlFiles)

    if ($files.Count -eq 0) {
        Write-Host "[LOCALIZACION] No encontre archivos .gml en: $Root" -ForegroundColor Red
        return
    }

    $allKeys = New-Object System.Collections.Generic.List[string]
    $seen = @{}
    $sources = @{}

    foreach ($file in $files) {
        $text = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
        $matches = $LocRegex.Matches($text)

        foreach ($match in $matches) {
            $literal = $match.Groups[1].Value
            $key = Decode-GmlLiteral $literal

            if (-not ($key -is [string])) { continue }
            if ($key.Length -eq 0) { continue }

            if (-not $seen.ContainsKey($key)) {
                $seen[$key] = $true
                [void]$allKeys.Add($key)
            }

            if (-not $sources.ContainsKey($key)) {
                $sources[$key] = New-Object System.Collections.Generic.List[string]
            }

            $before = $text.Substring(0, $match.Index)
            $line = ([regex]::Matches($before, "`n")).Count + 1
            $relative = $file.FullName.Substring($Root.Length).TrimStart([char[]]"\/")
            [void]$sources[$key].Add("$relative`:$line")
        }
    }

    $dataDir = Join-Path $Root "datafiles"
    $stateDir = Join-Path $Root ".localizacion"
    $esPath = Join-Path $dataDir "idioma_es.json"
    $enPath = Join-Path $dataDir "idioma_en.json"
    $archivePath = Join-Path $stateDir "idioma_en_obsoletos.json"
    $manifestPath = Join-Path $stateDir "manifest.json"
    $reportPath = Join-Path $stateDir "reporte.txt"

    if (-not (Test-Path -LiteralPath $dataDir)) {
        New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
    }

    if (-not (Test-Path -LiteralPath $stateDir)) {
        New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
    }

    $oldEn = Read-JsonObject $enPath
    $oldArchive = Read-JsonObject $archivePath

    $es = [ordered]@{}
    $en = [ordered]@{}

    foreach ($key in $allKeys) {
        $es[$key] = $key
        $en[$key] = Get-OldValue $oldEn $key ""
    }

    $archive = [ordered]@{}

    if ($null -ne $oldArchive) {
        foreach ($p in $oldArchive.PSObject.Properties) {
            $archive[$p.Name] = $p.Value
        }
    }

    $removedCount = 0

    if ($null -ne $oldEn) {
        foreach ($p in $oldEn.PSObject.Properties) {
            if (-not $seen.ContainsKey($p.Name)) {
                $archive[$p.Name] = $p.Value
                $removedCount++
            }
        }
    }

    $sourceOut = [ordered]@{}

    foreach ($key in $allKeys) {
        $sourceOut[$key] = @($sources[$key])
    }

    $manifest = [ordered]@{
        total = $allKeys.Count
        fuentes = $sourceOut
    }

    Write-Json $esPath $es
    Write-Json $enPath $en
    Write-Json $archivePath $archive
    Write-Json $manifestPath $manifest

    $pending = 0

    foreach ($key in $allKeys) {
        if ([string]::IsNullOrEmpty([string]$en[$key])) {
            $pending++
        }
    }

    $report = @(
        "REPORTE DE LOCALIZACION",
        "=======================",
        "Textos detectados: $($allKeys.Count)",
        "Traducciones inglesas pendientes: $pending",
        "Entradas inglesas obsoletas archivadas: $removedCount",
        "",
        "JSON escritos en UTF-8 SIN BOM.",
        "Proyecto: $Root",
        "ES: $esPath",
        "EN: $enPath"
    )

    Write-Utf8NoBom $reportPath (($report -join [Environment]::NewLine) + [Environment]::NewLine)

    Write-Host "[LOCALIZACION] OK | $($allKeys.Count) textos | $pending pendientes EN" -ForegroundColor Green
    Write-Host "[LOCALIZACION] JSON: UTF-8 SIN BOM" -ForegroundColor Cyan
}

function Get-Snapshot {
    $items = @(Get-GmlFiles)

    $parts = foreach ($item in $items) {
        "$($item.FullName)|$($item.Length)|$($item.LastWriteTimeUtc.Ticks)"
    }

    return ($parts -join "`n")
}

Write-Host "[LOCALIZACION] Proyecto: $Root" -ForegroundColor Cyan
Synchronize-Localization

if (-not $Watch) {
    exit 0
}

Write-Host ""
Write-Host "[LOCALIZACION] Vigilando .gml. Deja esta ventana abierta." -ForegroundColor Cyan

$last = Get-Snapshot

while ($true) {
    Start-Sleep -Seconds 1
    $now = Get-Snapshot

    if ($now -ne $last) {
        Start-Sleep -Milliseconds 250

        try {
            Synchronize-Localization
        }
        catch {
            Write-Host "[LOCALIZACION] ERROR: $($_.Exception.Message)" -ForegroundColor Red
        }

        $last = Get-Snapshot
    }
}
