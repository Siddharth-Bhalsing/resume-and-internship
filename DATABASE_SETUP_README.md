# Chanakya Internship and Resume Verifier - Database Setup

## Overview
This repository contains the complete database schema for the Chanakya Internship and Resume Verifier application. The database is designed to handle user management, internship postings, resume verification, government programs, and support systems.

## Database Structure

### Tables Overview
- **User Management**: `profiles`, `recruiter_profiles`, `government_officials`
- **Internship Management**: `internship_postings`, `internships`, `applications`, `workflow_status`
- **Verification System**: `resume_verifications`, `skills_assessments`, `document_verifications`
- **Support & Communication**: `notifications`, `grievances`, `updates`
- **Government Programs**: `schemes`

### Storage Buckets
- `resumes` - Student resume files
- `documents` - General document uploads
- `profile-images` - User profile pictures
- `certificates` - Educational certificates
- `experience-proofs` - Work experience documents
- `company-logos` - Company branding
- `internship-posters` - Internship advertisements
- `grievance-attachments` - Support ticket attachments
- `update-images` - Announcement images

## Setup Instructions

### Option 1: Complete Setup (Recommended)
1. Open Supabase Dashboard
2. Go to SQL Editor
3. Copy and paste the contents of `database_master_setup.sql`
4. Execute the script

### Option 2: Modular Setup
If you prefer to set up components separately:

1. **Run in this order:**
   - `database_01_user_management.sql`
   - `database_02_internship_management.sql`
   - `database_03_resume_verification.sql`
   - `database_04_support_communication.sql`
   - `database_05_government_programs.sql`
   - `database_06_storage_management.sql`

2. **For each file:**
   - Open Supabase SQL Editor
   - Copy and paste the file contents
   - Execute

## Key Features

### Security
- **Row Level Security (RLS)** enabled on all tables
- **Authentication** integrated with Supabase Auth
- **Role-based access control** for different user types

### Automation
- **Triggers** for automatic ID generation
- **Notifications** for status changes
- **Resume completion** calculation
- **Updated timestamps** automatic maintenance

### Performance
- **Indexes** on frequently queried columns
- **Optimized queries** for common operations
- **Efficient storage** policies

## Sample Data Included

The setup includes sample data for:
- Government officials
- Recruiter profiles
- Government schemes
- System announcements

## Environment Variables Required

Add these to your `.env.local` file:

```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

## Testing the Setup

After setup, you can test with:

1. **User Registration**: Create student accounts
2. **Recruiter Onboarding**: Register company representatives
3. **Internship Posting**: Submit and approve internships
4. **Application Process**: Students apply for internships
5. **Verification System**: Upload and verify documents

## Troubleshooting

### Common Issues

1. **Permission Errors**: Ensure you're using the service role key for admin operations
2. **RLS Blocking Queries**: Check that your policies allow the required operations
3. **Storage Upload Issues**: Verify bucket policies and user authentication

### Reset Database
If you need to reset:
```sql
-- Run this in Supabase SQL Editor
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
```

## Support

For issues with database setup:
1. Check Supabase logs in the dashboard
2. Verify all SQL files executed without errors
3. Ensure environment variables are correctly set
4. Test with a simple user registration first

## Version History

- **v1.0.0**: Initial complete database schema
- Includes all core functionality for the internship platform
- Comprehensive verification and support systems
- Government program management
- Real-time notifications and updates