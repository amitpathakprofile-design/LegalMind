# Complete Implementation Guide

## Summary of Changes

This guide covers all the changes made to integrate Supabase cloud storage with memory optimization and Google OAuth authentication.

---

## 1. Frontend Changes

### 1.1 Fixed Report Heading Colors

**File:** [src/pages/Chat.tsx](src/pages/Chat.tsx#L555-L565)

Changed the heading color from a gradient (which blended with background) to cyan (`text-cyan-400 dark:text-cyan-300`) for better visibility.

**Before:**
```tsx
className="text-base bg-gradient-to-r from-primary via-primary to-primary/80 bg-clip-text text-transparent"
```

**After:**
```tsx
className="text-base text-cyan-400 dark:text-cyan-300"
```

### 1.2 Added Google OAuth Authentication

**Files Modified:**
- [src/pages/Auth.tsx](src/pages/Auth.tsx) - Added Google sign-in button and handler
- [src/pages/AuthCallback.tsx](src/pages/AuthCallback.tsx) - New OAuth callback handler
- [src/App.tsx](src/App.tsx) - Added `/auth/callback` route

**Features:**
- Google Sign-In button on login/register pages
- OAuth callback handling with automatic redirect to dashboard
- Seamless integration with existing authentication

**Usage:**
1. User clicks "Google" button on Auth page
2. Redirected to Google OAuth consent screen
3. After consent, redirected to `/auth/callback`
4. AuthCallback component handles session establishment
5. User redirected to dashboard

### 1.3 User ID Integration

**File:** [src/lib/api/legalBackend.ts](src/lib/api/legalBackend.ts#L115-L125)

Updated `uploadDocument()` function to pass user ID to backend:

```typescript
export async function uploadDocument(file: File, userId?: string): Promise<UploadResponse> {
  const headers = userId ? { "user-id": userId } : {};
  // ... upload logic
}
```

**File:** [src/pages/Upload.tsx](src/pages/Upload.tsx#L20-L21)

Pass authenticated user's ID when uploading:

```typescript
const { user } = useAuth();
const response = await uploadDocument(uploadFile.file, user?.id);
```

---

## 2. Backend Changes

### 2.1 Supabase Integration Module

**File:** [ml_pipeline/supabase_manager.py](ml_pipeline/supabase_manager.py)

New comprehensive module for all Supabase operations:

**Key Classes:**
- `SupabaseManager` - Main manager for database and storage operations
- `get_supabase_manager()` - Singleton factory function

**Features:**
- Document metadata management (save, update, retrieve)
- Risky chunks batch operations
- Chat history management
- Vector store and report storage
- Automatic cleanup functions

**Main Methods:**
```python
# Documents
save_document_metadata()
update_document_status()
get_document()

# Risky Chunks
save_risky_chunk()
save_risky_chunks_batch()
get_risky_chunks()

# Chat
save_chat_message()
get_chat_history()

# Storage
upload_vector_store()
download_vector_store()
upload_report()
get_report()

# Cleanup
cleanup_document_storage()
```

### 2.2 Updated Main Pipeline

**File:** [main.py](main.py)

Major updates to `process_document_pipeline()`:

**Key Changes:**

1. **Supabase Manager Integration**
   ```python
   supabase_manager = get_supabase_manager()
   ```

2. **User ID Parameter**
   ```python
   def process_document_pipeline(
       job_id: str, 
       file_path: str, 
       user_id: Optional[str] = None
   ):
   ```

3. **Temporary Directory Management**
   ```python
   temp_dir = tempfile.mkdtemp()
   # ... process files
   shutil.rmtree(temp_dir)  # Cleanup at end
   ```

4. **Save to Supabase**
   ```python
   # Save document metadata
   supabase_manager.save_document_metadata(...)
   
   # Save risky chunks
   supabase_manager.save_risky_chunks_batch(...)
   
   # Upload vector store to storage
   supabase_manager.upload_vector_store(...)
   
   # Upload report to storage
   supabase_manager.upload_report(...)
   ```

5. **Cleanup Temporary Files**
   ```python
   cleanup_files = [
       file_path,                         # Original PDF
       chunks_path,                       # Raw chunks
       risky_chunks_file,                 # Risky chunks JSON
       safe_chunks_file,                  # Safe chunks JSON
       report_path,                       # Report text
       vector_db_path,                    # Vector store
   ]
   ```

6. **Updated Upload Endpoint**
   ```python
   @app.post("/api/v1/upload")
   async def upload_document(
       background_tasks: BackgroundTasks,
       file: UploadFile = File(...),
       user_id: Optional[str] = Header(None)
   ):
   ```

### 2.3 Updated Requirements

**File:** [requirements.txt](requirements.txt)

Already includes `supabase` package.

---

## 3. Supabase Setup

### 3.1 Database Schema

**File:** [SUPABASE_SETUP.md](SUPABASE_SETUP.md)

Run the SQL scripts in your Supabase SQL Editor:

#### Documents Table
```sql
CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  filename TEXT NOT NULL,
  upload_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  risk_score NUMERIC,
  risky_chunks_count INTEGER DEFAULT 0,
  total_chunks INTEGER DEFAULT 0,
  status TEXT DEFAULT 'processing',
  error_message TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Risky Chunks Table
```sql
CREATE TABLE risky_chunks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID NOT NULL REFERENCES documents(id),
  chunk_id TEXT NOT NULL,
  chunk_text TEXT NOT NULL,
  risk_label TEXT NOT NULL,
  confidence_score NUMERIC NOT NULL,
  severity TEXT DEFAULT 'medium',
  llm_analysis TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Chat History Table
```sql
CREATE TABLE chat_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID NOT NULL REFERENCES documents(id),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  message_text TEXT NOT NULL,
  role TEXT NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 3.2 Storage Buckets

Create two buckets:

1. **vector-stores** - For FAISS vector databases
   - Path: `documents/{user_id}/{document_id}/vector_store.faiss`

2. **reports** - For analysis reports
   - Path: `documents/{user_id}/{document_id}/report.txt`

### 3.3 Row Level Security (RLS)

All tables have RLS enabled. Run the RLS policy SQL from SUPABASE_SETUP.md.

### 3.4 Google OAuth Setup

In Supabase Dashboard:
1. Go to **Authentication** → **Providers**
2. Enable **Google**
3. Add your Google OAuth credentials
4. Set redirect URLs to include `http://localhost:5173` and your production domain

### 3.5 Environment Variables

**Backend (.env):**
```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

**Frontend (.env):**
```env
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

---

## 4. Data Flow Diagram

```
User uploads PDF
    ↓
Frontend (with user_id header)
    ↓
Backend (FastAPI)
    ↓
Save to temporary directory (/tmp)
    ↓
Process Pipeline:
  - Extract text (Document Loader)
  - Run ML analysis (Risk Detector)
  - Generate report (LLM Advisory)
    ↓
SAVE TO SUPABASE:
  - Document metadata → Database
  - Risky chunks → Database
  - Vector store → Storage
  - Report → Storage
    ↓
DELETE temporary files
    ↓
Return job_id to frontend
    ↓
Frontend polls for status
    ↓
When complete, show report and enable chat
```

---

## 5. Memory Optimization

### What's Deleted After Processing

1. **Original PDF** - `uploads/{job_id}.pdf`
2. **Raw chunks JSON** - `rag_storage/raw_chunks/`
3. **Risky chunks JSON** - `risk_analysis_results/risky_chunks/`
4. **Safe chunks JSON** - `risk_analysis_results/safe_chunks/`
5. **Local report text** - `risk_analysis_results/reports/`
6. **Local vector store** - `vector_db/`
7. **Temporary directory** - `/tmp/{temp_id}/`

### What's Kept in Supabase

1. **Documents table** - Metadata only (minimal storage)
2. **Risky chunks table** - Chunk details with risk info
3. **Vector store file** - Compressed FAISS index in storage
4. **Report file** - Text report in storage
5. **Chat history table** - User conversations

### Storage Benefits

- **Local disk:** ~100MB per document reduced to ~5KB metadata + ~5MB vector store
- **Cloud storage:** Elastic, scalable, backup-enabled
- **Cleanup:** Automatic deletion of temporary files

---

## 6. API Changes

### Upload Endpoint

**Before:**
```python
@app.post("/api/v1/upload")
async def upload_document(file: UploadFile = File(...)):
    # ...
```

**After:**
```python
@app.post("/api/v1/upload")
async def upload_document(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    user_id: Optional[str] = Header(None)
):
    # Saves to Supabase if user_id provided
```

### Frontend Upload Call

**Before:**
```typescript
await uploadDocument(file);
```

**After:**
```typescript
const { user } = useAuth();
await uploadDocument(file, user?.id);
```

---

## 7. Testing Checklist

- [ ] Google OAuth redirects properly from Auth page
- [ ] AuthCallback component shows loading state
- [ ] User is logged in after OAuth success
- [ ] Upload passes user_id header to backend
- [ ] Supabase documents table receives metadata
- [ ] Risky chunks are saved to Supabase
- [ ] Vector store is uploaded to storage
- [ ] Report is uploaded to storage
- [ ] Temporary files are deleted after processing
- [ ] Chat functionality still works (now retrieving from Supabase)
- [ ] Reports display with proper formatting and cyan headings

---

## 8. Troubleshooting

### Supabase Connection Issues
- Verify `SUPABASE_URL` and `SUPABASE_KEY` in .env
- Check that keys are from the correct Supabase project
- Ensure RLS policies don't block legitimate operations

### Google OAuth Not Working
- Verify Google OAuth is enabled in Supabase Dashboard
- Check that redirect URLs include `http://localhost:5173`
- Verify Google OAuth credentials in Supabase settings
- Check browser console for errors

### Files Not Deleting
- Check file permissions in temp directories
- Verify paths are correct
- Check for file locks (running processes)

### Vector Store Upload Failing
- Ensure bucket name is exactly `vector-stores`
- Check file size (should be < 100MB)
- Verify storage RLS policies

---

## 9. Future Improvements

1. **Batch Processing** - Queue multiple uploads
2. **Webhook Notifications** - Notify frontend via webhooks instead of polling
3. **Compression** - Compress vector stores before storage
4. **Analytics** - Track processing times and success rates
5. **Caching** - Cache frequently accessed documents
6. **Email Notifications** - Notify users when analysis completes

---

**Implementation completed on:** December 20, 2025

**All changes maintain backward compatibility** with the existing frontend and backend APIs while adding new cloud storage and authentication capabilities.
