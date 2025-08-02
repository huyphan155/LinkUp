@echo off
:: for emoji
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ===== Chrome path =====
set "CHROME_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe"

:: ===== Ensure history folder exists =====
if not exist "history" mkdir "history"
set "HISTORY_FILE=history\history.txt"

:: ===== Main menu =====
cls
echo ==========================================
echo 🚀 Welcome to LinkUp 🚀
echo Your magic shortcut to work ^& study
echo ==========================================
echo.
echo 1 - Study
echo 2 - Work
set /p choice=Select config (1/2): 

if "%choice%"=="1" set "CONFIG_FILE=configs\study.txt"
if "%choice%"=="2" set "CONFIG_FILE=configs\work.txt"

if not exist "%CONFIG_FILE%" (
    echo [ERROR] Cannot find config: %CONFIG_FILE%
    pause
    exit
)

:: ===== Log session start =====
echo ==== %date% %time% - Open from %CONFIG_FILE% ==== >> "%HISTORY_FILE%"

:: ===== Read config and launch links =====
for /f "usebackq tokens=1,2* delims=|" %%A in ("%CONFIG_FILE%") do (
    set "PROFILE=%%A"
    set "URL=%%B"
    set "NAME=%%C"

    :: Skip empty and comment lines
    if not "!PROFILE!"=="" if "!PROFILE:~0,1!" NEQ "#" (
        :: Trim leading spaces
        for /f "tokens=* delims= " %%x in ("!PROFILE!") do set "PROFILE=%%x"
        for /f "tokens=* delims= " %%x in ("!URL!") do set "URL=%%x"
        for /f "tokens=* delims= " %%x in ("!NAME!") do set "NAME=%%x"

        :: Remove all spaces for empty check
        set "TMP=!NAME!"
        set "TMP=!TMP: =!"

        :: Launch Chrome with the specific profile
        start "" "%CHROME_PATH%" --profile-directory="!PROFILE!" "!URL!"

        :: Write to history: if NAME empty → log only URL
        if "!TMP!"=="" (
            echo [!PROFILE!] !URL! >> "%HISTORY_FILE%"
        ) else (
            echo [!PROFILE!] !NAME! - !URL! >> "%HISTORY_FILE%"
        )
    )
)

echo. >> "%HISTORY_FILE%"
echo.
echo ✅ All tabs ^& apps launched successfully!
pause

endlocal
exit
