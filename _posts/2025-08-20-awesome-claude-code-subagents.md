---
layout: post
title: "116 Specialized Agents for Claude Code"
subtitle: "A curated collection of AI assistants for every development task"
date: 2025-08-20
---

What if you could have a senior developer for every specialty on demand? A Rust expert when you're fighting the borrow checker. A Kubernetes guru when your pods won't schedule. A security specialist when you're reviewing authentication code.

That's the premise behind the Awesome Claude Code Subagents collection—116 specialized AI agents, each configured for a specific domain, ready to assist through Claude Code.

## The Subagent Pattern

Claude Code supports subagents: specialized assistants that operate within isolated context windows. When you invoke a subagent, it sees only what's relevant to its specialty, preventing knowledge bleed between tasks.

Each subagent definition follows a standard format: YAML frontmatter specifying name, description, and required MCP tools, followed by Markdown sections defining role, expertise, workflows, and communication protocols.

The pattern is powerful because it's composable. You don't need one superintelligent agent that knows everything. You need many focused agents that excel at their specialties, coordinated when necessary.

## Organization by Domain

The 116 agents span ten categories:

**Core Development** covers the fundamentals: REST APIs, GraphQL services, frontend applications, backend systems, desktop and mobile apps. These are the bread-and-butter development tasks.

**Language Specialists** provides deep expertise in twenty-three languages: Python, Go, Rust, JavaScript/TypeScript, Java, C++, Swift, Kotlin, C#, PHP, Ruby, and more. Each agent knows the language's idioms, common patterns, and typical pitfalls.

**Infrastructure** handles DevOps concerns: Docker containerization, Kubernetes orchestration, Terraform infrastructure, CI/CD pipelines, incident response. These agents understand deployment beyond just writing code.

**Quality & Security** focuses on non-functional requirements: test automation, code review, penetration testing, compliance auditing, performance optimization. Quality isn't an afterthought; it has dedicated specialists.

**Data & AI** covers the machine learning ecosystem: model training, NLP pipelines, data engineering, LLM architecture, MLOps practices. As AI becomes central to software, these specialties become essential.

**Developer Experience** addresses the meta-concerns: build systems, CLI tools, documentation, refactoring strategies, git workflows. Good tooling makes everything else easier.

**Specialized Domains** handles niche areas: blockchain, fintech, game development, IoT, SEO. Not every project needs these, but when you do, specialized knowledge is invaluable.

**Business & Product** extends beyond code: product management, project planning, legal review, sales engineering. Software exists in a business context.

**Meta & Orchestration** handles multi-agent coordination: workflow orchestration, error handling, agent-to-agent communication. When you need agents working together, these manage the complexity.

**Research & Analysis** provides strategic capabilities: trend analysis, competitive intelligence, technology evaluation. Sometimes you need to understand before you build.

## Quality Standards Embedded

Each agent definition includes measurable quality criteria:

- Code coverage thresholds (typically >80%)
- Response time targets (p95 < 100ms for backend agents)
- Security requirements (zero critical issues)
- Performance baselines (specific throughput/latency targets)

These aren't suggestions—they're expectations encoded in the agent's operating instructions. When the Rust specialist reviews code, it checks for these criteria automatically.

## Inter-Agent Communication

Agents can communicate through a structured JSON protocol:

```json
{
  "requesting_agent": "security-specialist",
  "request_type": "get_context",
  "payload": { "query": "authentication implementation details" }
}
```

This enables sophisticated workflows. The backend developer might consult the security specialist about authentication, then the performance analyst about caching strategy. The conversation coordinates naturally.

## Deployment Patterns

Subagents deploy globally (`~/.claude/agents/`) or per-project (`.claude/agents/`). Project-level agents take precedence when names conflict.

For teams, this means standardized development practices. Everyone uses the same agent definitions, ensuring consistent review criteria, style guidelines, and quality standards.

## The MCP Integration

Agents specify their required MCP (Model Context Protocol) tools:

- File operations: Read, Write, Glob, Grep
- Code quality: eslint, sonarqube, semgrep
- Infrastructure: Docker, Terraform, kubectl
- Data: PostgreSQL, Redis, database connectors
- AI: transformers, langchain, wandb

Each agent only accesses the tools it needs, maintaining appropriate separation of concerns.

## Workflow Structure

Agents follow consistent three-phase workflows:

**Analysis Phase**: Understand requirements, examine existing code, identify constraints
**Implementation Phase**: Execute the actual work, with progress tracking
**Delivery Phase**: Verify quality, document changes, notify stakeholders

This structure creates predictable interactions regardless of specialty.

## Why This Matters

Expertise is expensive and scarce. A senior Rust developer with deep async experience, a security specialist who understands OAuth flows, a Kubernetes expert who's seen every scheduling failure mode—these people exist, but you can't have all of them on every team.

Subagents don't replace human expertise. But they capture and distribute knowledge patterns, making specialized assistance available when needed without requiring full-time specialists for every domain.

The collection is open source (MIT license) and actively maintained. As Claude's capabilities evolve, so do the agents. As new domains emerge, new specialists get added.

One hundred sixteen agents is a lot. But software development spans hundreds of specialties. This collection is a starting point, not an end point—a foundation for building the kind of development assistance that treats every specialty as worthy of deep expertise.
