---
layout: post
title: "The Siri-Style Voice Bot: Real-Time Conversations with OpenAI"
subtitle: "Building a voice interview chatbot with WebRTC, animated orb UI, and ephemeral authentication"
date: 2025-05-20
---

There's something magical about talking to an AI and having it respond with a voice. Not text-to-speech bolted on after the fact, but genuine real-time voice conversation. That's what I built with Cloid-Clean—a voice interview bot with a Siri-style animated orb that conducts real-time conversations.

## The WebRTC Foundation

The technical core is WebRTC, the same technology that powers video calls. But instead of peer-to-peer with another human, the peer connection goes to OpenAI's Realtime API. This isn't HTTP request-response; it's a persistent bidirectional stream where audio flows continuously.

The beauty of this approach is latency. Traditional voice bots have a painful sequence: record audio, send to server, transcribe, send to LLM, get response, send to TTS, stream audio back. Each step adds delay. With OpenAI's Realtime API, transcription, reasoning, and voice synthesis happen in a single streaming connection. The result feels conversational rather than transactional.

## The Animated Orb

I wanted the interface to feel alive. Drawing inspiration from Apple's design philosophy, I created an animated orb that breathes when idle, pulses when listening, and glows when speaking. The animation isn't decorative—it's functional feedback.

The Voice class implements a clean state machine: idle → connecting → listening → processing → speaking. Each state transition updates CSS classes, triggers animations, and shows appropriate status text. When you stop speaking, the orb's behavior tells you the system heard you and is thinking before you see any text.

## Ephemeral Token Pattern

Security for voice APIs is tricky. You can't expose your OpenAI API key to the browser—that's instant compromise. But the browser needs to authenticate with OpenAI's Realtime endpoint.

The solution is ephemeral tokens. The browser requests a session token from my backend, which generates it using my API key. This token is temporary, scoped to a single session, and safe to expose to the frontend. It's a pattern borrowed from OAuth but applied to real-time AI connections.

The backend is minimal: an Express server in development, a Vercel serverless function in production. It has one job: generate ephemeral tokens with the appropriate configuration, including the system instructions that define the AI's persona.

## Persona as System Instruction

The bot responds as "Koushik"—not a generic assistant, but a specific persona with a life story, values, and even growth areas to discuss in interviews. All of this is injected through system instructions when creating the session.

I learned that specificity in system instructions matters enormously. "Be helpful" produces bland responses. A detailed persona with specific rules ("ONLY answer interview-related questions", "respond in ENGLISH only", "keep responses under 45 seconds") produces focused, personality-rich conversations.

The scope enforcement was crucial. Without it, the bot would happily discuss recipes or write poetry. With strict scope rules, it gracefully declines off-topic requests while staying in character.

## Server-Side Voice Activity Detection

One subtle but important decision: letting OpenAI handle voice activity detection (VAD) server-side. Client-side VAD requires shipping audio processing code, tuning sensitivity thresholds, and handling edge cases like background noise.

Server-side VAD just works. You stream audio, and OpenAI figures out when you've stopped speaking. The `input_audio_buffer.speech_started` and `speech_stopped` events come back through the data channel, letting you update the UI state appropriately.

## The Minimal UI Philosophy

There's a quote I embedded in the code from Jony Ive: "True simplicity is derived from so much more than just the absence of clutter and ornamentation. It's about bringing order to complexity."

The interface has an orb, a transcript that shows only the last two messages, and navigation buttons with preset questions. That's it. No settings panels, no history browsers, no feature toggles. The complexity—WebRTC negotiation, audio encoding, state management—is invisible to the user.

## Deployment Reality

Getting this deployed taught me about Vercel's serverless constraints. My initial deployment failed with 404 errors. The issue? Vercel expects serverless functions in an `api/` folder with specific structure. Uploading just the function file doesn't work; you need the whole folder hierarchy.

The live deployment at voice-interview-bot-three.vercel.app works reliably now. It handles the token generation, the frontend serves static files, and the actual audio flows directly between browser and OpenAI. The architecture is simple because the infrastructure does the heavy lifting.

I'm proud of this project not because it's complex, but because it's minimal. Eight lines of HTML, a single JavaScript class, one serverless function. Yet it produces something that feels futuristic: a natural voice conversation with an AI persona. Sometimes the best engineering is knowing what to leave out.
