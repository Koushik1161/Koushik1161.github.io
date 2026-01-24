---
layout: post
title: "Geon: Building an AI Interviewer That Actually Cares"
subtitle: "Real-time voice AI with emotional intelligence for anxiety-free interviews"
date: 2025-09-02
---

Job interviews are stressful. Your palms sweat, your mind goes blank, you forget that brilliant answer you rehearsed. What if the interview itself could help you perform better?

Geon is an AI interviewer built with emotional intelligence at its core. Not just capable of evaluating candidates, but actually designed to reduce anxiety and bring out their best.

## The Design Philosophy: Anxiety Is the Enemy

Traditional interview tools focus on evaluation. Geon focuses on the interview experience itself. The insight: anxious candidates underperform. If we can reduce anxiety, we get better signal on actual capability.

This led to some unconventional design decisions:

**Color psychology matters.** We replaced stark whites and aggressive reds with calming blues and sage greens. Small change, meaningful impact on emotional state.

**Progressive disclosure.** Instead of one intimidating setup screen, we use a multi-step wizard. Each step is manageable. The full scope never overwhelms.

**Status transparency.** When the AI is "thinking," users know it. When it's listening, that's visible too. Uncertainty breeds anxiety; transparency reduces it.

```typescript
enum InterviewStatus {
    CONNECTING = "Setting up your interview...",
    LISTENING = "I'm listening...",
    THINKING = "Considering your response...",
    RESPONDING = "Sharing thoughts...",
    COMPLETE = "Interview complete"
}
```

## The Technical Stack: Real-Time Voice

Geon uses OpenAI's Realtime API over WebSockets for natural voice conversation:

```typescript
const realtimeClient = new OpenAIRealtimeClient({
    model: "gpt-4o-realtime-preview",
    sessionConfig: {
        turn_detection: { type: "server_vad" },
        voice: "echo"
    }
});

realtimeClient.on("response.audio.delta", (chunk) => {
    audioPlayer.queueChunk(chunk);
});

realtimeClient.on("conversation.item.input_audio_transcription", (transcript) => {
    updateTranscript("user", transcript);
});
```

Server-side voice activity detection means the AI knows when you're done speaking without awkward pauses or interruptions. The conversation flows naturally.

## Dual Mode Architecture

Not everyone wants a formal interview. We built two modes:

**Professional Mode**: Structured evaluation for hiring purposes. Scores on multiple dimensions, generates detailed reports, maintains formality throughout.

**Practice Mode**: AI Coach persona. More supportive, offers tips mid-interview, celebrates good answers, provides constructive feedback on weak ones. Perfect for interview prep.

```typescript
const personaConfig = {
    professional: {
        temperature: 0.7,
        systemPrompt: `You are a professional interviewer...`,
        evaluationMode: "strict"
    },
    practice: {
        temperature: 0.8,
        systemPrompt: `You are a supportive interview coach...`,
        evaluationMode: "developmental"
    }
};
```

Same underlying technology, completely different experiences.

## Voice Analytics: Beyond Words

We track more than what candidates say:

```typescript
interface VoiceAnalytics {
    speakingPace: number;        // words per minute
    fillerWordCount: number;     // ums, uhs, likes
    volumeConsistency: number;   // stability score
    clarityScore: number;        // pronunciation clarity
    confidenceLevel: number;     // derived from multiple factors
    energyLevel: number;         // engagement indicator
    responseTime: number;        // think time before answering
}
```

This data helps candidates understand not just what they said, but how they said it. Many people don't realize they speak too fast when nervous or drop their volume at the end of sentences.

## The Panic Button

Sometimes anxiety wins anyway. We added a literal panic button:

```typescript
function handlePanicButton() {
    // Pause the interview
    realtimeClient.pauseSession();

    // Show breathing exercise
    setShowBreathingExercise(true);

    // After completion, offer options
    setTimeout(() => {
        setShowResumeOptions(true);
        // Can resume, restart, or exit gracefully
    }, 60000);
}
```

A 60-second guided breathing exercise, then options to resume, restart, or exit without judgment. No interview tool I've seen has this, and it matters more than most features.

## Mock Mode: No API Required

Development and testing shouldn't require API costs. Mock mode provides realistic simulated interviews:

```typescript
class MockRealtimeClient {
    async simulateResponse(userInput: string) {
        const mockResponses = this.getContextualResponses(userInput);
        await this.simulateTypingDelay();

        return {
            transcript: mockResponses.text,
            analysis: this.generateMockAnalysis(userInput)
        };
    }
}
```

The mock generates contextually appropriate responses, simulates realistic timing, and produces plausible analytics. Users can explore the full experience before connecting to live AI.

## Security: Keeping Keys Safe

API keys never touch the browser:

```typescript
// Server endpoint
app.post("/session/token", rateLimit, async (req, res) => {
    const ephemeralToken = await openai.createEphemeralToken({
        expiry: "5m",
        scope: "realtime"
    });

    res.json({ token: ephemeralToken });
});
```

Clients get short-lived tokens scoped to specific capabilities. Even if intercepted, they expire quickly and can't access anything beyond the interview session.

## What I Learned

**Emotional design is technical design.** The breathing exercises, color choices, and panic button aren't separate from the "real" technical work. They're essential features that required as much thought as the WebSocket implementation.

**Voice analytics reveal hidden patterns.** People are often surprised by their own metrics. "I didn't realize I said 'um' that much" is common feedback. The data helps in ways subjective feedback can't.

**Mock modes are worth the investment.** Building a realistic mock system took significant effort, but it pays off in development velocity, demo capability, and user onboarding.

---

*Built with Next.js, OpenAI Realtime, and the conviction that interviews should help people succeed, not just filter them out.*
