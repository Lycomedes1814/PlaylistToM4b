#Requires -Version 5.1
<#
.SYNOPSIS
    Installs the ConvertYtPlaylistToM4b PowerShell module and its dependencies.
.DESCRIPTION
    - Installs yt-dlp and ffmpeg via winget (if not already present)
    - Copies the module to the current user's PowerShell Modules directory
    - Sets ExecutionPolicy to RemoteSigned for the current user if needed
#>

$ErrorActionPreference = "Stop"

function Write-Step  { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Ok    { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Warn  { param($msg) Write-Host $msg -ForegroundColor Yellow }

# ---------- helpers ----------

function Test-Command { param($name) $null -ne (Get-Command $name -ErrorAction SilentlyContinue) }

function Install-WingetPackage {
    param($id, $name)
    if (Test-Command $name) {
        Write-Ok "  $name is already installed, skipping."
        return
    }
    if (-not (Test-Command winget)) {
        Write-Warn "  winget not found — please install $name manually and re-run."
        return
    }
    Write-Host "  Installing $name via winget..." -ForegroundColor Gray
    winget install --id $id --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "  winget reported exit code $LASTEXITCODE for $name. It may already be installed or require a reboot."
    } else {
        Write-Ok "  $name installed."
    }
}

# ---------- Step 1: execution policy ----------

Write-Step "[1/3] Checking PowerShell execution policy..."
$policy = Get-ExecutionPolicy -Scope CurrentUser
if ($policy -in @("Restricted", "AllSigned")) {
    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
    Write-Ok "  ExecutionPolicy set to RemoteSigned for current user."
} else {
    Write-Ok "  ExecutionPolicy is '$policy', no change needed."
}

# ---------- Step 2: dependencies ----------

Write-Step "[2/3] Installing dependencies..."
Install-WingetPackage "yt-dlp.yt-dlp" "yt-dlp"
Install-WingetPackage "Gyan.FFmpeg"    "ffmpeg"

# Refresh PATH so newly installed tools are visible without reopening the shell
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("PATH", "User")

foreach ($cmd in @("yt-dlp", "ffmpeg", "ffprobe")) {
    if (Test-Command $cmd) {
        Write-Ok "  $cmd found on PATH."
    } else {
        Write-Warn "  $cmd not found on PATH after install. You may need to restart your shell."
    }
}

# ---------- Step 3: install module ----------

Write-Step "[3/3] Installing ConvertYtPlaylistToM4b module..."

$moduleFiles = @("ConvertYtPlaylistToM4b.psm1", "ConvertYtPlaylistToM4b.psd1")
foreach ($f in $moduleFiles) {
    if (-not (Test-Path (Join-Path $PSScriptRoot $f))) {
        Write-Host "Error: '$f' not found next to Install.ps1. Run the script from the repo folder." -ForegroundColor Red
        exit 1
    }
}

# Prefer PowerShell 7+ path, fall back to Windows PowerShell path
$psModulesDir = if ($PSVersionTable.PSVersion.Major -ge 6) {
    Join-Path $HOME "Documents\PowerShell\Modules"
} else {
    Join-Path $HOME "Documents\WindowsPowerShell\Modules"
}

$destDir = Join-Path $psModulesDir "ConvertYtPlaylistToM4b"
New-Item -ItemType Directory -Force -Path $destDir | Out-Null

foreach ($f in $moduleFiles) {
    Copy-Item (Join-Path $PSScriptRoot $f) $destDir -Force
}
Write-Ok "  Module installed to: $destDir"

# ---------- done ----------

Write-Host ""
Write-Ok "Installation complete."
Write-Host "Open a new PowerShell session and run:" -ForegroundColor Gray
Write-Host "  Convert-YtPlaylistToM4b -Url `"https://www.youtube.com/playlist?list=PLxxxxx`"" -ForegroundColor White
