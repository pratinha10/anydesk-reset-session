@echo off & setlocal enableextensions
title AnyDesk Reset Tool

chcp 437 >nul

:: Checks if the script is running as administrator (checks if the key exists in the registry)
reg query HKEY_USERS\S-1-5-19 >NUL || (
    call :banner
    echo   [ERROR] This script must be run as administrator.
    echo(
    echo   Right-click the file and select "Run as administrator".
    echo(
    pause >NUL
    exit
)

call :banner

echo   [1/5] Stopping AnyDesk...
call :stop_any
echo         [OK] Service stopped.
echo(

echo   [2/5] Removing license configuration...
del /f "%ALLUSERSPROFILE%\AnyDesk\service.conf" >nul 2>&1
del /f "%APPDATA%\AnyDesk\service.conf" >nul 2>&1
echo         [OK] Old license files removed.
echo(

echo   [3/5] Backing up your settings...
copy /y "%APPDATA%\AnyDesk\user.conf" "%temp%\" >nul 2>&1
rd /s /q "%temp%\thumbnails" 2>NUL
xcopy /c /e /h /r /y /i /k "%APPDATA%\AnyDesk\thumbnails" "%temp%\thumbnails" >nul 2>&1
echo         [OK] User config and thumbnails saved.
echo(

echo   [4/5] Clearing AnyDesk data and generating a new ID...
del /f /a /q "%ALLUSERSPROFILE%\AnyDesk\*" >nul 2>&1
del /f /a /q "%APPDATA%\AnyDesk\*" >nul 2>&1

call :start_any

echo         Waiting for AnyDesk to assign a new ID
:wait_lic
find "ad.anynet.id=" "%ALLUSERSPROFILE%\AnyDesk\system.conf" >nul 2>&1
if %errorlevel% neq 0 (
    <nul set /p "=."
    timeout /t 1 >nul
    goto wait_lic
)
echo(
echo         [OK] New ID generated.
echo(

echo   [5/5] Restoring your settings...
call :stop_any

move /y "%temp%\user.conf" "%APPDATA%\AnyDesk\user.conf" >nul 2>&1
xcopy /c /e /h /r /y /i /k "%temp%\thumbnails" "%APPDATA%\AnyDesk\thumbnails" >nul 2>&1
rd /s /q "%temp%\thumbnails" >nul 2>&1

call :start_any
echo         [OK] Settings restored.
echo(

echo  ============================================================
echo                     Reset completed!
echo    AnyDesk is ready to use with a fresh free-tier license.
echo  ------------------------------------------------------------
echo                  Tool made by pratinha10
echo  ============================================================
echo(
echo   Press ENTER to close...
pause >nul
goto :eof


:: ================================
:: BANNER
:: ================================
:banner
cls
echo(
echo  ============================================================
echo                     AnyDesk Reset Tool
echo            Resets the free-tier connection license
echo                     by pratinha10
echo  ============================================================
echo(
goto :eof


:: ================================
:: START ANYDESK
:: ================================
:start_any
echo         Starting AnyDesk service...

sc query AnyDesk | find "RUNNING" >nul
if %errorlevel%==0 (
    goto open_any
)

sc start AnyDesk >nul 2>&1

set count=0
:wait_start
sc query AnyDesk | find "RUNNING" >nul
if %errorlevel%==0 goto open_any

timeout /t 1 >nul
set /a count+=1
if %count% lss 15 goto wait_start

echo         [WARN] Service did not start in time.
goto :eof


:open_any
set "AnyDesk1=%ProgramFiles(x86)%\AnyDesk\AnyDesk.exe"
set "AnyDesk2=%ProgramFiles%\AnyDesk\AnyDesk.exe"

if exist "%AnyDesk1%" start "" "%AnyDesk1%"
if exist "%AnyDesk2%" start "" "%AnyDesk2%"

exit /b


:: ================================
:: STOP ANYDESK
:: ================================
:stop_any
sc query AnyDesk | find "STOPPED" >nul
if %errorlevel%==0 goto kill_proc

sc stop AnyDesk >nul 2>&1

set count=0
:wait_stop
sc query AnyDesk | find "STOPPED" >nul
if %errorlevel%==0 goto kill_proc

timeout /t 1 >nul
set /a count+=1
if %count% lss 15 goto wait_stop

:kill_proc
taskkill /f /im "AnyDesk.exe" >nul 2>&1
exit /b