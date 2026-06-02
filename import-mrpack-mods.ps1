$ErrorActionPreference = "Stop"

$mrpack = Get-ChildItem -Filter *.mrpack | Select-Object -First 1

if (-not $mrpack) {
    Write-Host "ERROR: No .mrpack file found in current folder." -ForegroundColor Red
    exit 1
}

$temp = Join-Path $PWD "_mrpack_extract"

if (Test-Path $temp) {
    Remove-Item $temp -Recurse -Force
}

New-Item -ItemType Directory -Path $temp | Out-Null

$zipPath = Join-Path $temp "pack.zip"
Copy-Item $mrpack.FullName $zipPath

Expand-Archive -Path $zipPath -DestinationPath $temp -Force

$indexPath = Join-Path $temp "modrinth.index.json"

if (-not (Test-Path $indexPath)) {
    Write-Host "ERROR: modrinth.index.json was not found inside .mrpack." -ForegroundColor Red
    exit 1
}

$index = Get-Content $indexPath -Raw | ConvertFrom-Json

$modFiles = @(
    $index.files | Where-Object {
        $_.path -like "mods/*" -and $_.hashes.sha512
    }
)

if ($modFiles.Count -eq 0) {
    Write-Host "ERROR: No mods/*.jar files with sha512 hashes found." -ForegroundColor Red
    exit 1
}

$hashes = @(
    $modFiles | ForEach-Object {
        $_.hashes.sha512
    }
)

Write-Host "Found mod files: $($modFiles.Count)"
Write-Host "Requesting Modrinth version data..."

$versions = @{}

for ($i = 0; $i -lt $hashes.Count; $i += 50) {
    $end = [Math]::Min($i + 49, $hashes.Count - 1)
    $chunk = @($hashes[$i..$end])

    $body = @{
        hashes = $chunk
        algorithm = "sha512"
    } | ConvertTo-Json -Depth 5

    $result = Invoke-RestMethod `
        -Method Post `
        -Uri "https://api.modrinth.com/v2/version_files" `
        -ContentType "application/json" `
        -Body $body `
        -Headers @{ "User-Agent" = "PineconePack-import-script" }

    foreach ($prop in $result.PSObject.Properties) {
        $versions[$prop.Name] = $prop.Value
    }
}

$commands = @()
$manual = @()

foreach ($file in $modFiles) {
    $hash = $file.hashes.sha512

    if ($versions.ContainsKey($hash)) {
        $version = $versions[$hash]
        $projectId = $version.project_id
        $versionId = $version.id
        $filename = Split-Path $file.path -Leaf

        $cmd = 'packwiz modrinth add --project-id "' + $projectId + '" --version-id "' + $versionId + '" --version-filename "' + $filename + '" -y'
        $commands += $cmd
    } else {
        $manual += $file.path
    }
}

$commands | Set-Content ".\add-modrinth-mods.ps1" -Encoding UTF8
$manual | Set-Content ".\manual-files.txt" -Encoding UTF8

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "Generated: add-modrinth-mods.ps1"
Write-Host "Generated: manual-files.txt"
Write-Host ""
Write-Host "Auto commands: $($commands.Count)"
Write-Host "Manual files: $($manual.Count)"
