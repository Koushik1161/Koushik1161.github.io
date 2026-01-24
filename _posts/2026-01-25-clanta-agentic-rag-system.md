---
layout: post
title: "Clanta: Building a Production-Ready Agentic RAG System"
subtitle: "How I created an autonomous document Q&A system with query routing, HyDE transformation, hybrid retrieval, and self-correction loops"
date: 2026-01-25
---

RAG has become the default pattern for grounding LLMs in external knowledge. But vanilla RAG—retrieve, augment, generate—hits a ceiling quickly. Complex queries need smarter strategies. Ambiguous questions need reformulation. Low-quality retrievals need filtering. This realization led me to build Clanta, an Agentic RAG system that thinks before it retrieves.

## The Limitation of Linear RAG

Traditional RAG follows a fixed pipeline. Query comes in, embeddings find similar documents, context gets stuffed into a prompt, LLM generates an answer. It works surprisingly well for straightforward factual questions. But it falls apart in predictable ways.

Ask a complex analytical question, and it retrieves surface-level matches rather than the deep context you need. Use technical jargon that differs from your document vocabulary, and semantic search whiffs entirely. Get unlucky with your top-k retrievals, and even a capable LLM hallucinates confidently from thin context.

Agentic RAG flips the paradigm. Instead of a pipeline, it's a loop. Instead of fixed behavior, it's adaptive. The system reasons about what kind of question you're asking, transforms queries to bridge vocabulary gaps, grades retrieved documents for relevance, and self-corrects when its answers drift from the source material.

## The Architecture: Five Autonomous Agents

Clanta orchestrates five specialized agents, each handling a distinct phase of the retrieval-generation cycle. Think of it as an assembly line where each station can call a halt and request do-overs.

**Query Router** examines incoming questions and classifies them into five categories: SIMPLE (general knowledge that might not need retrieval), FACTUAL (requires precise document lookup), ANALYTICAL (needs multi-step reasoning), COMPARISON (contrasting multiple items), and SUMMARY (condensing longer content). The routing decision shapes everything downstream—simple queries might skip retrieval entirely, while analytical ones trigger deeper search strategies.

```python
class QueryRouter:
    def classify_query(self, query: str) -> QueryType:
        classification_prompt = f"""Classify the following query:
- SIMPLE: General knowledge, no document lookup needed
- FACTUAL: Requires specific facts from documents
- ANALYTICAL: Requires reasoning over multiple facts
- COMPARISON: Comparing two or more items
- SUMMARY: Summarization requests

Query: {query}
Category:"""

        response = self.llm.complete(classification_prompt)
        return QueryType[response.text.strip().upper()]
```

**Query Transformer** bridges the vocabulary gap between how users ask questions and how documents express answers. The key technique here is HyDE—Hypothetical Document Embeddings. Instead of embedding the raw query, we ask the LLM to write a hypothetical paragraph that would answer the question, then embed that. The intuition: a made-up answer looks more like real answers than a question does.

```python
def generate_hyde(self, query: str) -> str:
    prompt = f"""Write a short paragraph from an authoritative source
that would answer this question. Don't mention this is hypothetical.

Question: {query}
Document paragraph:"""

    response = self.llm.complete(prompt)
    return response.text.strip()
```

**Hybrid Retriever** combines dense semantic search with sparse BM25 matching. Dense retrieval excels at conceptual similarity—finding documents that mean the same thing in different words. Sparse retrieval excels at exact matches—finding that specific error code or product name. Fusing both through reciprocal rank merging captures the best of both worlds.

**Document Grader** evaluates each retrieved chunk for actual relevance, not just vector similarity. High cosine similarity doesn't guarantee useful context. The grader uses the LLM to score each document 0-10 and filters out anything below threshold before generation begins.

**Hallucination Detector** verifies the final answer against source material using Vectara's HHEM model. If the response contains claims unsupported by the retrieved context, the system triggers self-correction—regenerating with explicit instructions to only use stated facts.

## M2 MacBook Air Optimization

Running this stack locally required careful model selection. With 16GB unified RAM, I couldn't afford the flagship models. But smaller variants still deliver impressive quality.

The embedding model is BAAI/bge-base-en-v1.5—768 dimensions, ~500MB in memory, with strong MTEB benchmark scores. For reranking, BAAI/bge-reranker-base provides cross-encoder accuracy at half the size of larger variants. Hallucination detection uses HHEM-2.1-Open, a T5-based model that actually outperforms GPT-4 on factual consistency benchmarks.

The total memory footprint stays around 2.2GB, leaving plenty of headroom for the operating system and the LlamaIndex orchestration layer:

| Component | Model | RAM Usage |
|-----------|-------|-----------|
| Embeddings | bge-base-en-v1.5 | ~500 MB |
| Reranker | bge-reranker-base | ~500 MB |
| Hallucination | HHEM-2.1-Open | ~600 MB |
| BM25 | bm25s | ~100 MB |
| Vector Store | Qdrant (local) | ~500 MB |

Metal Performance Shaders (MPS) acceleration means embeddings and reranking run on the M2's GPU cores. The difference is dramatic—batch embedding 100 documents takes 5-10 seconds instead of minutes.

## The Self-Correction Loop

The hallucination check isn't just a yes/no gate. When it detects unsupported claims, Clanta regenerates with additional constraints:

```python
def _self_correct(self, query: str, nodes: List[NodeWithScore],
                   original_answer: str) -> str:
    context = "\n\n".join([n.node.get_content() for n in nodes])

    correction_prompt = f"""The following answer may contain information
not supported by the sources. Rewrite to ONLY include information
directly stated in the sources. If sources don't have enough
information, acknowledge that.

Sources:
{context}

Original answer: {original_answer}
Question: {query}

Corrected answer (only use information from sources):"""

    return self.llm.complete(correction_prompt).text.strip()
```

The key phrase is "acknowledge that." Rather than hallucinating plausible-sounding details, a well-corrected response admits uncertainty. In my testing, this dramatically improved user trust—people prefer honest "I don't know" answers over confident fabrications.

## The Zen Terminal Interface

I spent an unreasonable amount of time on the CLI aesthetics. Clanta uses Rich for terminal rendering, with a Japanese-inspired minimalist theme. The color palette draws from traditional colors—Aka red for accents, Kinari cream for backgrounds, Hai gray for secondary text.

The confidence indicator uses three states: a filled circle (●) for high confidence above 70%, a half-moon (◐) for medium confidence 50-70%, and an empty circle (○) for low confidence. Users immediately understand the system's certainty without reading numbers.

```python
ZEN = {
    "red": "#C53D43",      # Aka (赤) - Traditional red
    "white": "#F5F5F5",    # Shiro (白)
    "gold": "#C9A86C",     # Kin (金)
    "gray": "#4A4A4A",     # Hai (灰)
}
```

The ASCII art banner, the spinners, the panel borders—everything follows this restrained palette. It sounds trivial, but a beautiful interface makes the tool a joy to use during long research sessions.

## Evaluation Against Research Papers

I tested Clanta against three arXiv papers: the original RAG paper by Lewis et al., and two reinforcement learning papers. With 142 chunks indexed across 52 pages, here's how the evaluation matrix looked:

| Query | Type Detected | Confidence | Assessment |
|-------|---------------|------------|------------|
| "What is RAG?" | simple | 67% | Excellent—DPR, BART, MIPS explained |
| "RAG-Sequence vs RAG-Token" | comparison | 78% | Clear mathematical differences |
| "How does DPR work?" | simple | 66% | Bi-encoder architecture described |
| "What datasets evaluated RAG?" | factual | 73% | Listed NQ, TriviaQA, FEVER, MS-MARCO |
| "Limitations of RAG?" | simple | 50% | Partial—retrieval collapse mentioned |
| "What is contrastive RL?" | simple | 57% | Cross-paper retrieval worked |

The cross-paper retrieval result surprised me—Clanta correctly retrieved content from the RL papers when asked about reinforcement learning, despite the query being classified as "simple" and primarily associated with the RAG domain.

## The Hard-Won Lessons

**LlamaIndex wrappers can be brittle.** I spent hours debugging version conflicts between LlamaIndex's HuggingFaceEmbedding wrapper and sentence-transformers. The solution was writing a custom embedding class that bypasses the wrapper entirely, using Pydantic's `Field()` and `PrivateAttr()` for proper attribute handling.

**Package version alignment is critical.** A single `pip install --force-reinstall` broke my torch/torchvision pairing and caused cryptic "operator does not exist" errors. Now I pin versions explicitly and test the full stack after any dependency change.

**Feature toggles enable debugging.** Every agentic component—routing, HyDE, reranking, grading, hallucination checking—can be individually disabled. This made isolating problems trivial. When confidence dropped unexpectedly, I could toggle features until I found the culprit.

**Grading is expensive.** LLM-based document grading adds a Claude call per retrieved chunk. For 20 chunks, that's 20 API calls before generation even starts. I disabled it by default and only enable for high-stakes queries where false positives are costly.

## What's Next

The obvious improvement is conversation memory. Right now, each query is independent. Adding chat history would enable follow-up questions and clarifications without re-stating context.

Caching is another win. HyDE documents and embeddings for repeated queries should be memoized. The same question within a session shouldn't trigger fresh API calls.

Finally, streaming. The current implementation blocks until the full answer is ready. Progressive generation would improve perceived latency, especially for longer responses.

Clanta started as a learning project to understand agentic patterns. It became a genuinely useful tool for researching papers and documentation. The core insight holds: LLMs are better when they reason about how to retrieve, not just what to retrieve. The extra API calls and latency pay dividends in answer quality.
