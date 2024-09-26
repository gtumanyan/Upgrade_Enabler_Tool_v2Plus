@setlocal DisableDelayedExpansion
@echo off

::Options to set by dev
SET "Version=v2.1_b3+"

REM User settings
REM When set to "0" = No install.wim optimizing
REM When set to "1" = Install.wim will be optimized, this can use all system resources and take a while
SET "Optimize=0"
REM When set to "0" the EI.CFG file won't be added
REM When set to "1" the EI.CFG file will be added (when there already is an EI.CFG it will be renamed to EI.CFG.ORI)
SET "EI_CFG_ADD=1"

echo===============================================
echo Check for Admin rights and elevate...
echo===============================================
	reg query "HKU\S-1-5-19" >nul 2>&1 || %NH% elevate "%~f0" && exit

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

if exist "x:\sources\install.wim" set WIMFILE=install.wim
if exist "x:\sources\install.esd" set WIMFILE=install.esd
TITLE Create Modified %WIMFILE% To Be Able To Directly Upgrade From any Windows Install %version%


echo.
echo===============================================
echo Running %WIMFILE% Upgrade Enabler %version%...
echo.
echo Crappy Tools By Enthousiast ^@MDL modded by WindR
echo===============================================
echo.
set "_wimlib=%~dp0bin\wimlib-imagex.exe"

if exist "TEMP" RD /S /Q "TEMP"
if not exist "x:\sources\%WIMFILE%" (
echo.
ECHO==========================================================
echo No %WIMFILE% file detected in sources dir...
ECHO==========================================================
echo.
pause
exit /b
)

mkdir "TEMP"
bin\7z.exe l x:\sources\setup.exe >.\TEMP\version.txt 2>&1
for /f "tokens=4 delims=. " %%i in ('findstr /i /b FileVersion .\TEMP\version.txt') do set vermajor=%%i

REM ==========

IF NOT DEFINED vermajor (
echo.
ECHO==========================================================
echo Detecting setup.exe version failed...
ECHO==========================================================
echo.
Goto :Cleanup
)

SET "Winver="
IF %vermajor% EQU 22000 SET "Winver=22000"
IF %vermajor% EQU 22621 SET "Winver=226x1"

IF %vermajor% EQU 9600 SET "Winver=9600"
IF %vermajor% EQU 17763 SET "Winver=17763"
IF %vermajor% EQU 19041 SET "Winver=1904x"
IF %vermajor% EQU 26100 SET "Winver=26100"

IF NOT DEFINED Winver (
echo.
ECHO==========================================================
echo Unsupported setup version %vermajor%
ECHO==========================================================
echo.
Goto :Cleanup
)


for /f "tokens=2 delims=: " %%# in ('dism.exe /english /get-wiminfo /wimfile:"x:\sources\%WIMFILE%" /index:1 ^| find /i "Architecture"') do set warch=%%#
echo.
echo===============================================
echo Adding the modified %Winver% %warch% UpgradeMatrix.xml to the %Winver% %warch% %WIMFILE%...
echo===============================================
echo.
for /f "tokens=3 delims=: " %%i in ('%_wimlib% info x:\sources\%WIMFILE% ^| findstr /c:"Image Count"') do set images=%%i
for /L %%i in (1,1,%images%) do (
  %_wimlib% update "x:\Sources\%WIMFILE%" %%i --command="add 'Files\UpgradeMatrix\UpgradeMatrix_%warch%.xml' '\Windows\servicing\Editions\UpgradeMatrix.xml'"
)
echo.
IF /I "%Optimize%"=="0" GOTO :CreateISO
echo===============================================
echo Optimizing the %Winver% %warch% WIM file...
echo===============================================
echo.
%_wimlib% optimize "x:\Sources\%WIMFILE%" --recompress
echo.
:CreateISO

echo.
:EI
IF /I "%EI_CFG_ADD%" NEQ "1" GOTO :SKIPEI
echo.
echo ============================================================
echo Copying the generic ei.cfg to the work dir...
echo ^(If exists, the original file will be renamed to EI.CFG.ORI^)
echo ============================================================
echo.
IF EXIST "x:\Sources\EI.CFG" ren "x:\Sources\EI.CFG" "EI.CFG.ORI"
COPY /Y "Files\EI.CFG" "x:\Sources\"
echo.
:SKIPEI


:Cleanup
echo.
echo===============================================
echo Cleaning up the TEMP folder...
echo===============================================
if exist "TEMP" RD /S /Q "TEMP"
echo.
pause
exit /b