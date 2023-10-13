@echo off
if "%~1"=="" goto :eof
if not exist "wimlib-imagex.exe" goto :eof
@setlocal DisableDelayedExpansion
set "target=%~1"
set "targen=%~nx1"
@cls
echo.
echo ____________________________________________________________
echo.
echo Checking . . .
echo.

set _bbb=0
set _win8=0
for /f "tokens=2 delims=: " %%# in ('wimlib-imagex info "%target%" 1 2^>nul ^| findstr /i /b /c:"Build:"') do set _bbb=%%#
if %_bbb% gtr 9700 goto :E_Wim
if %_bbb% lss 9100 goto :E_Wim
if %_bbb% lss 9500 set _win8=1

set "_err===== ERROR ===="
set "IFEO=HKLM\wSOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
set "_SxS=HKLM\wSOFTWARE\Microsoft\Windows\CurrentVersion\SideBySide"
set "_Cmp=HKLM\wCOMPONENTS\DerivedData\Components"
set "_Pkt=31bf3856ad364e35"
set "_OurVer=6.3.9603.30600"
set "xBT=x86"
set "_EsuKey=%_SxS%\Winners\x86_microsoft-windows-s..edsecurityupdatesai_%_Pkt%_none_b26c9b4c15d241fc"
set "_EsuCom=x86_microsoft-windows-s..edsecurityupdatesai_%_Pkt%_%_OurVer%_none_040417c14e4b4544"
set "_EsuIdn=4D6963726F736F66742D57696E646F77732D534C432D436F6D706F6E656E742D457874656E64656453656375726974795570646174657341492C2043756C747572653D6E65757472616C2C2056657273696F6E3D362E332E393630332E33303630302C205075626C69634B6579546F6B656E3D333162663338353661643336346533352C2050726F636573736F724172636869746563747572653D7838362C2076657273696F6E53636F70653D4E6F6E537853"
set "_EsuHsh=70FC6E62A198F5D98FDDE11A6E8D6C885E17C53FCFE1D927496351EADEB78E42"
wimlib-imagex info "%target%" 1 2>nul | find /i "x86_64" 1>nul && (
set "xBT=amd64"
set "_EsuKey=%_SxS%\Winners\amd64_microsoft-windows-s..edsecurityupdatesai_%_Pkt%_none_0e8b36cfce2fb332"
set "_EsuCom=amd64_microsoft-windows-s..edsecurityupdatesai_%_Pkt%_%_OurVer%_none_6022b34506a8b67a"
set "_EsuIdn=4D6963726F736F66742D57696E646F77732D534C432D436F6D706F6E656E742D457874656E64656453656375726974795570646174657341492C2043756C747572653D6E65757472616C2C2056657273696F6E3D362E332E393630332E33303630302C205075626C69634B6579546F6B656E3D333162663338353661643336346533352C2050726F636573736F724172636869746563747572653D616D6436342C2076657273696F6E53636F70653D4E6F6E537853"
set "_EsuHsh=423FEE4BEB5BCA64D89C7BCF0A69F494288B9A2D947C76A99C369A378B79D411"
)

set _WinPE=0
wimlib-imagex dir "%target%" 1 --path=sources\recovery\RecEnv.exe 1>nul 2>nul && set _WinPE=1

set _Winre=0
wimlib-imagex dir "%target%" 1 --path=Windows\System32\Recovery\winre.wim 1>nul 2>nul && set _Winre=1

set _EsuPkg=0
wimlib-imagex dir "%target%" 1 --path=Windows\WinSxS\Manifests\%_EsuCom%.manifest 1>nul 2>nul && set _EsuPkg=1
@title BypassESU Blue v2

:MainMenu
set _elr=0
@cls
echo ____________________________________________________________
echo.
if %_EsuPkg% equ 0 (
echo [2] Integrate ESU Suppressor
echo.
)
echo [9] Exit
echo.
echo ____________________________________________________________
echo.
choice /C 29 /N /M "Choose a menu option: "
set _elr=%errorlevel%
if %_elr%==2 exit
if %_elr%==1 if %_EsuPkg% equ 0 (goto :wimESU)
goto :MainMenu

:wimESU
@cls
echo.
echo ____________________________________________________________
echo.
echo Integrating ESU Suppressor . . .
echo.
echo %targen%
for /f "tokens=3 delims=: " %%# in ('wimlib-imagex info "%target%" ^| findstr /i /c:"Image Count"') do set imgcount=%%#
for /L %%# in (1,1,%imgcount%) do (
echo index %%#/%imgcount%
call :WIMt %%# 1>nul 2>nul
)

if %_Winre% equ 0 (
echo.
echo Done.
goto :TheEnd
)

echo.
echo ____________________________________________________________
echo.
echo Processing "winre.wim" . . .
echo.
echo extracting
wimlib-imagex extract "%target%" 1 Windows\System32\Recovery\winre.wim --dest-dir=.\re --no-acls --no-attributes 1>nul 2>nul
echo integrating
set "source=%target%"
set "target=re\winre.wim"
set _WinPE=1
call :WIMt 1 1>nul 2>nul
echo re-adding
for /L %%# in (1,1,%imgcount%) do (
wimlib-imagex update "%source%" %%# --command="add 're\winre.wim' '\Windows\System32\Recovery\winre.wim'" 1>nul 2>nul
)
if exist re\ rmdir /s /q re\
set "target=%source%"
echo.
echo Done.
goto :TheEnd

:WIMt
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
wimlib-imagex extract "%target%" %1 \Windows\System32\config\COMPONENTS \Windows\System32\config\SOFTWARE --dest-dir=.\temp
reg load HKLM\wCOMPONENTS "temp\COMPONENTS"
reg load HKLM\wSOFTWARE "temp\SOFTWARE"
reg delete "%_Cmp%\%_EsuCom%" /f
reg add "%_Cmp%\%_EsuCom%" /f /v "c!%_EsuFnd%" /t REG_BINARY /d ""
reg add "%_Cmp%\%_EsuCom%" /f /v identity /t REG_BINARY /d "%_EsuIdn%"
reg add "%_Cmp%\%_EsuCom%" /f /v S256H /t REG_BINARY /d "%_EsuHsh%"
reg add "%_EsuKey%" /f /ve /d %_OurVer:~0,3%
reg add "%_EsuKey%\%_OurVer:~0,3%" /f /ve /d %_OurVer%
reg add "%_EsuKey%\%_OurVer:~0,3%" /f /v %_OurVer% /t REG_BINARY /d 01
reg unload HKLM\wCOMPONENTS
reg unload HKLM\wSOFTWARE
type nul>wimupdt.txt
>>wimupdt.txt echo add '%_EsuCom%.manifest' '\Windows\WinSxS\Manifests\%_EsuCom%.manifest'
>>wimupdt.txt echo add 'temp\COMPONENTS' '\Windows\System32\config\COMPONENTS'
>>wimupdt.txt echo add 'temp\SOFTWARE' '\Windows\System32\config\SOFTWARE'
wimlib-imagex update "%target%" %1 < wimupdt.txt
del /f /q wimupdt.txt
rmdir /s /q .\temp
exit /b

:E_Wim
echo.
echo %_err%
echo Specified wim is not Windows NT 6.3/6.2
goto :TheEnd

:TheEnd
goto :eof
