// Simple script to create government official auth users
const { createClient } = require('@supabase/supabase-js')

// Load environment variables
require('dotenv').config({ path: '.env.local' })

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

console.log('🔧 Supabase URL:', supabaseUrl ? '✅ Set' : '❌ Missing')
console.log('🔑 Service Key:', supabaseServiceKey ? '✅ Set' : '❌ Missing')

if (!supabaseUrl || !supabaseServiceKey) {
    console.error('\n❌ Missing environment variables!')
    console.error('Please add to .env.local:')
    console.error('  NEXT_PUBLIC_SUPABASE_URL=your_url')
    console.error('  SUPABASE_SERVICE_ROLE_KEY=your_service_key')
    process.exit(1)
}

const supabase = createClient(supabaseUrl, supabaseServiceKey)

async function createUsers() {
    console.log('\n🏛️  Creating Government Official Auth Users...\n')

    const users = [
        { email: 'rajesh.kumar@gov.in', name: 'Dr. Rajesh Kumar', emp: 'EMP001' },
        { email: 'priya.sharma@gov.in', name: 'Ms. Priya Sharma', emp: 'EMP002' },
        { email: 'amit.singh@gov.in', name: 'Mr. Amit Singh', emp: 'EMP003' }
    ]

    for (const user of users) {
        console.log(`Creating: ${user.name} (${user.email})`)

        const { data, error } = await supabase.auth.admin.createUser({
            email: user.email,
            password: 'gov123456',
            email_confirm: true,
            user_metadata: {
                full_name: user.name,
                employee_id: user.emp,
                role: 'government'
            }
        })

        if (error) {
            if (error.message.includes('already registered')) {
                console.log(`  ⏭️  Already exists - skipping`)
            } else {
                console.log(`  ❌ Error: ${error.message}`)
            }
        } else {
            console.log(`  ✅ Created successfully!`)
        }
    }

    console.log('\n✨ Done! You can now login with:')
    console.log('   Employee ID: EMP001, EMP002, or EMP003')
    console.log('   Password: gov123456')
}

createUsers().then(() => process.exit(0)).catch(err => {
    console.error('Error:', err.message)
    process.exit(1)
})
