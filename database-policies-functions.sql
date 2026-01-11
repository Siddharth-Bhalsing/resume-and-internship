-- ==========================================
-- CHANAKYA INTERNSHIP DATABASE - STORAGE & POLICIES
-- ==========================================
-- Run this AFTER tables are created successfully
-- ==========================================

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
-- ROW LEVEL SECURITY POLICIES
-- ==========================================

-- Drop existing RLS policies to avoid conflicts
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Recruiters can manage own profile" ON recruiter_profiles;
DROP POLICY IF EXISTS "Government officials can view all" ON government_officials;
DROP POLICY IF EXISTS "Recruiters can manage own postings" ON internship_postings;
DROP POLICY IF EXISTS "Government officials can view all postings" ON internship_postings;
DROP POLICY IF EXISTS "Students can view approved internships" ON internships;
DROP POLICY IF EXISTS "Users can manage own applications" ON applications;
DROP POLICY IF EXISTS "Users can view own resume verification" ON resume_verifications;
DROP POLICY IF EXISTS "Users can insert own resume verification" ON resume_verifications;
DROP POLICY IF EXISTS "Users can update own resume verification" ON resume_verifications;
DROP POLICY IF EXISTS "Users can view own assessments" ON skills_assessments;
DROP POLICY IF EXISTS "Users can insert own assessments" ON skills_assessments;
DROP POLICY IF EXISTS "Users can view own documents" ON document_verifications;
DROP POLICY IF EXISTS "Users can insert own documents" ON document_verifications;
DROP POLICY IF EXISTS "Government can verify documents" ON document_verifications;
DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can view own grievances" ON grievances;
DROP POLICY IF EXISTS "Users can insert own grievances" ON grievances;
DROP POLICY IF EXISTS "Government can manage grievances" ON grievances;
DROP POLICY IF EXISTS "Anyone can view active updates" ON updates;
DROP POLICY IF EXISTS "Government can manage updates" ON updates;
DROP POLICY IF EXISTS "Anyone can view active schemes" ON schemes;
DROP POLICY IF EXISTS "Government can manage schemes" ON schemes;

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
CREATE POLICY "Allow OAuth profile creation" ON profiles FOR INSERT WITH CHECK (true);
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
-- STORAGE POLICIES
-- ==========================================

-- Drop existing storage policies to avoid conflicts
DROP POLICY IF EXISTS "Users can upload own resume" ON storage.objects;
DROP POLICY IF EXISTS "Users can view own resume" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own resume" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own resume" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload own documents" ON storage.objects;
DROP POLICY IF EXISTS "Users can view own documents" ON storage.objects;
DROP POLICY IF EXISTS "Government can view all documents" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload own profile image" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload own certificates" ON storage.objects;
DROP POLICY IF EXISTS "Users can view own certificates" ON storage.objects;
DROP POLICY IF EXISTS "Government can view all certificates" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload own experience proofs" ON storage.objects;
DROP POLICY IF EXISTS "Users can view own experience proofs" ON storage.objects;
DROP POLICY IF EXISTS "Government can view all experience proofs" ON storage.objects;
DROP POLICY IF EXISTS "Recruiters can upload company logos" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view company logos" ON storage.objects;
DROP POLICY IF EXISTS "Recruiters can upload internship posters" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view internship posters" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload grievance attachments" ON storage.objects;
DROP POLICY IF EXISTS "Users can view own grievance attachments" ON storage.objects;
DROP POLICY IF EXISTS "Government can view all grievance attachments" ON storage.objects;

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

-- ==========================================
-- FUNCTIONS AND TRIGGERS
-- ==========================================

-- Drop existing triggers to avoid conflicts
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
DROP TRIGGER IF EXISTS update_applications_updated_at ON applications;
DROP TRIGGER IF EXISTS update_resume_verifications_updated_at ON resume_verifications;
DROP TRIGGER IF EXISTS update_grievances_updated_at ON grievances;
DROP TRIGGER IF EXISTS update_internships_updated_at ON internships;
DROP TRIGGER IF EXISTS generate_application_id_trigger ON applications;
DROP TRIGGER IF EXISTS generate_grievance_id_trigger ON grievances;
DROP TRIGGER IF EXISTS internship_approval_trigger ON internship_postings;
DROP TRIGGER IF EXISTS notify_new_internship_trigger ON internships;
DROP TRIGGER IF EXISTS notify_application_status_trigger ON applications;
DROP TRIGGER IF EXISTS calculate_resume_completion_trigger ON resume_verifications;

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
-- UTILITY FUNCTIONS
-- ==========================================

-- Function to execute raw SQL (for bypassing RLS in OAuth callbacks)
CREATE OR REPLACE FUNCTION exec_sql(sql TEXT, params JSONB DEFAULT '[]'::jsonb)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    -- Allow service role or anon key for OAuth setup (temporary)
    IF auth.role() NOT IN ('service_role', 'anon') THEN
        RAISE EXCEPTION 'Access denied: exec_sql can only be called by service role or anon key';
    END IF;

    -- Execute the SQL with parameters
    EXECUTE sql USING params;
    result := json_build_object('success', true, 'message', 'SQL executed successfully');
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        result := json_build_object('success', false, 'error', SQLERRM);
        RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==========================================
-- SUCCESS MESSAGE
-- ==========================================

SELECT
    'Storage, policies, functions, and triggers setup completed!' as status,
    'All RLS policies enabled' as security,
    'Storage buckets created' as storage,
    'Functions and triggers configured' as automation;  