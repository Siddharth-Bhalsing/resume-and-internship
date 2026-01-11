# Government Login Fix - Quick Setup Guide

## ⚡ Quick Fix (If Script Fails)

If `node scripts/create-gov-auth-users.js` fails, follow these manual steps:

### Option 1: Create via Supabase Dashboard (Recommended)

1. **Go to your Supabase Dashboard**
   - Navigate to: https://supabase.com/dashboard
   - Select your project

2. **Go to Authentication > Users**
   - Click "Add User" button

3. **Create these 3 users:**

   **User 1:**
   - Email: `rajesh.kumar@gov.in`
   - Password: `gov123456`
   - Email Confirm: ✅ (check this box)
   - Click "Create User"

   **User 2:**
   - Email: `priya.sharma@gov.in`
   - Password: `gov123456`
   - Email Confirm: ✅
   - Click "Create User"

   **User 3:**
   - Email: `amit.singh@gov.in`
   - Password: `gov123456`
   - Email Confirm: ✅
   - Click "Create User"

4. **Done!** Now you can log in with:
   - Employee ID: `EMP001` / Password: `gov123456`
   - Employee ID: `EMP002` / Password: `gov123456`
   - Employee ID: `EMP003` / Password: `gov123456`

---

### Option 2: Use Supabase Admin API (Advanced)

If you have the Service Role Key, you can use this simple script:

```javascript
// Run in browser console on Supabase dashboard or in Node.js
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'YOUR_SUPABASE_URL',
  'YOUR_SERVICE_ROLE_KEY' // ⚠️ Never commit this!
)

const users = [
  { email: 'rajesh.kumar@gov.in', password: 'gov123456', name: 'Dr. Rajesh Kumar' },
  { email: 'priya.sharma@gov.in', password: 'gov123456', name: 'Ms. Priya Sharma' },
  { email: 'amit.singh@gov.in', password: 'gov123456', name: 'Mr. Amit Singh' }
]

for (const user of users) {
  const { data, error } = await supabase.auth.admin.createUser({
    email: user.email,
    password: user.password,
    email_confirm: true,
    user_metadata: { full_name: user.name, role: 'government' }
  })
  console.log(user.email, data ? '✅' : '❌', error?.message)
}
```

---

### Option 3: Reset Existing User Passwords

If users already exist but have wrong passwords:

1. Go to **Authentication > Users** in Supabase Dashboard
2. For each email (`rajesh.kumar@gov.in`, etc.):
   - Click the "..." menu next to the user
   - Select "Reset Password"
   - Set new password: `gov123456`
   - Confirm

---

## 🧪 Testing

**Test URL**: http://localhost:3000/gov-login

**Test Credentials:**
- Employee ID: `EMP001`
- Password: `gov123456`
- Enter CAPTCHA code as displayed
- Click "Secure Login"
- ✅ Should redirect to `/gov-dashboard`

---

## ⚠️ Troubleshooting

### Error: "Invalid employee ID"
- ✅ **Fixed**: Use `EMP001` not `GOV001`
- Run `setup-database-with-auth.sql` if table is empty

### Error: "Invalid password"  
- ✅ **Fixed**: Password is `gov123456` not `password123`
- Create auth users using one of the options above

### Error: "Database connection not configured"
- Check `.env.local` has valid `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY`

### Script doesn't work
- Check if you have `SUPABASE_SERVICE_ROLE_KEY` in `.env.local`
- Use manual Option 1 (Supabase Dashboard) instead

---

## 📝 Summary of Changes

✅ **Standardized Credentials:**
- Employee IDs: `EMP001`, `EMP002`, `EMP003` (was `GOV001`, etc.)
- Password: `gov123456` (was inconsistent)

✅ **Updated Files:**
- `LOGIN_CREDENTIALS.md`
- `GOVERNMENT_LOGIN_CREDENTIALS.md`
- `RECRUITER_LOGIN_CREDENTIALS.md`

✅ **Created Scripts:**
- `scripts/create-gov-auth-users.js` (automated setup)
- `GOVERNMENT_LOGIN_FIX_GUIDE.md` (this manual guide)
