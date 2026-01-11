# Database Deployment Guide

## Problem Solved
The original `complete-database-schema.sql` failed because:
- Policies referenced tables that didn't exist yet
- Storage policies conflicted with existing policies
- Functions tried to reference non-existent tables
- **FIXED**: Index `idx_recruiter_profiles_email` was referencing wrong column name (`email` instead of `contact_email`)
- **FIXED**: Existing policies and triggers now properly dropped before recreation

## Solution: Deploy in Order

### Step 1: Deploy Tables First
Run `database-tables-only.sql` in your Supabase SQL Editor first. This creates all tables without any policies.

### Step 2: Deploy Policies & Functions
After tables are created successfully, run `database-policies-functions.sql` to add:
- Row Level Security policies (with existing ones dropped first)
- Storage buckets and policies (with existing ones dropped first)
- Functions and triggers (with existing ones dropped first)

### Quick Deployment (Recommended)
Run `deploy-database.sql` which executes both scripts in the correct order.

## Files Created
- `database-tables-only.sql` - Tables and indexes only (FIXED column reference issue)
- `database-policies-functions.sql` - Policies, storage, functions, triggers (FIXED conflict handling)
- `deploy-database.sql` - Combined deployment script

## What Was Fixed
- ✅ Column reference errors in indexes
- ✅ Policy already exists conflicts
- ✅ Trigger already exists conflicts
- ✅ Function conflicts (using CREATE OR REPLACE)

## Expected Result
After deployment:
- ✅ Google OAuth will work
- ✅ User profiles will be created automatically
- ✅ All security policies will be active
- ✅ Storage buckets will be available

## Testing
1. Go to your login page
2. Click "Sign in with Google"
3. Complete OAuth flow
4. Check that user profile is created in the `profiles` table

## Troubleshooting
If you still get errors:
1. Make sure you're running the scripts in Supabase SQL Editor
2. Check that all tables were created in Step 1
3. Verify your Supabase project settings