---
layout: post
title: "Prism: From One Blog Post to Six Platform Posts in Five Minutes"
subtitle: "Building a multi-agent content repurposing engine"
date: 2025-11-06
---

Content creators face a familiar grind: you write a blog post, then spend hours adapting it for LinkedIn, Twitter, Reddit, email newsletters, Instagram, and TikTok. Each platform has different norms, lengths, and expectations. What if AI could handle that translation?

Prism transforms one piece of content into six platform-optimized posts using a multi-agent architecture. Five minutes instead of five hours.

## The Three-Agent Pipeline

Instead of one prompt doing everything, Prism uses three specialized agents:

### Agent 1: The Strategist

Analyzes the input content and creates a strategic brief:

```typescript
const strategistPrompt = `
Analyze this content and extract:
- Core message (one sentence)
- Target audience profile
- Brand voice DNA (tone, style, key phrases)
- Most compelling hook (categorize: curiosity gap, pattern interrupt,
  FOMO, bold statement, vulnerability, or contrarian)
- Key themes for adaptation
`;

const strategy = await claude.messages.create({
    model: "claude-haiku-4-5",
    temperature: 0.7,
    messages: [{ role: "user", content: strategistPrompt + inputContent }]
});
```

The strategist doesn't create content—it creates guidance for the creator.

### Agent 2: The Creator

Takes the strategic brief and generates platform-specific content:

```typescript
const platformSpecs = {
    linkedin: {
        length: "1200-1800 characters",
        style: "Professional but personal, first 2 lines crucial",
        hooks: "Pattern interrupt or vulnerability work well"
    },
    twitter: {
        length: "5-8 tweet thread",
        style: "Punchy, no hashtags in hook, viral angles",
        hooks: "Curiosity gap or bold statement"
    },
    reddit: {
        length: "300-500 words",
        style: "Authentic, anti-promotional, community-first",
        hooks: "Value-first, no marketing speak"
    },
    // ... email, instagram, tiktok
};
```

Each platform gets content tailored to its specific norms and algorithm preferences.

### Agent 3: The Optimizer

Evaluates and improves the generated content:

```typescript
const optimizerPrompt = `
For each platform post:
1. Predict engagement score (0-100)
2. Generate 2-3 A/B variants with different hook types
3. Explain what makes each variant likely to perform
`;
```

The optimizer doesn't just generate—it helps users choose between options with predicted performance data.

## The Anti-Repetition Engine

A subtle but crucial feature: the Creator agent tracks what it's used before:

```typescript
class RepetitionTracker {
    usedPhrases: Set<string> = new Set();
    usedHookTypes: Map<string, number> = new Map();
    usedQuestions: Set<string> = new Set();

    checkAndBlock(content: string): string[] {
        const issues = [];
        for (const phrase of this.usedPhrases) {
            if (content.includes(phrase)) {
                issues.push(`Repeated phrase: "${phrase}"`);
            }
        }
        return issues;
    }

    register(content: string, hookType: string) {
        this.extractPhrases(content).forEach(p => this.usedPhrases.add(p));
        this.usedHookTypes.set(hookType,
            (this.usedHookTypes.get(hookType) || 0) + 1);
    }
}
```

Without this, AI tends to reuse favorite phrases and structures. The tracker ensures each platform post feels distinct.

## Three Design Philosophies

I built three versions of the UI, each reflecting different design values:

**V1 (Original)**: Functional single-column layout. Gets the job done, no frills.

**V2 (Glassmorphism)**: Modern 2025 aesthetic with split panels, Framer Motion animations, dark mode, real-time agent status visualization. Impressive for demos.

**V3 (Jony Ive Edition)**: Radical reduction. Monochrome palette, zero decoration, mathematical precision in spacing. 28% less code than V2 but feels more sophisticated.

```typescript
// V3 Jony Ive Edition - Precision spacing
const spacing = {
    base: 4,
    scale: [4, 8, 16, 24, 32, 48, 64, 96]
};

const typography = {
    tracking: -0.022,  // Optical adjustment
    lineHeight: 1.5,
    fontStack: "SF Pro Display, system-ui"
};
```

The Jony Ive version taught me that constraint breeds creativity. Limiting to black and white forced every pixel to earn its place.

## Platform Intelligence

Each platform specification encodes current algorithm preferences:

```typescript
const linkedinSpec = {
    // First 2 lines show before "see more" - make them count
    hookPlacement: "lines 1-2",
    optimalLength: 1500,
    hashtagStrategy: "3-5 max, end of post",
    postingTip: "Native content outperforms links"
};

const twitterSpec = {
    // Threads outperform singles for thought leadership
    format: "thread",
    threadLength: "5-8 tweets",
    hookPlacement: "tweet 1, no hashtags",
    engagementTip: "Ask a question in final tweet"
};
```

These specs evolve as platforms change. The architecture makes updates easy.

## The Economics

Running the three-agent pipeline costs $0.03-0.12 per generation with Claude Haiku. At a $29/month subscription with unlimited generations, margins exceed 90% for typical usage.

```typescript
const unitEconomics = {
    apiCostPerGeneration: 0.08,  // average
    monthlySubscription: 29,
    breakEvenGenerations: 362,   // way more than users typically do
    estimatedMargin: 0.92
};
```

Good economics mean the product can be priced accessibly while remaining sustainable.

## What I Learned

**Specialization beats generalization.** Three focused agents outperform one trying to do everything. Each agent has clear inputs, outputs, and responsibilities.

**Platform knowledge is valuable.** Knowing that LinkedIn shows first 2 lines before "see more" or that Reddit hates promotional content—this domain knowledge makes the difference between generic and effective.

**Constraints are features.** The Jony Ive version succeeded by removing options, not adding them. Sometimes less really is more.

---

*Built with Next.js, Claude, and the conviction that content should meet audiences where they are.*
