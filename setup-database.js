// Database setup script
import { createClient } from '@supabase/supabase-js'
import { readFileSync } from 'fs'
import dotenv from 'dotenv'

// Load environment variables
dotenv.config({ path: '.env.local' })

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Missing Supabase environment variables')
  process.exit(1)
}

const supabase = createClient(supabaseUrl, supabaseKey)

async function setupDatabase() {
  console.log('🏗️ Setting up Chanakya Internship Database...\n')

  try {
    // Read the SQL file
    const sqlContent = readFileSync('database_complete_setup.sql', 'utf8')
    console.log('📄 SQL file loaded successfully')

    // Split SQL into individual statements (basic approach)
    const statements = sqlContent
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt.length > 0 && !stmt.startsWith('--'))

    console.log(`📝 Found ${statements.length} SQL statements to execute`)

    // Execute each statement
    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i]
      if (statement.trim()) {
        try {
          console.log(`⚡ Executing statement ${i + 1}/${statements.length}...`)

          // Use Supabase's rpc function to execute raw SQL
          const { error } = await supabase.rpc('exec_sql', { sql: statement })

          if (error) {
            console.error(`❌ Statement ${i + 1} failed:`, error.message)
            console.error('SQL:', statement.substring(0, 100) + '...')
          } else {
            console.log(`✅ Statement ${i + 1} executed successfully`)
          }
        } catch (err) {
          console.error(`❌ Statement ${i + 1} error:`, err.message)
        }
      }
    }

    console.log('\n🎉 Database setup completed!')
    console.log('🔍 Verifying setup...')

    // Verify tables were created
    const tables = ['profiles', 'recruiter_profiles', 'government_officials', 'internship_postings']
    for (const table of tables) {
      try {
        const { error } = await supabase.from(table).select('*', { count: 'exact', head: true })
        if (error) {
          console.error(`❌ Table '${table}' verification failed:`, error.message)
        } else {
          console.log(`✅ Table '${table}' verified`)
        }
      } catch (err) {
        console.error(`❌ Table '${table}' error:`, err.message)
      }
    }

  } catch (error) {
    console.error('❌ Database setup failed:', error.message)
  }
}

setupDatabase()