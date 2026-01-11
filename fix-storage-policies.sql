-- ==========================================
-- CHANAKYA INTERNSHIP DATABASE - CLEAN DEPLOYMENT
-- ==========================================
-- This script handles existing policies and deploys safely
-- ==========================================

-- First, drop existing storage policies if they exist
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

-- Now recreate the storage policies
CREATE POLICY "Users can upload own resume" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'resumes' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can view own resume" ON storage.objects FOR SELECT USING (bucket_id = 'resumes' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can update own resume" ON storage.objects FOR UPDATE USING (bucket_id = 'resumes' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can delete own resume" ON storage.objects FOR DELETE USING (bucket_id = 'resumes' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can upload own documents" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'documents' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can view own documents" ON storage.objects FOR SELECT USING (bucket_id = 'documents' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Government can view all documents" ON storage.objects FOR SELECT USING (bucket_id = 'documents' AND EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id'));

CREATE POLICY "Users can upload own profile image" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'profile-images' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Anyone can view profile images" ON storage.objects FOR SELECT USING (bucket_id = 'profile-images');

CREATE POLICY "Users can upload own certificates" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'certificates' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can view own certificates" ON storage.objects FOR SELECT USING (bucket_id = 'certificates' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Government can view all certificates" ON storage.objects FOR SELECT USING (bucket_id = 'certificates' AND EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id'));

CREATE POLICY "Users can upload own experience proofs" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'experience-proofs' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can view own experience proofs" ON storage.objects FOR SELECT USING (bucket_id = 'experience-proofs' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Government can view all experience proofs" ON storage.objects FOR SELECT USING (bucket_id = 'experience-proofs' AND EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id'));

CREATE POLICY "Recruiters can upload company logos" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'company-logos' AND EXISTS (SELECT 1 FROM recruiter_profiles WHERE id::text = (storage.foldername(name))[1] AND auth.uid() = id));
CREATE POLICY "Anyone can view company logos" ON storage.objects FOR SELECT USING (bucket_id = 'company-logos');

CREATE POLICY "Recruiters can upload internship posters" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'internship-posters' AND EXISTS (SELECT 1 FROM internship_postings WHERE id::text = (storage.foldername(name))[1] AND recruiter_id = auth.uid()));
CREATE POLICY "Anyone can view internship posters" ON storage.objects FOR SELECT USING (bucket_id = 'internship-posters');

CREATE POLICY "Users can upload grievance attachments" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'grievance-attachments' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can view own grievance attachments" ON storage.objects FOR SELECT USING (bucket_id = 'grievance-attachments' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Government can view all grievance attachments" ON storage.objects FOR SELECT USING (bucket_id = 'grievance-attachments' AND EXISTS (SELECT 1 FROM government_officials WHERE employee_id = auth.jwt() ->> 'employee_id'));

-- Success message
SELECT 'Database storage policies updated successfully!' as status;