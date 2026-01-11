import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'

export const dynamic = 'force-dynamic'

// No top-level Supabase initialization to prevent build-time crashes


export async function GET(request: Request) {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

  if (!supabaseUrl || !supabaseAnonKey || !supabaseUrl.startsWith('http')) {
    console.error('❌ Supabase configuration missing for auth callback')
    return NextResponse.redirect(`${new URL(request.url).origin}/auth/auth-code-error`)
  }

  const supabase = createClient(supabaseUrl, supabaseAnonKey)


  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')
  const next = searchParams.get('next') ?? '/dashboard'

  if (code) {
    const { data, error } = await supabase.auth.exchangeCodeForSession(code)

    if (!error && data.user && data.session) {
      console.log('🔄 Processing Google OAuth callback for user:', data.user.email)

      // Create authenticated client with the session
      const authenticatedSupabase = createClient(supabaseUrl, supabaseAnonKey, {
        auth: {
          persistSession: false,
          autoRefreshToken: false,
        },
        global: {
          headers: {
            Authorization: `Bearer ${data.session.access_token}`,
          },
        },
      })

      // Create or update user profile using SERVICE ROLE CLIENT (bypasses all RLS)
      console.log('🔄 Creating profile with service role client...')

      const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY

      if (serviceRoleKey) {
        const serviceSupabase = createClient(supabaseUrl, serviceRoleKey, {
          auth: {
            persistSession: false,
            autoRefreshToken: false,
          }
        })

        const { error: profileError } = await serviceSupabase
          .from('profiles')
          .upsert({
            id: data.user.id,
            full_name: data.user.user_metadata?.full_name || data.user.email?.split('@')[0],
            email: data.user.email,
            role: 'student',
            profile_step: 1,
            profile_completed: false,
          }, {
            onConflict: 'id'
          })

        if (profileError) {
          console.error('❌ Service role profile creation failed:', profileError)
          // Continue anyway, client side might handle it
        } else {
          console.log('✅ User profile created successfully with service role')
        }
      } else {
        console.log('⚠️ Skipping server-side profile creation: No Service Role Key found')
      }

      console.log('✅ User profile created successfully with service role')

      // Redirect to dashboard
      const forwardedHost = request.headers.get('x-forwarded-host')
      const isLocalEnv = process.env.NODE_ENV === 'development'

      if (isLocalEnv) {
        return NextResponse.redirect(`${origin}${next}`)
      } else if (forwardedHost) {
        return NextResponse.redirect(`https://${forwardedHost}${next}`)
      } else {
        return NextResponse.redirect(`${origin}${next}`)
      }
    } else {
      console.error('❌ OAuth callback error:', error?.message)
    }
  }

  // Return the user to an error page with instructions
  return NextResponse.redirect(`${origin}/auth/auth-code-error`)
}