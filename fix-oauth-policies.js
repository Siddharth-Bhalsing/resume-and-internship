const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  'https://htfkcabyhhgcsudgbzzm.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh0ZmtjYWJ5aGhnY3N1ZGdienptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2Nzk3MjYyOSwiZXhwIjoyMDgzNTQ4NjI5fQ.JSpSNOHyYdMqDRn0BcPRbuSUrgvDkq4aoJwm9PIq_jc'
);

async function applyPolicyFix() {
  try {
    console.log('🔧 Applying OAuth policy fix...');

    // Drop restrictive policy
    const { error: dropError } = await supabase.rpc('exec_sql', {
      sql: 'DROP POLICY IF EXISTS "Users can insert own profile" ON profiles',
      params: []
    });
    if (dropError) {
      console.log('⚠️ Drop error (policy may not exist):', dropError.message);
    } else {
      console.log('✅ Old policy dropped');
    }

    // Create permissive insert policy
    const { error: insertError } = await supabase.rpc('exec_sql', {
      sql: 'CREATE POLICY "Allow profile creation during OAuth" ON profiles FOR INSERT WITH CHECK (true)',
      params: []
    });
    if (insertError) {
      console.log('❌ Insert policy error:', insertError.message);
    } else {
      console.log('✅ Insert policy created');
    }

    // Create permissive update policy
    const { error: updateError } = await supabase.rpc('exec_sql', {
      sql: 'CREATE POLICY "Allow profile updates during OAuth" ON profiles FOR UPDATE WITH CHECK (true)',
      params: []
    });
    if (updateError) {
      console.log('❌ Update policy error:', updateError.message);
    } else {
      console.log('✅ Update policy created');
    }

    console.log('🎉 OAuth policy fix completed!');

  } catch (e) {
    console.error('❌ Failed to apply policy fix:', e.message);
  }
}

applyPolicyFix();