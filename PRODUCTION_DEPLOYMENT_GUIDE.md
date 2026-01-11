# 🚀 PRODUCTION DEPLOYMENT GUIDE

## Domain Requirements for OAuth

### ✅ **For Development (Current Setup)**
- **Domain**: `localhost:3000` ✅ Works fine
- **Google OAuth**: Configure `http://localhost:3000/auth/callback`
- **Supabase**: Site URL set to `http://localhost:3000`

### ✅ **For Production (Required)**
- **Domain**: Real domain name (e.g., `yourapp.com`, `myinternshipsystem.com`)
- **SSL**: HTTPS required (free with Let's Encrypt)
- **Hosting**: Vercel, Netlify, or any hosting platform

## 📋 **Production Deployment Steps**

### **Step 1: Get a Domain**
```bash
# Options:
# 1. Namecheap, GoDaddy, Google Domains (~$10-15/year)
# 2. Free subdomain: yourname.vercel.app (if using Vercel)
# 3. GitHub Pages: yourusername.github.io (limited OAuth support)
```

### **Step 2: Deploy to Vercel (Recommended)**

1. **Connect GitHub Repository**:
   ```bash
   # Push your code to GitHub first
   git add .
   git commit -m "Ready for production"
   git push origin main
   ```

2. **Deploy on Vercel**:
   - Go to [vercel.com](https://vercel.com)
   - Import your GitHub repository
   - Vercel will auto-detect Next.js
   - Deploy automatically

3. **Update Environment Variables**:
   - In Vercel dashboard → Project Settings → Environment Variables
   - Add all variables from `.env.local`
   - Set `NEXT_PUBLIC_SITE_URL` to your Vercel domain (e.g., `https://yourproject.vercel.app`)

### **Step 3: Configure OAuth for Production**

1. **Update Google OAuth**:
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - APIs & Services → Credentials
   - Edit your OAuth 2.0 Client ID
   - Add production redirect URI: `https://yourdomain.com/auth/callback`

2. **Update Supabase**:
   - Go to [Supabase Dashboard](https://supabase.com/dashboard)
   - Authentication → Settings
   - Update Site URL to: `https://yourdomain.com`
   - Update Auth Providers → Google
   - Update redirect URL to: `https://yourdomain.com/auth/callback`

### **Step 4: Update DNS (If using custom domain)**

For custom domain with Vercel:
1. In Vercel dashboard → Project Settings → Domains
2. Add your custom domain
3. Update DNS records as instructed by Vercel
4. Wait for SSL certificate (automatic)

## 🎯 **Quick Test Checklist**

- [ ] Domain purchased/registered
- [ ] Code deployed to Vercel/Netlify
- [ ] Environment variables updated in hosting platform
- [ ] Google OAuth redirect URI updated
- [ ] Supabase site URL updated
- [ ] SSL certificate active (HTTPS)
- [ ] Test OAuth login flow

## 💡 **Free Options for Testing**

1. **Vercel Free Tier**: `yourproject.vercel.app`
2. **Netlify Free**: `yourproject.netlify.app`
3. **Railway**: Free tier available
4. **Render**: Free tier with custom domain

## ⚠️ **Important Notes**

- **HTTP vs HTTPS**: OAuth requires HTTPS in production
- **CORS Issues**: Update all redirect URIs when domain changes
- **Environment Variables**: Never commit secrets to GitHub
- **Testing**: Always test OAuth after domain changes

---

**Ready to deploy? Start with Vercel - it's the easiest option! 🚀**</content>
<parameter name="filePath">c:\Users\ACER\splitwise\PRODUCTION_DEPLOYMENT_GUIDE.md