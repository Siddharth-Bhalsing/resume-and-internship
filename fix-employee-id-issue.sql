-- Fix for invalid employee_id issue
-- Run this in Supabase SQL Editor before running the main setup script

-- First, check if the table exists and drop it if it has wrong constraints
DO $$
BEGIN
    -- Check if government_officials table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'government_officials') THEN
        -- Drop the table to recreate it with correct structure
        DROP TABLE government_officials CASCADE;
        RAISE NOTICE 'Dropped existing government_officials table';
    END IF;

    -- Create the table with correct structure
    CREATE TABLE government_officials (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        employee_id VARCHAR(50) UNIQUE NOT NULL,
        name VARCHAR(255) NOT NULL,
        designation VARCHAR(255) NOT NULL,
        ministry VARCHAR(255) NOT NULL,
        department VARCHAR(255),
        email VARCHAR(255) NOT NULL,
        phone VARCHAR(20),
        role VARCHAR(50) DEFAULT 'officer',
        permissions JSONB DEFAULT '{}',
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    RAISE NOTICE 'Created government_officials table with correct structure';
END $$;