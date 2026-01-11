-- Fix for government_officials table structure
-- Run this in Supabase SQL Editor before running the main setup script

-- First, check if the table exists and ensure it has the correct structure
DO $$
BEGIN
    -- Check if government_officials table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'government_officials') THEN
        -- Check if ministry column exists
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                      WHERE table_name = 'government_officials' AND column_name = 'ministry') THEN
            -- Add the ministry column
            ALTER TABLE government_officials ADD COLUMN ministry VARCHAR(255);
            RAISE NOTICE 'Added ministry column to government_officials table';
        END IF;

        -- Check if department column exists and is nullable
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                      WHERE table_name = 'government_officials' AND column_name = 'department') THEN
            -- Add the department column as nullable
            ALTER TABLE government_officials ADD COLUMN department VARCHAR(255);
            RAISE NOTICE 'Added department column to government_officials table';
        ELSE
            -- Ensure department is nullable
            ALTER TABLE government_officials ALTER COLUMN department DROP NOT NULL;
            RAISE NOTICE 'Made department column nullable in government_officials table';
        END IF;

        -- Check if phone column exists
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                      WHERE table_name = 'government_officials' AND column_name = 'phone') THEN
            ALTER TABLE government_officials ADD COLUMN phone VARCHAR(20);
            RAISE NOTICE 'Added phone column to government_officials table';
        END IF;

        -- Check if permissions column exists
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                      WHERE table_name = 'government_officials' AND column_name = 'permissions') THEN
            ALTER TABLE government_officials ADD COLUMN permissions JSONB DEFAULT '{}';
            RAISE NOTICE 'Added permissions column to government_officials table';
        END IF;

        -- Check if is_active column exists
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                      WHERE table_name = 'government_officials' AND column_name = 'is_active') THEN
            ALTER TABLE government_officials ADD COLUMN is_active BOOLEAN DEFAULT true;
            RAISE NOTICE 'Added is_active column to government_officials table';
        END IF;

        RAISE NOTICE 'government_officials table structure verified and updated';
    ELSE
        -- Create the table if it doesn't exist
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
    END IF;
END $$;