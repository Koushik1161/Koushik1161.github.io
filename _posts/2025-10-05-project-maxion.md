---
layout: post
title: "Project Maxion: The Self-Healing Agentic Browser"
subtitle: "Building a multi-agent system that browses the web autonomously and adapts when websites change"
date: 2025-10-05
---

Web automation is fragile. Change one CSS class, and your carefully crafted Playwright script breaks. That frustration led to Project Maxion—an AI-powered browser that doesn't just automate web tasks, it understands them and adapts when websites change.

Think of it like this: traditional automation is following a recipe exactly, failing if an ingredient moves on the shelf. Maxion is having a chef who understands cooking, can find ingredients wherever they are, and adjusts when the store layout changes.

## The Multi-Agent Orchestra

The system uses four specialized agents coordinated by a central orchestrator:

**BrowserAgent** handles the actual web interaction—Playwright automation enhanced with AI-powered element detection. When a button's class changes from `btn-submit` to `submit-button`, traditional automation fails. BrowserAgent uses computer vision to find the button by appearance, not selector.

**PlannerAgent** decomposes complex goals into subtasks. "Book a flight to Tokyo" becomes: search for flights, compare prices, select options, fill passenger details, complete payment. The planner learns from past patterns, estimating complexity and suggesting optimizations.

**CritiqueAgent** validates outputs before they're final. It reviews quality, verifies success criteria, and generates improvement plans when something seems off. This catches errors before they propagate.

**Orchestrator Agent** coordinates everything using Reflective Monte Carlo Tree Search (R-MCTS). It builds decision trees of successful strategies, learns from failures, and improves over time. The reflection component lets it ask: "Why did that work? What should I do differently next time?"

## The Self-Healing Secret

Traditional automation breaks because it relies on brittle selectors. Maxion's self-healing works differently:

1. **Primary selector fails**: The usual CSS or XPath doesn't match
2. **Visual fallback activates**: AI examines the screenshot to find the element visually
3. **Element matched**: Computer vision identifies "the blue button that says Submit"
4. **Selector updated**: The system learns the new selector for next time

This isn't magic—it's the difference between "click element #submit-btn" and "click the submission button." Humans describe elements by function; Maxion does too.

## Memory That Matters

The hybrid memory system combines four storage types:

**Vector storage** (ChromaDB) enables semantic search. "How did I handle that Tokyo booking?" retrieves similar past tasks even without exact keyword matches.

**Graph database** (Neo4j) maps relationships. Which websites are related? What sequence of actions typically follows a login? Graph structure captures these patterns.

**Episodic memory** (LanceDB) handles temporal reasoning. What happened yesterday? How have my strategies evolved? Time-based retrieval enables learning from experience.

**Redis cache** provides performance optimization. Frequently accessed patterns are available instantly.

The combination means Maxion remembers not just facts, but relationships, sequences, and timelines.

## Real-Time Collaboration

Multiple users can work together in shared sessions with live cursor tracking, synchronized workspace state, and real-time agent activity broadcasts. This transforms Maxion from a personal tool into a collaborative platform.

The architecture uses WebSocket topic-based pub/sub with automatic reconnection. Users see each other's actions as they happen, and the system handles conflicts with optimistic concurrency.

## The Frontend Experience

The UI mimics professional tools like Arc and Perplexity—glassmorphic panels with transparency and backdrop blur, smooth animations, responsive multi-panel layouts. It doesn't look like a developer tool; it looks like a product.

Conversations flow naturally. Ask about flights, and the system shows real options with pricing. Request a comparison, and you get a structured analysis. The conversational interface hides the complexity of multi-agent coordination.

Voice control adds another modality. Natural language spoken commands work as well as typed ones.

## Smart Model Routing

Not every task needs GPT-4's full power. Maxion routes tasks intelligently:

- **Complex reasoning**: GPT-4o handles planning, critique, and novel situations
- **Simple operations**: GPT-4o-mini handles routine classification and extraction

This balances cost and quality. Most operations are simple; spending GPT-4 tokens on them would be wasteful.

## Security by Design

The system includes JWT authentication, rate limiting, input validation, and Content Security Policy headers. These aren't afterthoughts—they're baked into the architecture from the start.

Rate limiting protects both the system and external websites from abuse. Input sanitization prevents injection attacks. CSP headers block malicious content.

## Docker-First Deployment

Everything runs in containers:

```bash
./start.sh docker  # One command to deploy everything
```

Services include Redis, Neo4j, ChromaDB, backend, frontend, and optional Nginx. Health checks ensure dependencies are ready before services start. Volume management preserves data across restarts.

This makes deployment reproducible and scalable. Spin up more backend containers when load increases. Move to cloud infrastructure without code changes.

## What I Learned

Building Maxion taught me that automation and understanding are different problems. Traditional automation records and replays actions. Understanding means knowing why those actions work and adapting when circumstances change.

The multi-agent pattern genuinely helps with complex problems. Separating planning from execution from critique from orchestration makes each piece tractable. A single monolithic agent would be far more complex to build and debug.

Self-healing isn't a feature—it's an architecture. You can't bolt it onto brittle automation. You need to design from the start for adaptation, with fallback mechanisms and learning capabilities integrated throughout.

The collaboration features were surprisingly useful. What started as a nice-to-have became essential for my own workflow. Watching the system work, seeing agent activities in real-time, and being able to intervene when needed transforms the experience from "running a script" to "working with an assistant."

Web automation will never be fully reliable—websites change, networks fail, edge cases emerge. But automation that adapts, learns, and recovers is far more practical than automation that simply breaks.
