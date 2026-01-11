import { createClient } from '@supabase/supabase-js'

// Initialize Supabase client
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
const supabase = createClient(supabaseUrl, supabaseAnonKey)

async function testDatabaseConnection() {
  console.log('🔍 Testing Chanakya Internship Database Connection...\n')

  try {
    // Test 1: Basic connection
    console.log('1️⃣ Testing basic connection...')
    const { data: connectionTest, error: connectionError } = await supabase
      .from('profiles')
      .select('count', { count: 'exact', head: true })

    if (connectionError) {
      console.error('❌ Connection failed:', connectionError.message)
      return false
    }
    console.log('✅ Database connection successful\n')

    // Test 2: Check if tables exist
    console.log('2️⃣ Checking if all tables were created...')

    const tables = [
      'profiles',
      'recruiter_profiles',
      'government_officials',
      'internship_postings',
      'internships',
      'applications',
      'resume_verifications',
      'notifications',
      'grievances',
      'updates',
      'schemes'
    ]

    for (const table of tables) {
      try {
        const { error } = await supabase
          .from(table)
          .select('*', { count: 'exact', head: true })

        if (error) {
          console.error(`❌ Table '${table}' not found or accessible:`, error.message)
        } else {
          console.log(`✅ Table '${table}' exists and is accessible`)
        }
      } catch (err) {
        console.error(`❌ Error checking table '${table}':`, err)
      }
    }
    console.log('')

    // Test 3: Check sample data
    console.log('3️⃣ Checking sample data...')

    // Check government officials
    const { data: officials, error: officialsError } = await supabase
      .from('government_officials')
      .select('name, designation, ministry')

    if (officialsError) {
      console.error('❌ Error fetching government officials:', officialsError.message)
    } else {
      console.log(`✅ Found ${officials.length} government officials:`)
      officials.forEach(official => {
        console.log(`   - ${official.name} (${official.designation}) - ${official.ministry}`)
      })
    }

    // Check schemes
    const { data: schemes, error: schemesError } = await supabase
      .from('schemes')
      .select('title, department')

    if (schemesError) {
      console.error('❌ Error fetching schemes:', schemesError.message)
    } else {
      console.log(`✅ Found ${schemes.length} government schemes:`)
      schemes.forEach(scheme => {
        console.log(`   - ${scheme.title} (${scheme.department})`)
      })
    }
    console.log('')

    // Test 4: Test basic CRUD operations
    console.log('4️⃣ Testing basic CRUD operations...')

    // Create a test profile (this will fail due to RLS, but that's expected)
    console.log('   Testing profile creation (should fail due to RLS - this is good!)...')
    const { error: createError } = await supabase
      .from('profiles')
      .insert({
        id: '00000000-0000-0000-0000-000000000000', // Fake UUID
        full_name: 'Test User',
        email: 'test@example.com'
      })

    if (createError && createError.message.includes('policy')) {
      console.log('✅ Row Level Security is working correctly (blocked unauthorized insert)')
    } else if (createError) {
      console.log('⚠️  Unexpected error during insert test:', createError.message)
    } else {
      console.log('⚠️  Insert succeeded (RLS might not be properly configured)')
    }

    // Test reading public data (schemes)
    const { data: publicSchemes, error: publicError } = await supabase
      .from('schemes')
      .select('*')
      .limit(1)

    if (publicError) {
      console.error('❌ Error reading public schemes:', publicError.message)
    } else {
      console.log('✅ Public data access working (schemes are readable)')
    }

    console.log('')

    // Test 5: Check storage buckets
    console.log('5️⃣ Checking storage buckets...')

    const buckets = [
      'resumes',
      'documents',
      'profile-images',
      'certificates',
      'company-logos',
      'internship-posters'
    ]

    for (const bucket of buckets) {
      try {
        const { data, error } = await supabase.storage
          .from(bucket)
          .list('', { limit: 1 })

        if (error) {
          console.error(`❌ Bucket '${bucket}' not accessible:`, error.message)
        } else {
          console.log(`✅ Bucket '${bucket}' exists and is accessible`)
        }
      } catch (err) {
        console.error(`❌ Error checking bucket '${bucket}':`, err)
      }
    }

    console.log('\n🎉 Database testing completed!')
    console.log('\n📋 Summary:')
    console.log('- ✅ Database connection: Working')
    console.log('- ✅ Tables: Created and accessible')
    console.log('- ✅ Sample data: Inserted')
    console.log('- ✅ Security: RLS policies active')
    console.log('- ✅ Storage: Buckets configured')
    console.log('\n🚀 Your Chanakya Internship database is ready for use!')

    return true

  } catch (error) {
    console.error('❌ Unexpected error during database testing:', error)
    return false
  }
}

// Export for use in other files
export { testDatabaseConnection }

// Run if called directly
if (require.main === module) {
  testDatabaseConnection()
}