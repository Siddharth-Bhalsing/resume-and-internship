'use client'

import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Eye, EyeOff, Shield, User, GraduationCap, Lock, CheckCircle, AlertCircle, Loader2, RefreshCw } from 'lucide-react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import Image from 'next/image'
import { toast } from 'react-hot-toast'
import { supabase, isSupabaseConfigured, authenticateWithTimeout, signInWithGoogle } from '../../lib/supabase'


export default function StudentLoginPage() {
  const [showPassword, setShowPassword] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    captcha: '',
    otp: ''
  })
  const [step, setStep] = useState<'login'>('login')
  const [captchaCode, setCaptchaCode] = useState('G7X9M')
  const [errors, setErrors] = useState<{[key: string]: string}>({})
  const [showDevBypass, setShowDevBypass] = useState(false)
  const router = useRouter()


  const generateCaptcha = () => {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    let result = ''
    for (let i = 0; i < 5; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length))
    }
    setCaptchaCode(result)
    setFormData(prev => ({ ...prev, captcha: '' })) // Clear captcha input
  }

  useEffect(() => {
    generateCaptcha()
    
    // Always show dev bypass for easy access during development
    setShowDevBypass(true)
  }, [])

  // Check if user is already logged in
  useEffect(() => {
    const checkUser = async () => {
      const { data: { user } } = await supabase.auth.getUser()
      if (user) {
        router.push('/dashboard')
      }
    }
    checkUser()
  }, [router])


  const validateForm = () => {
    const newErrors: {[key: string]: string} = {}
    
    if (!formData.email) {
      newErrors.email = 'Email is required'
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = 'Please enter a valid email'
    }
    
    if (!formData.password) {
      newErrors.password = 'Password is required'
    } else if (formData.password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters'
    }
    
    if (!formData.captcha) {
      newErrors.captcha = 'Security code is required'
    } else if (formData.captcha.toUpperCase() !== captchaCode) {
      newErrors.captcha = 'Security code is incorrect'
    }
    
    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }


  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!validateForm()) return
    
    setIsLoading(true)
    setErrors({}) // Clear previous errors
    
    try {
      console.log('🔄 Starting login process...')
      
      // Check if Supabase is properly configured
      if (!isSupabaseConfigured()) {
        console.error('❌ Supabase not configured')
        setErrors({ 
          general: 'Database connection not configured. Please check environment variables.' 
        })
        toast.error('System configuration error. Please contact support.')
        return
      }
      
      // Use enhanced authentication with timeout
      const { data, error } = await authenticateWithTimeout(
        formData.email, 
        formData.password, 
        15000 // 15 second timeout
      )

      if (error) {
        console.error('❌ Login error:', error)
        
        if (error.message.includes('timeout')) {
          setErrors({ general: 'Request timed out. Please check your connection and try again.' })
          toast.error('Connection timeout. Please try again.')
        } else if (error.message.includes('Invalid login credentials')) {
          setErrors({ email: 'Invalid email or password' })
          toast.error('Invalid email or password')
        } else if (error.message.includes('Email not confirmed')) {
          setErrors({ email: 'Please check your email and confirm your account before logging in' })
          toast.error('Please verify your email first')
        } else if (error.message.includes('not properly configured')) {
          setErrors({ general: 'System configuration error. Please contact support.' })
          toast.error('System configuration error. Please contact support.')
        } else {
          setErrors({ general: error.message || 'Login failed. Please try again.' })
          toast.error('Login failed. Please try again.')
        }
        return
      }

      if (data.user) {
        console.log('✅ Login successful:', data.user.email)
        
        // Check if email is confirmed
        if (!data.user.email_confirmed_at) {
          setErrors({ email: 'Please check your email and confirm your account before logging in' })
          toast.error('Please verify your email first')
          return
        }
        
        toast.success(`Welcome back, ${data.user.email}!`)
        
        // Redirect to dashboard after short delay
        setTimeout(() => {
          router.push('/dashboard')
        }, 1000)
      }
      
    } catch (error: any) {
      console.error('❌ Unexpected login error:', error)
      
      if (error.message?.includes('Failed to fetch') || error.message?.includes('ERR_NAME_NOT_RESOLVED')) {
        setErrors({ 
          general: 'Unable to connect to authentication service. Please check your internet connection or contact support.' 
        })
        toast.error('Connection error. Please check your internet connection.')
      } else {
        setErrors({ general: 'An unexpected error occurred. Please try again.' })
        toast.error('Login failed. Please try again.')
      }
    } finally {
      setIsLoading(false)
    }
  }

  const handleDevBypass = () => {
    setIsLoading(true)
    toast.success('Development bypass activated! Going to dashboard...')
    setTimeout(() => {
      router.push('/dashboard')
    }, 1000)
  }

  // DISABLED: Google Sign-In functionality
  /*
  const handleGoogleSignIn = async () => {
    setIsLoading(true)
    setErrors({})

    try {
      console.log('🔄 Starting Google sign-in...')

      const { data, error } = await signInWithGoogle()

      if (error) {
        console.error('❌ Google sign-in error:', error)
        setErrors({ general: 'Failed to initiate Google sign-in. Please try again.' })
        toast.error('Google sign-in failed')
        return
      }

      // The redirect will happen automatically
      console.log('✅ Google OAuth initiated, redirecting...')

    } catch (error: any) {
      console.error('❌ Unexpected Google sign-in error:', error)
      setErrors({ general: 'An unexpected error occurred during Google sign-in.' })
      toast.error('Google sign-in failed')
    } finally {
      setIsLoading(false)
    }
  }
  */



  return (
    <div className="min-h-screen bg-white">
      <style jsx>{`
        .sliding-images-container {
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          overflow: hidden;
        }
        
        .sliding-image-login {
          position: absolute;
          width: 100%;
          height: 100%;
          animation: slideRightToLeftLogin 20s linear infinite;
        }
        
        .sliding-image-login:nth-child(1) { 
          animation-delay: 0s; 
        }
        .sliding-image-login:nth-child(2) { 
          animation-delay: 5s; 
        }
        .sliding-image-login:nth-child(3) { 
          animation-delay: 10s; 
        }
        .sliding-image-login:nth-child(4) { 
          animation-delay: 15s; 
        }
        
        @keyframes slideRightToLeftLogin {
          0% { 
            transform: translateX(100%);
            opacity: 0;
          }
          10% { 
            opacity: 0.7;
          }
          90% { 
            opacity: 0.7;
          }
          100% { 
            transform: translateX(-100%);
            opacity: 0;
          }
        }
      `}</style>


      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="container mx-auto">
          {/* Top Government Bar */}
          <div className="bg-gray-100 px-4 py-1 text-xs">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-4 text-gray-600">
                <span>🇮🇳 भारत सरकार | Government of India</span>
              </div>
              <div className="flex items-center space-x-4 text-gray-600">
                <span>🌐 English</span>
                <span>|</span>
                <span>हिंदी</span>
              </div>
            </div>
          </div>


          {/* Main Header */}
          <div className="px-4 py-3">
            <div className="flex items-center justify-center">
              <div className="flex items-center space-x-3">
                <div className="text-center">
                  <h1 className="text-xl font-bold text-gray-900">PM Internship & Resume Verifier</h1>
                  <p className="text-xs text-gray-600">MINISTRY OF EDUCATION</p>
                  <p className="text-xs text-gray-500">Government of India</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </header>


      <div className="flex flex-col lg:grid lg:grid-cols-2 min-h-screen">
        {/* Left Side - Sliding Images */}
        <div className="relative overflow-hidden bg-gradient-to-br from-orange-50 to-blue-100 h-64 lg:h-auto">
          {/* Sliding Images */}
          <div className="absolute inset-0 overflow-hidden">
            <div className="sliding-images-container">
              <div className="sliding-image-login">
                <Image
                  src="https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=800&h=600&fit=crop"
                  alt="Students studying"
                  width={800}
                  height={600}
                  className="object-cover w-full h-full opacity-70"
                />
              </div>
              <div className="sliding-image-login">
                <Image
                  src="https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=600&fit=crop"
                  alt="Student internship"
                  width={800}
                  height={600}
                  className="object-cover w-full h-full opacity-70"
                />
              </div>
              <div className="sliding-image-login">
                <Image
                  src="https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&h=600&fit=crop"
                  alt="Students collaborating"
                  width={800}
                  height={600}
                  className="object-cover w-full h-full opacity-70"
                />
              </div>
              <div className="sliding-image-login">
                <Image
                  src="https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800&h=600&fit=crop"
                  alt="Student learning"
                  width={800}
                  height={600}
                  className="object-cover w-full h-full opacity-70"
                />
              </div>
            </div>
          </div>
          
          {/* Content Overlay */}
          <div className="relative z-10 flex flex-col justify-center h-full p-4 lg:p-8">
            <div className="text-center text-white mb-4 lg:mb-8">
              <h2 className="text-2xl lg:text-4xl font-bold mb-2 lg:mb-4">Welcome to</h2>
              <h1 className="text-3xl lg:text-5xl font-bold mb-4 lg:mb-6 text-orange-400">Student Portal</h1>
              <p className="text-sm lg:text-xl mb-4 lg:mb-8 leading-relaxed max-w-md mx-auto">
                Access your internship opportunities and build your career with government-backed programs
              </p>
              <div className="bg-white/20 backdrop-blur-sm rounded-lg p-4 lg:p-6 border border-white/30">
                <div className="grid grid-cols-2 gap-2 lg:gap-4 text-center">
                  <div>
                    <div className="text-xl lg:text-2xl font-bold">50K+</div>
                    <div className="text-xs lg:text-sm opacity-90">Internships</div>
                  </div>
                  <div>
                    <div className="text-xl lg:text-2xl font-bold">25+</div>
                    <div className="text-xs lg:text-sm opacity-90">Departments</div>
                  </div>
                </div>
              </div>
            </div>


            {/* Text below images - Hidden on mobile */}
            <div className="hidden lg:block text-center text-white/90 mt-auto">
              <div className="bg-black/30 backdrop-blur-sm rounded-lg p-6 border border-white/20">
                <h3 className="text-xl font-bold mb-3">Student Access Portal</h3>
                <p className="text-sm leading-relaxed max-w-lg mx-auto">
                  Ministry of Education - Official student portal for PM Internship programs.
                  Secure access for students to explore opportunities and manage applications.
                </p>
                <div className="mt-4 text-xs opacity-75">
                  <p>🎓 Student Access | 🔐 Secure Login | 🏛️ Government Verified</p>
                </div>
              </div>
            </div>
          </div>
        </div>


        {/* Right Side - Login Form */}
        <div className="flex items-center justify-center p-4 lg:p-8 flex-1">
          <div className="max-w-md w-full">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6 }}
            >
              {/* Header */}
              <div className="text-center mb-6 lg:mb-8">
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ delay: 0.2, type: "spring", stiffness: 200 }}
                  className="flex justify-center mb-4 lg:mb-6"
                >
                  <div className="w-16 h-16 lg:w-20 lg:h-20 bg-gradient-to-br from-orange-600 to-blue-700 rounded-full flex items-center justify-center shadow-lg">
                    <GraduationCap className="w-8 h-8 lg:w-10 lg:h-10 text-white" />
                  </div>
                </motion.div>
                <h2 className="text-2xl lg:text-3xl font-bold text-gray-900 mb-2">Student Portal Access</h2>
                <p className="text-sm lg:text-base text-gray-600">Login to access your internship dashboard and opportunities</p>
                <div className="flex items-center justify-center mt-3 lg:mt-4 space-x-2">
                  <Lock className="w-4 h-4 text-orange-600" />
                  <span className="text-xs lg:text-sm text-orange-600 font-medium">Secure Student Access</span>
                </div>
                
                {/* Configuration Status */}
                {!isSupabaseConfigured() && (
                  <div className="mt-4 p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
                    <div className="flex items-center space-x-2">
                      <AlertCircle className="w-4 h-4 text-yellow-600" />
                      <span className="text-sm text-yellow-800">
                        Database configuration required
                      </span>
                    </div>
                  </div>
                )}
              </div>


              <motion.form
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                onSubmit={handleSubmit}
                className="space-y-4 lg:space-y-6"
              >
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Email Address
                      </label>
                      <input
                        type="email"
                        value={formData.email}
                        onChange={(e) => setFormData({...formData, email: e.target.value})}
                        className="w-full px-3 py-2 lg:px-4 lg:py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent transition-all text-sm lg:text-base"
                        placeholder="Enter your email address"
                      />
                      {errors.email && (
                        <p className="text-red-500 text-sm mt-1">{errors.email}</p>
                      )}
                    </div>


                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Password
                      </label>
                      <div className="relative">
                        <input
                          type={showPassword ? "text" : "password"}
                          value={formData.password}
                          onChange={(e) => setFormData({...formData, password: e.target.value})}
                          className="w-full px-3 py-2 lg:px-4 lg:py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent transition-all pr-10 lg:pr-12 text-sm lg:text-base"
                          placeholder="Enter your password"
                        />
                        <button
                          type="button"
                          onClick={() => setShowPassword(!showPassword)}
                          className="absolute right-2 lg:right-3 top-2 lg:top-3 text-gray-400 hover:text-gray-600"
                        >
                          {showPassword ? <EyeOff className="w-4 h-4 lg:w-5 lg:h-5" /> : <Eye className="w-4 h-4 lg:w-5 lg:h-5" />}
                        </button>
                      </div>
                      {errors.password && (
                        <p className="text-red-500 text-sm mt-1">{errors.password}</p>
                      )}
                    </div>


                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Security Code
                      </label>
                      <div className="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-3">
                        <input
                          type="text"
                          value={formData.captcha}
                          onChange={(e) => setFormData({...formData, captcha: e.target.value})}
                          className="flex-1 px-3 py-2 lg:px-4 lg:py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent transition-all text-sm lg:text-base"
                          placeholder="Enter code"
                        />
                        <div className="flex items-center space-x-2 justify-center sm:justify-start">
                          <div className="bg-gray-100 px-3 py-2 lg:px-4 lg:py-3 rounded-lg border font-mono text-base lg:text-lg tracking-wider">
                            {captchaCode}
                          </div>
                          <button
                            type="button"
                            onClick={generateCaptcha}
                            className="p-2 lg:p-3 text-gray-500 hover:text-gray-700 border rounded-lg hover:bg-gray-50 transition-colors"
                            title="Refresh Captcha"
                          >
                            <RefreshCw className="w-4 h-4 lg:w-5 lg:h-5" />
                          </button>
                        </div>
                      </div>
                      {errors.captcha && (
                        <p className="text-red-500 text-sm mt-1">{errors.captcha}</p>
                      )}
                    </div>


                    {/* Google Sign-In Button - DISABLED DUE TO OAUTH ISSUES */}
                    {/*
                    <div className="relative">
                      <div className="absolute inset-0 flex items-center">
                        <div className="w-full border-t border-gray-300" />
                      </div>
                      <div className="relative flex justify-center text-sm">
                        <span className="px-2 bg-white text-gray-500">Or continue with</span>
                      </div>
                    </div>

                    <motion.button
                      whileHover={{ scale: 1.02 }}
                      whileTap={{ scale: 0.98 }}
                      type="button"
                      onClick={handleGoogleSignIn}
                      disabled={isLoading}
                      className="w-full bg-white border-2 border-gray-300 text-gray-700 py-2.5 lg:py-3 px-4 rounded-lg font-semibold hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-all disabled:opacity-50 disabled:cursor-not-allowed text-sm lg:text-base flex items-center justify-center space-x-3"
                    >
                      <svg className="w-5 h-5" viewBox="0 0 24 24">
                        <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                        <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                        <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                        <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                      </svg>
                      <span>Continue with Google</span>
                      {isLoading && (
                        <Loader2 className="w-4 h-4 animate-spin" />
                      )}
                    </motion.button>
                    */}

                    <motion.button
                      whileHover={{ scale: 1.02 }}
                      whileTap={{ scale: 0.98 }}
                      type="submit"
                      disabled={isLoading}
                      className="w-full bg-gradient-to-r from-orange-600 to-blue-600 text-white py-2.5 lg:py-3 px-4 rounded-lg font-semibold hover:from-orange-700 hover:to-blue-700 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-2 transition-all disabled:opacity-50 disabled:cursor-not-allowed text-sm lg:text-base"
                    >
                      {isLoading ? (
                        <div className="flex items-center justify-center">
                          <Loader2 className="w-4 h-4 lg:w-5 lg:h-5 animate-spin mr-2" />
                          Signing In...
                        </div>
                      ) : (
                        'Sign In'
                      )}
                    </motion.button>
                    
              </motion.form>


              <div className="mt-6 lg:mt-8 text-center space-y-2">
                <div className="text-xs lg:text-sm text-gray-600">
                  Don't have an account?{' '}
                  <Link href="/register" className="text-orange-600 hover:text-orange-700 font-medium">
                    Register here
                  </Link>
                </div>
                <div className="text-xs lg:text-sm text-gray-600">
                  Government Official?{' '}
                  <Link href="/gov-login" className="text-blue-600 hover:text-blue-700 font-medium">
                    Access Government Portal
                  </Link>
                </div>
                <p className="text-xs lg:text-sm text-gray-600">
                  Need help? Contact{' '}
                  <Link href="/support" className="text-orange-600 hover:text-orange-700 font-medium">
                    Student Support
                  </Link>
                </p>
                
                {/* Small Development Bypass Button */}
                {showDevBypass && (
                  <button
                    type="button"
                    onClick={handleDevBypass}
                    disabled={isLoading}
                    className="mt-3 text-xs text-gray-500 hover:text-gray-700 underline transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    Dev Access
                  </button>
                )}
              </div>
            </motion.div>
          </div>
        </div>
      </div>
    </div>
  )
}
