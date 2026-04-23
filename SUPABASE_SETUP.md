# Supabase Setup Guide

## 1. Database Tables Schema

Run these SQL commands in Supabase SQL Editor:

```sql
-- ============================================================================
-- DOCUMENTS TABLE - Metadata about uploaded documents
-- ============================================================================
CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  filename TEXT NOT NULL,
  upload_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  risk_score NUMERIC,
  risky_chunks_count INTEGER DEFAULT 0,
  total_chunks INTEGER DEFAULT 0,
  status TEXT DEFAULT 'processing' CHECK (status IN ('processing', 'completed', 'failed')),
  error_message TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX documents_user_id_idx ON documents(user_id);
CREATE INDEX documents_status_idx ON documents(status);
CREATE INDEX documents_created_at_idx ON documents(created_at DESC);

-- ============================================================================
-- RISKY_CHUNKS TABLE - Individual risky clauses detected in documents
-- ============================================================================
CREATE TABLE risky_chunks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
  chunk_id TEXT NOT NULL,
  chunk_text TEXT NOT NULL,
  risk_label TEXT NOT NULL,
  confidence_score NUMERIC NOT NULL,
  severity TEXT DEFAULT 'medium' CHECK (severity IN ('high', 'medium', 'low')),
  llm_analysis TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX risky_chunks_document_id_idx ON risky_chunks(document_id);
CREATE INDEX risky_chunks_severity_idx ON risky_chunks(severity);

-- ============================================================================
-- CHAT_HISTORY TABLE - Store user conversations with documents
-- ============================================================================
CREATE TABLE chat_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  message_text TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX chat_history_document_id_idx ON chat_history(document_id);
CREATE INDEX chat_history_user_id_idx ON chat_history(user_id);
CREATE INDEX chat_history_timestamp_idx ON chat_history(timestamp DESC);

-- ============================================================================
-- ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================================================
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE risky_chunks ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_history ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own documents
CREATE POLICY "Users can view own documents"
  ON documents FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own documents"
  ON documents FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own documents"
  ON documents FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own documents"
  ON documents FOR DELETE
  USING (auth.uid() = user_id);

-- Policy: Users can only see risky chunks from their documents
CREATE POLICY "Users can view risky chunks from own documents"
  ON risky_chunks FOR SELECT
  USING (
    document_id IN (
      SELECT id FROM documents WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert risky chunks to own documents"
  ON risky_chunks FOR INSERT
  WITH CHECK (
    document_id IN (
      SELECT id FROM documents WHERE user_id = auth.uid()
    )
  );

-- Policy: Users can only see chat history for their documents
CREATE POLICY "Users can view own chat history"
  ON chat_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own chat history"
  ON chat_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

## 2. Storage Buckets

Create two storage buckets in Supabase:

### Bucket 1: `vector-stores`
- For FAISS vector databases (embeddings)
- Path: `documents/{document_id}/vector_store.faiss`
- Access: Private (RLS enabled)

### Bucket 2: `reports`
- For final analysis reports
- Path: `documents/{document_id}/report.txt`
- Access: Private (RLS enabled)

### Storage RLS Policies

```sql
-- For vector-stores bucket
CREATE POLICY "Users can upload to own vector stores"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'vector-stores'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can view own vector stores"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'vector-stores'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete own vector stores"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'vector-stores'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- For reports bucket (same policies)
CREATE POLICY "Users can upload to own reports"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'reports'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can view own reports"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'reports'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete own reports"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'reports'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );
```

## 3. Environment Variables

Add to `.env` in backend:

```env
# Supabase
SUPABASE_URL=your_supabase_project_url
SUPABASE_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

Add to frontend `.env`:

```env
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

## 4. Google OAuth Setup (Optional)

In Supabase Dashboard:
1. Go to **Authentication** → **Providers**
2. Enable **Google**
3. Add Google OAuth credentials:
   - Client ID
   - Client Secret
4. Add redirect URLs:
   - `http://localhost:5173` (development)
   - `https://yourdomain.com` (production)
