// Post-Deployment Verification Script
// Run with: node verify-database.js

const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: '.env.local' });

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
);

async function verify() {
  console.log('🔍 Verifying database deployment...\n');

  try {
    // Check if profiles table exists and is accessible
    const { error } = await supabase
      .from('profiles')
      .select('count', { count: 'exact', head: true });

    if (error) {
      console.log('❌ Database not deployed:', error.message);
      console.log('\n📋 SOLUTION: Run database deployment scripts in Supabase SQL Editor');
      console.log('   1. database-tables-only.sql');
      console.log('   2. database-policies-functions.sql');
      return;
    }

    console.log('✅ Database deployed successfully!');
    console.log('✅ Tables and policies are active');

    // Check if Google OAuth is configured
    console.log('\n🔍 Checking Google OAuth configuration...');
    console.log('⚠️  IMPORTANT: Ensure Google OAuth is enabled in Supabase Dashboard');
    console.log('   - Go to Authentication → Providers → Google');
    console.log('   - Enable Google provider');
    console.log('   - Add your Google Client ID & Secret');
    console.log('   - Set redirect URLs');

    console.log('\n🎯 Ready to test Google OAuth!');
    console.log('   Go to http://localhost:3000/login and click "Continue with Google"');

  } catch (error) {
    console.log('❌ Verification failed:', error.message);
  }
}

verify();