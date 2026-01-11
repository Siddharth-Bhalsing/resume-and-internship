-- ==========================================
-- CHANAKYA INTERNSHIP DATABASE - SAFE DEPLOYMENT
-- ==========================================
-- This script checks existing objects and creates only what's missing
-- ==========================================

-- Enable necessary extensions (safe)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- 1. USER MANAGEMENT TABLES (Safe Creation)
-- ==========================================

-- Student Profiles Table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles') THEN
        CREATE TABLE profiles (
            id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
            full_name VARCHAR(255),
            email VARCHAR(255),
            phone VARCHAR(20),
            date_of_birth DATE,
            gender VARCHAR(20),
            father_name VARCHAR(255),
            address_line1 TEXT,
            address_line2 TEXT,
            city VARCHAR(100),
            state VARCHAR(100),
            pincode VARCHAR(10),
            education_level VARCHAR(100),
            institution_name VARCHAR(255),
            course_name VARCHAR(255),
            year_of_passing INTEGER,
            bank_name VARCHAR(255),
            account_number VARCHAR(50),
            ifsc_code VARCHAR(20),
            account_holder_name VARCHAR(255),
            skills TEXT[],
            languages TEXT[],
            resume_url TEXT,
            profile_step INTEGER DEFAULT 1,
            profile_completed BOOLEAN DEFAULT false,
            document_verified BOOLEAN DEFAULT false,
            aadhaar_verified BOOLEAN DEFAULT false,
            digilocker_verified BOOLEAN DEFAULT false,
            role VARCHAR(50) DEFAULT 'student',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        RAISE NOTICE 'Created profiles table';
    ELSE
        RAISE NOTICE 'profiles table already exists';
    END IF;
END $$;

-- Recruiter Profiles Table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'recruiter_profiles') THEN
        CREATE TABLE recruiter_profiles (
            id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
            employee_id VARCHAR(50) UNIQUE NOT NULL,
            company_name VARCHAR(255) NOT NULL,
            company_website VARCHAR(255),
            company_description TEXT,
            industry VARCHAR(100),
            company_size VARCHAR(50),
            contact_person VARCHAR(255),
            contact_email VARCHAR(255) UNIQUE NOT NULL,
            contact_phone VARCHAR(20),
            address_line1 TEXT,
            address_line2 TEXT,
            city VARCHAR(100),
            state VARCHAR(100),
            pincode VARCHAR(10),
            gst_number VARCHAR(20),
            pan_number VARCHAR(20),
            approval_status VARCHAR(50) DEFAULT 'pending',
            approved_by UUID,
            approved_at TIMESTAMP WITH TIME ZONE,
            rejection_reason TEXT,
            profile_completed BOOLEAN DEFAULT false,
            profile_step INTEGER DEFAULT 1,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        RAISE NOTICE 'Created recruiter_profiles table';
    ELSE
        RAISE NOTICE 'recruiter_profiles table already exists';
    END IF;
END $$;

-- Government Officials Table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'government_officials') THEN
        CREATE TABLE government_officials (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            employee_id VARCHAR(50) UNIQUE NOT NULL,
            name VARCHAR(255) NOT NULL,
            email VARCHAR(255) UNIQUE NOT NULL,
            department VARCHAR(255) NOT NULL,
            designation VARCHAR(255) NOT NULL,
            phone VARCHAR(20),
            role VARCHAR(50) DEFAULT 'officer',
            permissions JSONB DEFAULT '{}',
            is_active BOOLEAN DEFAULT true,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        RAISE NOTICE 'Created government_officials table';
    ELSE
        RAISE NOTICE 'government_officials table already exists';
    END IF;
END $$;

-- ==========================================
-- 2. STORAGE BUCKETS (Safe Creation)
-- ==========================================

-- Create storage buckets safely
INSERT INTO storage.buckets (id, name, public)
VALUES
    ('resumes', 'resumes', true),
    ('documents', 'documents', true),
    ('profile-images', 'profile-images', true),
    ('certificates', 'certificates', true),
    ('experience-proofs', 'experience-proofs', true),
    ('company-logos', 'company-logos', true),
    ('internship-posters', 'internship-posters', true),
    ('grievance-attachments', 'grievance-attachments', true),
    ('update-images', 'update-images', true)
ON CONFLICT (id) DO NOTHING;

-- ==========================================
-- 3. CLEAN UP EXISTING POLICIES
-- ==========================================

-- Drop all existing storage policies to avoid conflicts
DO $$
DECLARE
    policy_record RECORD;
BEGIN
    FOR policy_record IN
        SELECT policyname
        FROM pg_policies
        WHERE tablename = 'objects' AND schemaname = 'storage'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', policy_record.policyname);
        RAISE NOTICE 'Dropped policy: %', policy_record.policyname;
    END LOOP;
END $$;

-- ==========================================
-- 4. CREATE STORAGE POLICIES
-- ==========================================

-- Resumes policies
CREATE POLICY "Users can upload own resume" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'resumes' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can view own resume" ON storage.objects FOR SELECT USING (bucket_id = 'resumes' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can update own resume" ON storage.objects FOR UPDATE USING (bucket_id = 'resumes' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can delete own resume" ON storage.objects FOR DELETE USING (bucket_id = 'resumes' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Documents policies
CREATE POLICY "Users can upload own documents" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'documents' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can view own documents" ON storage.objects FOR SELECT USING (bucket_id = 'documents' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Government can view all documents" ON storage.objects FOR SELECT USING (bucket_id = 'documents' AND EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id'));

-- Profile Images policies
CREATE POLICY "Users can upload own profile image" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'profile-images' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Anyone can view profile images" ON storage.objects FOR SELECT USING (bucket_id = 'profile-images');

-- Certificates policies
CREATE POLICY "Users can upload own certificates" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'certificates' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can view own certificates" ON storage.objects FOR SELECT USING (bucket_id = 'certificates' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Government can view all certificates" ON storage.objects FOR SELECT USING (bucket_id = 'certificates' AND EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id'));

-- Experience Proofs policies
CREATE POLICY "Users can upload own experience proofs" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'experience-proofs' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can view own experience proofs" ON storage.objects FOR SELECT USING (bucket_id = 'experience-proofs' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Government can view all experience proofs" ON storage.objects FOR SELECT USING (bucket_id = 'experience-proofs' AND EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id'));

-- Company Logos policies
CREATE POLICY "Recruiters can upload company logos" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'company-logos' AND EXISTS (SELECT 1 FROM recruiter_profiles WHERE id::text = (storage.foldername(name))[1] AND auth.uid() = id));
CREATE POLICY "Anyone can view company logos" ON storage.objects FOR SELECT USING (bucket_id = 'company-logos');

-- Internship Posters policies
CREATE POLICY "Recruiters can upload internship posters" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'internship-posters' AND EXISTS (SELECT 1 FROM internship_postings WHERE id::text = (storage.foldername(name))[1] AND recruiter_id = auth.uid()));
CREATE POLICY "Anyone can view internship posters" ON storage.objects FOR SELECT USING (bucket_id = 'internship-posters');

-- Grievance Attachments policies
CREATE POLICY "Users can upload grievance attachments" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'grievance-attachments' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can view own grievance attachments" ON storage.objects FOR SELECT USING (bucket_id = 'grievance-attachments' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Government can view all grievance attachments" ON storage.objects FOR SELECT USING (bucket_id = 'grievance-attachments' AND EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id'));

-- ==========================================
-- 5. ENABLE ROW LEVEL SECURITY
-- ==========================================

-- Enable RLS on core tables (safe)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE recruiter_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE government_officials ENABLE ROW LEVEL SECURITY;

-- ==========================================
-- 6. BASIC POLICIES FOR CORE TABLES
-- ==========================================

-- Profiles policies (essential for OAuth)
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Recruiter profiles policies
DROP POLICY IF EXISTS "Recruiters can manage own profile" ON recruiter_profiles;
CREATE POLICY "Recruiters can manage own profile" ON recruiter_profiles FOR ALL USING (auth.uid() = id);

-- Government officials policies
DROP POLICY IF EXISTS "Government officials can view all" ON government_officials;
CREATE POLICY "Government officials can view all" ON government_officials FOR SELECT USING (
    EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id')
);

-- ==========================================
-- SUCCESS MESSAGE
-- ==========================================

SELECT
    'Database core setup completed successfully!' as status,
    'Tables created: profiles, recruiter_profiles, government_officials' as tables_created,
    'Storage buckets and policies configured' as storage_setup,
    'Row Level Security enabled' as security_enabled;