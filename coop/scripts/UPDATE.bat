@echo off
setlocal
cd /d "%~dp0"
title Jak 2 Co-op - Update

rem After unzipping a new jak2-coop.zip over this folder: rebuilds the game code (about 1-2 minutes).
rem Doesn't need the ISO again, and doesn't touch your saves.
if not exist "data\iso_data\jak2\SYSTEM.CNF" if not exist "data\out\jak2\iso\GAME.CGO" (
  echo Jak 2 isn't installed here yet. Run SETUP.bat first.
  pause
  exit /b 1
)
tasklist /fi "imagename eq gk.exe" | find /i "gk.exe" >nul && (
  echo Close the game first, then run UPDATE.bat again.
  pause
  exit /b 1
)

echo Updating Jak 2 Co-op, don't close this window...
extractor.exe -g jak2 -c -f "%~dp0data\iso_data\jak2"
if errorlevel 1 (
  echo.
  echo Update FAILED. Send the text above to the host.
  pause
  exit /b 1
)
echo.
echo Done! Run PLAY.bat.
pause
