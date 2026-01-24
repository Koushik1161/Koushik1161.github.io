---
layout: post
title: "GPT Researcher: Autonomous Multi-Agent Research at Scale"
subtitle: "Exploring an open-source system that produces cited research reports through coordinated AI agents"
date: 2025-12-01
---

I keep coming back to the question: what would truly autonomous research look like? Not summarizing a few web pages, but the real thing—deep investigation, multi-source synthesis, cited conclusions. GPT Researcher is one of the most complete attempts I've seen.

## The Core Architecture

GPT Researcher isn't a single agent—it's a team. Eight specialized agents coordinate through LangGraph:

The **Chief Editor** orchestrates the workflow. The **Researcher** (the core GPT Researcher agent) conducts deep web and document research. The **Editor** plans outlines. The **Reviewer** validates accuracy. The **Revisor** refines based on feedback. The **Writer** compiles final reports. The **Publisher** exports to PDF, Word, or Markdown.

There's even a **Human** agent for feedback loops when human oversight is needed.

This mirrors how actual research teams work. Nobody does everything; specialists collaborate. The insight is that AI research should work the same way.

## The Deep Research Skill

What impressed me most is the deep research capability. It's not just running a few searches—it's tree-like exploration with configurable depth and breadth.

The system generates sub-queries from the main query, then sub-sub-queries from those, building a research tree. Each branch is explored concurrently. Context propagates across branches so later queries benefit from earlier findings.

A deep research task takes about 5 minutes and costs roughly $0.40 with o3-mini. That's remarkable for what amounts to an autonomous research assistant working through dozens of sources.

## The Retriever Ecosystem

GPT Researcher supports over 15 retrieval backends: Tavily, DuckDuckGo, Google, Bing, Arxiv, PubMed, Semantic Scholar, Exa, and more. You configure which retrievers to use via environment variables.

The MCP (Model Context Protocol) integration is particularly interesting. It means you can extend the system with custom data sources without modifying core code. Enterprise document stores, internal databases, proprietary APIs—all become searchable through the MCP interface.

## Report Generation Pipeline

The output isn't a wall of text—it's structured research. The system generates:

1. **Introduction**: Context and scope
2. **Body sections**: Organized by subtopic with citations
3. **Images**: Smart filtering of relevant visuals
4. **Conclusion**: Synthesized findings
5. **References**: Full source attribution

Reports typically run 2,000+ words with 20+ sources. The quality rivals what a human researcher might produce in hours or days.

## Configuration Depth

The system is deeply configurable. Three LLM tiers (strategic, smart, fast) can use different models for different tasks. Reasoning effort is adjustable. Report tone ranges from objective to casual to professional.

You can restrict searches to specific domains, use local documents instead of web sources, or combine both. The flexibility means the same tool works for academic research, market analysis, and internal knowledge synthesis.

## What Makes It Work

Several design decisions stand out:

**Async-first**: Everything uses Python async/await for concurrent operations. Research queries run in parallel, not sequentially.

**Cost tracking**: LLM calls are tracked, providing visibility into spending. Crucial for production deployment.

**Streaming UX**: WebSocket integration enables real-time progress updates. Users see research happening, not just final results.

**Modular skills**: Each capability (research, writing, curation) is an independent skill. They compose but don't depend on each other.

## The Prompt Engineering Layer

Prompts are organized into families that can be overridden for specific models. The MCP tool selection prompt is particularly clever—it asks the LLM which tools are relevant for a query before invoking them, saving unnecessary API calls.

Query generation prompts transform a research question into multiple focused sub-queries. This decomposition is key to comprehensive coverage.

## Limitations I Noticed

The system is powerful but not magic. It can still hallucinate if sources are unreliable. The report quality depends heavily on what's available online. Paywalled content is inaccessible. Recent events may not be indexed.

The multi-agent coordination adds latency. A quick question doesn't need eight agents—the overhead isn't always justified. The system is optimized for comprehensive research, not quick lookups.

## Why This Matters

We're in a transition period for research tools. Traditional search engines return links. ChatGPT returns summaries without sources. GPT Researcher attempts something more ambitious: cited, comprehensive, structured analysis.

The open-source nature matters too. Enterprise research tools with similar capabilities cost thousands monthly. This is available to anyone with an API key.

I don't think it replaces human researchers—deep judgment, novel connections, and creative leaps remain human strengths. But for the grinding work of gathering and synthesizing information, systems like this represent a step change in what's possible.

The future of research isn't AI or humans. It's humans augmented by AI teams that do the comprehensive groundwork, freeing humans for the creative work that only they can do.
