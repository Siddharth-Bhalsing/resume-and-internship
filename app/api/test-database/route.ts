import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'

export const dynamic = 'force-dynamic'

// No top-level Supabase initialization to prevent build-time crashes


export async function GET() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

  if (!supabaseUrl || !supabaseAnonKey || !supabaseUrl.startsWith('http')) {
    return NextResponse.json({
      error: 'Supabase configuration missing or invalid URL',
      timestamp: new Date().toISOString()
    }, { status: 500 })
  }

  const supabase = createClient(supabaseUrl, supabaseAnonKey)


  const results: {
    timestamp: string;
    tests: any[];
    overall?: any;
  } = {
    timestamp: new Date().toISOString(),
    tests: []
  }

  try {
    // Test 1: Database Connection
    results.tests.push({ name: 'Database Connection', status: 'running' })
    const { data: connectionData, error: connectionError } = await supabase
      .from('profiles')
      .select('count', { count: 'exact', head: true })

    if (connectionError) {
      results.tests[0].status = 'failed'
      results.tests[0].error = connectionError.message
    } else {
      results.tests[0].status = 'passed'
      results.tests[0].message = 'Successfully connected to database'
    }

    // Test 2: Tables Check
    results.tests.push({ name: 'Tables Existence', status: 'running' })
    const tables = [
      'profiles', 'recruiter_profiles', 'government_officials',
      'internship_postings', 'internships', 'applications',
      'resume_verifications', 'notifications', 'grievances',
      'updates', 'schemes'
    ]

    const tableResults = []
    for (const table of tables) {
      try {
        const { error } = await supabase
          .from(table)
          .select('*', { count: 'exact', head: true })

        tableResults.push({
          table,
          status: error ? 'failed' : 'passed',
          error: error?.message
        })
      } catch (err: any) {
        tableResults.push({
          table,
          status: 'failed',
          error: err.message
        })
      }
    }

    const failedTables = tableResults.filter(t => t.status === 'failed')
    if (failedTables.length === 0) {
      results.tests[1].status = 'passed'
      results.tests[1].message = `All ${tables.length} tables accessible`
    } else {
      results.tests[1].status = 'failed'
      results.tests[1].message = `${failedTables.length} tables failed`
      results.tests[1].details = tableResults
    }

    // Test 3: Sample Data Check
    results.tests.push({ name: 'Sample Data', status: 'running' })

    const { data: officials, error: officialsError } = await supabase
      .from('government_officials')
      .select('count', { count: 'exact', head: true })

    const { data: schemes, error: schemesError } = await supabase
      .from('schemes')
      .select('count', { count: 'exact', head: true })

    if (officialsError || schemesError) {
      results.tests[2].status = 'failed'
      results.tests[2].error = 'Error checking sample data'
    } else {
      results.tests[2].status = 'passed'
      results.tests[2].message = `Found ${officials} government officials and ${schemes} schemes`
    }

    // Test 4: Storage Buckets
    results.tests.push({ name: 'Storage Buckets', status: 'running' })

    const buckets = [
      'resumes', 'documents', 'profile-images', 'certificates',
      'company-logos', 'internship-posters'
    ]

    const bucketResults = []
    for (const bucket of buckets) {
      try {
        const { error } = await supabase.storage
          .from(bucket)
          .list('', { limit: 1 })

        bucketResults.push({
          bucket,
          status: error ? 'failed' : 'passed',
          error: error?.message
        })
      } catch (err: any) {
        bucketResults.push({
          bucket,
          status: 'failed',
          error: err.message
        })
      }
    }

    const failedBuckets = bucketResults.filter(b => b.status === 'failed')
    if (failedBuckets.length === 0) {
      results.tests[3].status = 'passed'
      results.tests[3].message = `All ${buckets.length} storage buckets accessible`
    } else {
      results.tests[3].status = 'failed'
      results.tests[3].message = `${failedBuckets.length} buckets failed`
      results.tests[3].details = bucketResults
    }

    // Test 5: RLS Security
    results.tests.push({ name: 'Security (RLS)', status: 'running' })

    const { error: rlsError } = await supabase
      .from('profiles')
      .insert({
        id: '00000000-0000-0000-0000-000000000000',
        full_name: 'Test User',
        email: 'test@example.com'
      })

    if (rlsError && rlsError.message.includes('policy')) {
      results.tests[4].status = 'passed'
      results.tests[4].message = 'Row Level Security is properly configured'
    } else {
      results.tests[4].status = 'warning'
      results.tests[4].message = 'RLS might not be properly configured'
    }

    // Overall status
    const failedTests = results.tests.filter(test => test.status === 'failed')
    const warningTests = results.tests.filter(test => test.status === 'warning')

    results.overall = {
      status: failedTests.length > 0 ? 'failed' : warningTests.length > 0 ? 'warning' : 'passed',
      message: failedTests.length > 0
        ? `${failedTests.length} tests failed`
        : warningTests.length > 0
          ? `${warningTests.length} tests with warnings`
          : 'All tests passed successfully',
      totalTests: results.tests.length,
      passedTests: results.tests.filter(t => t.status === 'passed').length,
      failedTests: failedTests.length,
      warningTests: warningTests.length
    }

    return NextResponse.json(results)

  } catch (error: any) {
    return NextResponse.json({
      timestamp: new Date().toISOString(),
      overall: {
        status: 'error',
        message: 'Unexpected error during testing',
        error: error.message
      }
    }, { status: 500 })
  }
}