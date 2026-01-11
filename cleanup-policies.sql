-- Clean up existing policies and realtime tables before running main setup
-- Run this in Supabase SQL Editor if you get "already exists" errors

-- Drop existing policies
DROP POLICY IF EXISTS "Public can view recruiters" ON recruiters;
DROP POLICY IF EXISTS "Students can view active internships" ON internships;
DROP POLICY IF EXISTS "Users can view own applications" ON applications;
DROP POLICY IF EXISTS "Users can insert own applications" ON applications;

-- Remove tables from realtime publication if they exist
DO $$
BEGIN
    -- Check and remove tables from realtime publication
    IF EXISTS (
        SELECT 1 FROM pg_publication_tables
        WHERE pubname = 'supabase_realtime' AND tablename = 'recruiters'
    ) THEN
        ALTER PUBLICATION supabase_realtime DROP TABLE recruiters;
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_publication_tables
        WHERE pubname = 'supabase_realtime' AND tablename = 'internship_postings'
    ) THEN
        ALTER PUBLICATION supabase_realtime DROP TABLE internship_postings;
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_publication_tables
        WHERE pubname = 'supabase_realtime' AND tablename = 'internships'
    ) THEN
        ALTER PUBLICATION supabase_realtime DROP TABLE internships;
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_publication_tables
        WHERE pubname = 'supabase_realtime' AND tablename = 'applications'
    ) THEN
        ALTER PUBLICATION supabase_realtime DROP TABLE applications;
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_publication_tables
        WHERE pubname = 'supabase_realtime' AND tablename = 'notifications'
    ) THEN
        ALTER PUBLICATION supabase_realtime DROP TABLE notifications;
    END IF;
END $$;