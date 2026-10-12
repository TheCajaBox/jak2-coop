@echo off
setlocal
cd /d "%~dp0"
title Jak 2 Co-op - Setup

if exist "data\out\jak2\iso\GAME.CGO" (
  echo Jak 2 is already installed here. Just run PLAY.bat.
  echo To reinstall, delete the "data\out" folder first.
  pause
  exit /b 0
)

rem gk/extractor need the Visual C++ 2015-2022 runtime
if not exist "%SystemRoot%\System32\vcruntime140_1.dll" (
  echo Installing Microsoft Visual C++ Runtime, needed by the game...
  winget install --id Microsoft.VCRedist.2015+.x64 -e --accept-package-agreements --accept-source-agreements
)
if not exist "%SystemRoot%\System32\vcruntime140_1.dll" (
  echo Could not install it automatically. Download and install "vc_redist.x64.exe" from
  echo https://aka.ms/vs/17/release/vc_redist.x64.exe and then run SETUP.bat again.
  pause
  exit /b 1
)

set "ISO=%~1"
if "%ISO%"=="" (
  echo Drag your Jak 2 ISO file onto this window and press Enter,
  echo or close this window and drag the ISO onto SETUP.bat.
  echo.
  set /p "ISO=ISO file: "
)
set "ISO=%ISO:"=%"
if not exist "%ISO%" (
  echo Could not find "%ISO%".
  pause
  exit /b 1
)

echo.
echo Extracting and building Jak 2. This takes 10-30 minutes, don't close this window.
echo.
extractor.exe -g jak2 -e -d -c "%ISO%"
if errorlevel 1 (
  echo.
  echo Setup FAILED. Send the text above to whoever gave you this package.
  pause
  exit /b 1
)

echo.
echo Done! Run PLAY.bat to start the game.
echo The first time, Windows may ask to allow gk.exe through the firewall: click Allow.
pause
