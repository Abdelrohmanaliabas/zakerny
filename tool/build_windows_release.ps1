[CmdletBinding()]
param(
    [switch]$BuildUsbBundle,
    [string]$OutputDir = "release"
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Building Zakerny Windows Release Bundle " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Ensure Flutter is available
$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCmd) {
    Write-Error "Flutter is not found in PATH."
    exit 1
}

# 2. Build Windows Release
Write-Host ""
Write-Host "[1/3] Running flutter build windows --release..." -ForegroundColor Yellow
flutter build windows --release
if ($LASTEXITCODE -ne 0) {
    Write-Error "Flutter build failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

# 3. Source directory
$buildSourceDir = "build\windows\x64\runner\Release"
if (-not (Test-Path $buildSourceDir)) {
    $fallback = Get-ChildItem -Path "build\windows" -Recurse -Filter "zakerny.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($fallback) {
        $buildSourceDir = $fallback.DirectoryName
    } else {
        Write-Error "Could not find built release directory at $buildSourceDir"
        exit 1
    }
}

Write-Host ""
Write-Host "[2/3] Build succeeded. Preparing release directory..." -ForegroundColor Yellow

$targetDir = $OutputDir
if ($BuildUsbBundle) {
    $targetDir = Join-Path $OutputDir "zakerny-usb-bundle"
}

if (Test-Path $targetDir) {
    Remove-Item -Path $targetDir -Recurse -Force
}
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

# 4. Copy build artifacts
Write-Host ""
Write-Host "[3/3] Copying files to $targetDir..." -ForegroundColor Yellow
Copy-Item -Path "$buildSourceDir\*" -Destination $targetDir -Recurse -Force

if ($BuildUsbBundle) {
    Write-Host ""
    Write-Host "Creating USB portable launcher..." -ForegroundColor Green
    $batFile = Join-Path $targetDir "Launch_Zakerny.bat"
    Set-Content -Path $batFile -Value "@echo off`r`nstart `"`" `"%~dp0zakerny.exe`"" -Encoding UTF8

    $zipPath = Join-Path $OutputDir "zakerny-windows-usb-bundle.zip"
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
    Compress-Archive -Path "$targetDir\*" -DestinationPath $zipPath -Force
    Write-Host "ZIP bundle created at: $zipPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  Build and Release Completed!            " -ForegroundColor Green
Write-Host "  Output: $targetDir                      " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
