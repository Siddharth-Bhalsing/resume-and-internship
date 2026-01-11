# 🔧 Google OAuth Configuration Fix

## ✅ Your Supabase Project Details
- **Project URL:** https://htfkcabyhhgcsudgbzzm.supabase.co
- **Environment:** ✅ Configured correctly
- **Connection Test:** ✅ **SUCCESSFUL** - Supabase is connected and working!

## 🎯 **IMMEDIATE ACTION REQUIRED: Configure Google OAuth in Supabase**

### **Right Now - Go to Supabase Dashboard:**

1. **Visit:** https://supabase.com/dashboard
2. **Select project:** `htfkcabyhhgcsudgbzzm`
3. **Go to:** Authentication → Providers → Google
4. **Click:** Enable Google provider
5. **Add:** Your Google Client ID & Secret
6. **Set redirect URLs:**
   ```
   http://localhost:3000/auth/callback
   https://splitwise-jet.vercel.app/auth/callback
   https://htfkcabyhhgcsudgbzzm.supabase.co/auth/v1/callback
   ```

### **Then test:**
```bash
npm run dev
# Go to http://localhost:3000/login
# Click "Continue with Google"
```

---

## 🚨 Current Issues & Solutions

You're experiencing OAuth errors because **Google OAuth is not configured in Supabase**. Here's the complete fix:

### **Error Breakdown:**
- **"Google OAuth not configured in Supabase"** → Google provider not enabled in Supabase Auth
- **"Invalid redirect URI"** → Redirect URLs don't match between Google Console & Supabase
- **"Network connectivity issues"** → OAuth flow interrupted
- **"Browser security restrictions"** → CORS or security policy issues

## 🚀 Step-by-Step Fix

### Step 1: Enable Google OAuth in Supabase

1. **Go to Supabase Dashboard**
   - Visit: https://supabase.com/dashboard
   - Select your project: `htfkcabyhhgcsudgbzzm`

2. **Navigate to Authentication**
   - Click **"Authentication"** in the left sidebar
   - Click **"Providers"** tab

3. **Enable Google Provider**
   - Find **"Google"** in the provider list
   - Click the toggle to **enable** it
   - You'll see fields for Client ID and Client Secret

### Step 2: Create Google Cloud Project

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com/
   - Sign in with your Google account

2. **Create/Switch Project**
   - Click the project dropdown at the top
   - Click **"New Project"**
   - Name it: `chanakya-internship-portal`
   - Click **"Create"**

### Step 3: Enable Required APIs

1. **Enable Google+ API**
   - In the left sidebar, go to **"APIs & Services"** → **"Library"**
   - Search for **"Google+ API"**
   - Click on it and **"Enable"**

2. **Enable Google People API** (recommended)
   - Search for **"People API"**
   - Click on it and **"Enable"**

### Step 4: Create OAuth Credentials

1. **Go to Credentials**
   - In the left sidebar, go to **"APIs & Services"** → **"Credentials"**

2. **Create OAuth 2.0 Client ID**
   - Click **"+ CREATE CREDENTIALS"**
   - Select **"OAuth 2.0 Client IDs"**

3. **Configure OAuth Consent Screen** (if prompted)
   - Choose **"External"** user type
   - Fill in app details:
     - **App name:** Chanakya Internship Portal
     - **User support email:** Your email
     - **Developer contact:** Your email
   - Add scopes: `.../auth/userinfo.email`, `.../auth/userinfo.profile`
   - Save and continue

4. **Create Client ID**
   - **Application type:** Web application
   - **Name:** Chanakya Internship Portal
   - **Authorized redirect URIs:**
     ```
     http://localhost:3000/auth/callback
     https://splitwise-jet.vercel.app/auth/callback
     https://htfkcabyhhgcsudgbzzm.supabase.co/auth/v1/callback
     ```

5. **Copy Credentials**
   - Copy the **Client ID** and **Client Secret**

### Step 5: Configure Supabase

1. **Back in Supabase Dashboard**
   - Go to **Authentication** → **Providers** → **Google**

2. **Enter Credentials**
   - **Client ID:** Paste your Google Client ID
   - **Client Secret:** Paste your Google Client Secret

3. **Configure Redirect URLs**
   - These should match your Google Console exactly:
     ```
     http://localhost:3000/auth/callback
     https://splitwise-jet.vercel.app/auth/callback
     https://htfkcabyhhgcsudgbzzm.supabase.co/auth/v1/callback
     ```

4. **Additional Settings**
   - **Enabled:** ✅ Checked
   - **Skip nonce check:** ❌ Unchecked (leave default)

5. **Save Changes**
   - Click **"Save"**

### Step 6: Environment Variables ✅

Your `.env.local` is now correctly configured:

```env
# Supabase Configuration ✅
NEXT_PUBLIC_SUPABASE_URL=https://htfkcabyhhgcsudgbzzm.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Site URL Configuration ✅
NEXT_PUBLIC_SITE_URL=http://localhost:3000

# Optional: For development ✅
NEXT_PUBLIC_ENVIRONMENT=development
```

### Step 7: Test the Configuration

1. **Restart your development server**
   ```bash
   npm run dev
   ```

2. **Test Google Sign-In**
   - Go to `http://localhost:3000/login`
   - Click **"Continue with Google"**
   - Complete the OAuth flow
   - Should redirect to dashboard

## 🔍 Troubleshooting

### If you still get errors:

1. **Check Supabase Auth Logs**
   - Go to Supabase Dashboard → Authentication → Logs
   - Look for OAuth-related errors

2. **Verify Redirect URIs Match**
   - Google Console URIs must exactly match Supabase redirect URLs
   - Include the full path: `/auth/callback`

3. **Check Browser Console**
   - Open DevTools (F12)
   - Check Console tab for JavaScript errors
   - Check Network tab for failed requests

4. **Test in Incognito Mode**
   - Browser extensions can interfere with OAuth

5. **Verify Database is Ready**
   - Make sure you've run the database deployment scripts
   - Check that the `profiles` table exists

### Common Issues:

- **"redirect_uri_mismatch"**: Double-check all redirect URIs match exactly
- **"invalid_client"**: Verify Client ID and Secret are correct
- **"access_denied"**: User denied permissions or account restrictions
- **Network errors**: Check internet connection and firewall settings

## 📞 Need Help?

If you're still having issues:

1. **Check the browser's Network tab** for the exact error response
2. **Verify all URLs are HTTPS in production** (except localhost)
3. **Make sure your Supabase project allows OAuth redirects**
4. **Test with a different Google account**

## ✅ Success Indicators

When working correctly, you should see:
- Redirect to Google OAuth page
- Permission request for email and profile
- Redirect back to your app
- User profile created in database
- Redirect to `/dashboard`

The OAuth flow should complete within 10-15 seconds normally.