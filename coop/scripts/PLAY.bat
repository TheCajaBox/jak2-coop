@echo off
cd /d "%~dp0"
if not exist "data\out\jak2\iso\GAME.CGO" (
  echo Jak 2 isn't installed yet. Run SETUP.bat first.
  pause
  exit /b 1
)
rem Port 8111 is where the co-op relay connects to this game.
start "" gk.exe --socketport 8111 --game jak2 -- -boot -fakeiso
