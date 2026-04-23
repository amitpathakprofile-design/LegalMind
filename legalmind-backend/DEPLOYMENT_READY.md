# Backend Deployment Checklist - HuggingFace Spaces

## Pre-Deployment ✓

### Code Quality
- [x] All endpoints working (tested locally)
- [x] Error handling implemented
- [x] Health check endpoint added
- [x] CORS properly configured
- [x] Input validation with Pydantic

### Dependencies
- [x] requirements.txt updated with all packages
- [x] No hardcoded credentials in code
- [x] Environment variables configured
- [x] Python 3.11+ compatible

### Database
- [x] Supabase tables created
- [x] RLS policies configured
- [x] Storage buckets created
- [x] Service role key generated

### Files to Deploy
- [x] Dockerfile - Container configuration
- [x] .dockerignore - Exclude unnecessary files
- [x] app.py - HF Spaces entry point
- [x] main.py - FastAPI application
- [x] requirements.txt - Dependencies
- [x] ml_pipeline/ - All ML modules
- [x] All source code files

## Deployment Steps

### Step 1: HuggingFace Space Setup
- [ ] Create account at https://huggingface.co
- [ ] Go to https://huggingface.co/new-space
- [ ] Select "Docker" as SDK
- [ ] Choose "Private" or "Public"
- [ ] Create Space
- [ ] Copy Space clone URL

### Step 2: Prepare Repository
```bash
# Clone your space repository
git clone https://huggingface.co/spaces/YOUR_USERNAME/YOUR_SPACE_NAME
cd YOUR_SPACE_NAME

# Copy all backend files here
# Verify: Dockerfile, app.py, main.py, requirements.txt, ml_pipeline/
```

### Step 3: Environment Secrets
In Space Settings → Secrets, add:
- [ ] `SUPABASE_URL` - Your Supabase project URL
- [ ] `SUPABASE_KEY` - Your Supabase anon key
- [ ] `SUPABASE_SERVICE_ROLE_KEY` - Service role key

### Step 4: Push to Deploy
```bash
git add .
git commit -m "Deploy LegalMind backend"
git push
```

### Step 5: Monitor Deployment
- [ ] Check Space page for build status
- [ ] View build logs for errors
- [ ] Wait for container to be ready (5-10 minutes)
- [ ] Test health endpoint once ready

## Post-Deployment ✓

### Verification
- [ ] Health check responds: `/health`
- [ ] API docs available: `/docs`
- [ ] All endpoints accessible in Swagger UI
- [ ] Database connection working
- [ ] File uploads/downloads working

### Testing
```bash
# Test endpoints (replace with your space URL)
BASE_URL=https://username-space-name.hf.space

# Health check
curl $BASE_URL/health

# API docs
curl $BASE_URL/docs

# Test upload (requires authentication token)
curl -X POST $BASE_URL/api/v1/upload \
  -F "file=@test.pdf" \
  -F "user_id=test-user"
```

### Frontend Integration
- [ ] Update `VITE_API_BASE_URL` in frontend .env
- [ ] Test all API calls from frontend
- [ ] Verify CORS headers work
- [ ] Test document upload/analysis flow
- [ ] Test chat functionality
- [ ] Test download/share features

## Monitoring & Maintenance

### Regular Checks
- [ ] Set up alerts for deployment failures
- [ ] Monitor Space resource usage
- [ ] Review error logs weekly
- [ ] Check API response times

### Updates
When pushing updates:
1. Test locally first
2. Commit with clear message
3. Push to Space (auto-deploys)
4. Monitor build in Space logs
5. Test endpoints after deployment

### Scaling
If you encounter issues:
- [ ] **Memory**: Upgrade Space tier
- [ ] **Performance**: Add request caching
- [ ] **Users**: Enable persistent storage
- [ ] **Models**: Use smaller models or quantized versions

## Rollback Plan

If deployment fails:

```bash
# Option 1: Push previous version
git revert HEAD
git push

# Option 2: Check Space settings and manually restart
# Go to Space → Settings → Restart Space

# Option 3: Clear cache and rebuild
# Go to Space → Settings → Rebuild Space
```

## Troubleshooting Checklist

### Build Fails
- [ ] All files present and committed
- [ ] No circular imports in code
- [ ] requirements.txt has all dependencies
- [ ] Python version compatible (3.11+)
- [ ] No syntax errors in Dockerfile

### Container Won't Start
- [ ] Check app.py imports main correctly
- [ ] Verify port 7860 is used in app.py
- [ ] Environment variables set in Secrets
- [ ] Check Dockerfile EXPOSE port

### API Returns Errors
- [ ] Check Supabase credentials in Secrets
- [ ] Verify database tables exist
- [ ] Check RLS policies are correct
- [ ] Review application logs in Space

### Slow Performance
- [ ] First request loads model (~2-3 min) - normal
- [ ] Check Space resource usage
- [ ] Verify database indexes configured
- [ ] Consider splitting large uploads

## Cleanup (Before Deployment)

- [x] Removed unnecessary README files
- [x] Cleaned up test files
- [x] Removed local .env file from git
- [x] Updated .gitignore for sensitive files
- [x] Verified no debug prints left in code

## Final Checklist

Before clicking deploy:
- [ ] All files committed and pushed
- [ ] Environment secrets configured
- [ ] Supabase database ready
- [ ] Frontend .env updated with API URL
- [ ] Local tests pass
- [ ] Dockerfile builds without errors
- [ ] requirements.txt complete
- [ ] No sensitive data in code
- [ ] Documentation up to date

---

**Ready for Deployment**: YES ✅

**Next Steps**:
1. Follow Step-by-step deployment guide in HF_SPACES_DEPLOYMENT.md
2. Push repository to HuggingFace Spaces
3. Monitor build completion (5-10 minutes)
4. Test all endpoints
5. Configure frontend with new API URL
6. Deploy frontend

---

**Deployment Date**: [DATE]
**Deployed By**: [YOUR NAME]
**Space URL**: [YOUR_SPACE_URL]
**Status**: [PENDING/IN PROGRESS/LIVE]
