---
layout: post
title: "Askly: Turn Any Website Into an AI Chatbot"
subtitle: "Building a complete RAG pipeline with neubrutalist design"
date: 2026-01-15
---

What if you could point at any website and instantly have an AI that knows everything on it? That's Askly (internally called ZappyBot)—a platform that crawls websites, builds vector embeddings, and provides intelligent chat powered by the crawled content.

No manual training. No content copying. Just paste a URL and start chatting.

## The RAG Pipeline

The system implements Retrieval-Augmented Generation from scratch:

**Crawling**: A breadth-first crawler traverses the target website, respecting robots.txt with 100ms delays between requests. Smart URL filtering skips login pages, admin panels, checkout flows, and binary files. Mozilla Readability extracts clean article content from messy HTML.

**Chunking**: LangChain's RecursiveCharacterTextSplitter breaks content into 512-byte chunks with 64-byte overlap. Multiple separator levels (paragraphs → lines → sentences → words → characters) ensure coherent chunks. Fragments under 20 characters are filtered as noise.

**Embedding**: OpenAI's text-embedding-3-small generates 1536-dimensional vectors for each chunk. These embeddings capture semantic meaning, enabling similarity search beyond keyword matching.

**Storage**: An in-memory vector store holds everything—no Pinecone, no Chroma, just JavaScript Maps with O(1) lookups. Perfect for serverless deployments where simplicity beats scalability.

**Query**: User questions get embedded, compared against all chunks via cosine similarity, and the top 5 matches become context for GPT-4o-mini. The LLM generates answers grounded in actual website content.

## The Cosine Similarity Implementation

No external libraries for the core similarity search:

```typescript
function cosineSimilarity(a: number[], b: number[]): number {
  let dotProduct = 0, normA = 0, normB = 0;
  for (let i = 0; i < a.length; i++) {
    dotProduct += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
}
```

This runs on every query, comparing against every stored chunk. For typical knowledge bases (under 100K chunks), the O(n) scan completes in milliseconds. External vector databases would add complexity without meaningful benefit at this scale.

## The Neubrutalist Design System

The UI makes a statement. Neubrutalism—bold geometric shapes, thick 3px borders, 6px drop shadows, high-contrast colors—creates visual energy that stands out in a sea of minimalist SaaS designs.

The color palette is deliberately playful: yellow, pink, blue, green, purple, orange as accents against off-white backgrounds. Every color combination passes WCAG 2.1 AA accessibility standards.

CSS custom properties define the design tokens:

```css
:root {
  --border-width: 3px;
  --shadow-offset: 6px;
  --radius-sm: 8px;
  --color-accent-yellow: #FFE566;
  --color-accent-pink: #FF99CC;
}
```

This isn't just aesthetic preference—it's positioning. In a market of look-alike products, visual distinctiveness is a competitive advantage.

## Rate Limiting Without a Database

API protection uses in-memory rate limiting:

- Bot creation: 5 per hour per IP (computationally expensive)
- Chat messages: 50 per minute per IP
- Read operations: 100 per minute per IP

A cleanup job runs every 5 minutes, pruning expired entries. The simplicity is intentional—no Redis dependency, no connection management, just works on Vercel's serverless platform.

## The MCP Server

A separate Node.js server implements Model Context Protocol, enabling Claude to programmatically create and manage chatbots. This separates concerns: the web app serves humans; the MCP server serves AI agents.

The integration means Claude can build a chatbot for a user's website without the user touching the UI. Agent-to-tool communication through standardized protocols—this is where the industry is heading.

## Source Attribution

Every answer includes source links with relevance scores. Users see not just what the AI says, but where it learned it. This transparency builds trust and enables verification.

The citations also provide legal cover. The chatbot isn't hallucinating or plagiarizing—it's explicitly referencing its sources.

## Progress Simulation

While the backend crawls and processes, the frontend simulates progress:

```typescript
const progressInterval = setInterval(() => {
  setProgress(prev => {
    if (prev < 30) { setStep("crawling"); return prev + 2; }
    else if (prev < 60) { setStep("chunking"); return prev + 3; }
    else if (prev < 90) { setStep("embedding"); return prev + 2; }
    return prev;
  });
}, 500);
```

The progress bar moves smoothly even though the backend processes in batches. This perceived performance matters—users feel the system is working, not stuck.

## What I Learned

**Zero-dependency RAG is practical**. You don't need LangChain's full ecosystem or a managed vector database. For moderate-scale applications, implementing cosine similarity yourself and storing vectors in memory works fine.

**Neubrutalism differentiates**. Design trends come in waves. Swimming against the minimalist current makes a product memorable, even if the functionality is similar to competitors.

**Rate limiting on serverless requires thought**. Without persistent state, in-memory limits reset on cold starts. For serious abuse prevention, you'd need distributed storage. For MVP-level protection, in-memory is enough.

**MCP integration is the future**. Building tools that AI agents can use programmatically opens new distribution channels. When Claude can recommend and use your product, that's a new kind of marketing.

**Source attribution builds trust**. Showing where answers come from transforms a chatbot from "magic black box" to "intelligent librarian." Users trust what they can verify.

Askly demonstrates that sophisticated AI features—vector search, RAG, multi-model pipelines—can be built with surprisingly little infrastructure. The hard part isn't the technology; it's making it useful and delightful for real users.
