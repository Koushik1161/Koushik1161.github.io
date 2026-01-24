---
layout: post
title: "Repour: Multi-Agent Content Repurposing"
subtitle: "Transforming one piece of content into six platform-optimized versions"
date: 2025-08-25
---

Content creators face a tedious reality: a single idea must be reformatted for LinkedIn, Twitter, Reddit, email, Instagram, and TikTok. Each platform has different length limits, tone expectations, and engagement patterns. Manual repurposing takes hours.

Repour automates this through a three-agent AI pipeline that maintains quality and prevents the repetition that plagues LLM-generated content.

## The Three-Agent Pipeline

**Strategist Agent** analyzes input content first. It extracts key themes, identifies the strongest hook, classifies hook type (curiosity gap, pattern interrupt, FOMO, bold statement, vulnerability, or contrarian), and fingerprints the brand voice. This analysis informs everything downstream.

The output isn't just summary—it's strategic insight: "This content works best on LinkedIn and Twitter because of its professional vulnerability angle. The hook 'I burned $10M with zero product-market fit' is vulnerability type, which performs well with authenticity-seeking audiences."

**Creator Agent** generates platform-specific content. But not through simple adaptation—through genuine reimagining. LinkedIn gets 1,200-1,800 character prose with story structure. Twitter gets 5-8 tweets, 200-240 characters each, with the strongest hook first. Reddit gets casual authenticity with vulnerability. Each platform receives content native to its culture.

The personality system is extensive. "Witty" mode rotates through 12 comedic devices:

1. Narrator asides: "(Narrator: I was not fine.)"
2. Deadpan contradiction: "I was confident. The market disagreed. Loudly."
3. Unexpected comparisons: "Like bringing a calculator to a SpaceX meeting."
4. Self-deprecating timelines: "Day 1: Genius. Day 365: Confused."

Each device is tracked to prevent reuse within a session.

**Optimizer Agent** generates A/B variants with different hook types and predicts engagement scores. A vulnerability hook might score 78% on LinkedIn but 65% on Twitter. A pattern interrupt might perform inversely. These predictions aren't guarantees—they're informed starting points for experimentation.

## The Anti-Repetition System

LLMs naturally repeat themselves. Given similar inputs, they produce similar outputs. Testing showed 70% repetition rates across generations—the same metaphors, the same phrases, the same structures.

The session manager solves this through tracking and banning:

```typescript
Session tracks:
- Metaphors used (exact phrases + domain)
- Signature phrases (one-time items like "Jedi-mind-tricking")
- Comedic devices (for witty tone rotation)
- Opening patterns (so-opening, question-opening, etc.)
- Ending patterns (what-question, key-takeaway, etc.)
```

When generating new content, the Creator Agent receives a "banned items" list. The prompt explicitly states: "ZERO TOLERANCE for reusing these patterns." The LLM is forced to find novel alternatives.

The pattern extractor automatically identifies what was used:

- Metaphors: "like [X]" and "as [X] as" patterns with domain classification
- Signature phrases: Known one-time phrases
- Comedic devices: 11 detectible patterns
- Opening/ending patterns: Classified by structure

After each generation, new patterns are stored. The next generation has a longer banned list. Repetition drops from 70% to under 15%.

## Cross-Platform Coherence

The hardest challenge isn't adapting content—it's maintaining coherence. A reader who sees both your LinkedIn post and Twitter thread should feel they're from the same voice about the same topic, even though the execution differs completely.

The solution: same facts, different stories.

Twitter emphasizes the hook and immediate lesson—the viral angle. LinkedIn adds system/framework context—the depth angle. Both reference the same underlying truth but through different narrative lenses.

The Strategist's brand voice fingerprint (tone, style, keywords) constrains the Creator. Even when generating wildly different content, core voice elements persist.

## Temperature Tuning

Each agent uses different temperature settings:

- **Strategist**: 0.7 (analytical, consistent)
- **Creator**: 0.8 (balanced creativity)
- **Optimizer**: 0.9 (exploratory for variants)

The Strategist needs reliability—you want the same content analyzed similarly each time. The Creator needs creativity within constraints. The Optimizer needs to generate genuinely different alternatives.

This tuning emerged from experimentation. Lower temperatures produced bland Creator output. Higher Strategist temperatures produced inconsistent analysis.

## Platform-Specific Formatting

Each platform has explicit requirements:

**LinkedIn**: 1,200-1,800 chars max, prose format, story structure with insights
**Twitter**: 5-8 tweets, 200-240 chars each, strong hook first
**Reddit**: Title + body format, casual tone, authentic vulnerability
**Email**: Subject line + body, curiosity-gap driven, scannable with CTAs
**Instagram**: 125-150 chars optimal, emoji-friendly, hashtag strategy
**TikTok**: 15-60 sec script, high-energy, pattern interrupt in first 3 seconds

These aren't suggestions—they're enforced in prompts. The Creator knows what good looks like for each platform.

## The Cost Story

Claude Haiku 4.5 was chosen deliberately:

- 3x lower cost than Sonnet ($1/$5 vs $3/$15 per million tokens)
- 2x faster response times
- Quality sufficient for this task

Total cost: $0.01-0.02 per generation for six platforms. At 100 generations/day, that's $1-2 daily—less than a coffee.

## What I Learned

**Session state solves repetition**. The banned-items pattern is generalizable. Any time LLM repetition is a problem, track what was generated and explicitly forbid reuse.

**Personality rules beat examples**. Rather than showing the LLM examples of witty content (few-shot), 50+ lines of explicit rules produce more consistent results. "Use deadpan contradiction" is more controllable than "be like this example."

**Platform expertise matters**. Generic "make it shorter for Twitter" produces generic output. Specific requirements ("5-8 tweets, 200-240 chars, hook first") produce native-feeling content.

**Multi-agent separation enables tuning**. Each agent can have different temperature, different system prompts, different validation. Monolithic prompts can't be tuned this granularly.

**Cookie-based sessions are enough**. No database needed. HTTP-only cookies with 24-hour expiry handle session tracking. Redis is the upgrade path, but cookies work for MVP.

Repour transforms hours of manual work into seconds of automated generation. More importantly, it produces content that feels crafted for each platform—not just resized for each platform. That's the difference between automation that helps and automation that embarrasses.
