@echo off
rem Builds the Teamruns OpenGOAL fork (gk, goalc, extractor) with the D: toolchain.
call "D:\Tools\VSBuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul || exit /b 1
set "PATH=D:\Tools\CMake\bin;C:\Program Files\NASM;%PATH%"
cd /d D:\REA\jak2mp\jak-project
if not exist out\build\Release\build.ninja (
  cmake --preset=Release-windows-clang-static || exit /b 1
)
cmake --build out\build\Release --target gk goalc extractor -j %NUMBER_OF_PROCESSORS% || exit /b 1
echo BUILD OK
