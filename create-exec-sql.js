const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  'https://htfkcabyhhgcsudgbzzm.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh0ZmtjYWJ5aGhnY3N1ZGdienptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2Nzk3MjYyOSwiZXhwIjoyMDgzNTQ4NjI5fQ.JSpSNOHyYdMqDRn0BcPRbuSUrgvDkq4aoJwm9PIq_jc'
);

async function createExecSqlFunction() {
  try {
    console.log('🔧 Creating exec_sql function...');

    const createFunctionSQL = `
      CREATE OR REPLACE FUNCTION exec_sql(sql TEXT, params JSONB DEFAULT '[]'::jsonb)
      RETURNS JSON AS $$
      DECLARE
          result JSON;
      BEGIN
          -- Allow service role or anon key for OAuth setup
          IF auth.role() NOT IN ('service_role', 'anon') THEN
              RAISE EXCEPTION 'Access denied: exec_sql can only be called by service role or anon key';
          END IF;

          -- Execute the SQL with parameters
          EXECUTE sql USING params;
          result := json_build_object('success', true, 'message', 'SQL executed successfully');
          RETURN result;
      EXCEPTION
          WHEN OTHERS THEN
              result := json_build_object('success', false, 'error', SQLERRM);
              RETURN result;
      END;
      $$ LANGUAGE plpgsql SECURITY DEFINER;
    `;

    // Try to execute the function creation directly
    const { data, error } = await supabase.from('profiles').select('*').limit(1);
    if (error) throw error;

    console.log('✅ Database connection successful');
    console.log('⚠️ Please run this SQL manually in Supabase SQL Editor:');
    console.log(createFunctionSQL);

  } catch (e) {
    console.error('❌ Error:', e.message);
  }
}

createExecSqlFunction();