-- Check if recruiters table exists and has data
SELECT * FROM recruiters LIMIT 5;

-- If the above fails, try this alternative table name:
SELECT * FROM recruiter_profiles LIMIT 5;

-- Check what tables you have:
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name LIKE '%recruit%';
