# 🗄️ Chanakya Internship Database Testing Guide

## Overview
This guide will help you verify that your Chanakya Internship database is properly set up, connected, and ready to store/use data.

## 🚀 Quick Test - Visit the Test Page

**Easiest way to test everything:**

1. Start your Next.js application:
   ```bash
   npm run dev
   ```

2. Open your browser and go to:
   ```
   http://localhost:3000/test-database
   ```

3. The page will automatically run comprehensive tests and show results.

## 📋 What the Tests Check

### ✅ Database Connection
- Verifies Supabase connection is working
- Tests basic query execution

### ✅ Tables Existence
- Checks all 11 core tables are created
- Verifies table accessibility

### ✅ Sample Data
- Confirms government officials were inserted
- Checks schemes data is available

### ✅ Storage Buckets
- Verifies 6 storage buckets exist
- Tests bucket accessibility

### ✅ Security (RLS)
- Confirms Row Level Security is active
- Tests that unauthorized operations are blocked

## 🧪 Manual Testing Commands

### Test with Node.js Script

```bash
# Run the database test script
node test-database.js
```

### Test Individual Components

#### 1. Check Environment Variables
```bash
# Verify your .env.local file has correct values
cat .env.local
```

#### 2. Test Supabase Connection
```javascript
// In browser console or Node.js
import { createClient } from '@supabase/supabase-js'
const supabase = createClient('your-url', 'your-key')
const { data, error } = await supabase.from('schemes').select('*')
console.log(data, error)
```

#### 3. Test Authentication
```javascript
// Test user registration
const { data, error } = await supabase.auth.signUp({
  email: 'test@example.com',
  password: 'password123'
})
```

#### 4. Test Data Operations
```javascript
// Test reading public data
const { data, error } = await supabase
  .from('schemes')
  .select('*')

// Test creating a profile (will fail due to RLS - this is good!)
const { data, error } = await supabase
  .from('profiles')
  .insert({
    full_name: 'Test User',
    email: 'test@example.com'
  })
```

## 🔍 Troubleshooting

### ❌ Database Connection Failed
- Check your `.env.local` file has correct Supabase URL and key
- Verify the database setup was completed in Supabase
- Check Supabase project is active

### ❌ Tables Not Found
- Re-run the `database_complete_setup.sql` in Supabase SQL Editor
- Check for any SQL errors during setup
- Verify you're using the correct Supabase project

### ❌ Storage Buckets Missing
- Storage buckets are created by the SQL script
- Check Supabase dashboard > Storage section
- Re-run the setup script if needed

### ❌ RLS Not Working
- Row Level Security policies are created by the SQL script
- Check Supabase dashboard > Authentication > Policies
- Verify policies are enabled on all tables

## 📊 Expected Test Results

### ✅ All Tests Pass
```
✅ Database Connection: passed
✅ Tables Existence: passed (11/11 tables)
✅ Sample Data: passed (3 officials, 2 schemes)
✅ Storage Buckets: passed (6/6 buckets)
✅ Security (RLS): passed
```

### 🎯 Next Steps After Successful Testing

1. **Create Test Accounts:**
   - Register a student account
   - Create a recruiter profile
   - Test government login

2. **Test Core Features:**
   - Post an internship (recruiter)
   - Apply for internship (student)
   - Upload resume/documents
   - Check notifications

3. **Deploy to Production:**
   - Update environment variables
   - Deploy to Vercel/Netlify
   - Test in production environment

## 🆘 Need Help?

If tests are failing:

1. Check the browser console for detailed error messages
2. Verify all environment variables are set correctly
3. Ensure the database setup script ran without errors
4. Check Supabase project status and billing

## 📞 Support

- Check the `DATABASE_SETUP_README.md` for detailed setup instructions
- Verify Supabase project configuration
- Test with the provided test page for automated diagnostics