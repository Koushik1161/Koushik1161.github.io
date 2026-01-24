---
layout: post
title: "FRIJAN: Voice-First AI Assistant Architecture"
subtitle: "Designing for speech as the primary interface"
date: 2025-06-08
---

Most AI assistants are text-first with voice bolted on. FRIJAN inverts this: speech is the primary interface, with text as the fallback. The difference shapes everything about the architecture.

## Voice-First Constraints

When speech is primary, latency becomes critical. Users tolerate delays in text interfaces that feel awkward in conversation. A two-second pause before typing a response is fine; a two-second silence in a voice conversation feels broken.

This constraint drives architectural decisions. The system needs to start responding before fully understanding the query. Streaming becomes essential, not optional.

Turn-taking is another constraint. Text conversations are asynchronous—you respond when ready. Voice conversations have rhythm. The system needs to know when you've stopped speaking and when you're just pausing for breath.

## The WebRTC Foundation

FRIJAN uses WebRTC for real-time audio, not REST APIs. Audio streams continuously rather than being recorded, uploaded, and processed in batches.

The connection is bidirectional: the user's microphone streams to the server while the server streams synthesized speech back. No round trips, no upload delays, no artificial turn boundaries.

## Server-Side Processing

Voice Activity Detection (VAD) runs server-side. The server analyzes the audio stream to determine when speech starts and stops, eliminating the need for push-to-talk and avoiding the complexity of client-side audio processing.

The trade-off is latency—sending audio to the server for VAD adds delay. But the latency is consistent and predictable, which matters more than absolute speed for conversational flow.

## The Streaming Response Pattern

Traditional request-response doesn't work for voice. You can't wait for the complete response before starting to speak—that creates awkward silences.

Instead, FRIJAN streams partial responses. As the LLM generates tokens, they're synthesized to speech and streamed back. The user hears the response beginning while the system is still generating the end.

This requires careful prompt engineering. The system needs to generate coherent partial responses, not just complete sentences. Opening phrases like "Let me think about that..." buy time while the actual answer is being generated.

## Persona Engineering

Voice assistants need consistent personality more than text interfaces. Vocal tone, pacing, and word choice all contribute to persona. FRIJAN defines this through system instructions that specify:

- Speaking style (conversational, not formal)
- Response length (brief for simple questions, detailed when needed)
- Personality traits (helpful, patient, occasionally playful)
- Topic boundaries (what to engage with, what to deflect)

The persona isn't just style—it's functional. A consistent personality makes interactions predictable and comfortable.

## Error Recovery

Voice errors are harder to recover from than text errors. If the system misunderstands a written message, you can re-read and correct. If it misunderstands speech, you might not know exactly what it heard.

FRIJAN handles this through confirmation patterns. For consequential actions, it restates what it understood before acting. For ambiguous input, it asks clarifying questions rather than guessing.

The goal is graceful degradation. Even when things go wrong, the conversation should continue smoothly rather than breaking entirely.

## The Minimal Interface

The UI is deliberately sparse: an animated orb that visualizes state, a transcript showing recent exchanges, and nothing else. No settings panels, no configuration options, no visible controls.

This isn't minimalism for aesthetics—it's minimalism for usability. In a voice-first interface, visual complexity distracts from the conversation. The orb's animation provides all necessary feedback: listening, thinking, speaking.

## What Worked

The streaming architecture was essential. Once I implemented true streaming, conversational flow improved dramatically. Latency matters less when partial responses bridge gaps.

Server-side VAD simplified the client dramatically. Client-side audio processing is complex and varies across devices. Server-side processing is consistent and controllable.

Strict persona instructions produced more natural conversations. Without specific guidance, the assistant would shift styles mid-conversation. With detailed persona specs, it maintained consistent character.

## What Didn't

Parallel conversation handling was harder than expected. When the user interrupts the system's speech, both audio streams overlap. Handling this gracefully requires complex state management that I didn't fully solve.

Background noise handling needed more work. In quiet environments, the system works well. In noisy environments, VAD triggers incorrectly and the experience degrades.

Long conversations accumulate context that eventually causes problems. The system doesn't yet have good summarization or memory management for extended sessions.

## Voice as Primary

Building voice-first rather than text-first changed my perspective on conversational AI. The constraints are different, the success criteria are different, and the architectural patterns are different.

Text interfaces are forgiving—users can skim, scroll back, and process at their own pace. Voice interfaces are unforgiving—every word is heard in real-time, and there's no going back.

But voice interfaces also feel more personal. When the system gets it right, the experience is genuinely conversational. That's worth the architectural complexity.
