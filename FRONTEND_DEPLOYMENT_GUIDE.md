# Frontend Deployment Guide - Vercel

## 🚀 Deployment Status: READY

### Frontend Optimizations Applied
✅ JWT token authentication on all API endpoints
✅ Delete account authorization fixed
✅ Console.log statements removed for production
✅ Build optimization with code splitting
✅ Production build configuration added
✅ Environment variables configured
✅ Vercel deployment config created
✅ TypeScript validation completed
✅ Error handling optimized

---

## 📋 Pre-Deployment Checklist

- [x] Delete account button fixed (JWT token now sent)
- [x] Change password button working
- [x] Account data isolation (user_id filtering)
- [x] Chat message accumulation fixed (backend)
- [x] Console logs removed
- [x] Environment variables configured
- [x] Build optimizations applied
- [x] No TypeScript errors
- [x] Error handling in place
- [x] CORS headers configured

---

## 🔧 Environment Variables

### Development (.env.local)
```
VITE_API_BASE_URL=http://localhost:8000
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

### Production (Vercel Dashboard)
Set these environment variables in Vercel project settings:

1. **VITE_API_BASE_URL**
   - Value: `https://your-backend-domain.com` (or HF Spaces URL)
   - Used by: All API calls

2. **VITE_SUPABASE_URL**
   - Value: Your Supabase project URL
   - Used by: Authentication & database

3. **VITE_SUPABASE_ANON_KEY**
   - Value: Your Supabase anon key
   - Used by: Public API access

---

## 📦 Build Output

### Build Command
```bash
npm run build
```

### Build Optimizations
- **Terser minification**: Removes console.log statements
- **Code splitting**: Separates vendor bundles for better caching
  - `react-vendor.js` - React core (~40KB)
  - `ui-vendor.js` - UI components (~80KB)
  - `index.js` - App code (~150KB)
- **No source maps**: Reduces build size and improves security
- **Drop console**: All console statements removed in production

### Expected Build Size
- Total bundle: ~300-400KB (gzipped: ~80-100KB)
- Loading time: <2s on 4G

---

## 🔐 API Authentication

### All Endpoints Now Protected
Every API call includes:
```typescript
headers: {
  "Authorization": `Bearer ${session.access_token}`
}
```

**Protected Endpoints:**
- POST `/api/v1/upload` - Document upload
- GET `/api/v1/documents` - User's documents only
- GET `/api/v1/document/{id}` - User's document only
- POST `/api/v1/chat/{id}` - User's chat only
- GET `/api/v1/chat/history/{user_id}/{doc_id}` - User's chat only
- POST `/api/v1/chat/history/save` - User's history only
- DELETE `/api/v1/auth/delete-account` - **User account only** ✅ FIXED
- More...

### Fixed: Delete Account
**Issue**: Was throwing "Unauthorized: No valid token provided"
**Root Cause**: JWT token not being sent in request headers
**Fix Applied**: 
- Added `deleteAccount()` function in `legalBackend.ts`
- Updated `Profile.tsx` to use the function with auth headers
- Now properly sends Bearer token to backend

---

## 🚀 Deployment Steps

### Option 1: GitHub Integration (Recommended)
1. Push code to GitHub:
   ```bash
   git add .
   git commit -m "Production ready: delete account fix, optimizations, env config"
   git push origin main
   ```

2. In Vercel dashboard:
   - Click "New Project"
   - Import from GitHub
   - Select `legal-analyzer-project` repository
   - Set Framework: **Vite**
   - Root directory: `legalmind-frontend`
   - Build command: `npm run build`
   - Output directory: `dist`

3. Add Environment Variables:
   - VITE_API_BASE_URL: `https://your-backend.vercel.app`
   - VITE_SUPABASE_URL: `[your-value]`
   - VITE_SUPABASE_ANON_KEY: `[your-value]`

4. Click "Deploy" ✅

### Option 2: Vercel CLI
```bash
# Install Vercel CLI
npm i -g vercel

# Login to Vercel
vercel login

# Deploy from project root
cd legalmind-frontend
vercel

# For production
vercel --prod
```

### Option 3: Direct Upload
1. Build locally:
   ```bash
   npm run build
   ```

2. Upload `dist/` folder to Vercel
3. Set environment variables
4. Configure root directory as `dist/`

---

## ✅ Testing After Deployment

### Test Checklist
1. **Authentication**
   - [ ] Sign up new account
   - [ ] Login works
   - [ ] Logout works
   - [ ] Session persists on refresh

2. **Profile**
   - [ ] Delete Account button works
   - [ ] Change Password button works
   - [ ] Profile settings load

3. **Documents**
   - [ ] Upload document
   - [ ] View document list (only own documents)
   - [ ] Access document analysis

4. **Chat**
   - [ ] Send messages in chat
   - [ ] Chat history persists on refresh
   - [ ] No message duplication
   - [ ] Chat only shows for correct user

5. **Account Isolation**
   - [ ] Create 2 accounts
   - [ ] Switch between accounts
   - [ ] Each sees only their documents
   - [ ] Each sees only their chat

6. **Error Handling**
   - [ ] Network error shows toast
   - [ ] Auth error redirects to login
   - [ ] 404 page works

---

## 🔍 Monitoring & Debugging

### Vercel Dashboard
- View deployment logs
- Monitor performance metrics
- Check build failures
- View function logs

### Client-Side Debugging
Removed console statements in production, but you can:
1. Check Network tab in DevTools
2. Check Application → Local Storage
3. Check Supabase dashboard for data

### Common Issues

**Issue**: "Unauthorized: No valid token provided"
- **Cause**: User not logged in or token expired
- **Solution**: User should log in again, token auto-refreshes

**Issue**: "Document not found"
- **Cause**: User trying to access another user's document
- **Solution**: Server correctly blocks with 403 Forbidden

**Issue**: "Chat not loading"
- **Cause**: Supabase connection issue
- **Solution**: Check VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY

**Issue**: Chat messages doubling
- **Cause**: Already fixed in backend (see backend deployment)
- **Solution**: Ensure backend is updated and restarted

---

## 🔄 Continuous Deployment

### Auto-Deploy on Push
With GitHub integration, every push to `main` auto-deploys:
1. Push code to GitHub
2. Vercel automatically builds and deploys
3. Get deployment URL in PR comment
4. Merge PR to deploy to production

### Rollback
If deployment fails:
1. Go to Vercel dashboard
2. Select previous deployment
3. Click "Promote to Production"

---

## 📊 Performance Metrics

### Core Web Vitals Targets
- **Largest Contentful Paint (LCP)**: < 2.5s
- **First Input Delay (FID)**: < 100ms
- **Cumulative Layout Shift (CLS)**: < 0.1

### Optimization Applied
- Code splitting for vendor libraries
- Lazy loading of route components
- Minification with terser
- No source maps in production
- Image optimization (if used)

---

## 🔐 Security Checklist

- [x] JWT authentication on all endpoints
- [x] No sensitive data in localStorage (except session tokens)
- [x] HTTPS enforced by Vercel
- [x] CORS properly configured
- [x] No console logs with sensitive data
- [x] Environment variables not exposed
- [x] Build doesn't include node_modules secrets

---

## 📝 Final Checklist Before Production

- [ ] Backend deployed and running
- [ ] Backend API_BASE_URL set in Vercel env
- [ ] Supabase credentials configured
- [ ] Test delete account on production
- [ ] Test document isolation
- [ ] Test chat persistence
- [ ] Monitor error logs for 24hrs
- [ ] Set up Sentry/monitoring (optional)

---

## 🎉 You're Ready to Deploy!

```bash
# Final check
npm run build

# If no errors, push to GitHub
git add .
git commit -m "Final production deployment"
git push origin main

# Vercel will auto-deploy ✅
```

**Production URL**: https://your-project.vercel.app

---

## 📞 Support

For deployment issues:
1. Check Vercel dashboard logs
2. Verify environment variables are set
3. Ensure backend is running and accessible
4. Check browser console for errors
5. Review this guide's troubleshooting section

