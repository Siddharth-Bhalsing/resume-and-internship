-- ============================================
-- FIX RECRUITER LOGIN REDIRECT ISSUE
-- ============================================

-- STEP 1: Check if recruiters table exists and has data
SELECT COUNT(*) as recruiter_count FROM recruiters;

-- STEP 2: If the above query returns 0, INSERT TEST DATA:

INSERT INTO recruiters (organization_id, organization_name, organization_type, ministry, contact_person, email, approval_status)
VALUES 
('ORG001', 'National Informatics Centre', 'government', 'Ministry of Electronics & IT', 'Dr. Suresh Patel', 'contact@nic.in', 'approved'),
('ORG002', 'Indian Space Research Organisation', 'government', 'Department of Space', 'Dr. Kavitha Nair', 'contact@isro.gov.in', 'approved'),
('ORG003', 'Bharat Heavy Electricals Limited', 'psu', 'Ministry of Heavy Industries', 'Mr. Ravi Gupta', 'contact@bhel.in', 'approved'),
('ORG004', 'Defence Research and Development Organisation', 'government', 'Ministry of Defence', 'Dr. Anita Verma', 'contact@drdo.gov.in', 'approved'),
('ORG005', 'Indian Railways', 'government', 'Ministry of Railways', 'Mr. Sanjay Gupta', 'contact@indianrailways.gov.in', 'approved')
ON CONFLICT (organization_id) DO NOTHING;

-- STEP 3: Verify data was inserted:
SELECT organization_id, organization_name, email, approval_status FROM recruiters;

-- ============================================
-- IMPORTANT: PASSWORD IS NOT IN THIS TABLE!
-- ============================================
-- The password 'recruiter123' is HARDCODED in the authentication code (lib/supabase.ts)
-- It's NOT stored in the database - this is mock authentication!

-- ============================================
-- IF TABLE DOESN'T EXIST, CREATE IT:
-- ============================================

CREATE TABLE IF NOT EXISTS recruiters (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    organization_id VARCHAR(50) UNIQUE NOT NULL,
    organization_name VARCHAR(255) NOT NULL,
    organization_type VARCHAR(100) NOT NULL,
    ministry VARCHAR(255),
    contact_person VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    approval_status VARCHAR(50) DEFAULT 'approved',
    approved_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Then run the INSERT statements above
