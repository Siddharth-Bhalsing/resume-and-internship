// Test Google OAuth Configuration
// Run this with: node test-google-oauth-config.js

const { createClient } = require('@supabase/supabase-js')

// Load environment variables
require('dotenv').config({ path: '.env.local' })

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

console.log('🔍 Testing Google OAuth Configuration\n')

// Check environment variables
console.log('1. Environment Variables:')
console.log(`   SUPABASE_URL: ${supabaseUrl ? '✅ Set' : '❌ Missing'}`)
console.log(`   SUPABASE_ANON_KEY: ${supabaseAnonKey ? '✅ Set' : '❌ Missing'}`)

// Create Supabase client
const supabase = createClient(supabaseUrl, supabaseAnonKey)

async function testOAuthConfiguration() {
  try {
    console.log('\n2. Testing Supabase Connection...')

    // Test basic connection
    const { data, error } = await supabase.auth.getSession()

    if (error) {
      console.log('❌ Supabase connection failed:', error.message)
      return
    }

    console.log('✅ Supabase connection successful')

    console.log('\n3. Checking OAuth Providers...')

    // This will help identify if Google OAuth is configured
    // Note: Supabase doesn't expose provider status via client, but we can test the OAuth flow

    console.log('ℹ️  To verify Google OAuth is configured:')
    console.log('   1. Go to https://supabase.com/dashboard')
    console.log('   2. Select your project')
    console.log('   3. Go to Authentication → Providers')
    console.log('   4. Ensure Google provider is enabled')
    console.log('   5. Verify Client ID and Secret are set')

    console.log('\n4. Testing OAuth Redirect URL...')

    const siteUrl = process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3000'
    const redirectUrl = `${siteUrl}/auth/callback`

    console.log(`   Expected redirect URL: ${redirectUrl}`)
    console.log('ℹ️  This URL must be added to:')
    console.log('   - Google Cloud Console → Authorized redirect URIs')
    console.log('   - Supabase Dashboard → Authentication → Providers → Google → Redirect URLs')

    console.log('\n📋 Next Steps:')
    console.log('1. Configure Google OAuth in Supabase Dashboard')
    console.log('2. Set up Google Cloud Console credentials')
    console.log('3. Add redirect URIs to both services')
    console.log('4. Test the OAuth flow')

  } catch (error) {
    console.log('❌ Test failed:', error.message)
  }
}

testOAuthConfiguration()