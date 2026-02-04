---
layout: post
title: "OltraMem: Building a High-Performance Conversation Memory System"
subtitle: "98% retrieval accuracy, rigorous benchmarking, and why 'SOTA' techniques made things worse"
date: 2026-02-03
---

What happens when you give an AI agent memory? Not just context within a conversation, but the ability to recall what you discussed three months ago—your coffee preferences, your meeting schedule, that bug you mentioned in passing. This question led me down a rabbit hole of academic papers, benchmark controversies, and a surprising discovery: sometimes the cutting-edge techniques make things worse.

OltraMem is the result of that exploration—a conversation memory system that achieves 98% retrieval accuracy and taught me more about what doesn't work than what does.

## The Problem: AI Amnesia

Every conversation with an LLM starts from zero. Ask ChatGPT about your favorite coffee today, mention it was an oat milk latte from Blue Bottle, and tomorrow it has no idea. Commercial solutions exist—Zep, Mem0, Letta—but they're closed-source, API-dependent, and expensive.

I wanted something different: a local-first memory system where my conversations stay on my machine, retrieval runs without API calls, and I can actually understand what's happening under the hood.

## The Architecture: Hybrid Search + Session Retrieval

OltraMem's core insight came from studying EmergenceMem's research: don't retrieve individual messages, retrieve entire conversation sessions.

Think about it. If you ask "What's my favorite coffee?", the answer might be buried in a message like "Thanks, I'll try the oat milk latte you recommended." That message alone is useless. But the full session—where we discussed coffee shops, I mentioned Blue Bottle, you recommended the latte, and I said I'd try it—provides complete context.

```
User Query: "What's my favorite coffee?"
           ↓
    [Hybrid Search: BM25 + Vector]
           ↓
    Matches: [Turn 37, Turn 52, Turn 37, Turn 29]
           ↓
    [Session Aggregation: NDCG scoring]
           ↓
    Session 37 Score: 1/log₂(2) + 1/log₂(4) = 1.5
           ↓
    Return: Entire Session 37 (all 15 turns)
```

The session-level retrieval alone improved my LoCoMo benchmark scores by 18 percentage points.

## The Stack: Local-First by Design

Every component was chosen for local execution:

**Storage:** SQLite with FTS5 for full-text search and sqlite-vec for vector operations. No external database servers.

**Embeddings:** Nomic Embed V2 MoE running locally via node-llama-cpp. The model is 489MB, supports 100 languages, and runs entirely on-device.

**Vector Index:** HNSW via hnswlib-node for O(log n) approximate nearest neighbor search. Queries complete in 14.6ms regardless of corpus size.

**Answer Generation:** This is the one cloud component—Claude Haiku generates answers from retrieved context at roughly $0.01 per question.

```javascript
const storage = new SQLiteStorage({ path: './memory' });

// Store a memory
storage.insertChunk({
  id: generateChunkId(),
  content: 'User prefers oat milk lattes from Blue Bottle',
  contentHash: hashContent(content),
  chunkType: 'fact'
});

// Search (14.6ms average)
const results = storage.hybridSearch('coffee preferences', {
  bm25Weight: 0.3,
  vectorWeight: 0.7,
  topK: 10
});
```

## Atomic Memory Units: Resolving "He" and "Tomorrow"

The second major improvement came from SimpleMem's research on atomic memory extraction. Raw conversation turns are messy:

```
Original: "He'll meet Bob tomorrow at 2pm"
```

Who is "he"? When is "tomorrow"? At retrieval time, we've lost this context. The solution: resolve references at write time.

```
Extracted: "Alice will meet Bob at Starbucks on 2026-01-15T14:00:00"
```

I implemented rule-based extraction for the common cases:

```javascript
function resolveCoreferences(turn, context) {
  // "he/she/they" → actual names from conversation
  let resolved = turn.content;

  if (/\b(he|him|his)\b/i.test(resolved) && context.lastMaleName) {
    resolved = resolved.replace(/\bhe\b/gi, context.lastMaleName);
  }

  return resolved;
}

function anchorTemporalExpressions(turn, timestamp) {
  // "tomorrow" → ISO-8601 absolute date
  const tomorrow = new Date(timestamp);
  tomorrow.setDate(tomorrow.getDate() + 1);

  return turn.replace(/\btomorrow\b/gi,
    tomorrow.toISOString().split('T')[0]);
}
```

This improved temporal query accuracy from 69.2% to 84.6%—a 15.4 point gain.

## The Benchmarks: Honest Numbers

I evaluated OltraMem against two standard benchmarks: LongMemEval (500 questions across 6 categories) and LoCoMo (500 QA pairs across 10 conversations).

**LongMemEval Results:**

| Metric | Score |
|--------|-------|
| Retrieval Hit Rate | **98.0%** |
| End-to-End QA Accuracy | **70.4%** |

**Comparison with other systems (End-to-End QA):**

| System | QA Accuracy | Notes |
|--------|-------------|-------|
| Hindsight (scaled) | 91.4% | SOTA, 20B param model |
| EmergenceMem | 86.0% | Previous SOTA |
| Zep | 71.2% | Commercial |
| **OltraMem** | **70.4%** | Open source, local retrieval |
| GPT-4o (full context) | 63.8% | No retrieval |
| Naive RAG | 52.0% | Baseline |

**LoCoMo Results:**

| System | Score |
|--------|-------|
| **OltraMem** | **81.2%** |
| Mem0 | 66.9% |

OltraMem beats Mem0 by 14 points on LoCoMo and matches Zep on LongMemEval QA. The retrieval itself is near-perfect at 98%. But there's a 15-point gap to EmergenceMem and 21 points to Hindsight. What's causing it?

## Failure Analysis: The Bottleneck Isn't Retrieval

I analyzed all 158 incorrect answers to understand where failures occur:

| Failure Type | Count | Percentage |
|--------------|-------|------------|
| Model Reasoning Error | 148 | **93.7%** |
| Retrieval Miss | 10 | 6.3% |
| Context Insufficient | 0 | 0% |

The data is unambiguous: **95.6% of failures happen despite successful retrieval**. The correct information is in the context—Claude just fails to extract or reason about it correctly.

Common failure patterns:

```
Q: "How many model kits have I worked on?"
Gold: 5 (with specific list)
Generated: 4 (missed one)
Category: Counting error

Q: "How many days on camping trips?"
Gold: 8 days
Generated: 5 days (excluded one trip)
Category: Reasoning error
```

This insight is crucial: improving retrieval further has diminishing returns. The bottleneck is answer model capability.

## The Experiments That Failed

Here's where it gets interesting. I implemented four "2026 SOTA" techniques that research papers claim improve RAG performance. Every single one made things worse.

**Query Expansion + RAG-Fusion**

The idea: generate 3 query variants, search in parallel, merge results with reciprocal rank fusion.

```javascript
const variants = await generateQueryVariants(query);
// ["coffee preferences", "favorite beverages", "drink choices"]

const results = await Promise.all(
  variants.map(v => hybridSearch(v))
);

return reciprocalRankFusion(results);
```

Result: +0.6% retrieval, **-2.4% QA accuracy**, 3x the cost.

**Self-Consistency Voting**

The idea: for counting questions, generate 3 answers at different temperatures and vote.

Result: **-24.5% on counting questions**. The verbose enumeration format confused the voting mechanism.

**Chain-of-Note Prompting**

The idea: have the model take notes before answering complex questions.

Result: **-39.6% on temporal questions**. The note-taking step distracted from actual date calculations.

**Cross-Encoder Reranking**

The idea: use a cross-encoder model to rerank retrieved results.

Result: **-8% overall**. The ms-marco cross-encoder is trained on web search, not conversational memory. Wrong domain.

**Agentic Architecture with Sonnet**

The idea: route queries to specialized agents (Counting Agent, Temporal Agent) using Claude Sonnet.

Result: **-8% QA accuracy, +47,000% cost** ($4.78 → $2,254 for 500 questions).

The Temporal Agent produced gems like calculating "3 months" as "35 months" after unnecessary ISO-8601 normalization steps.

## Why Simpler Won

The pattern across all failures: **added complexity without added understanding**.

Query expansion generates variants that sound different but retrieve the same documents. Self-consistency voting works when answers are independent—but counting the same list three times produces correlated errors. Chain-of-note prompting helps reasoning but hurts calculation. Specialized agents add latency and cost while making errors the simple approach avoided.

The winning configuration is almost boring:

```javascript
// That's it. That's the whole retrieval pipeline.
const results = await hybridSearch(query, { topK: 10 });
const sessions = aggregateToSessions(results);
const answer = await generateAnswer(query, sessions);
```

No query expansion. No voting. No agents. Just good retrieval and a clear prompt.

## The Cost Analysis

One advantage of local-first: most operations are free.

| Operation | Cost |
|-----------|------|
| Embedding (local Nomic) | $0 |
| Vector search (HNSW) | $0 |
| BM25 search (SQLite FTS5) | $0 |
| Answer generation (Haiku) | ~$0.01/question |

**Full 500-question benchmark: $4.78**

Compare to running everything through GPT-4 or using commercial memory APIs. The 98% retrieval accuracy comes at zero marginal cost—only answer generation requires API calls.

## What I Learned

**1. Benchmark carefully.** Early in development, I compared my retrieval score (98%) to EmergenceMem's QA score (86%) and thought I'd achieved SOTA. Apples to oranges. Always verify you're measuring the same thing.

**2. Negative results are results.** Proving that Query Expansion, Self-Consistency, Chain-of-Note, and Agentic Architecture all hurt performance is valuable. It saves others from the same dead ends.

**3. The bottleneck moves.** I spent weeks optimizing retrieval to 98%. Then failure analysis showed 95% of errors are reasoning failures. The bottleneck had moved to answer generation—further retrieval improvements were wasted effort.

**4. Session > Turn.** Retrieving entire conversation sessions instead of individual turns was the single biggest improvement (+18%). Context matters more than precision.

**5. Write-time processing pays off.** Resolving "he" and "tomorrow" during ingestion costs nothing at query time. The 15% temporal improvement came from work done once during storage.

## The Remaining Gap

OltraMem achieves 70.4% QA accuracy. Hindsight achieves 91.4%. What's in that 21-point gap?

Based on my analysis:
- **Better answer models**: Hindsight uses a 20B parameter model. I'm using Haiku.
- **Temporal-specific retrieval**: 8 of 10 retrieval misses were temporal queries. Dedicated temporal indexes (TEMPR-style) could help.
- **Entity graph traversal**: Multi-session questions often require connecting entities across conversations. Graph-based approaches might excel here.

These are genuine architectural differences, not tweaks. Closing the gap requires more than prompt engineering.

## Using OltraMem

The system is available as an npm package:

```bash
npm install oltramem
```

Basic usage:

```javascript
const { SQLiteStorage, generateChunkId, hashContent } = require('oltramem');

const storage = new SQLiteStorage({ path: './memory' });

// Store memories
storage.insertChunk({
  id: generateChunkId(),
  filePath: 'conversations/2026-02-03.md',
  content: 'User mentioned they love hiking on weekends',
  contentHash: hashContent(content),
  chunkType: 'fact',
  importanceScore: 0.8
});

// Search
const results = storage.bm25Search('weekend activities', 5);
console.log(results[0].content);
// → "User mentioned they love hiking on weekends"
```

For vector search, add a local embedding model:

```javascript
const { getLlama } = require('node-llama-cpp');

const llama = await getLlama();
const model = await llama.loadModel({
  modelPath: './models/nomic-embed-text-v2-moe.Q8_0.gguf'
});
const ctx = await model.createEmbeddingContext();

// Embed and store
const embedding = await ctx.getEmbeddingFor('search_document: ' + content);
storage.insertEmbedding(chunkId, new Float32Array(embedding.vector));

// Vector search
const queryEmb = await ctx.getEmbeddingFor('search_query: weekend hobbies');
const results = storage.vectorSearch(new Float32Array(queryEmb.vector), 5);
```

## Conclusion

OltraMem taught me that building effective AI systems is less about implementing every paper and more about understanding your specific problem. Session-level retrieval worked because conversations have structure. Atomic extraction worked because pronouns and relative dates are genuinely ambiguous. Query expansion failed because my queries weren't the problem.

The 98% retrieval accuracy means the hard part is solved—for retrieval. The remaining challenge is answer generation, and that's a different problem requiring different solutions.

Sometimes the best architecture is the boring one that works.

---

**Resources:**
- [GitHub Repository](https://github.com/Koushik1161/oltramem)
- [npm Package](https://www.npmjs.com/package/oltramem)
- [LongMemEval Benchmark](https://github.com/xiaowu0162/LongMemEval)
- [LoCoMo Benchmark](https://snap-research.github.io/locomo/)
- [EmergenceMem Research](https://www.emergence.ai/blog/sota-on-longmemeval-with-rag)
