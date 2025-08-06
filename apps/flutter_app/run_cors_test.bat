@echo off
echo Starting Chrome with CORS disabled for AI API testing...
echo.
echo WARNING: This disables web security - only use for testing!
echo.
start chrome --user-data-dir="C:\temp\chrome_cors_disabled" --disable-web-security --disable-features=VizDisplayCompositor --allow-running-insecure-content --disable-site-isolation-trials http://127.0.0.1:8080/ai_test.html
pause
