# Google OAuth Setup Guide for Chanakya Internship Portal

## 🚀 Complete Google OAuth Configuration

### Step 1: Supabase OAuth Configuration

1. **Go to Supabase Dashboard**
   - Visit [supabase.com](https://supabase.com)
   - Open your project dashboard
   - Navigate to **Authentication > Providers**

2. **Enable Google OAuth**
   - Find "Google" in the provider list
   - Click to enable it
   - You'll need Google Client ID and Secret

### Step 2: Google Cloud Console Setup

1. **Create Google Cloud Project**
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Create a new project or select existing one

2. **Enable Google+ API**
   - Go to "APIs & Services" > "Library"
   - Search for "Google+ API" and enable it

3. **Create OAuth 2.0 Credentials**
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "OAuth 2.0 Client IDs"
   - Choose "Web application"
   - Add authorized redirect URIs:
     ```
     For Development: http://localhost:3000/auth/callback
     For Production: https://yourdomain.com/auth/callback
     ```

4. **Get Client ID and Secret**
   - Copy the Client ID and Client Secret
   - These will be used in Supabase

### Step 3: Configure Supabase with Google Credentials

1. **Back in Supabase Dashboard**
   - Go to Authentication > Providers > Google
   - Enter your Google Client ID and Client Secret
   - Set redirect URLs (should match Google Console):
     ```
     http://localhost:3000/auth/callback
     https://yourdomain.com/auth/callback
     ```

2. **Save Configuration**
   - Click "Save" to apply changes

### Step 4: Environment Variables

Your `.env.local` should have:
```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

### Step 5: Test the Integration

1. **Start Development Server**
   ```bash
   npm run dev
   ```

2. **Test Google Sign-In**
   - Go to `/login`
   - Click "Continue with Google"
   - Complete OAuth flow
   - Should redirect to dashboard with profile created

### Step 6: Production Deployment

1. **Update Environment Variables**
   - Set `NEXT_PUBLIC_SITE_URL` to your production domain
   - Update Supabase redirect URLs

2. **Update Google Console**
   - Add production redirect URI to authorized URIs

## 🔧 Troubleshooting

### Common Issues:

1. **"Invalid OAuth access token"**
   - Check Google Client ID/Secret in Supabase
   - Verify redirect URIs match exactly

2. **"Redirect URI mismatch"**
   - Ensure redirect URIs in Google Console match Supabase config
   - Include both localhost and production URLs

3. **Profile not created**
   - Check database tables exist
   - Verify RLS policies allow profile creation

4. **CORS errors**
   - Ensure site URL is correctly set in environment variables

### Debug Steps:

1. Check browser console for errors
2. Verify network requests in browser dev tools
3. Check Supabase logs for authentication errors
4. Test with different browsers

## 📋 Current Implementation Status

✅ **Completed:**
- Google OAuth function in `supabase.ts`
- Auth callback route with profile creation
- Login page with Google sign-in button
- Error handling and user feedback
- Profile auto-creation on successful OAuth

⚠️ **Requires Manual Setup:**
- Supabase OAuth provider configuration
- Google Cloud Console credentials
- Authorized redirect URIs

## 🎯 Expected Flow

1. User clicks "Continue with Google"
2. Redirected to Google OAuth
3. User grants permissions
4. Redirected back to `/auth/callback`
5. Code exchanged for session
6. User profile created/updated
7. Redirected to dashboard

## 📞 Support

If you encounter issues:
1. Check this guide for configuration steps
2. Verify all credentials are correct
3. Test in incognito mode
4. Contact development team for assistance