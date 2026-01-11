-- Quick fix for OAuth profile creation
-- Run this in Supabase SQL Editor to allow profile creation during OAuth

-- Drop the restrictive policy
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

-- Add permissive policy for OAuth
CREATE POLICY "Allow profile creation during OAuth" ON profiles FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow profile updates during OAuth" ON profiles FOR UPDATE WITH CHECK (true);

-- Success message
SELECT 'OAuth profile creation policies updated!' as status;