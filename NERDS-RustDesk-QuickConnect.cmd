@echo off
setlocal

:: If not admin, relaunch this .cmd as admin (UAC prompt)
net session >nul 2>&1
if not %errorlevel%==0 (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0NERDS-RustDesk-QuickConnect.ps1"

echo.
pause
