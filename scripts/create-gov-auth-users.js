/**
 * Create Supabase Auth Users for Government Officials
 * 
 * This script creates auth users for government officials who exist in the
 * government_officials table but don't have corresponding auth accounts.
 * 
 * Usage: node scripts/create-gov-auth-users.js
 */

require('dotenv').config({ path: '.env.local' })
const { createClient } = require('@supabase/supabase-js')

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('❌ Missing required environment variables:')
  console.error('   - NEXT_PUBLIC_SUPABASE_URL')
  console.error('   - SUPABASE_SERVICE_ROLE_KEY')
  console.error('\nPlease check your .env.local file.')
  process.exit(1)
}

// Create admin client with service role key
const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
})

// Government officials data (must match database)
const PASSWORD = 'gov123456' // Standard password for all government officials

async function createGovernmentAuthUsers() {
  console.log('🏛️  Creating Supabase Auth Users for Government Officials\n')

  try {
    // Fetch all government officials from the database
    const { data: officials, error: fetchError } = await supabase
      .from('government_officials')
      .select('*')
      .eq('is_active', true)

    if (fetchError) {
      console.error('❌ Error fetching government officials:', fetchError.message)
      return
    }

    if (!officials || officials.length === 0) {
      console.error('❌ No government officials found in database.')
      console.log('\n💡 Tip: Run setup-database-with-auth.sql first to create officials in the database.')
      return
    }

    console.log(`📋 Found ${officials.length} government officials in database:\n`)

    let successCount = 0
    let skipCount = 0
    let errorCount = 0

    for (const official of officials) {
      console.log(`\n👤 Processing: ${official.name} (${official.employee_id})`)
      console.log(`   Email: ${official.email}`)

      // Check if auth user already exists
      const { data: existingUsers } = await supabase.auth.admin.listUsers()
      const userExists = existingUsers?.users?.some(user => user.email === official.email)

      if (userExists) {
        console.log('   ⏭️  User already exists - skipping')
        skipCount++
        continue
      }

      // Create auth user
      const { data: authUser, error: authError } = await supabase.auth.admin.createUser({
        email: official.email,
        password: PASSWORD,
        email_confirm: true,
        user_metadata: {
          full_name: official.name,
          employee_id: official.employee_id,
          role: 'government',
          designation: official.designation,
          ministry: official.ministry
        }
      })

      if (authError) {
        console.error(`   ❌ Error creating auth user: ${authError.message}`)
        errorCount++
        continue
      }

      console.log(`   ✅ Auth user created successfully`)
      console.log(`   🔑 Password: ${PASSWORD}`)
      successCount++

      // Create/update profile
      const { error: profileError } = await supabase
        .from('profiles')
        .upsert({
          id: authUser.user.id,
          full_name: official.name,
          email: official.email,
          role: 'government',
          profile_completed: true,
        }, {
          onConflict: 'id'
        })

      if (profileError) {
        console.warn(`   ⚠️  Profile creation warning: ${profileError.message}`)
      } else {
        console.log(`   ✅ Profile created/updated`)
      }
    }

    // Summary
    console.log('\n' + '='.repeat(60))
    console.log('📊 Summary:')
    console.log(`   ✅ Successfully created: ${successCount}`)
    console.log(`   ⏭️  Skipped (already exists): ${skipCount}`)
    console.log(`   ❌ Errors: ${errorCount}`)
    console.log('='.repeat(60))

    if (successCount > 0) {
      console.log('\n🎉 Auth users created successfully!')
      console.log('\n📝 Login Credentials:')
      console.log('   Employee IDs: EMP001, EMP002, EMP003')
      console.log(`   Password: ${PASSWORD}`)
      console.log('   URL: http://localhost:3000/gov-login')
    }

  } catch (error) {
    console.error('\n❌ Unexpected error:', error.message)
    process.exit(1)
  }
}

// Run the script
createGovernmentAuthUsers()
  .then(() => {
    console.log('\n✨ Script completed')
    process.exit(0)
  })
  .catch((error) => {
    console.error('\n❌ Script failed:', error)
    process.exit(1)
  })
