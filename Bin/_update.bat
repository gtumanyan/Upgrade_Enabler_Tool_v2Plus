@echo off>nul 2>&1
::
set name=wimlib-imagex
set exe=%name%.exe
set url="https://wimlib.net/downloads/index.html"
set mask=x86_64-bin\.zip
::
set "pp=%~dp0"
set "pe=%~dp0%exe%" 
call "%~dp0..\..\toolset.bat" "%~1" || goto SKIP
::BEGIN
call %spider% || goto SKIP
call %close% "%pe%" || goto SKIP
call %download_distr% || (call %msg% 3 & goto SKIP)
%unpack_distr% -x!devel -x!COPYING* || (call %msg% 4 & goto SKIP)
call %check_end%
call %msg% 100
:SKIP
call %end%