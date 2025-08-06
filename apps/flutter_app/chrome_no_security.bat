@echo off
echo ====================================
echo ULTRA SECURITY DISABLED CHROME 
echo ====================================
echo WARNING: ALL SECURITY FEATURES DISABLED!
echo Only for development testing!
echo.

REM Kill any existing Chrome processes
taskkill /F /IM chrome.exe >nul 2>&1

REM Wait a moment
timeout /t 2 /nobreak >nul

echo Starting Chrome with ALL security disabled...
start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" ^
--disable-web-security ^
--disable-features=VizDisplayCompositor ^
--user-data-dir="%TEMP%\chrome_no_security" ^
--allow-running-insecure-content ^
--disable-background-timer-throttling ^
--disable-backgrounding-occluded-windows ^
--disable-renderer-backgrounding ^
--disable-features=TranslateUI ^
--disable-ipc-flooding-protection ^
--no-first-run ^
--no-default-browser-check ^
--disable-default-apps ^
--disable-popup-blocking ^
--disable-prompt-on-repost ^
--no-sandbox ^
--test-type ^
--ignore-certificate-errors ^
--ignore-ssl-errors ^
--ignore-certificate-errors-spki-list ^
--ignore-certificate-errors-skip-list ^
--disable-extensions ^
--disable-plugins ^
--no-proxy-server ^
--allow-cross-origin-auth-prompt ^
--disable-site-isolation-trials ^
--disable-features=VizServiceDisplayCompositor ^
--disable-features=VizDisplayCompositor ^
http://localhost:8080/ai_test.html

echo.
echo Chrome launched with MAXIMUM security bypass!
echo You can now test the AI API without CORS issues.
echo.
pause
