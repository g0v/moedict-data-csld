import type { NextApiRequest, NextApiResponse } from 'next';
import { NextResponse } from 'next/server';

function isError(error: any): error is Error {
    return error instanceof Error;
}

export async function POST(req: Request) {
    const data = await req.json();
    const { text } = data;

    try {
        // Call the backend server with the text to check
        const backendResponse = await fetch('http://localhost:1111/api/word/check-text/', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ text: text }),
        });

        // If the response from the backend is not ok, throw an error to be caught below
        if (!backendResponse.ok) {
            throw new Error(`Backend error: ${backendResponse.status}`);
        }

        // Get the JSON from the backend response
        const data = await backendResponse.json();

        // Respond to the client with the data from the backend
        return NextResponse.json(data, { status: 200 })
    } catch (error) {
        // Handle any errors that occurred during the request
        const message = isError(error) ? error.message : 'An unknown error occurred';
        return NextResponse.json({ message: message }, { status: 500 })
    }
};
