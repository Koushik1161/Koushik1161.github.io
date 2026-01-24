---
layout: post
title: "Research Swarm: A Production-Grade Multi-Agent Research System"
subtitle: "Building and evaluating a five-agent pipeline that produces professional research reports"
date: 2026-01-23
---

What if you could automate the entire research process—not just search, but analysis, synthesis, writing, editing, and publishing? Research Swarm is my implementation of that vision: a multi-agent system where five specialized AI agents collaborate to produce comprehensive research reports from a single query.

The result: professional reports with citations, cross-referenced findings, and even contrarian perspectives. And crucially, a complete evaluation framework that proves the system works.

## The Five-Agent Orchestra

Think of it like a research team where each member has a specialized role:

**Lead Agent (Orchestrator)** receives the research query and decomposes it into subtasks. "What are the top AI trends for 2026?" becomes five specific research questions: agentic systems, multimodal integration, edge deployment, safety/alignment, and industry adoption. This decomposition uses Claude Opus 4.5 for reasoning quality.

**Researcher Agents** execute web searches for each subtask via Tavily API. Multiple researchers run sequentially (parallel execution hit rate limits), each gathering findings with source URLs. Claude Haiku 4.5 handles this—fast and cheap since the task is straightforward.

**Analyst Agent** synthesizes all findings into coherent themes. It identifies patterns across subtasks, resolves contradictions, and extracts key insights. Back to Opus 4.5 for the reasoning depth.

**Writer Agent** transforms the analysis into a structured report: executive summary, key findings with citations, analysis sections, and conclusion. Professional formatting, proper markdown structure.

**Editor Agent** fact-checks claims against sources, adds contrarian perspectives (what might be wrong with this analysis?), and improves clarity. The skeptical voice that prevents echo-chamber research.

**Publisher Agent** saves the final report to disk with metadata. No AI here—just file I/O.

## The Evaluation Framework That Proves It Works

Building a system isn't enough—you need to prove it works. Research Swarm includes a complete evaluation framework with two grading approaches:

**Rule-Based Checks (8 criteria):**
- Word count within 500-5000 words
- Required sections present (intro, findings, analysis, references)
- Contains citations with URLs
- Covers expected themes for the query
- Uses appropriate source domains
- Citations are consistent and sequential
- URLs return valid responses

**LLM-as-Judge (6 dimensions):**
- Relevance: Does it address the query?
- Accuracy: Are claims factually correct?
- Completeness: Is coverage comprehensive?
- Clarity: Is it well-organized and readable?
- Insight: Does it go beyond summarization?
- Citation Quality: Are sources credible?

Each dimension scores 1-5, then normalizes to percentages. Final score: 50% rule-based + 50% LLM judge.

## The Results

The evaluation suite produced concrete metrics:

| Query | Overall | Rule-Based | LLM Judge |
|-------|---------|------------|-----------|
| AI Trends 2026 | 87.0% | 87.5% | 86.7% |
| What is RAG? | 80.0% | 75.0% | 83.3% |
| AI Agent Risks | 94.0% | 100.0% | 90.0% |

Average: **87.0%** across all test cases. Not perfect, but solidly professional quality.

The weakest dimension was citation quality—sometimes numbering gaps or missing references. The strongest was clarity and completeness—the reports are well-organized and thorough.

## Technical Architecture Decisions

**Model tiering**: Opus 4.5 for reasoning (orchestration, analysis, writing, editing), Haiku 4.5 for execution (research). This balances quality with cost—roughly 165,000 tokens per research query.

**Sequential over parallel**: Initial parallel researcher execution hit API rate limits. Sequential processing with proper delays is slower but reliable. Future work: add rate limiting and restore parallelism.

**Tavily for search**: Free tier sufficient for development. Advanced search depth, up to 10 results per query, with domain filtering for source quality.

**Async throughout**: `AsyncAnthropic` client, async agent execution, async file I/O. The entire pipeline is non-blocking.

**Workflow state tracking**: Every agent execution is logged with input/output tokens. Status callbacks enable real-time progress UI.

## The Fallback Pattern

Real-world systems need graceful degradation. When JSON parsing fails (researcher returns prose instead of structured findings), the system falls back to text extraction:

```python
def _extract_findings_from_text(self, text: str) -> dict:
    """Fallback extraction when JSON parsing fails."""
    findings = []
    sources = []
    # Parse text content into structured data
    return {"key_findings": findings, "sources": sources}
```

Similarly, query decomposition has fallback logic—if the lead agent returns unparseable output, create a single subtask from the original query.

## Report Structure

Generated reports follow a consistent structure:

```markdown
# [Research Topic]

## Executive Summary
[2-3 paragraph overview]

## Key Findings

### Finding 1: [Title]
[Detailed explanation with citations [1][2]]

### Finding 2: [Title]
[Detailed explanation with citations [3][4]]

## Analysis

### Themes
[Cross-cutting patterns]

### Implications
[What this means]

### Contrarian Perspectives
[Alternative viewpoints]

## Conclusion
[Summary and recommendations]

## References
1. [Source 1](url)
2. [Source 2](url)
```

The editor explicitly adds contrarian perspectives—a rare feature that makes reports more balanced than typical AI-generated content.

## Evaluation CLI

The system includes comprehensive evaluation commands:

```bash
# Run quick evaluation suite (3 cases)
research-swarm eval run --suite quick

# Run with multiple trials
research-swarm eval run --suite quick --trials 3

# Evaluate existing report
research-swarm eval report ./output/report.md --query "Original query"

# List available eval cases
research-swarm eval list
```

Results export as both markdown reports and JSON for further analysis.

## Resource Usage

Real numbers from evaluation runs:

| Metric | Average |
|--------|---------|
| Execution Time | 8.2 minutes |
| Tokens Used | 165,000 |
| Report Length | 1,500-2,500 words |
| Sources Cited | 15-25 |

At current Claude pricing, that's roughly $2-3 per comprehensive research report. Expensive for casual use, reasonable for professional research automation.

## What I Learned

**Orchestration is the hard part**. Individual agents are straightforward. Coordinating them, handling failures, maintaining state across the pipeline—that's where complexity lives.

**Evaluation frameworks are essential**. Without metrics, "it seems to work" is the best you can say. With metrics, you can iterate systematically.

**LLM-as-judge correlates with human judgment**. GPT-4.1's scores on the six dimensions matched my own assessment of report quality. The approach is valid for automated evaluation.

**Sequential execution beats broken parallelism**. Rate limits are real. A slower, reliable system is better than a fast, flaky one.

**The editor agent adds genuine value**. Contrarian perspectives, fact-checking against sources, clarity improvements—these aren't cosmetic. They measurably improve report quality.

**Token costs add up**. 165,000 tokens per query constrains use cases. Caching, shorter context windows, or cheaper models for some agents would help.

Research Swarm demonstrates that multi-agent systems can produce professional-quality work—when properly orchestrated and rigorously evaluated. The architecture patterns generalize beyond research: any complex knowledge task can benefit from specialized agents coordinating through a structured workflow.
