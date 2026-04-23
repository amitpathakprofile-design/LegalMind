# Chat History Fix - Using AuthContext

## Problem
Chat history was **not saving** (0 rows in Supabase) because:
1. ❌ Trying to extract `user_id` from `localStorage` manually
2. ❌ localStorage key format might be different
3. ❌ Auth token might not exist
4. ❌ User might not be logged in when component loads

## Solution
**Use React's `AuthContext` hook** which properly provides the authenticated user:

```typescript
const { user } = useAuth();  // Gets authenticated user object
```

## Changes Made

### File: `legalmind-frontend/src/pages/Chat.tsx`

#### 1. Import AuthContext
```typescript
import { useAuth } from "@/contexts/AuthContext";
```

#### 2. Use user from AuthContext
```typescript
const Chat = () => {
  const { user } = useAuth();  // ✅ Properly authenticated user
  // ... rest of component
```

#### 3. Load chat history using user.id
```typescript
// OLD (broken):
const userStr = localStorage.getItem("sb-auth-token");
const authData = JSON.parse(userStr);
const userId = authData?.user?.id;  // ❌ Fragile parsing

// NEW (working):
if (user?.id) {
  const supabaseHistory = await getChatHistory(user.id, documentId);  // ✅
}
```

#### 4. Save chat history using user.id
```typescript
// OLD (broken):
const userStr = localStorage.getItem("sb-auth-token");
const authData = JSON.parse(userStr);
const userId = authData?.user?.id;

// NEW (working):
if (!documentId || !user?.id || messages.length === 0) return;

const saveHistory = async () => {
  try {
    const history = messages.filter(m => !m.isReport).map(m => ({
      role: m.role,
      content: m.content,
    }));
    
    if (history.length > 0) {
      console.log(`Saving ${history.length} messages...`);
      await saveChatHistory(user.id, documentId, history);  // ✅
      console.log("✅ Chat history saved successfully");
    }
  } catch (error) {
    console.warn("Could not save chat history:", error);
  }
};
```

#### 5. Updated dependencies
```typescript
useEffect(() => {
  // ... load logic
}, [documentId, toast, user]);  // ✅ Added user to dependencies

useEffect(() => {
  // ... save logic
}, [documentId, user?.id, messages]);  // ✅ user?.id in dependencies
```

## How It Works Now

### When user opens document:
1. ✅ AuthContext provides authenticated `user` object
2. ✅ Component loads chat history for `user.id` + `documentId`
3. ✅ History appears below the report

### When user types a message:
1. ✅ Message sent to backend
2. ✅ Response received
3. ✅ Both messages saved to Supabase after 2 seconds
4. ✅ Chat history table updated with new rows

### When user reopens document:
1. ✅ Same `user.id` + `documentId` combination
2. ✅ All previous messages loaded from `chat_history` table
3. ✅ User can continue conversation

## Result

**Supabase chat_history table** should now show:
- ✅ Rows populated when user chats with document
- ✅ Each row has: user_id, document_id, role, content, message_index
- ✅ RLS policies ensure user can only see their own chat

## Test Steps

1. Open browser console (F12)
2. Go to a document
3. Type a message
4. In console you should see:
   ```
   Saving 2 messages to Supabase for document [id]
   ✅ Chat history saved successfully
   ```
5. Check Supabase Database → chat_history table
   - Should see rows with your user_id and document_id
6. Close and reopen the document
   - Your previous chat should appear!

## Debug Tips

If chat still doesn't save:
1. Open browser console (F12)
2. Look for error messages in console
3. Check Network tab → see if `/api/v1/chat/history/save` request is sent
4. Check backend logs for errors
5. Make sure you're logged in (user object should exist)

---

## Key Difference

| Old Way | New Way |
|---------|---------|
| `localStorage.getItem("sb-auth-token")` | `useAuth()` hook |
| Manual JSON parsing | Direct `user` object |
| Error prone | Reliable & type-safe |
| Fails if not logged in | Handles auth automatically |
