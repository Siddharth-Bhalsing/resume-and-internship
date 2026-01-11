'use client'

import { useEffect } from 'react'
import { motion } from 'framer-motion'
import { AlertCircle, RefreshCw, Home, Mail } from 'lucide-react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'

export default function AuthCodeErrorPage() {
  const router = useRouter()

  useEffect(() => {
    // Auto redirect to login after 10 seconds
    const timer = setTimeout(() => {
      router.push('/login')
    }, 10000)

    return () => clearTimeout(timer)
  }, [router])

  return (
    <div className="min-h-screen bg-gradient-to-br from-red-50 to-orange-100 flex items-center justify-center p-4">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="max-w-md w-full bg-white rounded-xl shadow-lg p-8 text-center"
      >
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ delay: 0.2, type: "spring", stiffness: 200 }}
          className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-6"
        >
          <AlertCircle className="w-8 h-8 text-red-600" />
        </motion.div>

        <h1 className="text-2xl font-bold text-gray-900 mb-4">
          Authentication Error
        </h1>

        <p className="text-gray-600 mb-6 leading-relaxed">
          We encountered an issue while processing your Google sign-in.
          This might be due to a configuration issue or network problem.
        </p>

        <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
          <h3 className="text-sm font-semibold text-red-800 mb-2">
            Possible Causes:
          </h3>
          <ul className="text-sm text-red-700 space-y-1 text-left">
            <li>• Google OAuth not configured in Supabase</li>
            <li>• Invalid redirect URI</li>
            <li>• Network connectivity issues</li>
            <li>• Browser security restrictions</li>
          </ul>
        </div>

        <div className="space-y-3">
          <motion.button
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            onClick={() => router.push('/login')}
            className="w-full bg-gradient-to-r from-orange-600 to-blue-600 text-white py-3 px-4 rounded-lg font-semibold hover:from-orange-700 hover:to-blue-700 transition-all flex items-center justify-center space-x-2"
          >
            <RefreshCw className="w-5 h-5" />
            <span>Try Again</span>
          </motion.button>

          <Link
            href="/login"
            className="w-full bg-white border-2 border-gray-300 text-gray-700 py-3 px-4 rounded-lg font-semibold hover:bg-gray-50 transition-all flex items-center justify-center space-x-2"
          >
            <Home className="w-5 h-5" />
            <span>Back to Login</span>
          </Link>
        </div>

        <div className="mt-6 text-center">
          <p className="text-sm text-gray-500 mb-2">
            Still having issues?
          </p>
          <div className="flex items-center justify-center space-x-4 text-sm">
            <Link
              href="/support"
              className="text-blue-600 hover:text-blue-700 flex items-center space-x-1"
            >
              <Mail className="w-4 h-4" />
              <span>Contact Support</span>
            </Link>
          </div>
        </div>

        <div className="mt-6 text-xs text-gray-400">
          Auto-redirecting to login in 10 seconds...
        </div>
      </motion.div>
    </div>
  )
}