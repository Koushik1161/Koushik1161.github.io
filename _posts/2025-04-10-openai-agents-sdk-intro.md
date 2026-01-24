---
layout: post
title: "Getting Started with OpenAI's Agents SDK"
subtitle: "The simplest possible AI agent in 8 lines of code"
date: 2025-04-10
---

Sometimes the most valuable thing you can build is the simplest thing that works. When OpenAI released their Agents SDK, I wanted to understand it from first principles. Not a complex multi-agent system with tools and memory—just the minimal viable agent.

It turns out that's 8 lines of code.

## The Minimal Agent

```python
from agents import Agent, Runner

agent = Agent(
    name="TestAgent",
    instructions="You respond with 'Setup successful'.",
)

result = Runner.run_sync(agent, "Hello world")
print(result.final_output)
```

That's it. Import, configure, run, print. The `Agent` class wraps an LLM with instructions and optional tools. The `Runner` executes it synchronously and returns a result object. The `final_output` is what the agent produced.

I spent more time writing documentation for this than writing the code.

## What the SDK Abstracts

Behind those 8 lines, a lot is happening. The SDK manages the API connection, handles authentication through environment variables, constructs the appropriate message format, sends the request, parses the response, and handles any tool calls in a loop until the agent has a final answer.

If you've ever written this boilerplate yourself—and I have, many times—you know how much code this replaces. The SDK isn't doing anything magic, but it's doing a lot of plumbing.

## The Three Execution Modes

The Runner offers three ways to execute agents:

`run_sync()` blocks until completion. Simple, predictable, good for scripts and testing.

`run()` is async—you await it. Better for web applications where blocking is painful.

`run_streamed()` returns an iterator of tokens as they're generated. Essential for responsive UIs where you want to show text as it's produced.

I started with sync because it's easiest to understand. The async and streaming patterns build on the same foundation.

## Instructions Are Everything

The agent I built has trivial instructions: always respond with "Setup successful." But real agents live or die by their instructions. These are system prompts that shape every response.

Bad instructions are vague: "Be helpful." The agent has no constraints, no personality, no specific behaviors.

Good instructions are specific: detailed rules about response format, examples of correct behavior, constraints on what topics to address, style guidelines for tone and length. The more precisely you define the agent's behavior, the more reliably it performs.

I learned this lesson the hard way on earlier projects. Now I spend more time on instructions than on code.

## The Stateless Default

Each call to `run_sync()` is independent. The agent has no memory of previous conversations. This is intentional—statelessness is simpler and more predictable.

When you need memory, you add sessions explicitly. The SDK supports this, but it's opt-in. For many use cases (single-turn Q&A, processing pipelines), statelessness is exactly what you want.

## Cost Awareness

GPT-4o charges $2.50 per million input tokens and $10.00 per million output tokens. A simple conversation costs fractions of a cent. But agents can be chatty, especially with tools, and costs accumulate.

I got into the habit of tracking token usage even for simple tests. It's never bitten me badly on toy projects, but I've seen production systems where careless prompting led to surprising bills.

## From Minimal to Meaningful

This minimal agent is a foundation. The reference project I built alongside it shows the path forward: a conversational loop with error handling, configurable instructions, and graceful shutdown. But you can't understand the complex version without first understanding the simple one.

The Agents SDK makes building AI agents remarkably accessible. The core logic is 4 lines; everything else is UI, error handling, and documentation. That's a powerful abstraction—powerful enough that the interesting work shifts from "how do I call the API" to "what should the agent actually do."

That's where the real challenge begins.
