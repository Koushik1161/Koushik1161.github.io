---
layout: post
title: "Clarity: Making Academic Papers Actually Readable"
subtitle: "Building an AI-powered paper reader with progressive disclosure and knowledge graphs"
date: 2025-11-18
---

Academic papers are dense. They're written for experts, packed with jargon, and structured for peer review rather than comprehension. Every researcher knows the frustration of reading the same paragraph three times and still not quite getting it.

I built Clarity to fix that.

## The Problem: Papers Are Hard

When you open an academic PDF, you're on your own. No context, no explanation of terms, no way to ask "what does this actually mean?" You either already know the field or you're in for a rough time.

What if your PDF reader could actually help you understand what you're reading?

## The Solution: Progressive Disclosure

Clarity doesn't just display papers—it analyzes them and presents information at three levels of depth:

**Overview**: Title, authors, abstract, key concepts, main findings. Everything you need to decide if this paper is worth your time. Two minutes, in and out.

**Knowledge Map**: An interactive graph showing how concepts relate to each other. Click on a node to see its connections. Understand the structure of ideas before diving into details.

**Full Text**: The complete paper with AI assistance. Highlight any passage and ask questions. Get explanations at your level.

## The Technical Stack

The backend is straightforward Express.js with OpenAI's GPT-4o:

```javascript
app.post('/analyze', async (req, res) => {
    const text = await extractText(req.file);

    const analysis = await openai.chat.completions.create({
        model: 'gpt-4o',
        messages: [{
            role: 'user',
            content: `Analyze this academic paper and extract:
                - Title, authors, abstract
                - Key concepts with definitions
                - Methodology summary
                - Main findings
                - Section breakdown
                Return as structured JSON.

                Paper text: ${text.slice(0, 15000)}`
        }]
    });

    return JSON.parse(analysis.choices[0].message.content);
});
```

Notice the 15,000 character limit. Academic papers are long, and we don't need every word to extract structure and key concepts. This keeps API costs reasonable while capturing enough context for quality analysis.

## The Knowledge Graph

The most satisfying feature to build was the interactive knowledge graph using D3.js:

```javascript
function buildGraph(analysis) {
    const nodes = [
        { id: 'paper', label: analysis.title, type: 'main' },
        ...analysis.concepts.map(c => ({
            id: c.name, label: c.name, type: 'concept'
        })),
        ...analysis.sections.map(s => ({
            id: s.title, label: s.title, type: 'section'
        }))
    ];

    const links = [
        ...analysis.concepts.map(c => ({ source: 'paper', target: c.name })),
        ...analysis.sections.map(s => ({ source: 'paper', target: s.title }))
    ];

    return { nodes, links };
}
```

Color coding is automatic—main paper node in blue, concepts in green, sections in orange. The visual pattern makes structure immediately apparent.

## The AI Chat: Context-Aware Q&A

When you ask a question, Clarity doesn't just send it to GPT-4o blind. It includes context from the analyzed paper:

```javascript
async function askQuestion(question, paperAnalysis) {
    const context = `
        Paper: ${paperAnalysis.title}
        Key concepts: ${paperAnalysis.concepts.map(c => c.name).join(', ')}
        Findings: ${paperAnalysis.findings}
    `;

    return openai.chat.completions.create({
        model: 'gpt-4o',
        messages: [
            { role: 'system', content: `You are a research assistant helping explain this paper: ${context}` },
            { role: 'user', content: question }
        ]
    });
}
```

This context grounding means answers are specific to the paper you're reading, not generic explanations pulled from training data.

## Demo Mode: No API Key Required

One decision I'm proud of: Clarity works without an API key. In demo mode, it uses pre-analyzed data from "Attention Is All You Need" (the Transformer paper):

```javascript
if (!process.env.OPENAI_API_KEY) {
    console.log('No API key found, running in demo mode');
    return DEMO_ANALYSIS;
}
```

This lets anyone explore the interface and features before committing to API costs. It also makes development and testing much smoother.

## The Design Philosophy

I spent more time on UI/UX than I expected. Academic tools are often ugly and clunky—I wanted Clarity to feel like a product, not a research prototype.

Key principles:
- **Minimalism**: White space is a feature. Dense information needs breathing room.
- **Progressive disclosure**: Don't overwhelm. Show overview first, details on demand.
- **Responsive feedback**: Animations acknowledge user actions. Loading states are informative.

```css
.concept-card {
    backdrop-filter: blur(20px);
    background: rgba(255, 255, 255, 0.8);
    transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.concept-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}
```

Small touches like hover states and subtle shadows make the interface feel alive.

## What I Learned

**Structure extraction is powerful.** Once you have a paper's concepts and sections in structured form, you can build all kinds of features on top—graphs, summaries, flashcards, citations.

**Demo mode is worth the effort.** The friction of API key setup kills exploration. Making the app work without configuration opened it up to casual users.

**Academic tools need better design.** Researchers deserve well-designed software. The bar is low, which means small investments in UX pay outsized dividends.

---

*Built with React, D3.js, and the conviction that understanding shouldn't be a struggle.*
