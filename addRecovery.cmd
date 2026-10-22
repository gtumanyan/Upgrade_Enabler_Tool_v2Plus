@setlocal DisableDelayedExpansion
@echo off

::Options to set by dev
SET "Version=v2.1_b6"

echo===============================================
echo Check for Admin rights and elevate...
echo===============================================
	reg query "HKU\S-1-5-19" >nul 2>&1 || %NH% elevate "%~f0" && exit /b

:gotAdmin
pushd "%CD%"
CD /D "%~dp0"
cls

:: Re-launch the script with x64 process if it was initiated by x86 process on x64 bit Windows

if exist %SystemRoot%\Sysnative\cmd.exe (
set "_cmdf=%~f0"
setlocal EnableDelayedExpansion
start %SystemRoot%\Sysnative\cmd.exe /c ""!_cmdf!" %*"
exit /b
)

if exist "\sources\install.wim" set WIMFILE=install.wim
if exist "\sources\install.esd" set WIMFILE=install.esd

if not exist "\sources\%WIMFILE%" (
echo.
ECHO==========================================================
echo No %WIMFILE% file detected in sources dir...
ECHO==========================================================
echo.
pause
exit /b
)

TITLE Add Recovery to %WIMFILE%
:: 

set "_wimlib=%~dp0bin\wimlib-imagex.exe"

echo.
echo===============================================
echo Adding the Recovery.wim to the %WIMFILE%...
echo===============================================
echo.
for /f "tokens=3 delims=: " %%i in ('%_wimlib% info \sources\%WIMFILE% ^| findstr /c:"Image Count"') do set images=%%i
for /L %%i in (1,1,%images%) do (
  %_wimlib% update \sources\%WIMFILE% %%i --command="add Sources\WinRe.wim \Windows\System32\Recovery\Winre.wim"
)
