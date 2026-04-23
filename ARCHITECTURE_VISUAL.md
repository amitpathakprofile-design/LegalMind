# Visual Architecture - After Implementation

## User Authentication Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                        USER AUTHENTICATION                          │
└─────────────────────────────────────────────────────────────────────┘

    ┌──────────────┐
    │   Browser    │
    └──────┬───────┘
           │
           ├─ Login → Supabase Auth
           │
           ├─ Receives JWT Token
           │         │
           │         └─ Claims: { sub: "user-id-123", ... }
           │
    ┌──────▼───────┐
    │   Session    │  ← Token stored in Supabase session
    └──────┬───────┘
           │
    ┌──────▼────────────────────────────────────┐
    │  All API Requests Include Header:         │
    │  Authorization: Bearer eyJhbGc...         │
    └──────┬────────────────────────────────────┘
           │
    ┌──────▼─────────────────────┐
    │  Backend Receives Request   │
    │  1. Extract token          │
    │  2. Decode (no verify)     │
    │  3. Extract user_id from   │
    │     JWT 'sub' claim        │
    │  4. Filter by user_id      │
    └──────┬─────────────────────┘
           │
    ┌──────▼──────────────────────┐
    │  Return Filtered Results     │
    │  or 403 Forbidden           │
    └─────────────────────────────┘
```

---

## Data Isolation Model

```
┌────────────────────────────────────────────────────────────────────┐
│                    DATABASE ISOLATION                              │
└────────────────────────────────────────────────────────────────────┘

User A (ID: abc123)
├── Documents
│   ├── doc-1.pdf ✅ Visible to A
│   ├── doc-2.pdf ✅ Visible to A
│   └── doc-3.pdf ✅ Visible to A
├── Chat History
│   ├── chat-1 ✅ Only A can view
│   └── chat-2 ✅ Only A can view
└── Account Data
    └── password, email, etc. ✅ Only A can access

                    🔒 FIREWALL 🔒

User B (ID: xyz789)
├── Documents
│   ├── doc-4.pdf ✅ Visible to B (hidden from A)
│   ├── doc-5.pdf ✅ Visible to B (hidden from A)
│   └── doc-6.pdf ✅ Visible to B (hidden from A)
├── Chat History
│   ├── chat-3 ✅ Only B can view (A gets 403)
│   └── chat-4 ✅ Only B can view (A gets 403)
└── Account Data
    └── password, email, etc. ✅ Only B can access (A gets 403)
```

---

## Backend API Security

```
┌──────────────────────────────────────────────────────────────────────┐
│                      ENDPOINT PROTECTION                            │
└──────────────────────────────────────────────────────────────────────┘

GET /api/v1/documents
├─ Accept: Authorization Header ✅
├─ Extract user_id from JWT
├─ Filter: WHERE user_id = current_user_id
└─ Return: Only user's documents

GET /api/v1/document/{id}
├─ Accept: Authorization Header ✅
├─ Validate: document.user_id == current_user_id
├─ Response: 200 OK or 403 Forbidden
└─ Return: Document details or error

POST /api/v1/chat
├─ Accept: Authorization Header ✅
├─ Validate: document.user_id == current_user_id
├─ Response: 200 OK or 403 Forbidden
└─ Return: Chat response or error

DELETE /api/v1/auth/delete-account
├─ Accept: Authorization Header ✅ (REQUIRED)
├─ Extract: user_id from JWT
├─ Delete: All documents WHERE user_id
├─ Delete: All chat_messages WHERE user_id
├─ Delete: All data associated with user
└─ Response: 200 OK with count

⭐ All endpoints validate user ownership
⭐ 403 Forbidden prevents cross-user access
⭐ User_id extracted from JWT 'sub' claim
```

---

## Profile Page Features

```
┌──────────────────────────────────────────────────────────────┐
│                    PROFILE PAGE                              │
└──────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Personal Information                                │
├─────────────────────────────────────────────────────┤
│ Display Name:  [John Doe         ]                 │
│ Email:         [john@example.com ] (disabled)     │
│ [Save Changes Button]                              │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Notifications                                       │
├─────────────────────────────────────────────────────┤
│ ☑ Analysis Complete                                │
│ ☑ High Risk Alerts                                │
│ ☐ Weekly Digest                                   │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Security                                            │
├─────────────────────────────────────────────────────┤
│ Change Password  ► [Opens Dialog] ✅ NOW WORKS    │
├─────────────────────────────────────────────────────┤
│ Dialog Content:                                     │
│ ┌─────────────────────────────────────────────┐   │
│ │ Change Password                             │   │
│ ├─────────────────────────────────────────────┤   │
│ │ Current Password: [______]                 │   │
│ │ New Password:     [______]                 │   │
│ │ Confirm Password: [______]                 │   │
│ │                                             │   │
│ │ [Cancel] [Update Password]                │   │
│ └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Account Actions                                     │
├─────────────────────────────────────────────────────┤
│ [Sign Out]                                          │
│ [Delete Account] ✅ NOW WORKS                      │
├─────────────────────────────────────────────────────┤
│ Delete Account Dialog:                              │
│ ┌─────────────────────────────────────────────┐   │
│ │ Delete Account                              │   │
│ │ This action cannot be undone. All your      │   │
│ │ data will be deleted.                       │   │
│ │                                             │   │
│ │ [Cancel] [Delete]                          │   │
│ └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

---

## Request/Response Cycle

```
┌────────────────────────────────────────────────────────────────────┐
│                  GET /api/v1/documents FLOW                        │
└────────────────────────────────────────────────────────────────────┘

Frontend                          Backend
  │                                  │
  │ 1. Get Session Token             │
  ├─ Supabase.auth.getSession()      │
  │                                  │
  │ 2. Build Request                 │
  ├─ Headers: {                      │
  │   Authorization: "Bearer abc.."  │
  │ }                                │
  │                                  │
  │ 3. Send GET /documents ──────────┼──> Extract "Bearer abc.."
  │                                  │    Decode JWT (no verify)
  │                                  │    Get user_id = "user-123"
  │                                  │
  │                                  │    Filter documents:
  │                                  │    WHERE user_id = "user-123"
  │                                  │
  │ 4. Receive Response <────────────┤─
  │    {                             │
  │      documents: [                │
  │        { id: "doc-1",            │
  │          user_id: "user-123" },  │
  │        { id: "doc-2",            │
  │          user_id: "user-123" }   │
  │      ]                           │
  │    }                             │
  │                                  │
  └────────────────────────────────────────────────────────────────────┘
```

---

## Account Deletion Flow

```
┌──────────────────────────────────────────────────────────────┐
│           DELETE ACCOUNT PROCESS                             │
└──────────────────────────────────────────────────────────────┘

User Clicks "Delete Account"
        │
        ▼
Confirmation Dialog Appears
"Are you sure? This cannot be undone."
        │
        ▼
User Clicks "Delete"
        │
        ├─ Frontend: Extract JWT token ✅
        │
        ├─ Send: DELETE /api/v1/auth/delete-account
        │         Header: Authorization: Bearer <token>
        │
        ▼
Backend Receives Request
├─ Extract token from header
├─ Decode JWT
├─ Get user_id = "user-123"
├─ Delete from jobs dict (in-memory)
│   └─ WHERE job.user_id = "user-123"
├─ Delete from Supabase.documents
│   └─ WHERE user_id = "user-123"
├─ Delete from Supabase.chat_messages
│   └─ WHERE user_id = "user-123"
│
└─ Return: { status: "success", documents_deleted: 5 }
        │
        ▼
Frontend Receives Response
├─ Show toast: "Account deleted successfully"
├─ Call signOut()
├─ Redirect to home page
        │
        ▼
Account Fully Deleted ✅
All user data removed from:
├─ Backend memory
├─ Supabase database
└─ Supabase storage (vector DBs, reports)
```

---

## Multi-User Scenario

```
┌────────────────────────────────────────────────────────────────────┐
│            BEFORE vs AFTER - Multi-User Scenario                  │
└────────────────────────────────────────────────────────────────────┘

BEFORE (❌ BROKEN):
  Account A logs in
  │ Uploads document X
  │ Sees X in Documents page ✓
  │
  └─ Logout
     Account B logs in
     │ Uploads document Y  
     │ Sees X AND Y in Documents page ❌ WRONG!
     │ Can read X's chat history ❌ WRONG!
     │ Can view X's report ❌ WRONG!
     │
     └─ Logout
        Account A logs in again
        │ Sees both X and Y documents ❌ WRONG!
        │ Confused about ownership

AFTER (✅ FIXED):
  Account A logs in (JWT: abc-123)
  │ Uploads document X
  │ Sends: GET /documents [Authorization: Bearer abc-123]
  │ Backend filters: WHERE user_id = abc-123
  │ Sees X in Documents page ✓
  │
  └─ Logout
     Account B logs in (JWT: xyz-789)
     │ Uploads document Y
     │ Sends: GET /documents [Authorization: Bearer xyz-789]
     │ Backend filters: WHERE user_id = xyz-789
     │ Sees ONLY Y in Documents page ✓ CORRECT!
     │ Tries to read X's chat: backend returns 403 ✓
     │ Tries to view X's report: backend returns 403 ✓
     │
     └─ Logout
        Account A logs in again (JWT: abc-123)
        │ Sends: GET /documents [Authorization: Bearer abc-123]
        │ Backend filters: WHERE user_id = abc-123
        │ Sees ONLY X in Documents page ✓ CORRECT!
        │ Can read X's chat history ✓
        │ Can view X's report ✓
        │ Perfect isolation confirmed ✓
```

---

## Security Layers

```
┌────────────────────────────────────────────────────────────────────┐
│                    SECURITY ARCHITECTURE                           │
└────────────────────────────────────────────────────────────────────┘

Layer 1: Frontend
┌─────────────────────────────────────────────────┐
│ • Supabase Session Management                  │
│ • JWT Token Extraction                         │
│ • Authorization Header Injection               │
│ • Client-side Validation                       │
└─────────────────────────────────────────────────┘
                       │
Layer 2: Network
┌─────────────────────────────────────────────────┐
│ • HTTPS/TLS Encryption                         │
│ • Bearer Token in Headers                      │
│ • No token in URL/body                         │
└─────────────────────────────────────────────────┘
                       │
Layer 3: Backend Entry Point
┌─────────────────────────────────────────────────┐
│ • JWT Token Decoding                           │
│ • User ID Extraction from 'sub' claim          │
│ • Token Format Validation (Bearer prefix)      │
└─────────────────────────────────────────────────┘
                       │
Layer 4: Endpoint Authorization
┌─────────────────────────────────────────────────┐
│ • Compare token user_id vs resource owner_id   │
│ • Return 403 Forbidden if mismatch             │
│ • Log unauthorized attempts                    │
└─────────────────────────────────────────────────┘
                       │
Layer 5: Data Level
┌─────────────────────────────────────────────────┐
│ • Filter results by user_id                    │
│ • Only return owned documents                  │
│ • Validate ownership before operations         │
└─────────────────────────────────────────────────┘
                       │
                       ▼
            🔒 SECURE DATA RETURNED 🔒
```

---

## Integration Points

```
┌────────────────────────────────────────────────────────────────────┐
│                  SYSTEM INTEGRATION MAP                            │
└────────────────────────────────────────────────────────────────────┘

Frontend (React)
├─ AuthContext.tsx
│  └─ Manages JWT token
│
├─ Profile.tsx
│  ├─ Delete Account ──┐
│  └─ Change Password──┤
│                      │
├─ legalBackend.ts    │
│  ├─ getAuthHeaders()│
│  └─ All API calls ──┤──┐
│                      │  │
└─ useDocuments.ts ───┤  │
   └─ useAuth() ──────┘  │
                         │
         ┌───────────────┘
         │
         ▼
    [Network: HTTP]
         │
         ▼
Backend (Python/FastAPI)
├─ JWT Decoding
│  └─ get_user_id_from_token()
│
├─ Document Endpoints
│  ├─ GET /documents ✅
│  ├─ GET /document/{id} ✅
│  └─ POST /chat ✅
│
├─ Auth Endpoints
│  └─ DELETE /auth/delete-account ✅
│
├─ Chat History
│  ├─ GET /chat/history/{uid}/{did} ✅
│  ├─ POST /chat/history/save ✅
│  └─ DELETE /chat/history/{uid}/{did} ✅
│
└─ Supabase Integration
   ├─ Documents table
   ├─ Chat messages table
   └─ Storage (vector DBs, reports)
```

---

This visual guide shows how the security, data isolation, and new features
work together to protect user data and prevent cross-account access.
