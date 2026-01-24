---
layout: post
title: "Research Swarm: Multi-Agent Research That Actually Works"
subtitle: "Building a parallel research system that decomposes queries, investigates autonomously, and produces cited reports"
date: 2025-06-01
---

I've always been frustrated by research tools that promise automation but deliver chaos. They'll scrape a dozen web pages and dump unorganized text at you, calling it "research." Real research is different—it requires decomposition, investigation, synthesis, and careful citation. That's what Research Swarm is about.

## The Core Insight: Research as a Pipeline

Think about how you actually research a complex topic. You don't just search once and read. You break the question into subtopics, investigate each one, notice connections between findings, synthesize a narrative, then review and refine. Research Swarm mirrors this cognitive process with specialized agents.

The Lead Agent receives a query like "What are the top 3 AI trends for 2026?" and decomposes it into targeted subtasks. Maybe that becomes three parallel investigations: enterprise AI adoption, agentic systems evolution, and multimodal capabilities. Each subtask goes to a Researcher Agent that uses Tavily's search API to gather evidence.

Here's where it gets interesting. The Researchers don't just return raw search results. They extract key findings, note sources, identify themes, and flag gaps. This structured output feeds into an Analyst Agent that synthesizes across all research threads, finding patterns and contradictions.

## The Claude Opus + Haiku Strategy

Not all tasks need the same model. I use Claude Opus 4.5 for the reasoning-heavy work: the Lead Agent's query decomposition, the Analyst's synthesis, and the Writer's report generation. These require nuanced understanding and careful composition.

But the Researcher Agents? They're running Claude Haiku 4.5. Their job is simpler: take a search subtask, execute web searches, extract structured findings. Haiku handles this brilliantly at a fraction of the cost. A full research report uses 150-175K tokens across all agents, but the cost is manageable because 80% of those tokens are processed by the faster model.

## The Rate Limit Dance

Early versions tried to run all Researchers in parallel. Elegant in theory, frustrating in practice. Tavily's API has rate limits, and hammering it with concurrent requests led to failures and retries. The production version runs Researchers sequentially—less theoretically optimal, but 100% reliable.

This is a lesson I keep relearning: the difference between a demo and a system is handling constraints gracefully. Rate limits, timeout, malformed responses—the code is full of defensive patterns because the happy path is only part of the journey.

## Evaluation as a Feature

Most AI projects treat evaluation as an afterthought. "It seems to work" is the standard. Research Swarm has a comprehensive evaluation framework with dual scoring: rule-based checks and LLM-as-judge assessment.

The rule-based checks are deterministic. Does the report have 500-5000 words? Does it include required sections (Executive Summary, Key Findings, Conclusion)? Are citations properly formatted with sequential numbering? Do the URLs actually resolve? These aren't subjective—they're binary pass/fail.

The LLM Judge (GPT-4o, to avoid self-evaluation bias) scores six dimensions: relevance, accuracy, completeness, clarity, insight, and citation quality. Each gets a 1-5 rating with justification.

The final score blends both: 50% rule-based, 50% LLM-judged. On my evaluation suite, the system averages 87% overall score with 3/3 test cases passing. That's not perfect, but it's measurable—and measurable means improvable.

## The Writer-Editor Dance

One pattern I'm proud of is the Writer-Editor sequence. The Writer Agent produces a professional markdown report with proper citations, formatted sections, and coherent narrative flow. But writing is rewriting, so the Editor Agent fact-checks, tightens prose, and ensures citation consistency.

This separation matters. Writers generate; editors refine. Asking one agent to do both often produces either verbose first drafts or stilted, over-cautious writing. Two agents with clear roles produce better reports than one agent trying to be everything.

## What I'd Change

Looking back, I'd invest more in URL validation resilience. Some source URLs fail to resolve by the time evaluation runs, which hurts the rule-based score even though the content is valid. Caching fetched content during research would help.

I'd also experiment with parallel execution again, but with smarter rate limit handling—exponential backoff, request queuing, maybe a token bucket algorithm. Sequential is reliable but slow; there's room for improvement.

The system produces 2,200-2,700 word reports in 7-10 minutes. That's not instant, but it's comprehensive. For research that would take hours manually, that's a worthwhile tradeoff.
