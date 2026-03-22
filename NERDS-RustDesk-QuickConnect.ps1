# ==============================
# NERDS RustDesk QuickConnect
# Visible installer version
# ==============================

$ErrorActionPreference = "Stop"

function Pause-Exit {
    Write-Host ""
    Write-Host "Press any key to close..." -ForegroundColor Yellow
    [void][System.Console]::ReadKey($true)
    exit
}

Write-Host "NERDS RustDesk installer starting..." -ForegroundColor Cyan

# --- Admin check ---
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host "ERROR: Run this as Administrator." -ForegroundColor Red
    Pause-Exit
}

# --- Server config ---
$ServerIP  = "192.168.1.232"
$PublicKey = "l+9YTGVBlXU9dKuBfhM7JocCkf2MgbqVGYk6ExZUPP0="

$ConfigJson = "{`"id_server`":`"$ServerIP`",`"relay_server`":`"$ServerIP`",`"api_server`":`"`",`"key`":`"$PublicKey`"}"

# --- Password ---
$chars = (48..57) + (65..90) + (97..122)
$Password = -join (Get-Random -Count 12 -InputObject $chars | ForEach-Object { [char]$_ })

# --- Installer ---
$Installer = Join-Path $PSScriptRoot "rustdesk.exe"

if (!(Test-Path $Installer)) {
    Write-Host "ERROR: rustdesk.exe not found in this folder." -ForegroundColor Red
    Pause-Exit
}

try { Unblock-File -Path $Installer } catch {}

Write-Host "Launching RustDesk installer..." -ForegroundColor Yellow
Write-Host "Complete the install, then close the installer window." -ForegroundColor Yellow

Start-Process -FilePath $Installer -Wait

# --- Wait for install ---
$RustDeskPath = Join-Path $env:ProgramFiles "RustDesk"
if (!(Test-Path $RustDeskPath)) {
    Write-Host "ERROR: RustDesk install folder not found." -ForegroundColor Red
    Pause-Exit
}

Set-Location $RustDeskPath

# --- Install service ---
Write-Host "Installing RustDesk service..." -ForegroundColor Cyan
Start-Process ".\rustdesk.exe" -ArgumentList "--install-service" -Wait

Start-Sleep 2
try { Start-Service RustDesk -ErrorAction Stop } catch {}

# --- Apply config ---
Write-Host "Applying NERDS server configuration..." -ForegroundColor Cyan
.\rustdesk.exe --config $ConfigJson | Out-Null
.\rustdesk.exe --password $Password | Out-Null

$ID = (.\rustdesk.exe --get-id).Trim()

# --- Output ---
Write-Host ""
Write-Host "===================================" -ForegroundColor Green
Write-Host "NERDS REMOTE SUPPORT READY" -ForegroundColor Green
Write-Host "ID:       $ID" -ForegroundColor White
Write-Host "Password: $Password" -ForegroundColor White
Write-Host "===================================" -ForegroundColor Green
Write-Host ""
Write-Host "Send the ID and Password to NERDS." -ForegroundColor Yellow

Pause-Exit
