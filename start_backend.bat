@echo off
setlocal enabledelayedexpansion

echo [1/4] Activating virtual environment...
call backend\venv\Scripts\activate

echo [2/4] Starting Flask API in a new terminal...
start "Flask Server" cmd /k "backend\venv\Scripts\activate && python backend\main.py"

echo [3/4] Starting Cloudflare Tunnel and logging to cf.log...
start "Cloudflare Tunnel" cmd /c "backend\venv\Scripts\activate && cloudflared tunnel --url http://localhost:5000 --loglevel info > cf.log"

:: Wait for tunnel to initialize
echo Waiting for tunnel URL...
:wait_loop
timeout /t 15 > nul
findstr /c:"trycloudflare.com" cf.log > nul
if %errorlevel% neq 0 goto wait_loop

:: Extract the URL from JSON log
set "PUBLIC_URL="
for /f "tokens=*" %%i in ('findstr /c:"https://*.trycloudflare.com" cf.log') do (
    set "line=%%i"
    setlocal enabledelayedexpansion
    for /f "tokens=2 delims=:" %%a in ("!line!") do (
        set "maybe_url=%%a"
        set "maybe_url=!maybe_url:~1,-1!"  :: Remove quotes and trailing space
        set "PUBLIC_URL=!maybe_url!"
    )
    endlocal
)

:: Write to .env file
if defined PUBLIC_URL (
    echo PUBLIC_URL=%PUBLIC_URL% > .env
    echo [4/4] ✅ Tunnel URL saved to .env: %PUBLIC_URL%
) else (
    echo ❌ Failed to extract tunnel URL.
)

endlocal