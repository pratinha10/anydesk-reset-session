@echo off & setlocal enableextensions
title Reset AnyDesk

:: Checks if the script is running as administrator (checks if the key exists in the registry)
reg query HKEY_USERS\S-1-5-19 >NUL || (
    echo Please, run as administrator.
    pause >NUL
    exit
)

chcp 437 
:: Defines the code page

call :stop_any

:: Removes AnyDesk configuration files
del /f "%ALLUSERSPROFILE%\AnyDesk\service.conf"
del /f "%APPDATA%\AnyDesk\service.conf"

:: Saves the current user.conf to TEMP
copy /y "%APPDATA%\AnyDesk\user.conf" "%temp%\"

:: Removes old thumbnails
rd /s /q "%temp%\thumbnails" 2>NUL

:: Copies the current thumbnails to TEMP
xcopy /c /e /h /r /y /i /k "%APPDATA%\AnyDesk\thumbnails" "%temp%\thumbnails"

:: Removes all files from the AnyDesk folder (both system and user profiles)
del /f /a /q "%ALLUSERSPROFILE%\AnyDesk\*"
del /f /a /q "%APPDATA%\AnyDesk\*"

call :start_any

:lic
:: Waits until the system.conf file contains the line "ad.anynet.id="
:wait_lic
find "ad.anynet.id=" "%ALLUSERSPROFILE%\AnyDesk\system.conf" >nul 2>&1
if %errorlevel% neq 0 (
    timeout /t 1 >nul
    goto wait_lic
)

:: Restores configuration files
call :stop_any

move /y "%temp%\user.conf" "%APPDATA%\AnyDesk\user.conf" >nul 2>&1
xcopy /c /e /h /r /y /i /k "%temp%\thumbnails" "%APPDATA%\AnyDesk\thumbnails" >nul 2>&1
rd /s /q "%temp%\thumbnails" >nul 2>&1

call :start_any

echo *********
echo Completed.
echo(
goto :eof


:: ================================
:: START ANYDESK
:: ================================
:start_any
echo Starting AnyDesk service...

:: If it is already running, do not try to start it again
sc query AnyDesk | find "RUNNING" >nul
if %errorlevel%==0 (
    echo Service is already running.
    goto open_any
)

sc start AnyDesk >nul 2>&1

:: Waits up to 15 seconds to start up
set count=0
:wait_start
sc query AnyDesk | find "RUNNING" >nul
if %errorlevel%==0 goto open_any

timeout /t 1 >nul
set /a count+=1
if %count% lss 15 goto wait_start

echo Failed to start service.
goto :eof


:open_any
echo Opening executable...

set "AnyDesk1=%ProgramFiles(x86)%\AnyDesk\AnyDesk.exe"
set "AnyDesk2=%ProgramFiles%\AnyDesk\AnyDesk.exe"

if exist "%AnyDesk1%" start "" "%AnyDesk1%"
if exist "%AnyDesk2%" start "" "%AnyDesk2%"

exit /b


:: ================================
:: STOP ANYDESK
:: ================================
:stop_any
echo Stopping AnyDesk service...

:: If already stopped
sc query AnyDesk | find "STOPPED" >nul
if %errorlevel%==0 goto kill_proc

sc stop AnyDesk >nul 2>&1

:: Waits until it stops
set count=0
:wait_stop
sc query AnyDesk | find "STOPPED" >nul
if %errorlevel%==0 goto kill_proc

timeout /t 1 >nul
set /a count+=1
if %count% lss 15 goto wait_stop

echo Service did not respond correctly.
:kill_proc
taskkill /f /im "AnyDesk.exe" >nul 2>&1
exit /b