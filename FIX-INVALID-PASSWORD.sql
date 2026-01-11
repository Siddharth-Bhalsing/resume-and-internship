-- ===================================================================
-- MANUAL FIX FOR "INVALID PASSWORD" ERROR
-- Run this in Supabase SQL Editor OR use the instructions below
-- ===================================================================

-- OPTION 1: SQL Solution (if you have admin privileges)
-- ===================================================================
-- WARNING: This SQL approach only works if you have the auth admin extension
-- Most users should use OPTION 2 (Manual Dashboard) below instead

-- OPTION 2: MANUAL DASHBOARD METHOD (RECOMMENDED)
-- ===================================================================
-- Follow these exact steps to fix the "invalid password" error:

/*
STEP-BY-STEP INSTRUCTIONS:

1. Go to: https://supabase.com/dashboard

2. Select your project from the list

3. Click "Authentication" in the left sidebar

4. Click "Users" tab

5. Click the green "Add User" button (top right)

6. CREATE FIRST USER:
   - Email: rajesh.kumar@gov.in
   - Password: gov123456
   - ☑ CHECK the box "Auto Confirm User"
   - Click "Create User"

7. CREATE SECOND USER:
   - Click "Add User" again
   - Email: priya.sharma@gov.in
   - Password: gov123456
   - ☑ CHECK the box "Auto Confirm User"
   - Click "Create User"

8. CREATE THIRD USER:
   - Click "Add User" again
   - Email: amit.singh@gov.in
   - Password: gov123456
   - ☑ CHECK the box "Auto Confirm User"
   - Click "Create User"

9. VERIFY:
   - You should now see 3 users in the list
   - Each user should have a green "confirmed" badge

10. TEST LOGIN:
    - Go to: http://localhost:3000/gov-login
    - Employee ID: EMP001
    - Password: gov123456
    - Enter the CAPTCHA code
    - Click "Secure Login"
    - ✅ Should redirect to dashboard!

DONE! The "invalid password" error should be fixed.
*/

-- ===================================================================
-- TROUBLESHOOTING
-- ===================================================================

-- If you STILL get "invalid password" after creating users:

-- 1. Check if the government_officials table has data:
SELECT * FROM government_officials;

-- Expected result: Should show EMP001, EMP002, EMP003
-- If empty, run setup-database-with-auth.sql first

-- 2. Verify the emails match exactly:
SELECT employee_id, email FROM government_officials;

-- The emails MUST match:
--   rajesh.kumar@gov.in
--   priya.sharma@gov.in
--   amit.singh@gov.in

-- 3. If emails are different, update them:
-- UPDATE government_officials SET email = 'rajesh.kumar@gov.in' WHERE employee_id = 'EMP001';
-- UPDATE government_officials SET email = 'priya.sharma@gov.in' WHERE employee_id = 'EMP002';
-- UPDATE government_officials SET email = 'amit.singh@gov.in' WHERE employee_id = 'EMP003';

-- ===================================================================
-- SUMMARY
-- ===================================================================
/*
The "invalid password" error happens because:
1. ✅ Database has employee records (EMP001, EMP002, EMP003)
2. ❌ But NO auth users exist with those emails
3. ❌ Login tries to authenticate → fails because user doesn't exist

Fix: Create the 3 auth users in Supabase Dashboard (steps above)

After creating the users:
- Employee ID: EMP001, EMP002, or EMP003
- Password: gov123456
- Should work perfectly!
*/
