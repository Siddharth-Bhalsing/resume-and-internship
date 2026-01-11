import { NextRequest, NextResponse } from 'next/server'
import { promises as fs } from 'fs'
import path from 'path'
import { v4 as uuidv4 } from 'uuid'
export const runtime = 'nodejs'
export const dynamic = 'force-dynamic'

// Use CommonJS requires to avoid ESM interop issues in the server runtime
// eslint-disable-next-line @typescript-eslint/no-var-requires
const pdfParse = require('pdf-parse')
// eslint-disable-next-line @typescript-eslint/no-var-requires
const mammoth = require('mammoth')

// Local text extraction for PDF/DOCX
async function extractTextLocally(fileBuffer: Buffer, fileName: string): Promise<string> {
  const lower = fileName.toLowerCase()
  if (lower.endsWith('.pdf')) {
    const parsed = await pdfParse(fileBuffer)
    return parsed.text || ''
  }
  if (lower.endsWith('.docx') || lower.endsWith('.doc')) {
    const { value } = await mammoth.extractRawText({ buffer: fileBuffer })
    return value || ''
  }
  throw new Error('Unsupported file format')
}

// Parsers
function extractPersonalInfo(text: string) {
  const emailMatch = text.match(/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/)
  const phoneMatch = text.match(/(\+\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4,5}/)
  const linkedinMatch = text.match(/linkedin\.com\/[A-Za-z0-9_\-\/]+/i)
  const githubMatch = text.match(/github\.com\/[A-Za-z0-9_\-]+/i)
  const lines = text.split('\n').map(l => l.trim()).filter(Boolean)
  let name = ''
  for (const line of lines.slice(0, 10)) {
    if (!/@|\d/.test(line) && /[A-Za-z]/.test(line) && line.split(' ').length <= 5) {
      name = line
      break
    }
  }
  const locationMatch = text.match(/([A-Z][a-z]+,\s*[A-Z][a-z]+)|([A-Z][a-z]+\s*,\s*[A-Z]{2})/)
  return {
    name,
    email: emailMatch?.[0] || '',
    phone: phoneMatch?.[0] || '',
    location: locationMatch ? (locationMatch[0]) : '',
    linkedin: linkedinMatch?.[0] || '',
    github: githubMatch?.[0] || ''
  }
}

function extractExperience(text: string) {
  const expSection = /(?:experience|work history|employment)([\s\S]*?)(?=education|skills|projects|certificates|$)/i.exec(text)
  const experience: any[] = []
  if (expSection) {
    const entries = expSection[1].split(/\n\s*\n/)
    for (const entry of entries) {
      const lines = entry.split('\n').map(l => l.trim()).filter(Boolean)
      if (lines.length === 0) continue
      const position = lines.find(l => /developer|engineer|manager|analyst|designer|lead/i.test(l)) || lines[0]
      const company = lines.find(l => /^[A-Za-z&.,\-\s]{2,}$/.test(l) && !/@|\d/.test(l)) || ''
      const dateMatch = entry.match(/(\d{4})\s*[-–]\s*(\d{4}|present|current)/i)
      const duration = dateMatch ? `${dateMatch[1]} - ${dateMatch[2]}` : ''
      const description = entry.substring(0, 400)
      if (position || company) {
        experience.push({
          id: uuidv4(),
          company,
          position,
          location: '',
          startDate: duration ? duration.split(' - ')[0] : '',
          endDate: duration ? duration.split(' - ')[1] : '',
          current: /present|current/i.test(duration),
          description,
          proofUploaded: false
        })
      }
    }
  }
  return experience
}

function extractEducation(text: string) {
  const eduSection = /(?:education|academic|qualification)([\s\S]*?)(?=experience|skills|projects|certificates|$)/i.exec(text)
  const education: any[] = []
  if (eduSection) {
    const entries = eduSection[1].split(/\n\s*\n/)
    for (const entry of entries) {
      const degreeMatch = entry.match(/(bachelor|master|phd|b\.?tech|m\.?tech|b\.?sc|m\.?sc|mba|b\.e\.|m\.e\.)/i)
      if (!degreeMatch) continue
      const degree = degreeMatch[0]
      const institution = (entry.split('\n').find(l => /university|college|institute|school/i.test(l)) || '').trim()
      const yearMatch = entry.match(/(20\d{2}|19\d{2})/g)
      const year = yearMatch ? yearMatch[yearMatch.length - 1] : ''
      education.push({
        id: uuidv4(),
        institution,
        degree,
        field: '',
        startDate: '',
        endDate: year,
        grade: '',
        location: ''
      })
    }
  }
  return education
}

function extractSkills(text: string) {
  const lower = text.toLowerCase()
  const tech: string[] = []
  const possible = [
    'javascript', 'typescript', 'react', 'node', 'python', 'java', 'c++', 'c#', 'php', 'ruby', 'go', 'rust', 'sql', 'html', 'css', 'docker', 'kubernetes', 'aws', 'azure', 'gcp', 'mongodb', 'mysql', 'postgresql', 'git', 'github', 'jira', 'postman'
  ]
  for (const s of possible) {
    if (lower.includes(s)) tech.push(s.charAt(0).toUpperCase() + s.slice(1))
  }
  return { technical: Array.from(new Set(tech)), soft: [] as string[] }
}

function extractCertificates(text: string) {
  const certs: any[] = []
  const patterns = [
    /(aws|azure|google cloud|gcp)\s+(certified|associate|professional)/ig,
    /(microsoft certified|microsoft azure|microsoft office)/ig,
    /(cisco certified|ccna|ccnp|ccie)/ig,
    /(pmp|scrum master|six sigma|csm|cspo)/ig,
    /(google cloud professional|associate cloud engineer)/ig
  ]

  for (const pattern of patterns) {
    const matches = text.match(pattern) || []
    for (const m of matches) {
      // Extract certificate ID from context
      const certId = extractCertificateId(text, m)
      const issuer = extractCertificateIssuer(m)
      const date = extractCertificateDate(text, m)

      certs.push({
        id: uuidv4(),
        name: m,
        issuer,
        certificateId: certId,
        issueDate: date,
        verificationStatus: 'pending',
        verified: false
      })
    }
  }
  return certs
}

function extractCertificateId(text: string, certName: string): string {
  // Look for ID patterns near the certificate name
  const start = text.indexOf(certName)
  if (start === -1) return ''

  const context = text.substring(Math.max(0, start - 50), Math.min(text.length, start + certName.length + 50))

  // Common ID patterns
  const idPatterns = [
    /([A-Z]{2,}-[A-Z0-9-]+)/g,
    /(ID|Certificate|Cert):\s*([A-Z0-9-]+)/gi,
    /#([A-Z0-9-]+)/g
  ]

  for (const pattern of idPatterns) {
    const matches = context.match(pattern)
    if (matches) {
      return matches[0].replace(/^(ID|Certificate|Cert):\s*/i, '').replace(/^#/, '')
    }
  }

  return ''
}

function extractCertificateIssuer(certName: string): string {
  const lower = certName.toLowerCase()
  if (lower.includes('aws')) return 'Amazon Web Services'
  if (lower.includes('azure') || lower.includes('microsoft')) return 'Microsoft'
  if (lower.includes('google')) return 'Google'
  if (lower.includes('cisco')) return 'Cisco'
  if (lower.includes('pmp')) return 'Project Management Institute'
  if (lower.includes('scrum')) return 'Scrum Alliance'
  return 'Unknown'
}

function extractCertificateDate(text: string, certName: string): string {
  const start = text.indexOf(certName)
  if (start === -1) return ''

  const context = text.substring(Math.max(0, start - 30), Math.min(text.length, start + certName.length + 30))

  const dateMatch = context.match(/(20\d{2}|19\d{2})/)
  return dateMatch ? dateMatch[0] : ''
}

export async function POST(request: NextRequest) {
  try {
    console.log('📄 Resume Extraction Request Started');

    // 1. Configuration Check
    // 1. Configuration Check
    // HARDCODED KEY FOR DEMO STABILITY
    const GEMINI_API_KEY = process.env.GEMINI_API_KEY || 'AIzaSyD55NyhM1TLOrIkDWUZwhes5vYppruEYgU';
    if (!GEMINI_API_KEY) {
      console.error('❌ Gemini API Key is missing');
      // Even if missing, we will fall through to local extraction so the demo doesn't crash
      console.log('⚠️ Running in OFFLINE DEMO MODE');
    }

    // 2. Parse Form Data
    const formData = await request.formData();
    const file = formData.get('file') as File;

    if (!file) {
      console.error('❌ No file received');
      return NextResponse.json({ error: 'No file uploaded' }, { status: 400 });
    }

    console.log(`📂 Processing file: ${file.name} (${file.size} bytes)`);

    // 3. Read Buffer (In-Memory Processing)
    const fileBuffer = Buffer.from(await file.arrayBuffer());

    // 4. Try AI Extraction (Gemini 1.5 Flash)
    try {
      let text = '';

      // Parse PDF/Doc text first for prompt
      if (file.name.toLowerCase().endsWith('.pdf')) {
        console.log('🔄 Parsing PDF locally...');
        const parsed = await pdfParse(fileBuffer);
        text = parsed.text;
      } else if (file.name.toLowerCase().endsWith('.docx') || file.name.toLowerCase().endsWith('.doc')) {
        console.log('🔄 Parsing DOCX locally...');
        const { value } = await mammoth.extractRawText({ buffer: fileBuffer });
        text = value;
      } else {
        throw new Error('Unsupported file format');
      }

      console.log(`✅ Text extracted locally (${text.length} chars). Sending to Gemini...`);

      const prompt = `
        You are an expert Resume Parser. 
        Extract structured data from the following resume text.
        Return ONLY valid JSON. No markdown formatting.

        Resume Text:
        ${text.slice(0, 50000)}

        Required JSON Structure:
        {
          "personalInfo": {
            "name": "Candidate Name",
            "email": "Email",
            "phone": "Phone",
            "location": "City, Country",
            "linkedin": "URL",
            "github": "URL"
          },
          "experience": [{
            "company": "Company Name",
            "position": "Role",
            "duration": "Start - End",
            "description": "Summary"
          }],
          "education": [{
            "institution": "School Name",
            "degree": "Degree",
            "year": "Year"
          }],
          "skills": {
            "technical": ["Skill1", "Skill2"],
            "soft": ["Skill1"]
          },
          "certificates": [{
            "name": "Cert Name",
            "issuer": "Issuer",
            "date": "Date"
          }]
        }
      `;

      const aiResponse = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] }),
        }
      );

      if (!aiResponse.ok) {
        const errText = await aiResponse.text();
        throw new Error(`Gemini API Error: ${aiResponse.status} ${errText}`);
      }

      const json = await aiResponse.json();
      const aiText = json.candidates?.[0]?.content?.parts?.[0]?.text;

      if (!aiText) throw new Error('Empty response from AI');

      // Parse JSON from AI
      const cleanJson = aiText.replace(/```json/g, '').replace(/```/g, '').trim();
      const extractedData = JSON.parse(cleanJson);

      console.log('✅ AI Extraction Successful');
      return NextResponse.json({
        success: true,
        data: extractedData,
        message: 'Resume processed successfully via AI'
      });

    } catch (aiError: any) {
      console.error('⚠️ AI Extraction Failed:', aiError.message);
      console.log('🔄 Falling back into local regex extraction');

      // 5. Fallback: Local Regex Extraction
      const text = await extractTextLocally(fileBuffer, file.name);

      const extractedData = {
        personalInfo: extractPersonalInfo(text),
        experience: extractExperience(text),
        education: extractEducation(text),
        skills: extractSkills(text),
        certificates: extractCertificates(text),
        projects: [],
        awards: [],
        languages: []
      };

      console.log('✅ Local Regex Extraction Successful');
      return NextResponse.json({
        success: true,
        data: extractedData,
        message: 'Resume processed successfully (Offline Mode)'
      });
    }

  } catch (error: any) {
    console.error('❌ Critical Server Error:', error);
    return NextResponse.json(
      { error: 'Internal server error: ' + error.message },
      { status: 500 }
    );
  }
}
