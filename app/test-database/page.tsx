'use client'

export const dynamic = 'force-dynamic'


import { useState, useEffect } from 'react'

interface TestResult {
  name: string
  status: 'running' | 'passed' | 'failed' | 'warning'
  message?: string
  error?: string
  details?: any[]
}

interface DatabaseTestResults {
  timestamp: string
  tests: TestResult[]
  overall: {
    status: 'passed' | 'failed' | 'warning' | 'error'
    message: string
    totalTests: number
    passedTests: number
    failedTests: number
    warningTests: number
    error?: string
  }
}

export default function DatabaseTestPage() {
  const [results, setResults] = useState<DatabaseTestResults | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    testDatabase()
  }, [])

  const testDatabase = async () => {
    try {
      setLoading(true)
      const response = await fetch('/api/test-database')
      const data = await response.json()
      setResults(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    } finally {
      setLoading(false)
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'passed': return 'text-green-600 bg-green-100'
      case 'failed': return 'text-red-600 bg-red-100'
      case 'warning': return 'text-yellow-600 bg-yellow-100'
      case 'running': return 'text-blue-600 bg-blue-100'
      default: return 'text-gray-600 bg-gray-100'
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'passed': return '✅'
      case 'failed': return '❌'
      case 'warning': return '⚠️'
      case 'running': return '🔄'
      default: return '❓'
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <h2 className="text-xl font-semibold text-gray-700">Testing Database Connection...</h2>
          <p className="text-gray-500 mt-2">This may take a few seconds</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="bg-white p-8 rounded-lg shadow-md max-w-md w-full">
          <div className="text-center">
            <h2 className="text-xl font-semibold text-red-600 mb-4">Test Failed</h2>
            <p className="text-gray-600">{error}</p>
            <button
              onClick={testDatabase}
              className="mt-4 bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
            >
              Retry Test
            </button>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-4xl mx-auto px-4">
        <div className="bg-white rounded-lg shadow-md p-6 mb-6">
          <div className="flex items-center justify-between mb-6">
            <h1 className="text-2xl font-bold text-gray-900">
              🗄️ Chanakya Internship Database Test
            </h1>
            <button
              onClick={testDatabase}
              className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
            >
              🔄 Run Tests Again
            </button>
          </div>

          {/* Overall Status */}
          {results?.overall && (
            <div className={`p-4 rounded-lg mb-6 ${getStatusColor(results.overall.status)}`}>
              <div className="flex items-center">
                <span className="text-2xl mr-3">{getStatusIcon(results.overall.status)}</span>
                <div>
                  <h3 className="font-semibold text-lg">Overall Status: {results.overall.status.toUpperCase()}</h3>
                  <p>{results.overall.message}</p>
                  <div className="mt-2 text-sm">
                    Tests: {results.overall.passedTests} passed, {results.overall.failedTests} failed, {results.overall.warningTests} warnings
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Individual Tests */}
          <div className="space-y-4">
            {results?.tests.map((test, index) => (
              <div key={index} className="border rounded-lg p-4">
                <div className="flex items-center justify-between mb-2">
                  <h4 className="font-semibold text-gray-900">{test.name}</h4>
                  <span className={`px-2 py-1 rounded text-sm font-medium ${getStatusColor(test.status)}`}>
                    {getStatusIcon(test.status)} {test.status}
                  </span>
                </div>

                {test.message && (
                  <p className="text-gray-600 mb-2">{test.message}</p>
                )}

                {test.error && (
                  <p className="text-red-600 text-sm mb-2">Error: {test.error}</p>
                )}

                {test.details && (
                  <div className="mt-3">
                    <h5 className="font-medium text-gray-700 mb-2">Details:</h5>
                    <div className="bg-gray-50 p-3 rounded text-sm font-mono">
                      {JSON.stringify(test.details, null, 2)}
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>

          {/* Quick Actions */}
          <div className="mt-8 border-t pt-6">
            <h3 className="text-lg font-semibold mb-4">🚀 Quick Actions</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <a
                href="/register"
                className="bg-green-600 text-white px-4 py-3 rounded hover:bg-green-700 text-center"
              >
                Create Student Account
              </a>
              <a
                href="/recruiter-login"
                className="bg-blue-600 text-white px-4 py-3 rounded hover:bg-blue-700 text-center"
              >
                Test Recruiter Login
              </a>
              <a
                href="/gov-login"
                className="bg-purple-600 text-white px-4 py-3 rounded hover:bg-purple-700 text-center"
              >
                Test Government Login
              </a>
              <a
                href="/internships"
                className="bg-orange-600 text-white px-4 py-3 rounded hover:bg-orange-700 text-center"
              >
                Browse Internships
              </a>
            </div>
          </div>

          {/* Environment Info */}
          <div className="mt-6 p-4 bg-gray-50 rounded-lg">
            <h4 className="font-semibold text-gray-700 mb-2">📊 Test Information</h4>
            <div className="text-sm text-gray-600">
              <p><strong>Test Time:</strong> {results?.timestamp ? new Date(results.timestamp).toLocaleString() : 'N/A'}</p>
              <p><strong>Environment:</strong> {process.env.NODE_ENV || 'development'}</p>
              <p><strong>Database URL:</strong> {process.env.NEXT_PUBLIC_SUPABASE_URL ? '✅ Configured' : '❌ Missing'}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}