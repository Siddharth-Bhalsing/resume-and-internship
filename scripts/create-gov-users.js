// Create Supabase Auth users for government officials
// Run with: node scripts/create-gov-users.js

const { createClient } = require('@supabase/supabase-js')
require('dotenv').config({ path: '.env.local' })

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('❌ Missing environment variables')
  console.log('NEXT_PUBLIC_SUPABASE_URL:', supabaseUrl ? '✅' : '❌')
  console.log('SUPABASE_SERVICE_ROLE_KEY:', supabaseServiceKey ? '✅' : '❌')
  process.exit(1)
}

// Create admin client with service role
const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
})

const governmentOfficials = [
  {
    id: '550e8400-e29b-41d4-a716-446655440001',
    employee_id: 'EMP001',
    name: 'Dr. Rajesh Kumar',
    email: 'rajesh.kumar@gov.in',
    password: 'gov123456'
  },
  {
    id: '550e8400-e29b-41d4-a716-446655440002',
    employee_id: 'EMP002',
    name: 'Ms. Priya Sharma',
    email: 'priya.sharma@gov.in',
    password: 'gov123456'
  },
  {
    id: '550e8400-e29b-41d4-a716-446655440003',
    employee_id: 'EMP003',
    name: 'Mr. Amit Singh',
    email: 'amit.singh@gov.in',
    password: 'gov123456'
  }
]

async function createGovernmentUsers() {
  console.log('🏛️ Creating Supabase Auth users for government officials...\n')

  for (const official of governmentOfficials) {
    try {
      console.log(`Creating user for ${official.name} (${official.email})...`)

      // Check if user already exists
      const { data: existingUser } = await supabaseAdmin.auth.admin.listUsers()
      const userExists = existingUser.users.some(user => user.email === official.email)

      if (userExists) {
        console.log(`✅ User already exists: ${official.email}`)
        continue
      }

      // Create the auth user
      const { data, error } = await supabaseAdmin.auth.admin.createUser({
        uid: official.id, // Use specific UUID
        email: official.email,
        password: official.password,
        email_confirm: true, // Auto-confirm email
        user_metadata: {
          full_name: official.name,
          role: 'government',
          employee_id: official.employee_id
        }
      })

      if (error) {
        console.error(`❌ Failed to create user ${official.email}:`, error.message)
      } else {
        console.log(`✅ Created user: ${official.email} (ID: ${data.user.id})`)

        // Update the government_officials record with the auth user ID if needed
        // The ID should already match from the SQL script
      }
    } catch (error) {
      console.error(`❌ Error creating user ${official.email}:`, error)
    }
  }

  console.log('\n🏛️ Government official user creation completed!')
  console.log('\n📋 Login Credentials:')
  console.log('Employee ID: EMP001 | Password: gov123456 | Email: rajesh.kumar@gov.in')
  console.log('Employee ID: EMP002 | Password: gov123456 | Email: priya.sharma@gov.in')
  console.log('Employee ID: EMP003 | Password: gov123456 | Email: amit.singh@gov.in')
}

createGovernmentUsers().catch(console.error)