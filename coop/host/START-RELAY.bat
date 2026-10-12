@echo off
cd /d "%~dp0"
title Jak 2 Co-op - Relay
echo Players are read from players.txt. Keep this window open while you play.
echo.
node coop-relay.js
pause
