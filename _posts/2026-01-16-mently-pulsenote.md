---
layout: post
title: "Mently: YouTube Video Summarization That Actually Works"
subtitle: "Building PulseNote with graceful caption fallbacks and cost-optimized AI"
date: 2026-01-16
---

A 45-minute YouTube video contains maybe 10 minutes of insight. The rest is intro, outro, tangents, and filler. PulseNote extracts what matters: structured summaries, key points, timestamped chapters, and notable quotes—all in under a minute.

## Dual Transcript Strategy

The clever part is handling videos both with and without captions.

**Primary path**: Most YouTube videos have auto-generated or manual captions. PulseNote fetches these directly—fast, free, no API costs. Parse the caption JSON, extract timed segments, combine into full text.

**Fallback path**: Some videos disable captions. For these, PulseNote downloads the lowest-quality audio stream and transcribes via OpenAI's Whisper API. Slower and costs money, but works for everything.

```javascript
try {
  transcriptData = await fetchTranscript(videoId, language);
} catch (err) {
  transcriptData = await transcribeFromAudio(videoId, language);
  notice = 'Captions unavailable. Transcript generated from audio.';
}
```

Users see a small notice when using the fallback, but the experience is seamless. The system adapts without requiring user intervention.

## Structured AI Output

GPT-4o-mini receives the transcript (truncated to 12KB for cost management) and returns structured JSON:

```javascript
{
  overview: "2-3 sentence summary",
  key_points: ["point 1", "point 2", ...],
  chapters: [
    { time: "00:00", title: "Introduction", summary: "..." },
    { time: "05:30", title: "Main Argument", summary: "..." }
  ],
  quotes: ["Notable quote 1", "Notable quote 2"]
}
```

OpenAI's `response_format: { type: 'json_object' }` ensures valid JSON every time. No regex parsing of prose, no hoping the model follows the format. Structured output is the feature that makes this reliable.

## Cost Optimization

AI APIs charge by token. A full transcript might be 50,000 characters—expensive and often unnecessary. PulseNote truncates:

```javascript
function trimTranscript(text, maxChars = 12000) {
  if (cleaned.length > maxChars) {
    cleaned = `${cleaned.slice(0, maxChars)}...`;
    truncated = true;
  }
  return { text: cleaned, truncated };
}
```

Twelve thousand characters captures most key content while keeping API costs under a cent per video. When truncation happens, the UI flags it—users know they're getting a partial analysis.

For a free-to-use tool, this constraint is essential. Unbounded API costs would make the project unsustainable.

## YouTube Cookie Handling

YouTube aggressively rate-limits API access. The solution: authenticated requests using browser cookies.

```javascript
function getYouTubeAgent() {
  const { cookies, source } = loadYouTubeCookies();
  if (cookies) {
    cachedAgent = ytdl.createAgent(cookies);
    return cachedAgent;
  }
  cachedAgent = ytdl.createAgent();
  return cachedAgent;
}
```

Users can provide their YouTube cookies via environment variable or file path. Authenticated requests bypass most rate limiting. The system works without cookies but becomes more reliable with them.

Error messages guide users when 403 errors occur: "YouTube is blocking requests. Add your cookies to .env to continue." Actionable guidance reduces support burden.

## The Tab Interface

Results display across four tabs: Overview, Key Points, Chapters, Quotes. Tab switching is pure DOM manipulation:

```javascript
tabs.forEach((tab) => {
  tab.addEventListener('click', () => {
    // Toggle active states, show corresponding panel
  });
});
```

No React state management, no framework overhead. The entire frontend is vanilla JavaScript—readable, portable, fast.

## Transcript Search

The full transcript is searchable in the browser:

```javascript
const filtered = fullTranscriptLines.filter(
  line => line.text.toLowerCase().includes(query)
);
```

Client-side filtering means instant results without network calls. Users can find specific moments by keyword, then click timestamps to jump directly to that point in the video.

## Export Functionality

Everything combines into a single exportable document:

```javascript
currentSummaryText = [
  `Title: ${videoTitle.textContent}`,
  `Overview: ${summary.overview}`,
  'Key Points:', ...keyPoints,
  'Chapters:', ...chapters,
  'Quotes:', ...quotes
].filter(Boolean).join('\n');
```

Copy to clipboard or download as text file. The export includes everything—useful for saving research, sharing with colleagues, or archiving for later reference.

## Design Philosophy

The visual design follows a warm, organic aesthetic: cream backgrounds, teal interactives, orange accents, soft shadows. Typography uses Fraunces (display), Space Grotesk (sans), and IBM Plex Mono (monospace)—a distinctive combination that feels premium without being corporate.

Skeleton loaders maintain perceived performance during API calls. Processing time displays after completion, setting expectations for future use.

## What I Learned

**Fallback strategies are essential**. The caption-first, audio-fallback approach handles edge cases gracefully. Users don't need to know which path was taken; they just get results.

**Token truncation is a feature, not a bug**. Explicitly limiting input size controls costs and keeps response times fast. Flagging truncation maintains transparency.

**Structured output eliminates parsing headaches**. JSON mode guarantees valid structure. No more debugging why the model decided to use a different format this time.

**Vanilla JavaScript is underrated**. For applications this size, frameworks add complexity without proportional benefit. Direct DOM manipulation is readable and fast.

**Cookie authentication unlocks reliability**. YouTube's anti-bot measures are aggressive. Providing an authentication path transforms "sometimes works" into "reliably works."

PulseNote solves a real problem—video content overload—with appropriate technology. Not every feature needs cutting-edge AI. Sometimes the innovation is in the integration: combining captions, transcription APIs, and structured LLM output into a seamless experience.
