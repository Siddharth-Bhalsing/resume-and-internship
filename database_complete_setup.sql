-- ==========================================
-- CHANAKYA INTERNSHIP AND RESUME VERIFIER
-- COMPLETE DATABASE SCHEMA - ALL TABLES
-- ==========================================
-- This file contains the complete database setup for the
-- Chanakya Internship and Resume Verifier application.
-- Execute this file in Supabase SQL Editor for complete setup.
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
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    full_name TEXT,
    designation TEXT,
    employee_id TEXT,
    company_name TEXT,
    company_type TEXT,
    industry TEXT,
    company_size TEXT,
    website TEXT,
    email TEXT,
    phone TEXT,
    alternate_phone TEXT,
    address_line1 TEXT,
    address_line2 TEXT,
    city TEXT,
    state TEXT,
    pincode TEXT,
    company_registration_url TEXT,
    authorization_letter_url TEXT,
    id_proof_url TEXT,
    internship_types TEXT[],
    internship_alignment TEXT[],
    preferred_skills TEXT,
    min_duration TEXT,
    max_duration TEXT,
    stipend_range TEXT,
    terms_accepted BOOLEAN DEFAULT FALSE,
    data_consent BOOLEAN DEFAULT FALSE,
    profile_step INTEGER DEFAULT 1,
    profile_completed BOOLEAN DEFAULT FALSE,
    approval_status TEXT DEFAULT 'pending' CHECK (approval_status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    approved_at TIMESTAMP WITH TIME ZONE,
    approved_by UUID
);

-- Government Officials Table
CREATE TABLE IF NOT EXISTS government_officials (
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
CREATE INDEX IF NOT EXISTS idx_recruiter_profiles_email ON recruiter_profiles(email);
CREATE INDEX IF NOT EXISTS idx_recruiter_profiles_approval_status ON recruiter_profiles(approval_status);
CREATE INDEX IF NOT EXISTS idx_government_officials_employee_id ON government_officials(employee_id);

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
-- ROW LEVEL SECURITY POLICIES
-- ==========================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE recruiter_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE government_officials ENABLE ROW LEVEL SECURITY;
ALTER TABLE internship_postings ENABLE ROW LEVEL SECURITY;
ALTER TABLE internships ENABLE ROW LEVEL SECURITY;
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE resume_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE skills_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE grievances ENABLE ROW LEVEL SECURITY;
ALTER TABLE updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE schemes ENABLE ROW LEVEL SECURITY;

-- User Management Policies
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Recruiters can manage own profile" ON recruiter_profiles FOR ALL USING (auth.uid() = id);
CREATE POLICY "Government officials can view all" ON government_officials FOR SELECT USING (
    EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id')
);

-- Internship Management Policies
CREATE POLICY "Recruiters can manage own postings" ON internship_postings FOR ALL USING (auth.uid() = recruiter_id);
CREATE POLICY "Government officials can view all postings" ON internship_postings FOR SELECT USING (
    EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id')
);
CREATE POLICY "Students can view approved internships" ON internships FOR SELECT USING (status = 'active');
CREATE POLICY "Users can manage own applications" ON applications FOR ALL USING (auth.uid() = student_id);

-- Verification Policies
CREATE POLICY "Users can view own resume verification" ON resume_verifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own resume verification" ON resume_verifications FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own resume verification" ON resume_verifications FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can view own assessments" ON skills_assessments FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own assessments" ON skills_assessments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can view own documents" ON document_verifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own documents" ON document_verifications FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Government can verify documents" ON document_verifications FOR UPDATE USING (
    EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id')
);

-- Support Policies
CREATE POLICY "Users can view own notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can view own grievances" ON grievances FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own grievances" ON grievances FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Government can manage grievances" ON grievances FOR ALL USING (
    EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id')
);
CREATE POLICY "Anyone can view active updates" ON updates FOR SELECT USING (is_active = true);
CREATE POLICY "Government can manage updates" ON updates FOR ALL USING (
    EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id')
);

-- Government Programs Policies
CREATE POLICY "Anyone can view active schemes" ON schemes FOR SELECT USING (is_active = true);
CREATE POLICY "Government can manage schemes" ON schemes FOR ALL USING (
    EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id')
);

-- ==========================================
-- FUNCTIONS AND TRIGGERS
-- ==========================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_applications_updated_at BEFORE UPDATE ON applications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_resume_verifications_updated_at BEFORE UPDATE ON resume_verifications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_grievances_updated_at BEFORE UPDATE ON grievances FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_internships_updated_at BEFORE UPDATE ON internships FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to generate application ID
CREATE OR REPLACE FUNCTION generate_application_id()
RETURNS TRIGGER AS $$
BEGIN
    NEW.application_id := 'PMI-' || UPPER(SUBSTRING(REPLACE(gen_random_uuid()::text, '-', ''), 1, 6));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_application_id_trigger BEFORE INSERT ON applications FOR EACH ROW EXECUTE FUNCTION generate_application_id();

-- Function to generate grievance ID
CREATE OR REPLACE FUNCTION generate_grievance_id()
RETURNS TRIGGER AS $$
BEGIN
    NEW.grievance_id := 'GRV-' || UPPER(SUBSTRING(REPLACE(gen_random_uuid()::text, '-', ''), 1, 6));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_grievance_id_trigger BEFORE INSERT ON grievances FOR EACH ROW EXECUTE FUNCTION generate_grievance_id();

-- Function to notify internship approval
CREATE OR REPLACE FUNCTION notify_internship_approved()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
        INSERT INTO notifications (user_id, title, message, type, related_id, related_type)
        SELECT NEW.recruiter_id, 'Internship Approved', 'Your internship posting "' || NEW.title || '" has been approved and is now live.', 'success', NEW.id, 'posting';
        INSERT INTO internships (posting_id, title, company, ministry, location, type, duration, stipend, description, requirements, skills, max_applications, deadline, posted_by)
        SELECT NEW.id, NEW.title, rp.company_name, 'Approved Organization', NEW.location, COALESCE(NEW.work_type, 'hybrid'), NEW.duration, NEW.stipend, NEW.description, NEW.requirements, array_to_string(NEW.required_skills, ', '), NEW.max_applications, NEW.deadline, NEW.approved_by FROM recruiter_profiles rp WHERE rp.id = NEW.recruiter_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER internship_approval_trigger AFTER UPDATE ON internship_postings FOR EACH ROW EXECUTE FUNCTION notify_internship_approved();

-- Function to notify new internships
CREATE OR REPLACE FUNCTION notify_new_internship()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO notifications (user_id, title, message, type, category, related_id, related_type)
    SELECT id, 'New Internship Posted: ' || NEW.title, 'A new internship opportunity has been posted at ' || NEW.company || '. Apply now!', 'info', 'internship', NEW.id, 'internship'
    FROM profiles WHERE profile_completed = true;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notify_new_internship_trigger AFTER INSERT ON internships FOR EACH ROW WHEN (NEW.status = 'active') EXECUTE FUNCTION notify_new_internship();

-- Function to notify application status changes
CREATE OR REPLACE FUNCTION notify_application_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status != OLD.status THEN
        INSERT INTO notifications (user_id, title, message, type, category, related_id, related_type)
        VALUES (NEW.student_id, 'Application Status Updated', 'Your application for internship has been ' || NEW.status || '.', CASE WHEN NEW.status = 'approved' THEN 'success' WHEN NEW.status = 'rejected' THEN 'error' ELSE 'info' END, 'application', NEW.id, 'application');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notify_application_status_trigger AFTER UPDATE ON applications FOR EACH ROW EXECUTE FUNCTION notify_application_status_change();

-- Function to calculate resume completion
CREATE OR REPLACE FUNCTION calculate_resume_completion()
RETURNS TRIGGER AS $$
BEGIN
    SELECT CASE WHEN NEW.resume_url IS NOT NULL THEN 20 ELSE 0 END + CASE WHEN NEW.certificate_verified THEN 20 ELSE 0 END + CASE WHEN NEW.experience_verified THEN 20 ELSE 0 END + CASE WHEN NEW.github_verified THEN 15 ELSE 0 END + CASE WHEN NEW.linkedin_verified THEN 15 ELSE 0 END + CASE WHEN array_length(NEW.skills_assessed, 1) > 0 THEN 10 ELSE 0 END INTO NEW.completion_percentage;
    IF NEW.completion_percentage >= 100 THEN NEW.verification_status := 'completed'; ELSIF NEW.completion_percentage > 0 THEN NEW.verification_status := 'in_progress'; ELSE NEW.verification_status := 'pending'; END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER calculate_resume_completion_trigger BEFORE UPDATE ON resume_verifications FOR EACH ROW EXECUTE FUNCTION calculate_resume_completion();

-- ==========================================
-- STORAGE BUCKETS
-- ==========================================

INSERT INTO storage.buckets (id, name, public) VALUES
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
-- STORAGE POLICIES
-- ==========================================

-- Resumes
CREATE POLICY "Users can upload own resume" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'resumes' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can view own resume" ON storage.objects FOR SELECT USING (bucket_id = 'resumes' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can update own resume" ON storage.objects FOR UPDATE USING (bucket_id = 'resumes' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can delete own resume" ON storage.objects FOR DELETE USING (bucket_id = 'resumes' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Documents
CREATE POLICY "Users can upload own documents" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'documents' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can view own documents" ON storage.objects FOR SELECT USING (bucket_id = 'documents' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Government can view all documents" ON storage.objects FOR SELECT USING (bucket_id = 'documents' AND EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id'));

-- Profile Images
CREATE POLICY "Users can upload own profile image" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'profile-images' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Anyone can view profile images" ON storage.objects FOR SELECT USING (bucket_id = 'profile-images');

-- Certificates
CREATE POLICY "Users can upload own certificates" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'certificates' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can view own certificates" ON storage.objects FOR SELECT USING (bucket_id = 'certificates' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Government can view all certificates" ON storage.objects FOR SELECT USING (bucket_id = 'certificates' AND EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id'));

-- Experience Proofs
CREATE POLICY "Users can upload own experience proofs" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'experience-proofs' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can view own experience proofs" ON storage.objects FOR SELECT USING (bucket_id = 'experience-proofs' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Government can view all experience proofs" ON storage.objects FOR SELECT USING (bucket_id = 'experience-proofs' AND EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id'));

-- Company Logos
CREATE POLICY "Recruiters can upload company logos" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'company-logos' AND EXISTS (SELECT 1 FROM recruiter_profiles WHERE id::text = (storage.foldername(name))[1] AND auth.uid() = id));
CREATE POLICY "Anyone can view company logos" ON storage.objects FOR SELECT USING (bucket_id = 'company-logos');

-- Internship Posters
CREATE POLICY "Recruiters can upload internship posters" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'internship-posters' AND EXISTS (SELECT 1 FROM internship_postings WHERE id::text = (storage.foldername(name))[1] AND recruiter_id = auth.uid()));
CREATE POLICY "Anyone can view internship posters" ON storage.objects FOR SELECT USING (bucket_id = 'internship-posters');

-- Grievance Attachments
CREATE POLICY "Users can upload grievance attachments" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'grievance-attachments' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can view own grievance attachments" ON storage.objects FOR SELECT USING (bucket_id = 'grievance-attachments' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Government can view all grievance attachments" ON storage.objects FOR SELECT USING (bucket_id = 'grievance-attachments' AND EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id'));

-- Update Images
CREATE POLICY "Government can upload update images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'update-images' AND EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id'));
CREATE POLICY "Anyone can view update images" ON storage.objects FOR SELECT USING (bucket_id = 'update-images');

-- ==========================================
-- SAMPLE DATA
-- ==========================================

-- Government Officials
INSERT INTO government_officials (employee_id, name, designation, ministry, email, role) VALUES
('GOV001', 'Dr. Rajesh Kumar', 'Joint Secretary', 'Ministry of Home Affairs', 'rajesh.kumar@gov.in', 'admin'),
('GOV002', 'Ms. Priya Sharma', 'Director', 'Ministry of Electronics & IT', 'priya.sharma@gov.in', 'officer'),
('GOV003', 'Mr. Amit Singh', 'Under Secretary', 'Ministry of Skill Development', 'amit.singh@gov.in', 'officer')
ON CONFLICT (employee_id) DO NOTHING;

-- Recruiter
INSERT INTO recruiter_profiles (full_name, designation, employee_id, company_name, company_type, industry, company_size, website, email, phone, address_line1, city, state, pincode, internship_types, internship_alignment, preferred_skills, min_duration, max_duration, stipend_range, terms_accepted, data_consent, profile_step, profile_completed, approval_status) VALUES
('Rajesh Kumar', 'Senior HR Manager', 'TCS001', 'Tata Consultancy Services', 'private', 'it', '1000+', 'https://www.tcs.com', 'hr@tcs.com', '+91 9876543210', 'TCS House, Raveline Street', 'Mumbai', 'Maharashtra', '400001', ARRAY['Technical', 'Research'], ARRAY['Web Development', 'Software Development', 'Testing'], 'Java, Python, React, Node.js, Database Management', '3', '12', '25000-50000', TRUE, TRUE, 6, TRUE, 'approved')
ON CONFLICT DO NOTHING;

-- Schemes
INSERT INTO schemes (title, department, ministry, description, duration, stipend, eligibility, features, locations, slots) VALUES
('Chanakya Internship Scheme', 'Ministry of Home Affairs', 'Ministry of Home Affairs', 'Flagship internship program providing hands-on experience in government departments', '6-12 months', '₹25,000 - ₹40,000', 'Graduate/Post-graduate in any discipline', ARRAY['Direct mentorship', 'Policy exposure', 'Government certificate'], ARRAY['New Delhi', 'Mumbai', 'Bangalore'], 10000),
('Digital India Internship', 'Ministry of Electronics and IT', 'Ministry of Electronics and IT', 'Technology-focused internships in AI, ML, and Digital Governance', '3-6 months', '₹30,000 - ₹50,000', 'Engineering/MCA/MSc in Computer Science', ARRAY['Tech projects', 'Innovation labs', 'Startup exposure'], ARRAY['Hyderabad', 'Pune', 'Chennai'], 5000)
ON CONFLICT DO NOTHING;

-- Updates
INSERT INTO updates (title, content, category, priority, is_active, published_by) VALUES
('Welcome to Chanakya Internship Portal', 'We are excited to launch the Chanakya Internship and Resume Verifier platform. This initiative aims to connect talented students with premier organizations while ensuring the highest standards of verification and skill assessment.', 'announcement', 5, TRUE, (SELECT id FROM government_officials WHERE employee_id = 'GOV001' LIMIT 1))
ON CONFLICT DO NOTHING;

-- ==========================================
-- ENABLE REALTIME
-- ==========================================

ALTER PUBLICATION supabase_realtime ADD TABLE internships;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE applications;
ALTER PUBLICATION supabase_realtime ADD TABLE updates;

-- ==========================================
-- GRANT PERMISSIONS
-- ==========================================

GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- ==========================================
-- SETUP COMPLETION MESSAGE
-- ==========================================

SELECT '🎉 Chanakya Internship and Resume Verifier database setup completed successfully!' as status;
SELECT '✅ All tables, policies, functions, and triggers created' as setup_status;
SELECT '✅ Sample data inserted for testing' as sample_data;
SELECT '✅ Storage buckets and policies configured' as storage_status;
SELECT '🚀 Ready for deployment and testing!' as next_steps;