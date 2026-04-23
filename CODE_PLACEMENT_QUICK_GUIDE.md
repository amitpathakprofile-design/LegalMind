# Quick Code Placement Guide - Document Persistence Fix

## 🎯 Exact File Locations & Line Numbers

---

## FIX #1: Update Backend Documents Endpoint
**Location:** `legalmind-backend/main.py`  
**Find the section:** Lines 475-495

### CURRENT CODE (DELETE THIS):
```python
@app.get("/api/v1/documents")
def list_documents(authorization: Optional[str] = Header(None, alias="Authorization")):
    """
    List all processed documents for current user
    """
    # Extract user ID from token
    user_id = get_user_id_from_token(authorization)
    
    documents = []
    for job_id, job in jobs.items():
        if job["status"] == JobStatus.COMPLETED:
            # Filter by user_id if token is present
            job_user_id = job.get("result", {}).get("user_id")
            if user_id and job_user_id != user_id:
                continue  # Skip documents from other users
            
            documents.append({
                "id": job_id,
                **job["result"]
            })
    
    return {"documents": documents}
```

### PASTE THIS INSTEAD:
```python
@app.get("/api/v1/documents")
def list_documents(authorization: Optional[str] = Header(None, alias="Authorization")):
    """
    List all processed documents for current user from Supabase database
    This queries the persistent documents table instead of in-memory jobs
    """
    user_id = get_user_id_from_token(authorization)
    
    if not user_id:
        return {"documents": []}
    
    try:
        supabase_manager = get_supabase_manager()
        
        # Query Supabase documents table directly (not in-memory jobs dict)
        response = supabase_manager.client.table("documents") \
            .select("*") \
            .eq("user_id", user_id) \
            .eq("status", "completed") \
            .order("upload_date", desc=True) \
            .execute()
        
        documents = response.data if response.data else []
        
        # Rename fields for frontend compatibility
        formatted_documents = []
        for doc in documents:
            formatted_doc = dict(doc)
            # Ensure document_id field exists
            if "document_id" not in formatted_doc:
                formatted_doc["document_id"] = formatted_doc.get("id")
            # Rename risky_chunks_count to risky_chunks
            if "risky_chunks_count" in formatted_doc:
                formatted_doc["risky_chunks"] = formatted_doc["risky_chunks_count"]
            formatted_documents.append(formatted_doc)
        
        return {"documents": formatted_documents}
    
    except Exception as e:
        print(f"❌ Error listing documents from Supabase: {e}")
        return {"documents": []}
```

---

## FIX #2: Add Document Existence Check Endpoint
**Location:** `legalmind-backend/main.py`  
**Insert AFTER the `/api/v1/documents` endpoint (after line 495)**

### PASTE THIS NEW ENDPOINT:
```python

@app.get("/api/v1/document-exists/{document_id}")
def check_document_exists(document_id: str, authorization: Optional[str] = Header(None, alias="Authorization")):
    """
    Verify if document exists and belongs to current user
    Returns 404 if document deleted, doesn't exist, or belongs to another user
    """
    user_id = get_user_id_from_token(authorization)
    
    try:
        supabase_manager = get_supabase_manager()
        
        # Query Supabase to verify document exists
        response = supabase_manager.client.table("documents") \
            .select("id, user_id, status") \
            .eq("id", document_id) \
            .single() \
            .execute()
        
        if not response.data:
            print(f"⚠️  Document not found: {document_id}")
            return {"exists": False, "message": "Document not found"}
        
        doc = response.data
        
        # Verify user owns this document
        if user_id and doc.get("user_id") != user_id:
            print(f"⚠️  Unauthorized access to document: {document_id}")
            return {"exists": False, "message": "Unauthorized"}
        
        # Check if document was deleted or failed
        status = doc.get("status")
        if status in ["deleted", "failed"]:
            print(f"⚠️  Document unavailable (status={status}): {document_id}")
            return {"exists": False, "message": "Document unavailable"}
        
        return {
            "exists": True,
            "status": status,
            "message": "Document available"
        }
    
    except Exception as e:
        print(f"❌ Error checking document existence: {e}")
        return {"exists": False, "message": f"Error: {str(e)}"}
```

---

## FIX #3: Update Frontend Documents Page
**Location:** `legalmind-frontend/src/pages/Documents.tsx`  
**Find the section:** Lines 38-65 (the first useEffect)

### CURRENT CODE (REPLACE THIS PART):
```tsx
  useEffect(() => {
    const fetchDocuments = async () => {
      try {
        setLoading(true);
        const data = await getDocuments();
        setDocuments(data);
      } catch (error: any) {
        toast({
          title: "Error",
          description:
            error?.message || "Failed to load documents from analysis backend.",
          variant: "destructive",
        });
      } finally {
        setLoading(false);
      }
    };

    fetchDocuments();
  }, [toast]);
```

### PASTE THIS INSTEAD:
```tsx
  const { user, loading: authLoading } = useAuth();

  useEffect(() => {
    // Wait for auth to load before fetching documents
    if (authLoading) return;
    
    // If user not logged in, show empty list
    if (!user?.id) {
      setDocuments([]);
      setLoading(false);
      return;
    }

    const fetchDocuments = async () => {
      try {
        setLoading(true);
        const data = await getDocuments();
        
        // Validate each document still exists (handles deleted documents)
        const validDocuments = [];
        for (const doc of data) {
          try {
            const exists = await checkDocumentExists(doc.document_id || doc.id);
            if (exists) {
              validDocuments.push(doc);
            }
          } catch (error) {
            console.warn(`Could not verify document ${doc.id}, excluding from list`);
          }
        }
        
        setDocuments(validDocuments);
      } catch (error: any) {
        toast({
          title: "Error",
          description:
            error?.message || "Failed to load documents from analysis backend.",
          variant: "destructive",
        });
      } finally {
        setLoading(false);
      }
    };

    fetchDocuments();
  }, [user?.id, authLoading, toast]);
```

---

## FIX #4: Add Document Existence Check to API
**Location:** `legalmind-frontend/src/lib/api/legalBackend.ts`  
**Insert AFTER the `getDocuments()` function (around line 180)**

### PASTE THIS NEW FUNCTION:
```typescript

export async function checkDocumentExists(
  documentId: string
): Promise<boolean> {
  /**
   * Verify if document still exists and belongs to current user
   * Returns false if: document deleted, not found, or user unauthorized
   */
  try {
    const headers = await getAuthHeaders();
    const response = await fetch(
      `${API_BASE_URL}/api/v1/document-exists/${documentId}`,
      { headers }
    );
    const data = await handleResponse<{ exists: boolean; message: string }>(response);
    return data.exists ?? false;
  } catch (error) {
    console.error("Error checking document existence:", error);
    return false; // Assume deleted if verification fails
  }
}
```

---

## FIX #5: Add Safety Check in Chat Page
**Location:** `legalmind-frontend/src/pages/Chat.tsx`  
**Find the section:** Inside the `useEffect` that loads document details (around line 85-120)

### FIND THIS SECTION:
```tsx
  useEffect(() => {
    if (!documentId) {
      setLoadingInitial(false);
      // Load general suggestions
      getChatbotSuggestions()
        .then(setSuggestedQuestions)
        .catch(() => {
          setSuggestedQuestions([
            "What are the key risks in this contract?",
            "Explain the liability clause",
            "Is the termination clause fair?",
            "What should I negotiate?",
          ]);
        });
      return;
    }

    const load = async () => {
      try {
        setLoadingInitial(true);

        const [details, reportRes, suggestions] = await Promise.all([
          getDocumentDetails(documentId),
          getReport(documentId),
          getChatbotSuggestions(documentId),
        ]);
```

### PASTE THIS BEFORE THE `[details, reportRes, suggestions]` line:
```tsx
  useEffect(() => {
    if (!documentId) {
      setLoadingInitial(false);
      // Load general suggestions
      getChatbotSuggestions()
        .then(setSuggestedQuestions)
        .catch(() => {
          setSuggestedQuestions([
            "What are the key risks in this contract?",
            "Explain the liability clause",
            "Is the termination clause fair?",
            "What should I negotiate?",
          ]);
        });
      return;
    }

    const load = async () => {
      try {
        setLoadingInitial(true);

        // SAFETY CHECK: Verify document still exists before loading
        const exists = await checkDocumentExists(documentId);
        if (!exists) {
          toast({
            title: "Document Not Found",
            description: "This document no longer exists or has been deleted. Redirecting to documents...",
            variant: "destructive",
          });
          navigate("/documents");
          return;
        }

        const [details, reportRes, suggestions] = await Promise.all([
          getDocumentDetails(documentId),
          getReport(documentId),
          getChatbotSuggestions(documentId),
        ]);
```

### Also add import at the TOP of Chat.tsx:
Find this import section:
```tsx
import {
  getDocumentDetails,
  getReport,
  chatWithDocument,
  chatWithBot,
  getChatbotSuggestions,
  saveChatHistory,
  getChatHistory,
  deleteChatHistory,
  type ChatHistoryItem,
} from "@/lib/api/legalBackend";
```

And add `checkDocumentExists` to it:
```tsx
import {
  getDocumentDetails,
  getReport,
  chatWithDocument,
  chatWithBot,
  getChatbotSuggestions,
  saveChatHistory,
  getChatHistory,
  deleteChatHistory,
  checkDocumentExists,
  type ChatHistoryItem,
} from "@/lib/api/legalBackend";
```

---

## ✅ Verification Checklist

After pasting all code:

### Backend Tests
- [ ] Start backend: `python main.py`
- [ ] Open Postman or use curl to test:
  ```
  GET /api/v1/documents
  Header: Authorization: Bearer <your_token>
  ```
  Should return documents from Supabase, not in-memory
  
- [ ] Test document check:
  ```
  GET /api/v1/document-exists/fake-doc-id
  Header: Authorization: Bearer <your_token>
  ```
  Should return `{"exists": false}`

### Frontend Tests
- [ ] Run: `npm run dev` in `legalmind-frontend/`
- [ ] Sign in with your account
- [ ] Go to /documents - should load your documents from Supabase
- [ ] Manually delete a document in Supabase
- [ ] Refresh page - deleted doc should disappear
- [ ] Try to access deleted doc by URL - should show error & redirect

### Production Deployment
```bash
# Backend (HF Spaces or server)
- Push changes to repository
- Restart backend service
- Test endpoints

# Frontend (Vercel)
npm run build
npm run preview  # Test locally first
# Then deploy to Vercel
```

---

## Common Issues & Fixes

| Issue | Solution |
|-------|----------|
| "No documents loading" | Check: user_id is in auth token, Supabase table has data |
| 401 Unauthorized errors | Ensure auth headers are sent with request |
| Documents still show after delete | Clear browser cache, restart backend |
| Import errors | Make sure you added `checkDocumentExists` to imports |
| Types not matching | Verify field names: `document_id` vs `id` |

---

## Testing with Different Users

1. **User A Signs Up**
   - Uploads document
   - Sees it in /documents ✅

2. **User A Signs Out, User B Signs In**
   - User B sees EMPTY dashboard ✅

3. **User B Uploads Document**
   - Both users now have 1 document each

4. **Admin Deletes User A's Doc in Supabase**
   - User A refreshes, doc is gone ✅
   - User B still sees theirs ✅

---

## Need Help?

Check the detailed analysis in `DOCUMENT_PERSISTENCE_FIX.md` for:
- Architecture diagrams
- Flow charts
- Detailed explanations of each fix
- Why the current system doesn't work
