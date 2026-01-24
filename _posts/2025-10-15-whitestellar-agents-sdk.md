---
layout: post
title: "WhiteStellar: Learning the OpenAI Agents SDK from First Principles"
subtitle: "A structured curriculum for mastering AI agent development"
date: 2025-10-15
---

Documentation tells you what. Tutorials tell you how. But mastery requires understanding why. WhiteStellar is my attempt to create a learning path that builds real agent development expertise.

## The Curriculum Structure

Four lessons, each building on the last:

**Lesson 1: Hello Agent (30 min)** - The basics. What is an agent? How do you create one? What happens when you run it?

**Lesson 2: Configuration (45 min)** - Tuning behavior. Model selection, temperature, token limits. When to use each setting.

**Lesson 3: Instructions Engineering (60 min)** - The heart of agent development. How to write instructions that produce consistent, high-quality behavior.

**Lesson 4: Running Agents (45 min)** - Production patterns. Async execution, error handling, retry logic, scaling.

Total: 8-10 hours from zero to production-ready.

## The Core Insight: Instructions Are Everything

I learned this the hard way: you can use the best model with perfect configuration, and your agent will still fail if the instructions are wrong.

Good instructions follow the RRR pattern:

```python
instructions = """
# ROLE
You are a customer support specialist for TechCorp, handling billing inquiries.

# RESPONSIBILITIES
- Answer billing questions accurately and completely
- Look up account information when needed
- Escalate complex issues to human agents
- Log all interactions for quality review

# RULES
- Never share sensitive account details in full
- Always verify customer identity before account changes
- Maintain professional, empathetic tone
- If unsure, say so rather than guessing
"""
```

ROLE defines identity. RESPONSIBILITIES define scope. RULES define constraints. This structure produces consistent behavior.

## Configuration by Use Case

Different tasks need different settings. I built a reference matrix:

```python
CONFIGS = {
    "customer_support": {
        "model": "gpt-4o-mini",
        "temperature": 0.3,
        "max_tokens": 300
    },
    "code_generation": {
        "model": "gpt-4o",
        "temperature": 0.2,
        "max_tokens": 1000
    },
    "creative_writing": {
        "model": "gpt-4o",
        "temperature": 1.2,
        "max_tokens": 1500
    },
    "data_analysis": {
        "model": "gpt-4o-mini",
        "temperature": 0.1,
        "max_tokens": 600
    }
}
```

Temperature ranges matter:
- **0.0-0.3**: Factual, consistent (support, code, analysis)
- **0.5-0.9**: Conversational balance
- **1.0-2.0**: Creative, experimental

## Async Patterns for Production

Single-threaded agents are fine for demos. Production needs concurrency:

```python
import asyncio
from openai_agents import Agent, Runner

async def process_batch(requests: list[str]) -> list[str]:
    agent = Agent(
        name="processor",
        instructions="Process incoming requests efficiently.",
        model="gpt-4o-mini"
    )

    # Run all requests in parallel
    tasks = [Runner.run(agent, request) for request in requests]
    results = await asyncio.gather(*tasks)

    return [r.output for r in results]
```

Sequential: 100 requests × 2 seconds = 200 seconds
Parallel: 100 requests × 2 seconds / concurrency = 20 seconds

That's a 10x improvement with basic async patterns.

## Error Handling: The Unsexy Essential

Production agents fail. Networks timeout. APIs rate-limit. Your code needs to handle this:

```python
async def resilient_run(agent, input_text, max_retries=3):
    for attempt in range(max_retries):
        try:
            result = await asyncio.wait_for(
                Runner.run(agent, input_text),
                timeout=30.0
            )
            return result

        except asyncio.TimeoutError:
            if attempt < max_retries - 1:
                await asyncio.sleep(2 ** attempt)  # Exponential backoff
            else:
                raise

        except Exception as e:
            if "rate_limit" in str(e).lower():
                await asyncio.sleep(60)  # Wait for rate limit reset
            else:
                raise
```

Exponential backoff, rate limit handling, timeout protection. Unglamorous but essential.

## The Learning Path

Each lesson includes:

1. **Concept introduction** with analogies and mental models
2. **Code examples** you can run immediately
3. **Exercises** to test understanding
4. **Common mistakes** to avoid

The exercises matter. Reading about agents doesn't build skill. Building agents does.

## What I'd Add

The current curriculum focuses on single agents. Future modules could cover:

- **Multi-agent orchestration**: Agents that delegate to other agents
- **Tool use**: Giving agents access to APIs and functions
- **Memory systems**: Agents that remember across sessions
- **Evaluation**: Measuring agent quality at scale

But you need to walk before you run. Single-agent mastery is the foundation.

## Why This Matters

The agents SDK makes it easy to create an agent. It doesn't make it easy to create a good agent. Good agents need:

- Clear instructions that define behavior precisely
- Appropriate configuration for the task
- Production-ready infrastructure
- Thoughtful error handling

WhiteStellar bridges that gap between "it runs" and "it works well."

---

*Built with OpenAI's Agents SDK and the conviction that learning should be structured, hands-on, and honest about complexity.*
