@echo off
REM LegalMind Quick Start Script for Windows
REM Automates setup of both frontend and backend

setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║       ^!  LegalMind - Quick Start Setup Script            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Step 1: Check Prerequisites
echo [1/6] Checking Prerequisites...

where python >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ✗ Python is not installed. Please install Python 3.9+
    exit /b 1
) else (
    echo ✓ Python is installed
    set PYTHON_CMD=python
)

where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ✗ Node.js is not installed. Please install Node.js 18+
    exit /b 1
) else (
    echo ✓ Node.js is installed
)

where npm >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ✗ npm is not installed
    exit /b 1
) else (
    echo ✓ npm is installed
)

echo.

REM Step 2: Setup Backend
echo [2/6] Setting up Backend...

cd legalmind-backend

echo Creating Python virtual environment...
%PYTHON_CMD% -m venv venv

echo Activating virtual environment...
call venv\Scripts\activate.bat

echo Installing Python dependencies...
python -m pip install --upgrade pip
pip install -r requirements.txt

echo ✓ Backend setup complete
echo.

REM Step 3: Create Backend .env
echo [3/6] Creating Backend Environment Variables...

if exist .env (
    echo ⚠  .env already exists, skipping...
) else (
    (
        echo # HuggingFace API (for embeddings) - Get from https://huggingface.co/settings/tokens
        echo HF_TOKEN=hf_YOUR_TOKEN_HERE
        echo HUGGINGFACE_API_TOKEN=hf_YOUR_TOKEN_HERE
        echo.
        echo # OpenRouter API (for Chatbot) - Get from https://openrouter.ai/keys
        echo OPENAI_API_KEY=sk-or-v1-YOUR_KEY_HERE
        echo OPENAI_API_BASE=https://openrouter.ai/api/v1
        echo LLM_MODEL=kwaipilot/kat-coder-pro:free
        echo.
        echo # Supabase Configuration - Get from https://supabase.com/dashboard
        echo VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
        echo VITE_SUPABASE_ANON_KEY=YOUR_ANON_KEY_HERE
    ) > .env
    echo Created .env - Please fill in your API keys
)

cd ..
echo.

REM Step 4: Setup Frontend
echo [4/6] Setting up Frontend...

cd legalmind-project

echo Installing Node dependencies...
npm install

echo ✓ Frontend setup complete
echo.

REM Step 5: Create Frontend .env
echo [5/6] Creating Frontend Environment Variables...

if exist .env (
    echo ⚠  .env already exists, skipping...
) else (
    (
        echo # Supabase Configuration
        echo VITE_SUPABASE_PROJECT_ID=YOUR_PROJECT_ID
        echo VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
        echo VITE_SUPABASE_ANON_KEY=YOUR_ANON_KEY_HERE
        echo.
        echo # API Configuration (Optional - defaults to localhost:8000^)
        echo VITE_API_BASE_URL=http://localhost:8000
    ) > .env
    echo Created .env - Please fill in your Supabase credentials
)

cd ..
echo.

REM Step 6: Summary
echo [6/6] Setup Complete!
echo.
echo ✓ All dependencies installed
echo ✓ Environment files created
echo.
echo Next Steps:
echo.
echo 1. Update environment variables:
echo    - legalmind-backend\.env (Add HuggingFace and OpenRouter tokens^)
echo    - legalmind-project\.env (Add Supabase credentials^)
echo.
echo 2. Start the backend (in Command Prompt^):
echo    cd legalmind-backend
echo    venv\Scripts\activate.bat
echo    python main.py
echo.
echo 3. Start the frontend (in another Command Prompt^):
echo    cd legalmind-project
echo    npm run dev
echo.
echo 4. Open browser to http://localhost:5173
echo.
echo Documentation:
echo    - Setup Guide: SETUP_GUIDE.md
echo    - Deployment: DEPLOYMENT_GUIDE.md
echo    - API Docs: http://localhost:8000/docs
echo.
echo 🚀 Happy analyzing with LegalMind!
echo.

endlocal
