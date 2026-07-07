# Syncs all Swift files under HealthyLife/ into project.pbxproj
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$pbxPath = Join-Path $root "HealthyLife.xcodeproj\project.pbxproj"
$pbx = Get-Content $pbxPath -Raw

$swiftFiles = Get-ChildItem -Path (Join-Path $root "HealthyLife") -Filter "*.swift" -Recurse |
    ForEach-Object {
        $rel = $_.FullName.Substring((Join-Path $root "HealthyLife\").Length) -replace '\\', '/'
        [PSCustomObject]@{ Name = $_.Name; RelPath = $rel; Full = $_.FullName }
    } | Sort-Object RelPath

function New-Id([string]$prefix) {
    return ($prefix + ([guid]::NewGuid().ToString("N").Substring(0, 16)))
}

$existingRefs = [regex]::Matches($pbx, '/\* ([^*]+\.swift) \*/') | ForEach-Object { $_.Groups[1].Value }
$toAdd = $swiftFiles | Where-Object { $existingRefs -notcontains $_.Name }

if ($toAdd.Count -eq 0) {
    Write-Host "All Swift files already in project."
    exit 0
}

Write-Host "Adding $($toAdd.Count) Swift files..."

$buildFileSection = ""
$fileRefSection = ""
$sourcesEntries = ""
$groupUpdates = @{}

foreach ($file in $toAdd) {
    $buildId = New-Id "B"
    $refId = New-Id "F"
    $buildFileSection += "`t`t$buildId /* $($file.Name) in Sources */ = {isa = PBXBuildFile; fileRef = $refId /* $($file.Name) */; };`n"
    $fileRefSection += "`t`t$refId /* $($file.Name) */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = $($file.Name); sourceTree = `<group>`; };`n"
    $sourcesEntries += "`t`t`t`t$buildId /* $($file.Name) in Sources */,`n"

    $dir = Split-Path $file.RelPath -Parent
    if ([string]::IsNullOrEmpty($dir)) { $dir = "." }
    if (-not $groupUpdates.ContainsKey($dir)) { $groupUpdates[$dir] = @() }
    $groupUpdates[$dir] += "`t`t`t`t$refId /* $($file.Name) */,"
}

$pbx = $pbx -replace '(?s)(/\* Begin PBXBuildFile section \*/\r?\n)', "`$1$buildFileSection"
$pbx = $pbx -replace '(?s)(/\* Begin PBXFileReference section \*/\r?\n)', "`$1$fileRefSection"

# Insert into Sources build phase before closing );
$pbx = $pbx -replace '(?s)(A50000000000000000000002 /\* Sources \*/ = \{[^}]+files = \(\r?\n)', "`$1$sourcesEntries"

# Map folder paths to pbx group comments
$folderMap = @{
    "App" = "A40000000000000000000004 /* App */"
    "Models" = "A40000000000000000000005 /* Models */"
    "Domain" = "A40000000000000000000006 /* Domain */"
    "Data" = "A40000000000000000000007 /* Data */"
    "Theme" = "A40000000000000000000009 /* Theme */"
    "UI/Activation" = "A4000000000000000000000B /* Activation */"
    "UI/Consent" = "A4000000000000000000000C /* Consent */"
    "UI/Survey" = "A4000000000000000000000D /* Survey */"
    "UI/Main" = "A4000000000000000000000E /* Main */"
    "UI/Today" = "A4000000000000000000000F /* Today */"
    "UI/Plan" = "A40000000000000000000010 /* Plan */"
    "UI/Diary" = "A40000000000000000000011 /* Diary */"
    "UI/More" = "A40000000000000000000012 /* More */"
}

# Components group - create if needed
$componentsFiles = $groupUpdates["UI/Components"]
if ($componentsFiles) {
    if ($pbx -notmatch 'UI/Components') {
        $groupId = "A40000000000000000000013"
        $pbx = $pbx -replace '(A40000000000000000000012 /\* More \*/ = \{ isa = PBXGroup; children = \([^)]+\); path = More; sourceTree = "<group>"; \};)',
            "`$1`n`t`t$groupId /* Components */ = { isa = PBXGroup; children = ($($componentsFiles -join '')); path = Components; sourceTree = ""<group>""; };"
        $pbx = $pbx -replace '(A40000000000000000000012 /\* More \*/,)',
            "`$1`n`t`t`t`t$groupId /* Components */,"
    }
    $groupUpdates.Remove("UI/Components")
}

foreach ($dir in $groupUpdates.Keys) {
    $entries = $groupUpdates[$dir] -join "`n"
    $groupKey = $folderMap[$dir]
    if ($groupKey) {
        $escaped = [regex]::Escape($groupKey)
        $pbx = [regex]::Replace($pbx, "($escaped = \{ isa = PBXGroup; children = \()", "`${1}$entries`n")
    }
}

Set-Content -Path $pbxPath -Value $pbx -NoNewline
Write-Host "Done. Added files:"
$toAdd | ForEach-Object { Write-Host "  - $($_.RelPath)" }
