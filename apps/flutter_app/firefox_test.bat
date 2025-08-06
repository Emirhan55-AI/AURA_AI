@echo off
echo ====================================
echo FIREFOX CORS BYPASS
echo ====================================

REM Close Firefox if running
taskkill /F /IM firefox.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo Starting Firefox with security disabled...

REM Try to find Firefox in common locations
if exist "C:\Program Files\Mozilla Firefox\firefox.exe" (
    start "" "C:\Program Files\Mozilla Firefox\firefox.exe" -url "http://localhost:8080/ai_test.html" -new-instance -profile "%TEMP%\firefox_dev_profile"
) else if exist "C:\Program Files (x86)\Mozilla Firefox\firefox.exe" (
    start "" "C:\Program Files (x86)\Mozilla Firefox\firefox.exe" -url "http://localhost:8080/ai_test.html" -new-instance -profile "%TEMP%\firefox_dev_profile"  
) else (
    echo Firefox not found in standard locations
    echo Please install Firefox or update the path
    pause
    exit /b 1
)

echo Firefox launched for CORS testing!
pause
