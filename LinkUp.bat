@echo off
:: for emoji
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ===== Always run from script's folder =====
cd /d "%~dp0"

:: ===== Chrome path =====
set "CHROME_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe"

:: ===== Ensure required folders exist =====
if not exist "history" mkdir "history"
if not exist "configs" mkdir "configs"

:: ===== Paths =====
set "HISTORY_FILE=history\history.txt"
set "USAGE_FILE=history\usage_count.txt"

:: ===== List available configs =====
cls
echo ==========================================
echo      🗡️   LinkUp Adventure  🗡️
echo   Choose your path, brave traveler!
echo ==========================================
echo.
set "i=0"
for %%F in (configs\*.txt) do (
    set /a i+=1
    set "CFG_!i!=%%F"
    echo !i! - %%~nF
)
echo.
set /p choice=Select config number: 

:: ===== Validate choice =====
for /f "delims=0123456789" %%x in ("!choice!") do (
    echo [ERROR] Please enter a number from the menu.
    pause
    exit /b
)

:: ===== Get selected config =====
set "CONFIG_FILE="
for /l %%n in (1,1,%i%) do (
    if /i "!choice!"=="%%n" set "CONFIG_FILE=!CFG_%%n!"
)
if "!CONFIG_FILE!"=="" (
    echo [ERROR] Invalid choice number.
    pause
    exit /b
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

        :: Update usage count
        call :UPDATE_USAGE "!URL!"

        :: Write to history
        if "!TMP!"=="" (
            echo [!PROFILE!] !URL! >> "%HISTORY_FILE%"
        ) else (
            echo [!PROFILE!] !NAME! - !URL! >> "%HISTORY_FILE%"
        )
    )
)

echo. >> "%HISTORY_FILE%"

:: ===== Pomodoro Mode =====
echo.
set /p OPEN_POMODORO=📅 Do you want to start Pomodoro Timer? (Y/N): 
if /i "!OPEN_POMODORO!"=="Y" (
    echo 🕒 Opening Pomofocus and starting timer...
    start "" "%CHROME_PATH%" --profile-directory="Default" "https://pomofocus.io"
    timeout /t 5 >nul
    powershell -Command "$wshell = New-Object -ComObject wscript.shell; $wshell.AppActivate('Pomofocus'); Start-Sleep -Milliseconds 500; $wshell.SendKeys(' ')"
)

echo.
echo ✅ All tabs ^& apps launched successfully!
pause
endlocal
exit /b


:: ===== Function: Update usage count =====
:UPDATE_USAGE
setlocal enabledelayedexpansion
set "TARGET_URL=%~1"
set "FOUND=0"

:: ===== Temp file paths =====
set "TEMP_FILE=%TEMP%\usage_tmp.txt"
set "PADDED_FILE=%TEMP%\usage_padded.txt"
set "PADDED_SORTED_FILE=%TEMP%\usage_sorted_padded.txt"
set "SORTED_FILE=%TEMP%\usage_sorted.txt"

:: Ensure usage_count.txt exists
if not exist "%~dp0%USAGE_FILE%" type nul > "%~dp0%USAGE_FILE%"

(for /f "usebackq tokens=1,2 delims=|" %%u in ("%~dp0%USAGE_FILE%") do (
    if /i "%%u"=="%TARGET_URL%" (
        set /a COUNT=%%v+1
        echo %TARGET_URL%^|!COUNT!
        set "FOUND=1"
    ) else (
        echo %%u^|%%v
    )
)) > "!TEMP_FILE!"

if "!FOUND!"=="0" (
    echo %TARGET_URL%^|1 >> "!TEMP_FILE!"
)

move /y "!TEMP_FILE!" "%~dp0%USAGE_FILE%" >nul

:: ===== Sort usage_count.txt by usage descending =====
(
for /f "tokens=1,2 delims=|" %%a in ('type "%~dp0%USAGE_FILE%"') do (
    set "NUM=000%%b"
    set "NUM=!NUM:~-3!"
    echo !NUM!^|%%a
)
) > "!PADDED_FILE!"

sort /R "!PADDED_FILE!" > "!PADDED_SORTED_FILE!"

(
for /f "tokens=1* delims=|" %%a in ('type "!PADDED_SORTED_FILE!"') do (
    echo %%b^|%%a
)
) > "!SORTED_FILE!"

move /y "!SORTED_FILE!" "%~dp0%USAGE_FILE%" >nul

:: Clean temp files
del /q "!PADDED_FILE!" >nul 2>&1
del /q "!PADDED_SORTED_FILE!" >nul 2>&1
del /q "!SORTED_FILE!" >nul 2>&1
del /q "!TEMP_FILE!" >nul 2>&1

endlocal
goto :eof
