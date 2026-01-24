---
layout: post
title: "Godfather: AI-Powered News Aggregation"
subtitle: "Using Claude to curate and score the AI industry's daily developments"
date: 2025-08-10
---

Keeping up with AI news is exhausting. OpenAI announces something. Anthropic responds. Google ships. Meta open-sources. ArXiv overflows with papers. Reddit debates. Hacker News critiques. It's too much to track manually, and simple aggregation just creates more noise.

Godfather takes a different approach: use AI to curate AI news. Claude categorizes, scores importance, and generates actionable summaries. The result is a daily digest that surfaces what actually matters.

## The Collection Layer

Three collectors feed the system:

**RSS Collector** monitors official blogs from OpenAI, Anthropic, Google, Meta, Cohere, and Hugging Face. These are primary sources—announcements come here first. ArXiv feeds add academic papers in AI and ML categories.

**Hacker News Collector** queries Algolia's API for AI-related stories, filtering by engagement thresholds. The community's voting surfaces interesting content, but also introduces opinion and reaction.

**Reddit Collector** harvests from r/MachineLearning, r/LocalLLaMA, and r/artificial. Different communities emphasize different aspects—research, practical implementation, general discussion.

All collectors are async, running in parallel. Each generates unique IDs for deduplication because the same story often appears across multiple sources.

## The Processing Pipeline

Raw items flow through three Claude-powered processors:

**Categorizer** classifies into nine buckets: model releases, API updates, research papers, industry news, tutorials, opinions, tool releases, funding, and other. It also tags associated companies—which announcement is this about?

**ImportanceScorer** rates 1-10 considering impact breadth (does this affect many developers or few?), novelty (genuinely new or incremental?), credibility (official source or speculation?), timeliness (breaking or old news?), and engagement (community reaction level).

**Summarizer** generates 2-3 sentence summaries, extracts actionable insights, and identifies key entities. Not just "what happened" but "what does this mean for you?"

Each processor includes fallback heuristics. If Claude's API is unavailable, keyword-based categorization and scoring keep the system running. Degraded, but operational.

## Dual Storage Strategy

SQLite stores structured data: raw items, processed items with scores and categories, alert history, collection statistics. Standard relational queries work well here.

ChromaDB adds semantic search. Vector embeddings enable "find me stories similar to this" queries that keyword matching can't handle. When you want to explore a topic rather than search for specific terms, vectors shine.

The combination provides both precise and fuzzy retrieval.

## Multiple Interfaces

Different contexts need different presentations:

**Digest mode** generates a categorized daily summary. Model releases first, then research papers, then industry news. Within categories, items sort by importance score. It's the morning briefing.

**Watch mode** runs continuously, syncing periodically and alerting on high-importance items. Terminal notifications with bells for breaking developments. It's the live monitoring station.

**TUI Dashboard** provides an interactive Textual-based interface with live statistics, scrollable feeds, and alert management. It's the control center.

**CLI** offers quick access for specific needs: `godfather top` for highest-scoring stories, `godfather search <query>` for specific topics, `godfather sync` for manual refresh.

## The Intelligence Layer

What makes this more than aggregation is the AI processing. Consider a story: "OpenAI releases new model."

Simple aggregation: here's the headline and link.

Godfather processing: Category is "Model Releases." Importance is 9/10 because it's a major vendor with broad ecosystem impact. Summary explains what's new and different. Actionable insight notes that existing API calls may need updates. Companies tagged: OpenAI.

This context transforms information into intelligence. You know not just what happened, but why it matters and what to do about it.

## Configuration Philosophy

TOML configuration with Pydantic validation. Sources are pre-configured but customizable. User settings control digest timing, alert thresholds, poll intervals. API keys come from environment variables or config files.

The defaults work. Customization is available but not required.

## Graceful Degradation

AI systems fail. APIs rate-limit. Networks drop. Godfather handles this:

- Individual collector failures don't cascade; other sources continue
- Claude API unavailability triggers fallback heuristics
- Rate limiting is handled with backoff
- Database errors are caught and logged

The system should work even when parts don't.

## What I Learned

AI-curated content is genuinely better than raw aggregation. The importance scoring alone saves significant triage time.

Multiple interfaces for the same data serve different needs well. Morning digest vs. real-time monitoring vs. interactive exploration are all valid modes.

Fallback heuristics matter. Systems that fail completely when AI is unavailable are fragile. Systems with degraded modes are resilient.

The news landscape moves fast, but patterns persist. Model releases, research papers, industry consolidation—the categories are stable even as specific stories change.

Building tools for your own information diet is valuable. You understand your needs better than any generic service. Custom curation beats one-size-fits-all.
