-- ==========================================
-- CHANAKYA INTERNSHIP DATABASE DEPLOYMENT SCRIPT
-- ==========================================
-- This script deploys the database in the correct order:
-- 1. Tables first
-- 2. Then policies, storage, and functions
-- ==========================================

-- Step 1: Run the tables creation script
\i database-tables-only.sql

-- Step 2: Run the policies and functions script
\i database-policies-functions.sql

-- Success message
SELECT
    'Database deployment completed successfully!' as status,
    'All tables, policies, and functions are now active' as message,
    'Google OAuth authentication should now work' as next_step;