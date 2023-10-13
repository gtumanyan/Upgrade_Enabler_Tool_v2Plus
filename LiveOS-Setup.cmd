@setlocal DisableDelayedExpansion
@echo off
set "_args=%*"
set "_elv="
if not defined _args goto :NoProgArgs
if "%~1"=="" set "_args="&goto :NoProgArgs
set _args=%_args:"=%
for %%A in (%_args%) do (
if /i "%%A"=="-wow" (set _rel1=1) else if /i "%%A"=="-arm" (set _rel2=1) else if /i "%%A"=="-su" (set _elv=1)
)
:NoProgArgs
set "_cmdf=%~f0"
if exist "%SystemRoot%\Sysnative\cmd.exe" if not defined _rel1 (
setlocal EnableDelayedExpansion
start %SystemRoot%\Sysnative\cmd.exe /c ""!_cmdf!" -wow %*"
exit /b
)
if exist "%SystemRoot%\SysArm32\cmd.exe" if /i %PROCESSOR_ARCHITECTURE%==AMD64 if not defined _rel2 (
setlocal EnableDelayedExpansion
start %SystemRoot%\SysArm32\cmd.exe /c ""!_cmdf!" -arm %*"
exit /b
)
set "SysPath=%SystemRoot%\System32"
set "Path=%SystemRoot%\System32;%SystemRoot%\System32\Wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0\"
if exist "%SystemRoot%\Sysnative\reg.exe" (
set "SysPath=%SystemRoot%\Sysnative"
set "Path=%SystemRoot%\Sysnative;%SystemRoot%\Sysnative\Wbem;%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\;%Path%"
)
set "_err===== ERROR ===="
set "_SxS=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SideBySide"
set "_Cmp=HKLM\COMPONENTS\DerivedData\Components"
set "_Pkt=31bf3856ad364e35"
set "_OurVer=6.3.9603.30600"
set "xBT=amd64"
set "xSU=superUser64.exe"
set "_EsuKey=%_SxS%\Winners\amd64_microsoft-windows-s..edsecurityupdatesai_%_Pkt%_none_0e8b36cfce2fb332"
set "_EsuCom=amd64_microsoft-windows-s..edsecurityupdatesai_%_Pkt%_%_OurVer%_none_6022b34506a8b67a"
set "_EsuIdn=4D6963726F736F66742D57696E646F77732D534C432D436F6D706F6E656E742D457874656E64656453656375726974795570646174657341492C2043756C747572653D6E65757472616C2C2056657273696F6E3D362E332E393630332E33303630302C205075626C69634B6579546F6B656E3D333162663338353661643336346533352C2050726F636573736F724172636869746563747572653D616D6436342C2076657273696F6E53636F70653D4E6F6E537853"
set "_EsuHsh=423FEE4BEB5BCA64D89C7BCF0A69F494288B9A2D947C76A99C369A378B79D411"
if /i %PROCESSOR_ARCHITECTURE%==x86 (if not defined PROCESSOR_ARCHITEW6432 (
  set "xBT=x86"
  set "xSU=superUser32.exe"
  set "_EsuKey=%_SxS%\Winners\x86_microsoft-windows-s..edsecurityupdatesai_%_Pkt%_none_b26c9b4c15d241fc"
  set "_EsuCom=x86_microsoft-windows-s..edsecurityupdatesai_%_Pkt%_%_OurVer%_none_040417c14e4b4544"
  set "_EsuIdn=4D6963726F736F66742D57696E646F77732D534C432D436F6D706F6E656E742D457874656E64656453656375726974795570646174657341492C2043756C747572653D6E65757472616C2C2056657273696F6E3D362E332E393630332E33303630302C205075626C69634B6579546F6B656E3D333162663338353661643336346533352C2050726F636573736F724172636869746563747572653D7838362C2076657273696F6E53636F70653D4E6F6E537853"
  set "_EsuHsh=70FC6E62A198F5D98FDDE11A6E8D6C885E17C53FCFE1D927496351EADEB78E42"
  )
)

set _win8=0
for /f "tokens=6 delims=[]. " %%# in ('ver') do (
if %%# gtr 9700 goto :E_Win
if %%# lss 9100 goto :E_Win
if %%# lss 9500 set _win8=1
)
reg query HKU\S-1-5-19 1>nul 2>nul || goto :E_Admin

set "_bat=%~f0"
set "_work=%~dp0"
set "_work=%_work:~0,-1%"
setlocal EnableDelayedExpansion
pushd "!_work!"
if not exist "bin\" goto :E_DLL
cd bin\
for %%# in (
%xSU%
%_EsuCom%.manifest
) do (
if not exist "%%~#" (set "_file=%%~nx#"&goto :E_DLL)
)

call :TIcmd 1>nul 2>nul
whoami /USER | find /i "S-1-5-18" 1>nul && (
goto :Begin
) || (
if defined _elv goto :E_TI
net start TrustedInstaller 1>nul 2>nul
1>nul 2>nul %xSU% /c cmd.exe /c ""!_bat!" -su" &exit /b
)
whoami /USER | find /i "S-1-5-18" 1>nul || goto :E_TI

:Begin
@cls
echo.
echo ____________________________________________________________
echo.
echo Checking . . .
echo.

set "_sku="
for /f "tokens=2 delims==" %%# in ('"wmic OS Get OperatingSystemSKU /value" 2^>nul') do set "_sku=%%#"
if "%_sku%"=="" goto :E_WMI

set _EsuPkg=0
if exist "%SystemRoot%\WinSxS\Manifests\%_EsuCom%.manifest" (
reg query "%_EsuKey%" /ve 2>nul | find /i "%_OurVer:~0,3%" 1>nul && (
  reg query "%_EsuKey%\%_OurVer:~0,3%" /ve 2>nul | find /i "%_OurVer%" 1>nul && set _EsuPkg=1
  )
)

if %_EsuPkg% equ 0 if exist "%SystemRoot%\WinSxS\pending.xml" (
echo.
echo Pending update operation detected.
echo restart the system first, then run the script.
goto :TheEnd
)

set _EsuUpdt=0
set "_EsuMajor="
set "_EsuWinner="
if not exist "%SystemRoot%\WinSxS\Manifests\%xBT%_microsoft-windows-s..edsecurityupdatesai*.manifest" goto :proceed
reg query "%_EsuKey%" 1>nul 2>nul || goto :proceed
reg query HKLM\COMPONENTS 1>nul 2>nul || reg load HKLM\COMPONENTS %SysPath%\Config\COMPONENTS 1>nul 2>nul
reg query "%_Cmp%" /f "%xBT%_microsoft-windows-s..edsecurityupdatesai_*" /k 2>nul | find /i "edsecurityupdatesai" 1>nul || goto :proceed
for /f "tokens=4 delims=_" %%# in ('dir /b "%SystemRoot%\WinSxS\Manifests\%xBT%_microsoft-windows-s..edsecurityupdatesai*.manifest"') do (
set "_ChkVer=%%#"&call :checkver
)
goto :proceed

:checkver
if "%_ChkVer%"=="%_OurVer%" exit /b
reg query "%_Cmp%" /f "%xBT%_microsoft-windows-s..edsecurityupdatesai_%_Pkt%_%_ChkVer%_*" /k 2>nul | find /i "%_ChkVer%" 1>nul || exit /b
reg query "%_EsuKey%\%_ChkVer:~0,3%" /t REG_BINARY 2>nul | find /i "%_ChkVer%" 1>nul || exit /b
if %_win8% equ 0 (
if "%_ChkVer:~4,4%" equ "9600" if "%_ChkVer:~9,5%" geq "20780" set _EsuUpdt=1
if "%_ChkVer:~4,4%" geq "9601" set _EsuUpdt=1
) else (
if "%_ChkVer:~4,4%" equ "9200" if "%_ChkVer:~9,5%" geq "24400" set _EsuUpdt=1
if "%_ChkVer:~4,4%" geq "9201" set _EsuUpdt=1
)
set "_EsuMajor=%_ChkVer:~0,3%"
set "_EsuWinner=%_ChkVer%"
exit /b

:proceed
set _wufile=wuaueng.dll
if exist "%SysPath%\wuaueng2.dll" set _wufile=wuaueng2.dll
@title BypassESU Blue v2

:MainMenu
set _elr=0
@cls
echo ____________________________________________________________
echo.
if %_EsuPkg% equ 0 (
echo [2] Install ESU Suppressor
echo.
)
if %_EsuPkg% equ 1 if %_EsuUpdt% equ 0 (
echo [5] Remove ESU Suppressor
echo.
)
echo [9] Exit
echo.
echo ____________________________________________________________
echo.
choice /C 259 /N /M "Choose a menu option: "
set _elr=%errorlevel%
if %_elr%==3 goto :eof
if %_elr%==2 if %_EsuPkg% equ 1 if %_EsuUpdt% equ 0 (goto :Uninstall)
if %_elr%==1 if %_EsuPkg% equ 0 (goto :Install)
goto :MainMenu

:Install
@cls
echo.
echo ____________________________________________________________
echo.
echo Installing ESU Suppressor . . .
echo.
call :StopService wuauserv 1>nul 2>nul
call :DoManual 1>nul 2>nul
echo.
echo Done.
goto :TheEnd

:DoManual
if %_win8% equ 0 (
  set "_EsuFnd=microsoft-w..-foundation_%_Pkt%_6.3.9600.16384_d1250fcb45c3a9e5"
  if /i "%xBT%"=="x86" (
  set "_EsuFnd=microsoft-w..-foundation_%_Pkt%_6.3.9600.16384_750674478d6638af"
  )
) else (
  set "_EsuFnd=microsoft-w..-foundation_%_Pkt%_6.2.9200.16384_39305724fb90d968"
  if /i "%xBT%"=="x86" (
  set "_EsuFnd=microsoft-w..-foundation_%_Pkt%_6.2.9200.16384_dd11bba143336832"
  )
)
copy /y %_EsuCom%.manifest %SystemRoot%\WinSxS\Manifests\
reg query HKLM\COMPONENTS 1>nul 2>nul || reg load HKLM\COMPONENTS %SysPath%\Config\COMPONENTS 1>nul 2>nul
reg delete "%_Cmp%\%_EsuCom%" /f
reg add "%_Cmp%\%_EsuCom%" /f /v "c^!%_EsuFnd%" /t REG_BINARY /d ""
reg add "%_Cmp%\%_EsuCom%" /f /v identity /t REG_BINARY /d "%_EsuIdn%"
reg add "%_Cmp%\%_EsuCom%" /f /v S256H /t REG_BINARY /d "%_EsuHsh%"
reg add "%_EsuKey%" /f /ve /d %_OurVer:~0,3%
reg add "%_EsuKey%\%_OurVer:~0,3%" /f /ve /d %_OurVer%
reg add "%_EsuKey%\%_OurVer:~0,3%" /f /v %_OurVer% /t REG_BINARY /d 01
for /f "tokens=* delims=" %%# in ('reg query HKLM\COMPONENTS\DerivedData\VersionedIndex 2^>nul ^| findstr /i VersionedIndex') do reg delete "%%#" /f
reg unload HKLM\COMPONENTS 1>nul 2>nul || call :StopService TrustedInstaller 1>nul 2>nul
exit /b

:Uninstall
@cls
if exist "%SystemRoot%\WinSxS\pending.xml" (
echo.
echo Pending update operation detected.
echo restart the system first, then run the script.
goto :TheEnd
)
echo.
echo ____________________________________________________________
echo.
echo Removing ESU Suppressor . . .
echo.
call :RemoveManual 1>nul 2>nul
echo.
echo Done.
goto :TheEnd

:RemoveManual
reg query HKLM\COMPONENTS 1>nul 2>nul || reg load HKLM\COMPONENTS %SysPath%\Config\COMPONENTS 1>nul 2>nul
reg delete "%_Cmp%\%_EsuCom%" /f
reg delete "%_EsuKey%\%_OurVer:~0,3%" /f /v %_OurVer%
del /f /q "%SystemRoot%\WinSxS\Manifests\%_EsuCom%.manifest"
if not exist "%SystemRoot%\WinSxS\Manifests\*_microsoft-windows-s..edsecurityupdatesai*.manifest" (
reg delete "%_EsuKey%" /f
) else (
if defined _EsuWinner (
  reg add "%_EsuKey%" /f /ve /d "%_EsuMajor%"
  reg add "%_EsuKey%\%_EsuMajor%" /f /ve /d "%_EsuWinner%"
  ) else (
  reg delete "%_EsuKey%" /f
  )
)
for /f "tokens=* delims=" %%# in ('reg query HKLM\COMPONENTS\DerivedData\VersionedIndex 2^>nul ^| findstr /i VersionedIndex') do reg delete "%%#" /f
reg unload HKLM\COMPONENTS 1>nul 2>nul || call :StopService TrustedInstaller 1>nul 2>nul
dism.exe /Online /Get-Packages
exit /b

:StopService
sc query %1 | find /i "STOPPED" || net stop %1 /y
sc query %1 | find /i "STOPPED" || sc stop %1
exit /b

:TIcmd
reg delete HKU\.DEFAULT\Console\^%%SystemRoot^%%_system32_cmd.exe /f
reg add HKU\.DEFAULT\Console /f /v FaceName /t REG_SZ /d Consolas
reg add HKU\.DEFAULT\Console /f /v FontFamily /t REG_DWORD /d 0x36
reg add HKU\.DEFAULT\Console /f /v FontSize /t REG_DWORD /d 0x100000
reg add HKU\.DEFAULT\Console /f /v FontWeight /t REG_DWORD /d 0x190
reg add HKU\.DEFAULT\Console /f /v ScreenBufferSize /t REG_DWORD /d 0x12c0050
exit /b

:E_TI
echo %_err%
echo Failed running the script with TrustedInstaller privileges.
goto :TheEnd

:E_WMI
echo %_err%
echo Failed detecting OS SKU.
echo Verify that Windows Management Instrumentation service "WinMgmt" is working.
goto :TheEnd

:E_Admin
echo %_err%
echo This script requires administrator privileges.
goto :TheEnd

:E_Win
echo %_err%
echo This project is for Windows 8/8.1 - Server 2012 R1/R2 only.
goto :TheEnd

:E_DLL
echo %_err%
echo Required file bin\%_file% is missing.

:TheEnd
echo.
echo Press any key to exit.
pause >nul
goto :eof
