-- ============================================
-- DIAGNOSTIC: Find the Password Mismatch Issue
-- ============================================

-- STEP 1: Check what's in government_officials table
-- Run this in Supabase SQL Editor:

SELECT 
    employee_id,
    email,
    name
FROM government_officials
WHERE employee_id IN ('EMP001', 'EMP002', 'EMP003');

-- Expected output:
-- employee_id | email                    | name
-- EMP001      | rajesh.kumar@gov.in     | Dr. Rajesh Kumar
-- EMP002      | priya.sharma@gov.in     | Ms. Priya Sharma  
-- EMP003      | amit.singh@gov.in       | Mr. Amit Singh

-- ============================================
-- STEP 2: Check Supabase Auth Users
-- ============================================

-- You CANNOT query auth.users directly in SQL
-- Instead, go to Supabase Dashboard:
-- 1. Authentication → Users
-- 2. Look for these emails:
--    - rajesh.kumar@gov.in
--    - priya.sharma@gov.in
--    - amit.singh@gov.in

-- ============================================
-- STEP 3: Debug - What email is being used?
-- ============================================

-- Add this console log to see what's happening
-- Open: lib/supabase.ts
-- In authenticateGovernmentOfficial function around line 383

-- Add these lines after line 387:
-- console.log('🔍 DEBUG - Employee ID:', employeeId)
-- console.log('🔍 DEBUG - Email from DB:', official.email)
-- console.log('🔍 DEBUG - Attempting auth with password')

-- ============================================
-- COMMON ISSUES:
-- ============================================

-- Issue 1: Email mismatch
-- The email in government_officials table doesn't match 
-- the email of the Supabase auth user

-- Issue 2: Auth user doesn't exist
-- There's no Supabase auth user with that email at all

-- Issue 3: Wrong password in Supabase
-- The Supabase auth user exists but has a different password
-- than what you're typing

-- ============================================
-- SOLUTION:
-- ============================================

-- Option A: Check auth user email
-- Go to Supabase Dashboard → Authentication → Users
-- What EMAIL do you see for your government user?
-- Does it match the email in government_officials table?

-- Option B: Reset the password
-- In Supabase Dashboard → Authentication → Users
-- Find the user → Click "..." → Send Password Reset
-- OR
-- Delete the user and recreate with known password

-- Option C: Update government_officials email
-- If your auth user has email like "government@example.com":
UPDATE government_officials 
SET email = 'YOUR_ACTUAL_AUTH_USER_EMAIL@example.com' 
WHERE employee_id = 'EMP001';
