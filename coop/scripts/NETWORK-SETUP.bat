@echo off
setlocal
cd /d "%~dp0"
title Jak 2 Co-op - Network setup

rem Needs admin for the firewall rule, re-launch elevated if necessary
net session >nul 2>&1
if errorlevel 1 (
  echo Asking for administrator permission to add the firewall rule...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

echo Where is this PC?
echo   1 = Same house as the host (same Wi-Fi / router)
echo   2 = Another house (uses Tailscale, a free private network)
choice /c 12 /n /m "Choose 1 or 2: "
set "WHERE=%errorlevel%"

if "%WHERE%"=="2" call :tailscale || goto :failed

echo.
echo Allowing the game (TCP port 8111) through Windows Firewall,
echo only from your home network and Tailscale, not the whole internet...
netsh advfirewall firewall delete rule name="Jak 2 Co-op" >nul 2>&1
netsh advfirewall firewall add rule name="Jak 2 Co-op" dir=in action=allow protocol=TCP localport=8111 remoteip=LocalSubnet,100.64.0.0/10 profile=any >nul || goto :failed

echo.
echo ============================================================
if "%WHERE%"=="2" (
  echo Send the host this Tailscale address:
  "%ProgramFiles%\Tailscale\tailscale.exe" ip -4
) else (
  echo Send the host this address:
  powershell -NoProfile -Command "(Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq 'Up' }).IPv4Address.IPAddress"
)
echo ============================================================
echo Network setup done.
pause
exit /b 0

:tailscale
if not exist "%ProgramFiles%\Tailscale\tailscale.exe" (
  echo.
  echo Installing Tailscale...
  winget install --id Tailscale.Tailscale -e --accept-package-agreements --accept-source-agreements
  if not exist "%ProgramFiles%\Tailscale\tailscale.exe" (
    echo Automatic install failed. Install it from https://tailscale.com/download then run this again.
    exit /b 1
  )
)
echo.
echo First open the invite link the host sent you and accept it.
echo Then sign in with that same account when Tailscale asks (a browser page or a link below).
"%ProgramFiles%\Tailscale\tailscale.exe" up
exit /b 0

:failed
echo.
echo Network setup FAILED. Send the text above to the host.
pause
exit /b 1
