# LegalMind - Complete Deployment Guide

## 📋 Project Overview

LegalMind is an AI-powered legal contract analysis platform with:
- **Frontend**: React + TypeScript + Vite + Tailwind CSS
- **Backend**: FastAPI + Python with ML Pipeline
- **AI Integration**: LangChain + OpenRouter API for Chatbot
- **Database**: Supabase for Authentication & Storage
- **ML Models**: HuggingFace embeddings + Legal risk classifier

---

## 🚀 Quick Start

### Prerequisites

- Node.js >= 18 (for frontend)
- Python >= 3.9 (for backend)
- Git
- Environment variables set up

### Frontend Setup

```bash
cd legalmind-project

# Install dependencies
npm install
# or with bun
bun install

# Development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

### Backend Setup

```bash
cd legalmind-backend

# Create virtual environment
python -m venv venv

# Activate (Windows)
venv\Scripts\activate

# Activate (macOS/Linux)
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run development server
python main.py

# Production (use gunicorn/uvicorn with process manager)
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

---

## 🔑 Environment Variables

### Frontend (.env)

```env
# Supabase Configuration
VITE_SUPABASE_PROJECT_ID=sclncfdtbjovzmemgxhh
VITE_SUPABASE_URL=https://sclncfdtbjovzmemgxhh.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# API Base (optional - defaults to http://localhost:8000)
VITE_API_BASE_URL=http://localhost:8000
# For production: VITE_API_BASE_URL=https://your-api.com
```

### Backend (.env)

```env
# HuggingFace API (for embeddings)
HF_TOKEN=your_huggingface_token_here
HUGGINGFACE_API_TOKEN=your_huggingface_token_here

# OpenRouter API (for Chatbot LLM)
OPENAI_API_KEY=your_openrouter_api_key_here
OPENAI_API_BASE=https://openrouter.ai/api/v1
LLM_MODEL=kwaipilot/kat-coder-pro:free

```# Supabase Configuration
VITE_SUPABASE_URL=https://sclncfdtbjovzmemgxhh.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## 🏗️ Project Structure

### Frontend (legalmind-project/)

```
src/
├── pages/              # Route pages
│   ├── Auth.tsx        # Login/Register
│   ├── PasswordReset.tsx # Password reset page ✨ NEW
│   ├── Dashboard.tsx   # Main dashboard
│   ├── Documents.tsx   # Document list
│   ├── Chat.tsx        # AI Chat interface ✨ ENHANCED
│   ├── Upload.tsx      # Document upload
│   └── Profile.tsx     # User profile
├── components/         # Reusable components
│   ├── Layout.tsx      # Main layout
│   ├── ProtectedRoute.tsx
│   └── ui/             # shadcn UI components
├── contexts/          # React contexts
│   └── AuthContext.tsx # Auth state management
├── lib/
│   ├── api/
│   │   └── legalBackend.ts # Backend API calls ✨ ENHANCED
│   └── validations/
│       └── auth.ts    # Zod schemas
└── main.tsx
```

### Backend (legalmind-backend/)

```
├── main.py                 # FastAPI application ✨ UPDATED
├── requirements.txt        # Python dependencies ✨ UPDATED
├── ml_pipeline/
│   ├── Document_loader.py # PDF processing
│   ├── risk_detector.py   # Risk classification
│   ├── LLM_advisory.py    # Report generation
│   └── chatbot.py         # AI Chatbot ✨ NEW
├── uploads/              # Temporary file storage
├── vector_db/            # FAISS vector stores
├── rag_storage/          # RAG chunks
└── risk_analysis_results/ # Analysis output
```

---

## 🔄 API Endpoints

### Authentication (Supabase)

```
POST   /auth/signup           - Register new user
POST   /auth/signin           - Login user
GET    /auth/reset-password   - Password reset
POST   /auth/update-password  - Update password
```

### Document Analysis

```
POST   /api/v1/upload                    - Upload PDF
GET    /api/v1/job/{job_id}             - Check processing status
GET    /api/v1/documents                - List all documents
GET    /api/v1/document/{document_id}   - Get document details
GET    /api/v1/report/{document_id}     - Download report
```

### Chat & Assistant

```
POST   /api/v1/chat                      - Chat about specific document
POST   /api/v1/chatbot                   - Chat with AI assistant ✨ NEW
GET    /api/v1/chatbot/suggestions      - Get suggested questions ✨ NEW
GET    /api/v1/chatbot/health           - Check chatbot status ✨ NEW
```

---

## 🤖 Chatbot Features

The LegalMind AI Assistant uses **LangChain + OpenRouter API**:

### Capabilities:
- 💬 Contract clause analysis and explanation
- 🎯 Risk identification and negotiation suggestions
- 📚 App feature guidance
- 🔍 Document-aware conversations
- 💡 Smart suggestions for user questions

### System Prompt:
The chatbot is configured with a comprehensive legal AI system prompt that:
- Explains contract clauses in simple language
- Identifies potential risks and severity levels
- Provides negotiation recommendations
- Guides users through LegalMind features
- Reminds users to consult professional lawyers

### Usage:
```typescript
// General chat (no document context)
const response = await chatWithBot("What is a non-compete clause?");

// Document-specific chat
const response = await chatWithBot(
  "What are the key risks?",
  chatHistory,
  documentId
);

// Get suggestions
const suggestions = await getChatbotSuggestions(documentId);
```

---

## 📄 Password Reset Flow

### New PasswordReset Page (`src/pages/PasswordReset.tsx`)

**Two-step process:**

1. **Request Reset**: User enters email
   - Supabase sends password reset link
   - User receives email with reset token

2. **Update Password**: User clicks link and sets new password
   - Validates password strength (min 8 chars)
   - Confirms password match
   - Updates via Supabase Auth

**Routes:**
- `/auth/reset-password` - Main reset page
- Query params: `?token=xxx&type=recovery` - Auto-fill for update step

**AuthContext Methods:**
- `resetPassword(email)` - Request reset link
- `updatePassword(password)` - Set new password

---

## 🏭 ML Pipeline

### 3-Stage Processing:

```
1. Document Ingestion
   └─ PDF text extraction → Chunking → Embeddings → FAISS Index

2. Risk Detection
   └─ Ensemble classifier → Risk scoring → Chunk categorization

3. LLM Advisory
   └─ Report generation → RAG setup → Chat enabled
```

### Model Cache:
- Risk detection model pre-loaded on startup
- Singleton pattern prevents memory overhead
- Lazy loading fallback if pre-load fails

---

## 📦 Building for Production

### Frontend Build

```bash
cd legalmind-project

# Build optimized bundle
npm run build

# Output: dist/

# Deploy to Vercel/Netlify/Static host
# Just upload dist/ folder
```

### Backend Deployment

**Using Gunicorn + Uvicorn:**
```bash
pip install gunicorn
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

**Docker:**
```dockerfile
FROM python:3.11
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Docker Compose:**
```yaml
version: '3.8'
services:
  backend:
    build: ./legalmind-backend
    ports:
      - "8000:8000"
    environment:
      - HF_TOKEN=${HF_TOKEN}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - OPENAI_API_BASE=${OPENAI_API_BASE}
    volumes:
      - ./legalmind-backend/uploads:/app/uploads
      - ./legalmind-backend/vector_db:/app/vector_db

  frontend:
    build: ./legalmind-project
    ports:
      - "3000:3000"
    environment:
      - VITE_API_BASE_URL=http://localhost:8000
```

---

## 🔒 Security Checklist

- [ ] Change default API keys before production
- [ ] Enable HTTPS for all endpoints
- [ ] Set CORS properly (not `allow_origins=["*"]`)
- [ ] Use environment variables for all secrets
- [ ] Implement rate limiting
- [ ] Add request validation
- [ ] Enable Supabase RLS policies
- [ ] Use CSRF tokens if needed
- [ ] Implement file upload validation
- [ ] Monitor API usage and costs

### CORS Configuration (Production)
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://yourdomain.com"],  # Specific domain
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)
```

---

## 🚀 Deployment Platforms

### Frontend
- **Vercel**: Recommended for Vite + React
  ```bash
  npm install -g vercel
  vercel
  ```
- **Netlify**: Drag & drop `dist/` folder
- **GitHub Pages**: Configure base URL in vite.config.ts
- **AWS S3 + CloudFront**
- **Azure Static Web Apps**

### Backend
- **Railway**: Simple deployment from Git
- **Render**: Free tier available
- **Heroku**: Classic choice (requires buildpack update)
- **AWS EC2 + ECS**: For scale
- **Google Cloud Run**: Serverless option
- **DigitalOcean**: Affordable VPS

### Combined
- **Vercel + Vercel Functions** (fullstack)
- **Fly.io** (Docker container)
- **Azure App Service**

---

## 📊 Performance Optimization

### Frontend
- ✅ Code splitting (Vite automatic)
- ✅ Image optimization (use WebP)
- ✅ Minification (Vite build)
- ✅ Lazy loading (React.lazy)
- ✅ Caching strategy (localStorage for chat history)

### Backend
- ✅ Model caching (singleton pattern)
- ✅ Connection pooling
- ✅ Async processing (background tasks)
- ✅ Response compression
- ✅ Database indexing (Supabase)

---

## 🧪 Testing

### Frontend
```bash
npm install -D vitest @testing-library/react
npm run test
```

### Backend
```bash
pip install pytest pytest-asyncio
pytest
```

---

## 📞 Support & Troubleshooting

### Common Issues

**Chatbot not responding:**
- Check `OPENAI_API_KEY` is set
- Verify `OPENAI_API_BASE` points to OpenRouter
- Check backend health: `GET /api/v1/chatbot/health`

**Password reset not working:**
- Verify Supabase email configuration
- Check email redirect URL matches deployment domain
- Ensure `.env` has correct Supabase credentials

**Upload fails:**
- Check file size limit (50MB)
- Verify PDF is valid and readable
- Check disk space on backend server

**Slow performance:**
- Model loading takes time on first request
- Enable caching/CDN for frontend
- Use production database indexes
- Monitor API response times

---

## 📝 Version History

- **v1.0.0** (Current)
  - ✨ Password reset page
  - ✨ AI Chatbot with LangChain
  - ✨ Chat dashboard integration
  - ✨ Risk analysis pipeline
  - ✨ Document upload & analysis
  - ✨ Authentication with Supabase

---

## 📄 License

LegalMind © 2025. All rights reserved.

---

## 🎯 Next Steps

1. **Set up environment variables** - Copy .env files
2. **Install dependencies** - npm install & pip install
3. **Start development** - npm run dev & python main.py
4. **Test chatbot** - Upload document and chat
5. **Deploy** - Follow platform-specific guides above

Happy analyzing! 🚀
