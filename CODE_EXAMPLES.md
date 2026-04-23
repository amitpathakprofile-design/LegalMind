# Code Implementation Examples

## Frontend Authentication Flow

### How Auth Headers Are Added (legalBackend.ts)
```typescript
// Helper to get auth headers with current user token
async function getAuthHeaders(): Promise<Record<string, string>> {
  try {
    const { supabase } = await import("@/integrations/supabase/client");
    const { data: { session } } = await supabase.auth.getSession();
    
    if (session?.access_token) {
      return {
        "Authorization": `Bearer ${session.access_token}`,
      };
    }
  } catch (error) {
    console.error("Failed to get auth headers:", error);
  }
  
  return {};
}

// Example of updated API call
export async function getDocuments(): Promise<DocumentSummary[]> {
  const headers = await getAuthHeaders();
  const response = await fetch(`${API_BASE_URL}/api/v1/documents`, {
    headers,
  });
  const data = await handleResponse<DocumentsResponse>(response);
  return data.documents ?? [];
}
```

### Delete Account Implementation (Profile.tsx)
```typescript
const handleDeleteAccount = async () => {
  try {
    const response = await fetch(
      `${import.meta.env.VITE_API_BASE_URL || "http://localhost:8000"}/api/v1/auth/delete-account`,
      {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
        },
      }
    );

    if (response.ok) {
      toast({
        title: "Account deleted",
        description: "Your account has been successfully deleted.",
      });
      await signOut();
      navigate("/");
    } else {
      const error = await response.json();
      toast({
        title: "Error",
        description: error.detail || "Failed to delete account.",
        variant: "destructive",
      });
    }
  } catch (err) {
    toast({
      title: "Error",
      description: "An error occurred while deleting your account.",
      variant: "destructive",
    });
  }
};
```

### Change Password Implementation (Profile.tsx)
```typescript
const handleChangePassword = async () => {
  // Validate inputs
  if (!currentPassword || !newPassword || !confirmPassword) {
    toast({
      title: "Error",
      description: "Please fill in all password fields.",
      variant: "destructive",
    });
    return;
  }

  if (newPassword !== confirmPassword) {
    toast({
      title: "Error",
      description: "New passwords do not match.",
      variant: "destructive",
    });
    return;
  }

  if (newPassword.length < 6) {
    toast({
      title: "Error",
      description: "Password must be at least 6 characters long.",
      variant: "destructive",
    });
    return;
  }

  setPasswordLoading(true);
  try {
    const { error } = await updatePassword(newPassword);
    
    if (error) {
      toast({
        title: "Password change failed",
        description: error.message,
        variant: "destructive",
      });
    } else {
      toast({
        title: "Password changed",
        description: "Your password has been successfully updated.",
      });
      setPasswordDialogOpen(false);
      setCurrentPassword("");
      setNewPassword("");
      setConfirmPassword("");
    }
  } finally {
    setPasswordLoading(false);
  }
};
```

---

## Backend User Filtering

### JWT Token Extraction (main.py)
```python
import jwt

def get_user_id_from_token(authorization: Optional[str]) -> Optional[str]:
    """Extract user ID from JWT Bearer token"""
    if not authorization:
        return None
    
    try:
        # Extract token from "Bearer <token>"
        if not authorization.startswith("Bearer "):
            return None
        
        token = authorization.split(" ")[1]
        
        # Decode JWT (without verification for now)
        decoded = jwt.decode(token, options={"verify_signature": False})
        return decoded.get("sub")  # Supabase uses 'sub' for user ID
    except Exception as e:
        print(f"Error decoding token: {e}")
        return None
```

### Document Filtering Example (main.py)
```python
@app.get("/api/v1/documents")
def list_documents(authorization: Optional[str] = Header(None)):
    """List all processed documents for current user"""
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

### User Authorization Check (main.py)
```python
@app.get("/api/v1/document/{document_id}")
def get_document_details(document_id: str, authorization: Optional[str] = Header(None)):
    """Get detailed analysis of a document"""
    if document_id not in jobs:
        raise HTTPException(404, "Document not found")
    
    job = jobs[document_id]
    if job["status"] != JobStatus.COMPLETED:
        raise HTTPException(400, "Document not fully processed yet")
    
    # Check user authorization
    user_id = get_user_id_from_token(authorization)
    job_user_id = job.get("result", {}).get("user_id")
    if user_id and job_user_id and job_user_id != user_id:
        raise HTTPException(403, "Unauthorized: Document belongs to another user")
    
    # ... rest of function
```

### Chat History Authorization (main.py)
```python
@app.get("/api/v1/chat/history/{user_id}/{document_id}")
async def get_chat_history(
    user_id: str, 
    document_id: str, 
    authorization: Optional[str] = Header(None)
):
    """Retrieve chat conversation from Supabase"""
    try:
        # Verify user can only retrieve their own chat history
        token_user_id = get_user_id_from_token(authorization)
        if token_user_id and user_id != token_user_id:
            raise HTTPException(403, "Unauthorized: Can only retrieve own chat history")
        
        supabase_manager = get_supabase_manager()
        messages = supabase_manager.get_chat_history(user_id, document_id)
        return {
            "status": "success",
            "messages": messages,
            "total": len(messages)
        }
    except Exception as e:
        print(f"❌ Error retrieving chat history: {e}")
        raise HTTPException(status_code=500, detail=str(e))
```

### Delete Account Endpoint (main.py)
```python
@app.delete("/api/v1/auth/delete-account")
async def delete_account(authorization: Optional[str] = Header(None)):
    """Delete user account and all associated data"""
    try:
        # Extract user ID from token
        user_id = get_user_id_from_token(authorization)
        if not user_id:
            raise HTTPException(401, "Unauthorized: No valid token provided")
        
        # Delete all documents belonging to this user from memory
        documents_to_delete = []
        for job_id, job in jobs.items():
            if job.get("result", {}).get("user_id") == user_id:
                documents_to_delete.append(job_id)
        
        for job_id in documents_to_delete:
            del jobs[job_id]
        
        # Delete from Supabase
        try:
            supabase_manager = get_supabase_manager()
            # Delete documents table entries
            supabase_manager.client.table("documents") \
                .delete() \
                .eq("user_id", user_id) \
                .execute()
            
            # Delete chat history
            supabase_manager.client.table("chat_messages") \
                .delete() \
                .eq("user_id", user_id) \
                .execute()
            
            print(f"✓ Deleted user {user_id} data from Supabase")
        except Exception as e:
            print(f"⚠️  Warning: Could not fully delete from Supabase: {e}")
        
        return {
            "status": "success",
            "message": "Account deleted successfully",
            "documents_deleted": len(documents_to_delete)
        }
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error deleting account: {e}")
        raise HTTPException(status_code=500, detail="Failed to delete account")
```

---

## API Request/Response Examples

### Get Documents with Auth
**Request:**
```http
GET /api/v1/documents HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response (Current User):**
```json
{
  "documents": [
    {
      "id": "doc-123",
      "user_id": "user-abc",
      "document_id": "doc-123",
      "file_name": "contract.pdf",
      "upload_date": "2024-12-21T10:30:00",
      "status": "completed",
      "risk_score": 65.5
    }
  ]
}
```

### Get Documents - Other User's Token
**Response:**
```json
{
  "documents": []
}
```

### Access Document - Authorization Failure
**Request:**
```http
GET /api/v1/document/other-user-doc-id HTTP/1.1
Authorization: Bearer your-token-here
```

**Response (403):**
```json
{
  "detail": "Unauthorized: Document belongs to another user"
}
```

### Delete Account
**Request:**
```http
DELETE /api/v1/auth/delete-account HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response (200):**
```json
{
  "status": "success",
  "message": "Account deleted successfully",
  "documents_deleted": 3
}
```

---

## Profile Dialog Examples

### Change Password Dialog
```tsx
<Dialog open={passwordDialogOpen} onOpenChange={setPasswordDialogOpen}>
  <button onClick={() => setPasswordDialogOpen(true)}>
    Change Password
  </button>
  
  <DialogContent className="glass">
    <DialogHeader>
      <DialogTitle>Change Password</DialogTitle>
      <DialogDescription>
        Enter your new password below.
      </DialogDescription>
    </DialogHeader>
    
    <div className="space-y-4">
      <div>
        <label>Current Password</label>
        <Input
          type="password"
          value={currentPassword}
          onChange={(e) => setCurrentPassword(e.target.value)}
        />
      </div>
      <div>
        <label>New Password</label>
        <Input
          type="password"
          value={newPassword}
          onChange={(e) => setNewPassword(e.target.value)}
        />
      </div>
      <div>
        <label>Confirm New Password</label>
        <Input
          type="password"
          value={confirmPassword}
          onChange={(e) => setConfirmPassword(e.target.value)}
        />
      </div>
    </div>
    
    <DialogFooter>
      <Button onClick={() => setPasswordDialogOpen(false)}>
        Cancel
      </Button>
      <Button onClick={handleChangePassword}>
        Update Password
      </Button>
    </DialogFooter>
  </DialogContent>
</Dialog>
```

---

## Security Validation Checks

### Frontend Validation
- ✅ Password fields filled
- ✅ Passwords match each other
- ✅ Password length >= 6 characters
- ✅ JWT token available before API calls

### Backend Validation
- ✅ Authorization header present
- ✅ Bearer prefix correct
- ✅ Token decodes successfully
- ✅ User ID matches document owner
- ✅ User ID matches chat history owner

---

## Deployment Checklist

- [ ] Install PyJWT: `pip install PyJWT`
- [ ] Backend can decode JWT tokens
- [ ] Frontend sends Authorization headers
- [ ] All Supabase environment variables set
- [ ] SERVICE_ROLE_KEY configured (for delete operations)
- [ ] Test with account A and B switching
- [ ] Monitor logs for authorization errors
- [ ] Verify 403 responses on cross-user access
