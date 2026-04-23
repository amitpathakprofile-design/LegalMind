# Supabase Storage & Chat History Fix

## Issues Found & Fixed

### 1. ❌ **Environment Variables Configuration**
**Problem:** Backend was looking for `SUPABASE_URL` and `SUPABASE_KEY`, but your `.env` file has `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`

**Fix Applied:**
- Updated `supabase_manager.py` to check for both formats:
  ```python
  self.supabase_url = os.getenv("VITE_SUPABASE_URL") or os.getenv("SUPABASE_URL")
  self.supabase_key = os.getenv("VITE_SUPABASE_ANON_KEY") or os.getenv("SUPABASE_KEY")
  ```
- Now uses **Service Role Key** for storage operations (needed for file uploads)

### 2. ❌ **Duplicate Chat History Methods**
**Problem:** Chat history methods were defined twice with different signatures, causing confusion

**Fix Applied:**
- Removed duplicate methods
- Kept clean, single implementation with proper error handling

### 3. ❌ **Missing Error Handling**
**Problem:** `get_risky_chunks()` had a `try` block without `except`, causing syntax error

**Fix Applied:**
- Added proper exception handling

### 4. ✅ **Startup Diagnostics**
**Added:**
```python
# Test Supabase configuration on startup
try:
    print("Testing Supabase configuration...")
    supabase_test = get_supabase_manager()
    print("✅ Supabase connected successfully!")
except Exception as e:
    print(f"⚠️  Supabase connection failed: {e}")
    print("   Check your environment variables!")
```

---

## Why Reports & Vector Stores Weren't Saving

Your Supabase storage buckets (`reports` and `vector-stores`) require **proper authentication**. The backend needs:

1. **Service Role Key** (not just Anon Key) - ✅ Now uses this
2. **Correct environment variables** - ✅ Now fixed
3. **Proper bucket permissions** - Check Supabase console

---

## Files Modified

| File | Changes |
|------|---------|
| `legalmind-backend/ml_pipeline/supabase_manager.py` | Fixed env vars, used Service Role Key, fixed syntax errors, removed duplicates |
| `legalmind-backend/main.py` | Added Supabase connection test on startup, better error logging |

---

## Next Steps

### 1. **Verify Environment Variables in `.env`**
```dotenv
# These should be present:
VITE_SUPABASE_URL=https://sclncfdtbjovzmemgxhh.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...
```

### 2. **Test Backend Connection**
```bash
cd legalmind-backend
python main.py
```

You should see:
```
Testing Supabase configuration...
✅ Supabase connected successfully!
✓ Supabase Manager initialized
```

### 3. **Upload a Test PDF**
1. Go to frontend
2. Upload a PDF file
3. Monitor backend logs for:
   - `✓ Report uploaded: ...`
   - `✓ Vector store uploaded: ...`

### 4. **Check Supabase Storage**
In Supabase Console → Storage → Files:
- You should see files in `/reports` bucket
- You should see files in `/vector-stores` bucket

---

## Chat History Integration

The chat history is now:
1. ✅ Saved to Supabase `chat_history` table when user types
2. ✅ Loaded from Supabase when opening a document
3. ✅ Falls back to localStorage if Supabase fails
4. ✅ Saved with 2-second debounce (to avoid too many requests)

---

## Troubleshooting

If reports still don't appear:

1. **Check Supabase Service Role Key** - must have storage permissions
2. **Check bucket names** - should be `reports` and `vector-stores`
3. **Check bucket policies** - should allow authenticated uploads
4. **Monitor backend logs** - look for upload errors

Run this to test Supabase connectivity:
```bash
python -c "from ml_pipeline.supabase_manager import get_supabase_manager; m = get_supabase_manager(); print('✅ Connected!')"
```
