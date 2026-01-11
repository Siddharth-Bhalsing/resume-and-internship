
import { NextRequest, NextResponse } from 'next/server';
import pdf from 'pdf-parse';

export const dynamic = 'force-dynamic'

// NOTE: In production, use process.env.GEMINI_API_KEY
// For this local demo, we use the key provided by the user.
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || 'AIzaSyD55NyhM1TLOrIkDWUZwhes5vYppruEYgU';

export async function POST(req: NextRequest) {
    try {
        const formData = await req.formData();
        const file = formData.get('resume') as File;
        const jobDescription = formData.get('jobDescription') as string || 'General Software Engineering role';

        if (!file) {
            return NextResponse.json({ error: 'No resume file provided' }, { status: 400 });
        }

        // 1. Parse PDF
        const buffer = Buffer.from(await file.arrayBuffer());
        let text = '';
        try {
            const data = await pdf(buffer);
            text = data.text;
        } catch (e) {
            console.error('PDF Parse Error:', e);
            return NextResponse.json({ error: 'Failed to parse PDF' }, { status: 500 });
        }

        // 2. truncate text if too long (Gemini has limits, though fairly large)
        const truncatedText = text.slice(0, 30000);

        // 3. Construct Prompt
        const prompt = `
      You are an expert Resume Verifier for the Government of India.
      Analyze the following resume text against the job description: "${jobDescription}".
      
      Resume Text:
      ${truncatedText}

      Output strictly in JSON format with the following structure:
      {
        "name": "Candidate Name (extract from text)",
        "email": "Candidate Email (extract)",
        "position": "Suggested Position based on skills",
        "verificationScore": (number 0-100 based on match),
        "riskLevel": ("low", "medium",, or "high" - high if fake keywords or inconsistencies found),
        "status": "verified" (if score > 70) else "flagged",
        "flags": ["list", "of", "red", "flags", "or", "missing", "skills"]
      }
      Do not include markdown formatting like \`\`\`json. Just the raw JSON.
    `;

        // 4. Call Gemini API
        const response = await fetch(
            `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`,
            {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    contents: [{ parts: [{ text: prompt }] }],
                }),
            }
        );

        if (!response.ok) {
            const err = await response.text();
            console.error('Gemini API Error:', err);
            return NextResponse.json({ error: 'AI Service Unavailable' }, { status: 503 });
        }

        const json = await response.json();
        const aiText = json.candidates?.[0]?.content?.parts?.[0]?.text;

        if (!aiText) {
            throw new Error('No response from AI');
        }

        // 5. Parse AI Response
        let result;
        try {
            // Clean up markdown code blocks if present
            const cleanJson = aiText.replace(/```json/g, '').replace(/```/g, '').trim();
            result = JSON.parse(cleanJson);
        } catch (e) {
            console.error('JSON Parse Error:', e);
            // Fallback or retry logic could go here
            return NextResponse.json({ error: 'Failed to parse AI response' }, { status: 500 });
        }

        // Add metadata
        result.id = Math.random().toString(36).substr(2, 9);
        result.submittedAt = new Date().toISOString().split('T')[0];

        return NextResponse.json(result);

    } catch (error: any) {
        console.error('Verify Route Error:', error);
        return NextResponse.json({ error: error.message }, { status: 500 });
    }
}
