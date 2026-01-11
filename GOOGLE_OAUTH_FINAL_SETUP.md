# GOOGLE OAUTH FINAL SETUP GUIDE

## 🚨 CRITICAL: Complete These Steps to Fix OAuth

### Step 1: Get Service Role Key
1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project: `htfkcabyhhgcsudgbzzm`
3. Go to **Settings** → **API**
4. Copy the **service_role** key (not the anon key)
5. Replace `your_service_role_key_here` in `.env.local` with the actual key

### Step 2: Enable Google OAuth Provider
1. In Supabase Dashboard, go to **Authentication** → **Providers**
2. Find **Google** and click to enable it
3. Add your Google OAuth credentials:
   - **Client ID**: From Google Cloud Console
   - **Client Secret**: From Google Cloud Console
4. Set **Redirect URLs** to:
   - `http://localhost:3000/auth/callback` (development)
   - `https://yourdomain.com/auth/callback` (production)

### Step 3: Test the OAuth Flow
1. Start your development server: `npm run dev`
2. Go to `http://localhost:3000/login`
3. Click "Sign in with Google"
4. Complete OAuth flow
5. Check browser console and server logs for success messages

## 🔧 What Was Fixed

### ✅ Database Tables & Policies
- All internship system tables deployed
- RLS policies configured
- Storage buckets created

### ✅ OAuth Callback Logic
- Enhanced error handling and logging
- Multi-layered profile creation approach:
  1. Try authenticated client (respects RLS)
  2. Fallback to service role client (bypasses RLS)
  3. Clear error messages with solutions

### ✅ Environment Configuration
- Updated Supabase credentials
- Added service role key placeholder
- Proper site URL configuration

## 🐛 Troubleshooting

### If OAuth Still Fails:
1. **Check Service Role Key**: Ensure it's correctly added to `.env.local`
2. **Verify Google Provider**: Confirm it's enabled in Supabase
3. **Check Console Logs**: Look for detailed error messages
4. **Database Connection**: Ensure tables exist and are accessible

### Common Error Messages:
- `"Database error saving new user"` → Missing service role key
- `"Could not find the function"` → Service role key not set
- `"Invalid OAuth callback"` → Google provider not configured

## 🎯 Expected Behavior After Fix

1. User clicks "Sign in with Google"
2. Redirects to Google OAuth
3. User grants permissions
4. Returns to `/auth/callback`
5. Profile automatically created in database
6. Redirects to dashboard with success message

## 📝 Next Steps

Once OAuth works:
1. Test user registration and login
2. Verify profile data is saved correctly
3. Test dashboard access
4. Deploy to production with proper domain

---

**Status**: Ready for testing once service role key is added!</content>
<parameter name="filePath">c:\Users\ACER\splitwise\GOOGLE_OAUTH_FINAL_SETUP.md