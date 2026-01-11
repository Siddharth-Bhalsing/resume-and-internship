const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');

const supabase = createClient(
  'https://htfkcabyhhgcsudgbzzm.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh0ZmtjYWJ5aGhnY3N1ZGdienptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc5NzI2MjksImV4cCI6MjA4MzU0ODYyOX0.HUUa_L3wADb2PV_yHgfjNoiHzCvTcObX7wQxk--MM0Q'
);

async function deployFunctions() {
  try {
    console.log('🔧 Deploying database functions...');

    // Read the SQL file
    const sqlContent = fs.readFileSync('./database-policies-functions.sql', 'utf8');

    // Split by semicolons and execute each statement
    const statements = sqlContent
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt.length > 0 && !stmt.startsWith('--'));

    console.log(`Found ${statements.length} statements to execute`);

    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i];
      if (statement.length < 10) continue; // Skip empty statements

      console.log(`Executing statement ${i + 1}/${statements.length}...`);

      try {
        const { data, error } = await supabase.rpc('exec_sql', {
          sql: statement,
          params: []
        });

        if (error) {
          console.error(`❌ Error in statement ${i + 1}:`, error.message);
        } else {
          console.log(`✅ Statement ${i + 1} executed successfully`);
        }
      } catch (err) {
        console.error(`❌ Exception in statement ${i + 1}:`, err.message);
      }
    }

    console.log('🎉 Database functions deployment completed!');

  } catch (error) {
    console.error('❌ Failed to deploy functions:', error.message);
  }
}

deployFunctions();