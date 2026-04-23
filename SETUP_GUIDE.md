# LegalMind - Setup & Configuration Guide

## ✅ Complete Setup Checklist

### 1️⃣ Frontend Setup

```bash
cd legalmind-project

# Install dependencies
npm install
# or with bun
bun install

# Verify installation
npm list react vite

# Start development server
npm run dev
# Open http://localhost:5173 in browser
```

**Frontend Features Added:**
- ✅ Password reset page (`/auth/reset-password`)
- ✅ Enhanced Chat with AI Chatbot
- ✅ Chatbot suggestion system
- ✅ Document context awareness
- ✅ Session persistence

### 2️⃣ Backend Setup

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

# Verify key packages
pip list | grep -E "fastapi|langchain|torch"

# Start backend server
python main.py
# Server runs on http://localhost:8000
```

**Backend Features Added:**
- ✅ AI Chatbot service (`ml_pipeline/chatbot.py`)
- ✅ ChatBot API endpoints (`/api/v1/chatbot/*`)
- ✅ LangChain integration for OpenRouter
- ✅ Document context in chatbot responses
- ✅ Suggestion generation system

### 3️⃣ Environment Variables

#### Frontend: `legalmind-project/.env`

```env
# Supabase Configuration (REQUIRED)
VITE_SUPABASE_PROJECT_ID=sclncfdtbjovzmemgxhh
VITE_SUPABASE_URL=https://sclncfdtbjovzmemgxhh.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjbG5jZmR0YmpvdnptZW1neGhoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU5ODIxNzUsImV4cCI6MjA4MTU1ODE3NX0.kJn49tVVfXwzRkPLgoiMCYJeqcbiqcwGK2f9TsPJSg0

# API Configuration (OPTIONAL - defaults to localhost:8000)
VITE_API_BASE_URL=http://localhost:8000
# For production: VITE_API_BASE_URL=https://api.yourdomain.com
```

#### Backend: `legalmind-backend/.env`

```env
# HuggingFace (for embeddings) - REQUIRED
HF_TOKEN=your_token_here
HUGGINGFACE_API_TOKEN=your_token_here

# OpenRouter API (for Chatbot) - REQUIRED
OPENAI_API_KEY=your_api_key_here
OPENAI_API_BASE=https://openrouter.ai/api/v1
LLM_MODEL=kwaipilot/kat-coder-pro:free

# Supabase Configuration (REQUIRED)
VITE_SUPABASE_URL=https://sclncfdtbjovzmemgxhh.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjbG5jZmR0YmpvdnptZW1neGhoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU5ODIxNzUsImV4cCI6MjA4MTU1ODE3NX0.kJn49tVVfXwzRkPLgoiMCYJeqcbiqcwGK2f9TsPJSg0
```

---

## 🎯 Testing the Setup

### Test Frontend

```bash
# 1. Navigate to http://localhost:5173
# 2. Try registering a new account
# 3. Upload a test PDF document
# 4. Wait for analysis (check console for status)
# 5. Click chat icon and start chatting
# 6. Click "Forgot Password?" to test reset page
```

### Test Backend

```bash
# In separate terminal:
cd legalmind-backend
python main.py

# Test endpoints:
curl http://localhost:8000/
# Expected: {"status": "healthy", "service": "LegalMind API"}

# Test chatbot health:
curl http://localhost:8000/api/v1/chatbot/health

# Test chatbot chat:
curl -X POST http://localhost:8000/api/v1/chatbot \
  -H "Content-Type: application/json" \
  -d '{"message": "What is a non-compete clause?"}'
```

### Test Chatbot Locally

```bash
cd legalmind-backend/ml_pipeline
python chatbot.py

# This will run demo interactions
```

---

## 🆕 New Features Overview

### 1. Password Reset Page

**Location**: `/auth/reset-password`

**Two-Step Process:**
1. User enters email → receives reset link
2. User clicks link → sets new password

**Implementation:**
- Frontend: `src/pages/PasswordReset.tsx`
- Backend: Supabase Auth handles email + token
- AuthContext: New `updatePassword()` method

**Usage:**
```tsx
// In Auth page, show "Forgot Password?" link
// Routes to /auth/reset-password
// User gets email with reset link
// Link redirects with token: /auth/reset-password?token=xxx&type=recovery
// User sets new password
```

### 2. AI Chatbot Integration

**Location**: `/chat` (general) or `/document/:id/chat` (specific)

**Components:**
- **Frontend**: Enhanced `Chat.tsx` page
- **Backend**: New `ml_pipeline/chatbot.py` service
- **API**: `/api/v1/chatbot` endpoints

**System Prompt:**
The chatbot has a comprehensive legal AI system prompt that:
- Explains legal concepts clearly
- Identifies and ranks risks
- Suggests negotiation points
- Guides through app features
- Maintains professional liability disclaimers

**Key Features:**
```typescript
// Chat with AI (no document)
await chatWithBot("What is a non-compete clause?")

// Chat with document context
await chatWithBot(
  "What are the key risks?",
  chatHistory,
  documentId
)

// Get suggestions for a document
await getChatbotSuggestions(documentId)

// Check chatbot health
await checkChatbotHealth()
```

### 3. Enhanced Chat Features

**Dashboard Chat:**
- General AI assistant mode (no document needed)
- Suggested questions loaded from backend
- Full chat history persistence
- Smooth UI with loading states

**Document-Specific Chat:**
- Risk score display
- Risk badge color coding
- Risky clauses counter
- Report download button
- Document context in responses

---

## 📦 New & Updated Dependencies

### Frontend (no changes to package.json)
- All existing dependencies compatible
- Uses existing API integration layer

### Backend (requirements.txt additions)
Already included:
- `langchain-openai` - OpenRouter integration
- `langchain-core` - Message types
- `python-dotenv` - Environment variables

All dependencies are already in `requirements.txt` ✅

---

## 🔌 API Integration Points

### Frontend → Backend

```typescript
// Old: Document-specific chat
POST /api/v1/chat
{
  "document_id": "uuid",
  "message": "...",
  "chat_history": [...]
}

// New: General chatbot
POST /api/v1/chatbot
{
  "message": "...",
  "chat_history": [...],
  "document_id": "optional-uuid"
}

// New: Get suggestions
GET /api/v1/chatbot/suggestions?document_id=uuid

// New: Health check
GET /api/v1/chatbot/health
```

### Chatbot → OpenRouter

```python
# LangChain handles this automatically
from langchain_openai import ChatOpenAI

chat_model = ChatOpenAI(
    model="kwaipilot/kat-coder-pro:free",
    openai_api_key=API_KEY,
    openai_api_base="https://openrouter.ai/api/v1"
)

# Invoke with messages
response = chat_model.invoke(messages)
```

---

## 🐛 Troubleshooting

### Frontend Issues

**Port 5173 already in use:**
```bash
# Kill process and restart
npm run dev -- --port 5174
```

**Module not found errors:**
```bash
# Clear node_modules and reinstall
rm -rf node_modules
npm install
```

**Supabase auth not working:**
- Check VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY
- Verify Supabase project is active
- Check browser console for detailed errors

### Backend Issues

**ModuleNotFoundError for langchain:**
```bash
# Reinstall requirements
pip install -r requirements.txt --upgrade
```

**OpenRouter API key error:**
```bash
# Verify in .env:
# OPENAI_API_KEY=sk-or-v1-...
# OPENAI_API_BASE=https://openrouter.ai/api/v1
```

**Model preload fails:**
- First request will be slower (model loads on demand)
- Check console logs for specific error
- Verify HF_TOKEN is valid

**CORS errors:**
```
# Backend has CORS enabled for all origins
# If issues persist, check:
# 1. Backend is running on port 8000
# 2. Frontend env has correct VITE_API_BASE_URL
```

---

## 📊 Project Statistics

### Frontend
- Files: 50+ components
- Lines of Code: ~5,000+
- Dependencies: 45+
- Bundle Size: ~1.2MB (production)

### Backend
- Files: 5 modules
- Lines of Code: ~2,000+
- Dependencies: 15+
- Model Size: ~500MB (HuggingFace cache)

### Chatbot Service
- Lines: ~300+ (chatbot.py)
- System Prompt: ~300 chars
- Response Time: ~2-5 seconds
- Token Usage: ~0.001 per request (OpenRouter free tier)

---

## 🚀 Performance Tips

### Frontend
- Use lazy loading for pages: `React.lazy()`
- Implement code splitting for large components
- Cache chat history locally (already done)
- Use service workers for offline support

### Backend
- Model caching prevents repeated loading
- Async processing for file uploads
- Background task queue for large PDFs
- Consider CDN for static files

### Chatbot
- Responses cached in localStorage
- Context summarization for long conversations
- Batching multiple API calls
- Rate limiting (1 request/second recommended)

---

## 📝 Code Examples

### Use Chatbot in a Custom Component

```tsx
import { useState } from "react";
import { chatWithBot } from "@/lib/api/legalBackend";

export function MyChatbot() {
  const [messages, setMessages] = useState<any[]>([]);
  
  const handleMessage = async (text: string) => {
    const response = await chatWithBot(
      text,
      messages.map(m => ({ role: m.role, content: m.content }))
    );
    
    setMessages(prev => [...prev, 
      { role: 'user', content: text },
      { role: 'assistant', content: response.response }
    ]);
  };
  
  return <div>/* Chat UI */</div>;
}
```

### Use Password Reset in Auth

```tsx
import { useAuth } from "@/contexts/AuthContext";

export function LoginForm() {
  const { resetPassword } = useAuth();
  
  const handleForgotPassword = async (email: string) => {
    const { error } = await resetPassword(email);
    if (!error) {
      // Show success message
    }
  };
  
  return <button onClick={() => handleForgotPassword(email)}>
    Forgot Password?
  </button>;
}
```

---

## ✨ Complete Feature List

### Authentication ✅
- [x] Sign up with email/password
- [x] Login with email/password
- [x] Email confirmation
- [x] Password reset
- [x] Session persistence
- [x] Logout

### Document Analysis ✅
- [x] PDF upload (drag & drop)
- [x] Text extraction with OCR
- [x] Chunk-based processing
- [x] Risk detection (ML model)
- [x] Risk scoring
- [x] Report generation

### Chat & Assistant ✅
- [x] Document-specific chat
- [x] General chatbot
- [x] Suggested questions
- [x] Chat history persistence
- [x] LangChain integration
- [x] OpenRouter API
- [x] Context awareness

### UI/UX ✅
- [x] Responsive design
- [x] Dark mode ready
- [x] Toast notifications
- [x] Loading states
- [x] Error handling
- [x] Beautiful cards & animations

### Dashboard ✅
- [x] Document list
- [x] Risk stats
- [x] Upload progress
- [x] Quick actions
- [x] Notifications

---

## 🎓 Learning Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [React Documentation](https://react.dev/)
- [LangChain Documentation](https://python.langchain.com/)
- [OpenRouter API Docs](https://openrouter.ai/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Vite Documentation](https://vitejs.dev/)

---

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review console logs and error messages
3. Check backend FastAPI docs: `http://localhost:8000/docs`
4. Verify all environment variables are set correctly

---

## 🎉 You're Ready!

Your LegalMind setup is complete. Start by:
1. Running frontend and backend servers
2. Register a new account
3. Upload a PDF document
4. Start chatting with the AI assistant
5. Test password reset functionality

Happy legal analyzing! 🚀
