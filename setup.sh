#!/bin/bash
# LegalMind Quick Start Script
# Automates setup of both frontend and backend

set -e

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║       🏛️  LegalMind - Quick Start Setup Script            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Check Prerequisites
echo -e "${BLUE}[1/6] Checking Prerequisites...${NC}"

check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}✗ $1 is not installed${NC}"
        return 1
    else
        echo -e "${GREEN}✓ $1 is installed${NC}"
        return 0
    fi
}

echo "Checking Python..."
if ! check_command python3; then
    if ! check_command python; then
        echo -e "${RED}Python is not installed. Please install Python 3.9+${NC}"
        exit 1
    fi
    PYTHON_CMD="python"
else
    PYTHON_CMD="python3"
fi

echo "Checking Node.js..."
check_command node || (echo -e "${RED}Node.js is not installed. Please install Node.js 18+${NC}" && exit 1)

echo "Checking npm..."
check_command npm || (echo -e "${RED}npm is not installed${NC}" && exit 1)

echo ""

# Step 2: Setup Backend
echo -e "${BLUE}[2/6] Setting up Backend...${NC}"

cd legalmind-backend

echo "Creating Python virtual environment..."
$PYTHON_CMD -m venv venv

if [ "$OSTYPE" == "msys" ] || [ "$OSTYPE" == "cygwin" ]; then
    # Windows
    source venv/Scripts/activate
else
    # Unix/Mac
    source venv/bin/activate
fi

echo "Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo -e "${GREEN}✓ Backend setup complete${NC}"
echo ""

# Step 3: Create Backend .env
echo -e "${BLUE}[3/6] Creating Backend Environment Variables...${NC}"

if [ -f .env ]; then
    echo -e "${YELLOW}⚠ .env already exists, skipping...${NC}"
else
    cat > .env << 'EOF'
# HuggingFace API (for embeddings) - Get from https://huggingface.co/settings/tokens
HF_TOKEN=hf_YOUR_TOKEN_HERE
HUGGINGFACE_API_TOKEN=hf_YOUR_TOKEN_HERE

# OpenRouter API (for Chatbot) - Get from https://openrouter.ai/keys
OPENAI_API_KEY=sk-or-v1-YOUR_KEY_HERE
OPENAI_API_BASE=https://openrouter.ai/api/v1
LLM_MODEL=kwaipilot/kat-coder-pro:free

# Supabase Configuration - Get from https://supabase.com/dashboard
VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
VITE_SUPABASE_ANON_KEY=YOUR_ANON_KEY_HERE
EOF
    echo -e "${YELLOW}Created .env - Please fill in your API keys${NC}"
fi

cd ..
echo ""

# Step 4: Setup Frontend
echo -e "${BLUE}[4/6] Setting up Frontend...${NC}"

cd legalmind-project

echo "Installing Node dependencies..."
npm install

echo -e "${GREEN}✓ Frontend setup complete${NC}"
echo ""

# Step 5: Create Frontend .env
echo -e "${BLUE}[5/6] Creating Frontend Environment Variables...${NC}"

if [ -f .env ]; then
    echo -e "${YELLOW}⚠ .env already exists, skipping...${NC}"
else
    cat > .env << 'EOF'
# Supabase Configuration
VITE_SUPABASE_PROJECT_ID=YOUR_PROJECT_ID
VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
VITE_SUPABASE_ANON_KEY=YOUR_ANON_KEY_HERE

# API Configuration (Optional - defaults to localhost:8000)
VITE_API_BASE_URL=http://localhost:8000
EOF
    echo -e "${YELLOW}Created .env - Please fill in your Supabase credentials${NC}"
fi

cd ..
echo ""

# Step 6: Summary
echo -e "${BLUE}[6/6] Setup Complete!${NC}"
echo ""
echo -e "${GREEN}✓ All dependencies installed${NC}"
echo -e "${GREEN}✓ Environment files created${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo "1. Update environment variables:"
echo "   - legalmind-backend/.env (Add HuggingFace and OpenRouter tokens)"
echo "   - legalmind-project/.env (Add Supabase credentials)"
echo ""
echo "2. Start the backend (in one terminal):"
echo "   cd legalmind-backend"
if [ "$OSTYPE" == "msys" ] || [ "$OSTYPE" == "cygwin" ]; then
    echo "   venv\\Scripts\\activate"
else
    echo "   source venv/bin/activate"
fi
echo "   python main.py"
echo ""
echo "3. Start the frontend (in another terminal):"
echo "   cd legalmind-project"
echo "   npm run dev"
echo ""
echo "4. Open browser to http://localhost:5173"
echo ""
echo -e "${BLUE}📚 Documentation:${NC}"
echo "   - Setup Guide: SETUP_GUIDE.md"
echo "   - Deployment: DEPLOYMENT_GUIDE.md"
echo "   - API Docs: http://localhost:8000/docs"
echo ""
echo "🚀 Happy analyzing with LegalMind!"
echo ""
