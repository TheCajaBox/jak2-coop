@echo off
setlocal
title Jak 2 Co-op - Host Tailscale setup
rem Only needed when someone plays from another house.

if not exist "%ProgramFiles%\Tailscale\tailscale.exe" (
  echo Installing Tailscale...
  winget install --id Tailscale.Tailscale -e --accept-package-agreements --accept-source-agreements
)
if not exist "%ProgramFiles%\Tailscale\tailscale.exe" (
  echo Automatic install failed. Install it from https://tailscale.com/download then run this again.
  pause
  exit /b 1
)

echo Sign in to Tailscale (create a free account if you don't have one).
"%ProgramFiles%\Tailscale\tailscale.exe" up

echo.
echo Now invite the remote players: the admin page will open, click "Invite users"
echo and send them the link. (The free Personal plan covers a small group like this.)
start "" "https://login.tailscale.com/admin/users"
echo.
echo When they send you their 100.x.x.x address, add it to players.txt and run START-RELAY.bat.
pause
