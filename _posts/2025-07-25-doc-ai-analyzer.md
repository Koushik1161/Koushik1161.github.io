---
layout: post
title: "Building a Production-Ready Document Analysis Platform"
subtitle: "Full-stack AI document processing with real-time WebSocket updates and dual NLP strategies"
date: 2025-07-25
---

Document analysis sounds simple until you try to build it properly. Extract text from PDFs. Run NER. Generate summaries. Show results. But the gap between "working demo" and "production system" is vast—error handling, progress feedback, graceful degradation, security, and user experience all demand attention.

Doc AI Analyzer is my attempt at bridging that gap.

## The Dual-AI Strategy

The core insight came from watching users try simpler document tools. They wanted accuracy, but they also wanted speed. Pure spaCy NER is fast but misses context. Pure GPT-4 is accurate but slow. Why choose?

The system runs both. spaCy provides a fast baseline extraction: standard entity types (PERSON, ORG, DATE, MONEY) identified in milliseconds. Then GPT-4 refines these results with contextual understanding—resolving ambiguities, merging related entities, identifying domain-specific patterns.

I call it "Palantir-level intelligence" in the code comments, partly as aspiration, partly as humor. The point is that layered analysis beats either approach alone.

## The WebSocket Progress Dance

Nobody likes staring at a spinner wondering if anything is happening. The backend broadcasts progress updates through WebSockets at every processing stage: 20% for PDF extraction, 50% for NER analysis, 80% for summarization, 100% for completion.

The frontend receives these updates and animates a progress bar with stage descriptions. If something fails, the error state propagates immediately—no waiting for a timeout to discover a problem.

This required restructuring the backend around async task processing. Each stage completes, broadcasts progress, then continues. It's more complex than synchronous processing, but the UX improvement is dramatic.

## Mathematical Expression Detection

This feature surprised me with its complexity. Academic PDFs often contain equations—inline math, display equations, LaTeX environments. Regex patterns catch the obvious cases ($...$, $$...$$), but images of equations require different handling.

The original plan was GPT-4 Vision for math extraction from images. It works, but the latency was painful. For the current version, I disabled it in favor of text-based extraction, documenting the Vision approach for future enhancement when APIs get faster.

## The FastAPI Foundation

I've built backends in Flask, Express, and Django. FastAPI has become my default for new projects. Type hints everywhere, automatic OpenAPI documentation, native async support, and Pydantic validation for request/response schemas.

The middleware layer handles cross-cutting concerns: request logging, correlation IDs, error transformation, CORS configuration. Health check endpoints at three levels (/health, /api/v1/ready, /api/v1/metrics) support different monitoring needs.

## The Next.js 14 Frontend

The frontend uses App Router with TypeScript throughout. React Query manages API state—caching, refetching, optimistic updates. Framer Motion provides smooth transitions that make the interface feel polished rather than mechanical.

The dark mode implementation is more than a toggle. It detects system preferences, persists choice to localStorage, and applies themes through CSS custom properties. It's a small feature that demonstrates attention to user experience.

## Glassmorphism and the Modern Aesthetic

The visual design uses glassmorphism—semi-transparent cards with blur effects that create depth without heavy shadows. It's trendy, but it's also functional: content layers are visually distinct while maintaining focus on the document analysis results.

I pair this with responsive layouts that adapt genuinely, not just stack columns. On mobile, the upload interface simplifies, progress indicators become more prominent, and navigation collapses gracefully.

## Production Readiness Checklist

I maintain a mental checklist for "production ready":

- Input validation on all endpoints ✓
- Error responses that hide implementation details ✓
- Structured logging with request correlation ✓
- Health endpoints for orchestration ✓
- Environment-based configuration ✓
- Async processing to prevent blocking ✓
- Graceful degradation when services fail ✓

Doc AI Analyzer passes these checks. It's not perfect—there's always more hardening possible—but it's deployable with confidence.

## The LangChain Evolution

Building this during LangChain's 0.3 transition taught me about API stability in fast-moving ecosystems. The old `LLMChain` pattern was deprecated; the new pipe operator syntax (`chain = prompt | llm`) is cleaner but required migration.

I documented these fixes explicitly in the codebase. Future me (or anyone maintaining this) will appreciate knowing which patterns are current and which are legacy.

## What I'd Do Differently

If I rebuilt this from scratch, I'd add batch processing for multiple documents—the single-document assumption is limiting for real workflows. I'd also invest in citation extraction, connecting findings to specific page numbers and paragraphs.

The current metrics are good but basic. A more sophisticated system would track processing times per document size, success rates by PDF type, and user engagement with results. Data-driven improvement requires measuring the right things.

This project represents my current thinking on what "production-ready AI application" means. Not just features, but reliability, observability, and user experience. The code is more than twice as long as a demo version would be, but it's code I could hand off to an ops team and sleep at night.
