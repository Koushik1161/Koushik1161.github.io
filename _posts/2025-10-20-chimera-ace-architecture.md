---
layout: post
title: "Chimera: Building Agents That Actually Think"
subtitle: "Implementing the ACE cognitive architecture with persistent memory and learning"
date: 2025-10-20
---

Most AI agents are glorified function callers. They receive a prompt, maybe use a tool, return a result. There's no deliberation, no self-awareness, no learning. Chimera is my attempt at something more: an agent that thinks structurally, knows its limitations, and improves over time.

## The Seven-Layer Framework

The core of Chimera is the ACE (Autonomous Cognitive Entity) architecture, which defines seven reasoning layers:

1. **Aspirational**: What are my values and long-term mission?
2. **Global Strategy**: How do I convert goals into constrained plans?
3. **Self-Model**: What can I actually do? What are my limitations?
4. **Executive Function**: What are the concrete steps to execute?
5. **Cognitive Control**: Am I on track? Should I revise?
6. **Task Prosecution**: Execute actions through tools.
7. **Reflection**: What did I learn? How should I improve?

This isn't just structure for structure's sake. Each layer forces specific reasoning that would otherwise be skipped. The Self-Model layer, in particular, prevents the confident hallucination that plagues many agents.

## The Memory Triad

Thinking without memory is goldfish cognition. Chimera implements three memory types:

**Episodic memory** stores specific task executions—what was attempted, what succeeded, what failed. "Task: Search for AI trends and save to file → Success with 3 tool calls."

**Semantic memory** captures general patterns. "Web search tools work best with specific, focused queries." This isn't task-specific but applies across contexts.

**Procedural memory** holds rules and heuristics. "Validate arguments before invoking tools." These become part of the agent's playbook for future tasks.

## The Learning Loop

Here's where it gets interesting. Before each task, the agent queries memory for relevant experiences and applicable rules. This context shapes planning—an agent that failed at similar tasks before will approach more cautiously.

After execution, the Reflection layer stores new memories. Episodic memories capture what happened. If patterns emerge, semantic memories crystallize them. If new guidelines become clear, procedural rules are added.

The result is genuine improvement across tasks. In testing, confidence scores increased from 0.75 to 0.88 to 0.92 across three related tasks as the agent accumulated relevant experience.

## The TF-IDF Retrieval

Memory retrieval uses a custom TF-IDF implementation—no external vector database required. It's not as sophisticated as embedding-based retrieval, but it works well enough for in-process memory and keeps the system self-contained.

The retrieval mechanism supports filtering by memory type and similarity threshold. When planning a web search task, you can specifically request procedural memories about search strategies while ignoring unrelated episodic memories.

Persistence matters too. Memories serialize to JSON, surviving process restarts. The TF-IDF vocabulary and IDF values persist separately, ensuring consistent embeddings across sessions.

## The MCP Tool Server

Chimera integrates with an MCP (Model Context Protocol) server exposing six tools: web search, file read/write, code execution, HTTP requests, and directory listing. Each tool has a JSON schema defining inputs and outputs.

The agent doesn't hardcode tool knowledge—it reads the schema to understand what's available. This means you can add new tools without modifying agent code. Just register them in the tools registry.

Code execution deserves special mention. It runs in a subprocess with a 30-second timeout, preventing runaway processes. The agent can write and execute Python, but with safety limits.

## Validation Results

I tested the system across four phases:

**Phase 0.1** (ACE prompt validation): Three diverse tasks—coding, research, planning—scored 4.73/5 average. The prompt reliably produces structured reasoning regardless of task type.

**Phase 0.2** (MCP tool integration): Tool invocation works, error handling catches failures, timeouts prevent hangs.

**Phase 0.4** (Memory system): All three memory types work. Semantic search returns relevant results. Learning across runs is measurable.

The system passes its design goals. Whether it's "intelligent" in any deep sense is a philosophical question I'll leave aside.

## The Honest Limitations

TF-IDF is basic. For production, you'd want proper vector embeddings and a database like Pinecone or Milvus. Memory grows forever without pruning. Deduplication is missing. The tools are mocked in testing—real web and HTTP integration would require more infrastructure.

These are engineering limitations, not architectural ones. The structure supports more sophisticated implementations.

## Why Structure Matters

The main lesson from Chimera is that structure produces better reasoning. Forcing an agent through seven defined layers produces more careful, more self-aware, more improvable behavior than "just figure it out."

It's like the difference between thinking through a problem and just saying whatever comes to mind. The structure is cognitive scaffolding that prevents shortcuts and ensures thoroughness.

Whether this approach scales to more complex tasks—multi-day projects, novel domains, ambiguous goals—remains to be seen. But as a foundation for agents that think deliberately rather than react reflexively, the ACE architecture shows promise.
