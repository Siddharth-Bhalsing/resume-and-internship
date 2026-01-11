-- ==========================================
-- CHANAKYA INTERNSHIP DATABASE - TABLES FIRST
-- ==========================================
-- Creates all tables first, then storage, then policies
-- ==========================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- 1. USER MANAGEMENT TABLES
-- ==========================================

-- Student Profiles Table
CREATE TABLE IF NOT EXISTS profiles (
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

-- Recruiter Profiles Table
CREATE TABLE IF NOT EXISTS recruiter_profiles (
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

-- Government Officials Table
CREATE TABLE IF NOT EXISTS government_officials (
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

-- ==========================================
-- 2. INTERNSHIP MANAGEMENT TABLES
-- ==========================================

-- Internship Postings Table
CREATE TABLE IF NOT EXISTS internship_postings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    recruiter_id UUID REFERENCES recruiter_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    requirements TEXT,
    responsibilities TEXT,
    department TEXT,
    location TEXT,
    work_type TEXT CHECK (work_type IN ('remote', 'onsite', 'hybrid')),
    duration TEXT,
    stipend TEXT,
    max_applications INTEGER DEFAULT 50,
    current_applications INTEGER DEFAULT 0,
    deadline DATE,
    required_skills TEXT[],
    preferred_qualifications TEXT,
    education_level TEXT,
    screening_questions JSONB DEFAULT '[]',
    benefits TEXT[],
    company_description TEXT,
    contact_email TEXT,
    contact_phone TEXT,
    application_instructions TEXT,
    poster_url TEXT,
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'approved', 'rejected', 'live', 'closed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    approved_at TIMESTAMP WITH TIME ZONE,
    approved_by UUID,
    submitted_at TIMESTAMP WITH TIME ZONE,
    reviewed_at TIMESTAMP WITH TIME ZONE
);

-- Live Internships Table
CREATE TABLE IF NOT EXISTS internships (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    posting_id UUID REFERENCES internship_postings(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    company VARCHAR(255) NOT NULL,
    ministry VARCHAR(255) NOT NULL,
    department VARCHAR(255),
    location VARCHAR(255) NOT NULL,
    type VARCHAR(100) NOT NULL,
    duration VARCHAR(100) NOT NULL,
    stipend VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    requirements TEXT NOT NULL,
    skills TEXT NOT NULL,
    applications INTEGER DEFAULT 0,
    max_applications INTEGER DEFAULT 100,
    deadline DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    posted_by UUID REFERENCES government_officials(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Applications Table
CREATE TABLE IF NOT EXISTS applications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    student_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    internship_id UUID REFERENCES internships(id) ON DELETE CASCADE,
    posting_id UUID REFERENCES internship_postings(id) ON DELETE CASCADE,
    application_data JSONB NOT NULL,
    resume_url TEXT,
    cover_letter_url TEXT,
    additional_documents JSONB DEFAULT '[]',
    status VARCHAR(50) DEFAULT 'submitted',
    recruiter_status VARCHAR(50) DEFAULT 'pending',
    government_status VARCHAR(50) DEFAULT 'pending',
    application_id VARCHAR(20) UNIQUE,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Workflow Status Tracking
CREATE TABLE IF NOT EXISTS workflow_status (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    posting_id UUID REFERENCES internship_postings(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL,
    changed_by UUID,
    changed_by_type VARCHAR(50) NOT NULL,
    comments TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- 3. RESUME & VERIFICATION TABLES
-- ==========================================

-- Resume Verifications Table
CREATE TABLE IF NOT EXISTS resume_verifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    resume_url TEXT,
    resume_analysis JSONB DEFAULT '{}',
    certificate_number VARCHAR(100),
    certificate_verified BOOLEAN DEFAULT FALSE,
    experience_documents TEXT[],
    experience_verified BOOLEAN DEFAULT FALSE,
    github_username VARCHAR(100),
    github_verified BOOLEAN DEFAULT FALSE,
    github_data JSONB DEFAULT '{}',
    linkedin_profile VARCHAR(255),
    linkedin_verified BOOLEAN DEFAULT FALSE,
    linkedin_data JSONB DEFAULT '{}',
    skills_assessed TEXT[],
    skills_scores JSONB DEFAULT '{}',
    verification_status VARCHAR(50) DEFAULT 'pending',
    completion_percentage INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Skills Assessments Table
CREATE TABLE IF NOT EXISTS skills_assessments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    skill_name VARCHAR(100) NOT NULL,
    assessment_type VARCHAR(50) DEFAULT 'quiz',
    questions JSONB DEFAULT '{}',
    answers JSONB DEFAULT '{}',
    score INTEGER,
    max_score INTEGER DEFAULT 100,
    duration_minutes INTEGER,
    status VARCHAR(50) DEFAULT 'pending',
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Document Verifications Table
CREATE TABLE IF NOT EXISTS document_verifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    document_type VARCHAR(100) NOT NULL,
    document_url TEXT,
    verification_status VARCHAR(50) DEFAULT 'pending',
    verification_notes TEXT,
    verified_by UUID REFERENCES government_officials(id),
    verified_at TIMESTAMP WITH TIME ZONE,
    expiry_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- 4. SUPPORT & COMMUNICATION TABLES
-- ==========================================

-- Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    category VARCHAR(50) DEFAULT 'general',
    related_id UUID,
    related_type VARCHAR(50),
    read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Grievances Table
CREATE TABLE IF NOT EXISTS grievances (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    grievance_id VARCHAR(50) UNIQUE,
    category VARCHAR(100) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    priority VARCHAR(50) DEFAULT 'medium',
    status VARCHAR(50) DEFAULT 'open',
    assigned_to UUID REFERENCES government_officials(id),
    resolution TEXT,
    attachments TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Updates/Announcements Table
CREATE TABLE IF NOT EXISTS updates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    image TEXT,
    category VARCHAR(100) DEFAULT 'announcement',
    priority INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    published_by UUID REFERENCES government_officials(id),
    published_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- 5. GOVERNMENT PROGRAMS TABLES
-- ==========================================

-- Schemes Table
CREATE TABLE IF NOT EXISTS schemes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    department VARCHAR(255) NOT NULL,
    ministry VARCHAR(255),
    description TEXT NOT NULL,
    duration VARCHAR(100),
    stipend VARCHAR(100),
    eligibility TEXT,
    features TEXT[],
    locations TEXT[],
    deadline DATE,
    slots INTEGER,
    image_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- INDEXES FOR PERFORMANCE
-- ==========================================

-- User Management Indexes
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_profile_completed ON profiles(profile_completed);
CREATE INDEX IF NOT EXISTS idx_profiles_profile_step ON profiles(profile_step);
CREATE INDEX IF NOT EXISTS idx_recruiter_profiles_contact_email ON recruiter_profiles(contact_email);
CREATE INDEX IF NOT EXISTS idx_recruiter_profiles_approval_status ON recruiter_profiles(approval_status);
CREATE INDEX IF NOT EXISTS idx_government_officials_employee_id ON government_officials(employee_id);
CREATE INDEX IF NOT EXISTS idx_government_officials_email ON government_officials(email);

-- Internship Management Indexes
CREATE INDEX IF NOT EXISTS idx_internship_postings_recruiter_id ON internship_postings(recruiter_id);
CREATE INDEX IF NOT EXISTS idx_internship_postings_status ON internship_postings(status);
CREATE INDEX IF NOT EXISTS idx_internship_postings_deadline ON internship_postings(deadline);
CREATE INDEX IF NOT EXISTS idx_internships_status ON internships(status);
CREATE INDEX IF NOT EXISTS idx_internships_deadline ON internships(deadline);
CREATE INDEX IF NOT EXISTS idx_internships_ministry ON internships(ministry);
CREATE INDEX IF NOT EXISTS idx_applications_student_id ON applications(student_id);
CREATE INDEX IF NOT EXISTS idx_applications_internship_id ON applications(internship_id);
CREATE INDEX IF NOT EXISTS idx_applications_status ON applications(status);

-- Verification Indexes
CREATE INDEX IF NOT EXISTS idx_resume_verifications_user_id ON resume_verifications(user_id);
CREATE INDEX IF NOT EXISTS idx_resume_verifications_status ON resume_verifications(verification_status);
CREATE INDEX IF NOT EXISTS idx_skills_assessments_user_id ON skills_assessments(user_id);
CREATE INDEX IF NOT EXISTS idx_document_verifications_user_id ON document_verifications(user_id);

-- Support Indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(read);
CREATE INDEX IF NOT EXISTS idx_grievances_user_id ON grievances(user_id);
CREATE INDEX IF NOT EXISTS idx_grievances_status ON grievances(status);
CREATE INDEX IF NOT EXISTS idx_updates_is_active ON updates(is_active);

-- Government Programs Indexes
CREATE INDEX IF NOT EXISTS idx_schemes_is_active ON schemes(is_active);
CREATE INDEX IF NOT EXISTS idx_schemes_ministry ON schemes(ministry);

-- ==========================================
-- SUCCESS MESSAGE
-- ==========================================

SELECT 'All database tables created successfully!' as status;