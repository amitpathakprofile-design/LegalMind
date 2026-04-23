# Quick Start Guide - Supabase Integration

## 🚀 Quick Setup (5 minutes)

### Step 1: Supabase Database Setup

1. Go to your [Supabase Dashboard](https://supabase.com/dashboard)
2. Open your project's SQL Editor
3. Copy and paste all SQL from `SUPABASE_SETUP.md`
4. Click "Run" to create tables and policies

### Step 2: Create Storage Buckets

1. Go to **Storage** → **Buckets**
2. Click **New Bucket**
3. Create bucket named: `vector-stores` (Public: NO)
4. Create bucket named: `reports` (Public: NO)

### Step 3: Enable Google OAuth

1. Go to **Authentication** → **Providers**
2. Find **Google** and click **Enable**
3. Add your Google OAuth credentials:
   - Get them from [Google Cloud Console](https://console.cloud.google.com)
   - Create OAuth 2.0 Client ID (Web Application)
4. Set Redirect URLs:
   ```
   http://localhost:5173/auth/callback
   https://yourdomain.com/auth/callback
   ```

### Step 4: Configure Environment Variables

**Backend (legalmind-backend/.env):**
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

**Frontend (legalmind-frontend/.env):**
```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_key_here
```

### Step 5: Install Dependencies

**Backend:**
```bash
pip install supabase
```

**Frontend:**
Already has `@supabase/supabase-js` in package.json

### Step 6: Test

1. Start frontend: `npm run dev`
2. Start backend: `python main.py`
3. Try Google sign-in
4. Upload a PDF document
5. Check Supabase Dashboard to see data

---

## 📊 What Gets Saved to Supabase

### Documents Table
- Document metadata (filename, risk score, status)
- User association for privacy
- Upload timestamps

### Risky Chunks Table
- Individual risky clauses found
- Risk classification and confidence
- LLM analysis if available

### Chat History Table
- User-bot conversations
- Document-specific chats
- Conversation history for training

### Vector Store (Storage)
- FAISS index for semantic search
- Allows chat to find relevant clauses
- About 5-20MB per document

### Report (Storage)
- Final analysis report
- PDF text format
- About 10-50KB per document

---

## 🧹 Memory Cleanup

After processing, these are automatically deleted:
- Original PDF file
- Temporary processing files
- Local JSON files
- Local vector store
- Temporary directories

**Only cloud copies in Supabase are kept!**

---

## ✅ Verification Checklist

After setup, verify:

- [ ] Can sign in with Google
- [ ] AuthCallback page shows briefly then redirects
- [ ] Can upload PDF files
- [ ] Documents table in Supabase has new row after upload
- [ ] Risky chunks appear in risky_chunks table
- [ ] Vector store file in `vector-stores` bucket
- [ ] Report file in `reports` bucket
- [ ] Chat works (uses vector store from storage)
- [ ] Temporary files deleted from disk

---

## 🐛 Common Issues & Fixes

### Google OAuth redirect fails
```
Solution: Update redirect URL in Google Console AND Supabase
- Google Cloud Console: https://console.cloud.google.com
- Supabase: Authentication → Providers → Google → Redirect URLs
```

### "Supabase not configured" warning
```
Solution: Check .env files have SUPABASE_URL and keys
- Backend .env in legalmind-backend/
- Frontend .env in legalmind-frontend/
```

### "No user found" on upload
```
Solution: Make sure you're logged in
- Try Google sign-in or email signup
- Check user ID is being passed to backend
```

### Vector store upload fails
```
Solution: Check bucket exists and RLS policies
- Bucket name must be exactly: vector-stores
- Check Storage → Policies in Supabase
```

---

## 📈 Performance Metrics

**Before Supabase:**
- Disk usage per document: ~100-200MB
- No backup/recovery mechanism
- Local processing only

**After Supabase:**
- Disk usage per document: ~100KB (metadata only)
- Cloud backup included
- Global accessibility
- Scalable storage

---

## 🔐 Security

All data is protected by:
- **Row Level Security (RLS)** - Users can only see their own data
- **Auth integration** - Only authenticated users can access
- **Storage policies** - Private buckets with user-scoped access
- **Encrypted HTTPS** - All data in transit encrypted

---

## 📞 Support

If you need help:
1. Check `IMPLEMENTATION_GUIDE.md` for detailed docs
2. Check `SUPABASE_SETUP.md` for database schema
3. Review error messages in browser console
4. Check backend logs for processing errors

---

**You're all set! 🎉 Start uploading documents and analyzing them with Supabase.**
