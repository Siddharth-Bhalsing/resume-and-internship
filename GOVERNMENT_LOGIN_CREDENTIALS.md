# Government Login Credentials

## 🏛️ **PM Internship Portal - Login Credentials**

## 🏛️ Government Officials (Working Credentials)

**Standard Password for All**: `goverment`

- **Employee ID**: `EMP001`
  - Name: Dr. Rajesh Kumar
  - Email: rajesh.kumar@gov.in
  - Designation: Joint Secretary
  - Ministry: Ministry of Education
  
- **Employee ID**: `EMP002`
  - Name: Ms. Priya Sharma  
  - Email: priya.sharma@gov.in
  - Designation: Director
  - Ministry: Ministry of Electronics & IT
  
- **Employee ID**: `EMP003`
  - Name: Mr. Amit Singh
  - Email: amit.singh@gov.in
  - Designation: Under Secretary
  - Ministry: Ministry of Skill Development

## 🏢 Recruiters/Organizations
- **Organization ID**: `ORG001` | **Password**: `recruiter123`
  - Organization: National Informatics Centre
  - Ministry: Ministry of Electronics & IT
  
- **Organization ID**: `ORG002` | **Password**: `recruiter123`
  - Organization: Indian Space Research Organisation
  - Ministry: Department of Space
  
- **Organization ID**: `ORG003` | **Password**: `recruiter123`
  - Organization: Bharat Heavy Electricals Limited
  - Ministry: Ministry of Heavy Industries
  
- **Organization ID**: `ORG004` | **Password**: `recruiter123`
  - Organization: Defence Research and Development Organisation
  - Ministry: Ministry of Defence
  
- **Organization ID**: `ORG005` | **Password**: `recruiter123`
  - Organization: Indian Railways
  - Ministry: Ministry of Railways

## 📋 Setup Instructions

### Step 1: Create Database Tables
1. Run `setup-database-with-auth.sql` in Supabase SQL Editor
2. This creates the `government_officials` table and inserts test officials

### Step 2: Create Auth Users
```bash
node scripts/create-gov-auth-users.js
```
This creates Supabase Auth users for all government officials.

### Step 3: Test Login
1. Go to: http://localhost:3000/gov-login
2. Use any employee ID: `EMP001`, `EMP002`, or `EMP003`
3. Password: `goverment`
4. Enter the CAPTCHA code
5. Click "Secure Login"

✅ All organizations are pre-approved for immediate use

---

## 🔐 **How to Login:**

### **Step 1: Access Government Portal**
- Go to: `/gov-login`
- Use any of the Employee IDs above
- Enter the corresponding password

### **Step 2: Complete Security**
- Enter the displayed CAPTCHA code
- Click "Secure Login"

### **Step 3: OTP Verification**
- Enter any 6-digit number (e.g., `123456`)
- Click "Verify & Access Dashboard"

### **Step 4: Access Dashboard**
- You'll be redirected to `/gov-dashboard`
- Full access to post internships, manage applications, etc.

---

## 📊 **Database Setup Required:**

**Before using these credentials, run this SQL in your Supabase SQL Editor:**

```sql
-- Run the fix-database.sql file to create all tables and insert sample data
-- This includes the government_officials table with these credentials
```

---

## 🎯 **Features Available After Login:**

1. **Post New Internships** - Real-time posting to student dashboard
2. **Manage Applications** - Review and process student applications  
3. **Student Verification** - Verify profiles and documents
4. **Analytics Dashboard** - View statistics and reports
5. **Notification System** - Send updates to students
6. **Certificate Management** - Issue completion certificates

---

## 🔧 **Technical Notes:**

- Credentials are stored in `government_officials` table
- Session data stored in browser sessionStorage
- Real-time integration with student dashboard via Supabase
- All government actions are logged and tracked

**Ready to use immediately after running the database setup!** 🚀
