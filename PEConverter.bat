REM Copyright (c) Robert Hilton 2012
REM robert.a.hilton.jr@gmail.com
REM Usage: PEConverter.bat
REM Enter the ghost image name: ghost.wim

@echo off
set imgName= 
set /p imgName=Enter the ghost image name: 
if /i %PROCESSOR_ARCHITECTURE% EQU X86 set PATH=C:\Program Files\Windows AIK\Tools\PETools\;C:\Program Files\Windows AIK\Tools\PETools\..\%PROCESSOR_ARCHITECTURE%;C:\Program Files\Windows AIK\Tools\PETools\..\%PROCESSOR_ARCHITECTURE%\Servicing;%PATH%;
if /i %PROCESSOR_ARCHITECTURE% NEQ X86 set PATH=C:\Program Files\Windows AIK\Tools\PETools\;C:\Program Files\Windows AIK\Tools\PETools\..\%PROCESSOR_ARCHITECTURE%;C:\Program Files\Windows AIK\Tools\PETools\..\x86;C:\Program Files\Windows AIK\Tools\PETools\..\%PROCESSOR_ARCHITECTURE%\Servicing;C:\Program Files\Windows AIK\Tools\PETools\..\x86\Servicing;%PATH%;
cd /d %~dp0
mkdir ghostPEMount
REM mkdir temp
goto copype




:copype
setlocal
set a=x86
set b=%~dp0\newPE
set _P=C:\Program Files\Windows AIK\Tools\PETools\
set TEMPL=ISO

if /i "%a%"=="" goto usage
if /i "%b%"=="" goto usage
if /i not "%3"=="" goto usage
set SOURCE=%_P%%a%
set DEST=%b%

if not exist "%SOURCE%\winpe.wim" (
  echo File does not exist: "%SOURCE%\winpe.wim"
  exit /b 1
)

if exist "%DEST%" (
  echo Destination directory exists: %b%
  exit /b 1
)

mkdir "%DEST%"
if errorlevel 1 (
  echo Unable to create destination: %b%
  exit /b 1
)

echo.
echo ===================================================
echo Creating Windows PE customization working directory
echo.
echo     %DEST%
echo ===================================================
echo.

mkdir "%DEST%\%TEMPL%"
if errorlevel 1 goto :FAIL
mkdir "%DEST%\mount"
if errorlevel 1 goto :FAIL

if exist "%SOURCE%\bootmgr" copy "%SOURCE%\bootmgr" "%DEST%\%TEMPL%"
if errorlevel 1 goto :FAIL
if exist "%SOURCE%\bootmgr.efi" copy "%SOURCE%\bootmgr.efi" "%DEST%\%TEMPL%"
if errorlevel 1 goto :FAIL
if exist "%SOURCE%\boot\etfsboot.com" copy "%SOURCE%\boot\etfsboot.com" "%DEST%"
if errorlevel 1 goto :FAIL
if exist "%SOURCE%\boot\efisys.bin" copy "%SOURCE%\boot\efisys.bin" "%DEST%"
if errorlevel 1 goto :FAIL
if exist "%SOURCE%\boot\efisys_noprompt.bin" copy "%SOURCE%\boot\efisys_noprompt.bin" "%DEST%"
if errorlevel 1 goto :FAIL
if exist "%SOURCE%\boot" xcopy /cherky "%SOURCE%\boot" "%DEST%\%TEMPL%\boot\"
if errorlevel 1 goto :FAIL
if exist "%SOURCE%\EFI" xcopy /cherky "%SOURCE%\EFI" "%DEST%\%TEMPL%\EFI\"
if errorlevel 1 goto :FAIL
mkdir "%DEST%\%TEMPL%\sources"
if errorlevel 1 goto :FAIL
copy "%SOURCE%\winpe.wim" "%DEST%\winpe.wim"
if errorlevel 1 goto :FAIL

endlocal

goto CONT

:usage
echo Usage: copype [x86 ^| amd64 ^| ia64] destination
echo.
echo Example: copype x86 c:\windowspe-x86
goto :EOF

:FAIL
echo Failed to create working directory
goto :EOF

:CONT
imagex /mountrw newPE\winpe.wim 1 newPE\mount
imagex /mount %imgName% 2 ghostPEMount
xcopy /Y /E /H ghostPEMount\* newPE\mount
imagex /unmount /commit newPE\mount
imagex /unmount ghostPEMount
move /y newpe\winpe.wim %imgname:~0,-4%_converted.wim
rmdir /s /q ghostpemount
rmdir /s /q temp
rmdir /s /q newpe
goto :EOF

