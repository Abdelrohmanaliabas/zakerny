[CmdletBinding()]
param(
    [switch]$BuildUsbBundle,
    [switch]$BuildInstaller,
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

if ($BuildInstaller -or (Test-Path "installer\zakerny_setup.iss")) {
    $isccPaths = @(
        "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "$env:ProgramFiles\Inno Setup 6\ISCC.exe"
    )
    $isccExe = $isccPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if ($isccExe) {
        Write-Host ""
        Write-Host "Compiling Inno Setup Windows Installer..." -ForegroundColor Cyan
        & "$isccExe" "installer\zakerny_setup.iss"
        if ($LASTEXITCODE -eq 0) {
            $builtInstaller = Get-ChildItem -Path $OutputDir -Filter "Zakerny_Windows_Setup*.exe" | Select-Object -First 1
            if ($builtInstaller) {
                # Copy to build\windows for instant access
                Copy-Item $builtInstaller.FullName -Destination "build\windows\" -Force
                Write-Host "Setup installer ready at: $($builtInstaller.FullName)" -ForegroundColor Green
                Write-Host "Also copied to: build\windows\$($builtInstaller.Name)" -ForegroundColor Green
            }
        } else {
            Write-Warning "Inno Setup compilation returned non-zero code: $LASTEXITCODE"
        }
    } else {
        Write-Host "Inno Setup compiler (ISCC.exe) not found. Skipping installer generation." -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  Build and Release Completed!            " -ForegroundColor Green
Write-Host "  Output: $targetDir                      " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
