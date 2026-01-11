import { createClient } from '@supabase/supabase-js'

// Environment validation
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

// Get the correct site URL for redirects
const getSiteUrl = () => {
  // Priority order: Environment variable > Vercel URL > Window location > Fallback
  if (process.env.NEXT_PUBLIC_SITE_URL) {
    return process.env.NEXT_PUBLIC_SITE_URL
  }

  // Vercel automatically sets VERCEL_URL
  if (process.env.VERCEL_URL) {
    return `https://${process.env.VERCEL_URL}`
  }

  // For client-side, use window.location.origin
  if (typeof window !== 'undefined') {
    return window.location.origin
  }

  // Fallback for server-side rendering
  return 'https://splitwise-jet.vercel.app'
}

// Check if environment variables are properly configured
if (!supabaseUrl || !supabaseAnonKey ||
  supabaseUrl.includes('placeholder') ||
  supabaseAnonKey.includes('placeholder')) {
  console.error('❌ Supabase configuration error: Missing or invalid environment variables')
  console.error('Please check your .env.local file and ensure NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY are set')
}

// Create Supabase client with enhanced configuration
export const supabase = createClient(
  supabaseUrl || 'https://placeholder.supabase.co',
  supabaseAnonKey || 'placeholder-key',
  {
    auth: {
      persistSession: true,
      autoRefreshToken: true,
      detectSessionInUrl: true,
      flowType: 'pkce',
      debug: false
    },
    global: {
      headers: {
        'x-client-info': 'chanakya-internship-portal'
      }
    },
    db: {
      schema: 'public'
    }
  }
)

// Helper function to check if Supabase is properly configured
export const isSupabaseConfigured = () => {
  return supabaseUrl &&
    supabaseAnonKey &&
    !supabaseUrl.includes('placeholder') &&
    !supabaseAnonKey.includes('placeholder')
}

// Enhanced authentication helper with timeout and retry logic
export const authenticateWithTimeout = async (
  email: string,
  password: string,
  timeoutMs: number = 15000
): Promise<{ data: any; error: any }> => {
  if (!isSupabaseConfigured()) {
    return {
      data: null,
      error: { message: 'Supabase is not properly configured. Please check your environment variables.' }
    }
  }

  const timeoutPromise = new Promise<never>((_, reject) =>
    setTimeout(() => reject(new Error('Authentication request timeout')), timeoutMs)
  )

  const authPromise = supabase.auth.signInWithPassword({
    email,
    password,
  })

  try {
    const result = await Promise.race([authPromise, timeoutPromise])
    return result as { data: any; error: any }
  } catch (error) {
    if (error instanceof Error && error.message.includes('timeout')) {
      return {
        data: null,
        error: { message: 'Authentication request timed out. Please check your internet connection and try again.' }
      }
    }
    return {
      data: null,
      error: { message: error instanceof Error ? error.message : 'Authentication failed' }
    }
  }
}

// Magic link authentication with timeout
export const sendMagicLinkWithTimeout = async (
  email: string,
  timeoutMs: number = 10000
): Promise<{ data: any; error: any }> => {
  if (!isSupabaseConfigured()) {
    return {
      data: null,
      error: { message: 'Supabase is not properly configured. Please check your environment variables.' }
    }
  }

  const timeoutPromise = new Promise<never>((_, reject) =>
    setTimeout(() => reject(new Error('Magic link request timeout')), timeoutMs)
  )

  const siteUrl = getSiteUrl()
  console.log('🔗 Sending magic link with redirect to:', `${siteUrl}/auth/callback`)

  const magicLinkPromise = supabase.auth.signInWithOtp({
    email,
    options: {
      emailRedirectTo: `${siteUrl}/auth/callback`
    }
  })

  try {
    const result = await Promise.race([magicLinkPromise, timeoutPromise])
    return result as { data: any; error: any }
  } catch (error) {
    if (error instanceof Error && error.message.includes('timeout')) {
      return {
        data: null,
        error: { message: 'Magic link request timed out. Please check your internet connection and try again.' }
      }
    }
    return {
      data: null,
      error: { message: error instanceof Error ? error.message : 'Magic link failed' }
    }
  }
}

// Database Types
export interface User {
  id: string
  email: string
  full_name: string
  phone?: string
  location?: string
  linkedin?: string
  github?: string
  created_at: string
  updated_at: string
}

export interface Resume {
  id: string
  user_id: string
  file_name: string
  file_path: string
  extracted_data: any
  verification_status: 'pending' | 'verified' | 'rejected'
  created_at: string
  updated_at: string
}

export interface Experience {
  id: string
  user_id: string
  company: string
  position: string
  location?: string
  start_date: string
  end_date?: string
  current: boolean
  description?: string
  verification_status: 'pending' | 'verified' | 'rejected'
  created_at: string
}

export interface Education {
  id: string
  user_id: string
  institution: string
  degree: string
  field?: string
  grade?: string
  start_date: string
  end_date: string
  verification_status: 'pending' | 'verified' | 'rejected'
  created_at: string
}

export interface Skill {
  id: string
  user_id: string
  name: string
  category: 'technical' | 'soft'
  proficiency: 'beginner' | 'intermediate' | 'advanced' | 'expert'
  verified: boolean
  created_at: string
}

export interface Document {
  id: string
  user_id: string
  type: 'resume' | 'certificate' | 'id_proof' | 'education' | 'experience'
  name: string
  file_path: string
  verification_status: 'pending' | 'verified' | 'rejected'
  verified_by?: string
  verified_at?: string
  created_at: string
}

export interface Grievance {
  id: string
  user_id: string
  subject: string
  description: string
  category: 'technical' | 'verification' | 'application' | 'other'
  status: 'open' | 'in_progress' | 'resolved' | 'closed'
  priority: 'low' | 'medium' | 'high' | 'urgent'
  assigned_to?: string
  resolution?: string
  created_at: string
  updated_at: string
}

export interface SkillAssessment {
  id: string
  user_id: string
  skill_name: string
  score: number
  total_questions: number
  correct_answers: number
  time_taken: number
  status: 'completed' | 'in_progress' | 'not_started'
  created_at: string
}

// Google OAuth authentication
export const signInWithGoogle = async () => {
  if (!isSupabaseConfigured()) {
    return {
      data: null,
      error: { message: 'Supabase is not properly configured. Please check your environment variables.' }
    }
  }

  try {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${getSiteUrl()}/auth/callback`,
        queryParams: {
          access_type: 'offline',
          prompt: 'consent',
        },
      }
    })

    return { data, error }
  } catch (error) {
    return {
      data: null,
      error: error
    }
  }
}

// Enhanced user registration with profile creation
export const signUpWithEmail = async (
  email: string,
  password: string,
  userData: {
    full_name?: string
    phone?: string
    role?: 'student' | 'recruiter' | 'government'
  } = {}
): Promise<{ data: any; error: any }> => {
  if (!isSupabaseConfigured()) {
    return {
      data: null,
      error: { message: 'Supabase is not properly configured. Please check your environment variables.' }
    }
  }

  try {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: userData.full_name,
          phone: userData.phone,
          role: userData.role || 'student',
        }
      }
    })

    return { data, error }
  } catch (error) {
    return {
      data: null,
      error: error
    }
  }
}

// Create or update user profile after authentication
export const createUserProfile = async (user: any, additionalData: any = {}) => {
  if (!user) return { error: { message: 'No user provided' } }

  try {
    // Check if profile already exists
    const { data: existingProfile } = await supabase
      .from('profiles')
      .select('id')
      .eq('id', user.id)
      .single()

    if (existingProfile) {
      // Update existing profile
      const { data, error } = await supabase
        .from('profiles')
        .update({
          full_name: user.user_metadata?.full_name || additionalData.full_name || user.email?.split('@')[0],
          email: user.email,
          role: additionalData.role || 'student',
          updated_at: new Date().toISOString(),
          ...additionalData
        })
        .eq('id', user.id)
        .select()

      return { data, error }
    } else {
      // Create new profile
      const { data, error } = await supabase
        .from('profiles')
        .insert({
          id: user.id,
          full_name: user.user_metadata?.full_name || additionalData.full_name || user.email?.split('@')[0],
          email: user.email,
          role: additionalData.role || 'student',
          profile_step: 1,
          profile_completed: false,
          ...additionalData
        })
        .select()

      return { data, error }
    }
  } catch (error) {
    return {
      data: null,
      error: error
    }
  }
}

// Government official authentication
export const authenticateGovernmentOfficial = async (
  employeeId: string,
  password: string
): Promise<{ data: any; error: any }> => {
  if (!isSupabaseConfigured()) {
    return {
      data: null,
      error: { message: 'Supabase is not properly configured. Please check your environment variables.' }
    }
  }

  try {
    // First check if employee ID exists in government_officials table
    const { data: official, error: officialError } = await supabase
      .from('government_officials')
      .select('*')
      .eq('employee_id', employeeId)
      .single()

    if (officialError || !official) {
      return {
        data: null,
        error: { message: 'Invalid employee ID or official not found' }
      }
    }

    // MOCK AUTHENTICATION - Check password directly without Supabase Auth
    // This allows login without creating auth users in Supabase Authentication
    const VALID_PASSWORD = 'goverment' // Standard password for all officials

    if (password !== VALID_PASSWORD) {
      return {
        data: null,
        error: { message: 'Invalid login credentials' }
      }
    }

    // Create a mock user object to maintain compatibility
    const mockUser = {
      id: official.id,
      email: official.email,
      user_metadata: {
        full_name: official.name,
        employee_id: official.employee_id,
        role: 'government'
      }
    }

    // Create a mock session
    const mockSession = {
      access_token: 'mock-token-' + Date.now(),
      refresh_token: 'mock-refresh-' + Date.now(),
      expires_in: 3600,
      token_type: 'bearer',
      user: mockUser
    }

    console.log('✅ Mock authentication successful for:', official.name)

    // Return mock auth data and official info
    return {
      data: {
        user: mockUser,
        session: mockSession,
        official: official
      },
      error: null
    }
  } catch (error) {
    return {
      data: null,
      error: error
    }
  }
}

// Recruiter authentication
export const authenticateRecruiter = async (
  organizationId: string,
  password: string
): Promise<{ data: any; error: any }> => {
  if (!isSupabaseConfigured()) {
    return {
      data: null,
      error: { message: 'Supabase is not properly configured. Please check your environment variables.' }
    }
  }

  try {
    // First check if organization ID exists in recruiters table
    const { data: recruiter, error: recruiterError } = await supabase
      .from('recruiters')
      .select('*')
      .eq('organization_id', organizationId)
      .single()

    if (recruiterError || !recruiter) {
      return {
        data: null,
        error: { message: 'Invalid organization ID or recruiter not found' }
      }
    }

    if (recruiter.approval_status !== 'approved') {
      return {
        data: null,
        error: { message: `Account status: ${recruiter.approval_status}. Please contact support.` }
      }
    }

    // MOCK AUTHENTICATION - Check password directly without Supabase Auth
    const VALID_PASSWORD = 'recruiter123' // Standard password for all recruiters

    if (password !== VALID_PASSWORD) {
      return {
        data: null,
        error: { message: 'Invalid login credentials' }
      }
    }

    // Create a mock user object
    const mockUser = {
      id: recruiter.id,
      email: recruiter.email,
      user_metadata: {
        full_name: recruiter.contact_person,
        organization_id: recruiter.organization_id,
        role: 'recruiter'
      }
    }

    // Create a mock session
    const mockSession = {
      access_token: 'mock-token-' + Date.now(),
      refresh_token: 'mock-refresh-' + Date.now(),
      expires_in: 3600,
      token_type: 'bearer',
      user: mockUser
    }

    console.log('✅ Mock authentication successful for:', recruiter.organization_name)

    // Return mock auth data and recruiter info
    return {
      data: {
        user: mockUser,
        session: mockSession,
        recruiter: recruiter
      },
      error: null
    }
  } catch (error) {
    return {
      data: null,
      error: error
    }
  }
}
