@setlocal DisableDelayedExpansion
@echo off
REM change wording if needed for echo commands..

::Options to set by dev
SET "Version=v2.0"


:: Re-launch the script with x64 process if it was initiated by x86 process on x64 bit Windows

if exist %SystemRoot%\Sysnative\cmd.exe (
set "_cmdf=%~f0"
setlocal EnableDelayedExpansion
start %SystemRoot%\Sysnative\cmd.exe /c ""!_cmdf!" %*"
exit /b
)

if exist "x:\sources\install.wim" set WIMFILE=install.wim
if exist "x:\sources\install.esd" set WIMFILE=install.esd

if not exist "x:\sources\%WIMFILE%" (
echo.
ECHO==========================================================
echo No %WIMFILE% file detected in sources dir...
ECHO==========================================================
echo.
pause
exit /b
)

TITLE Add Y.A.S.T Recovery to %WIMFILE%

echo===============================================
echo Check for Admin rights...
echo===============================================
if not "%1"=="am_admin" powershell start -verb runas '%0' am_admin & exit /b

:gotAdmin
pushd "%CD%"
CD /D "%~dp0"
cls

set "_wimlib=%~dp0bin\wimlib-imagex.exe"

echo.
echo===============================================
echo Adding the Y.A.S.T Recovery.wim to the %Winver% %WIMFILE%...
echo===============================================
echo.
for /f "tokens=3 delims=: " %%i in ('%_wimlib% info x:\sources\%WIMFILE% ^| findstr /c:"Image Count"') do set images=%%i
for /L %%i in (1,1,%images%) do (
  %_wimlib% update x:\sources\%WIMFILE% %%i --command="add Sources\WinRe.wim \Windows\System32\Recovery\Winre.wim"
)
echo.
echo===============================================
echo Optimizing the %Winver% %WIMFILE% file...
echo===============================================
echo.
%_wimlib% optimize "x:\Sources\%WIMFILE%" --recompress
echo.