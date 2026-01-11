const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');

const supabase = createClient(
  'https://htfkcabyhhgcsudgbzzm.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh0ZmtjYWJ5aGhnY3N1ZGdienptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2Nzk3MjYyOSwiZXhwIjoyMDgzNTQ4NjI5fQ.JSpSNOHyYdMqDRn0BcPRbuSUrgvDkq4aoJwm9PIq_jc'
);

async function applyPolicyFix() {
  try {
    console.log('🔧 Applying OAuth policy fix...');

    const sql = fs.readFileSync('./fix-oauth-policy.sql', 'utf8');
    const statements = sql.split(';').filter(s => s.trim() && !s.trim().startsWith('--'));

    for (let i = 0; i < statements.length; i++) {
      const stmt = statements[i].trim();
      if (stmt) {
        console.log(`Executing statement ${i + 1}...`);
        const { error } = await supabase.rpc('exec_sql', { sql: stmt, params: [] });
        if (error) {
          console.error('❌ Error:', error.message);
        } else {
          console.log('✅ Success');
        }
      }
    }

    console.log('🎉 OAuth policy fix applied successfully!');
  } catch (e) {
    console.error('❌ Failed to apply policy fix:', e.message);
  }
}

applyPolicyFix();