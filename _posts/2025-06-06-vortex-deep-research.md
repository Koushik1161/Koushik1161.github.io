---
layout: post
title: "Vortex: Deep Research with Iterative Refinement"
subtitle: "Building an agent that knows when it doesn't know enough"
date: 2025-06-06
---

Most research tools give you an answer and call it done. But real research is iterative—you search, you learn, you realize what you're missing, you search again. Vortex Deep Research was my attempt to build an agent that researches the way humans actually research.

## The Core Insight: Reflection Loops

The breakthrough was adding a reflection step. After gathering initial results, the agent asks itself: "Do I have enough information to answer this question well? What's missing?"

```python
class ReflectionState(TypedDict):
    is_sufficient: bool
    knowledge_gaps: List[str]
    follow_up_queries: List[str]
```

If the reflection identifies gaps, the agent generates new search queries and goes around again. This continues until either the agent is satisfied or it hits the configured maximum loops.

Think of it like a curious researcher who keeps pulling threads until they understand the full picture.

## The Architecture: LangGraph for State Management

I built Vortex on LangGraph because agentic workflows need proper state management. Each step in the research process reads from and writes to a shared state:

```python
class OverallState(TypedDict):
    messages: List[Message]
    search_queries: List[str]
    research_results: List[ResearchResult]
    sources: List[Source]
    reflection: Optional[ReflectionState]
    final_answer: Optional[str]
```

The workflow is a graph of nodes connected by conditional edges:

```
generate_queries → parallel_search → reflect → [continue?] → finalize
                                       ↑          ↓
                                       └──────────┘
```

That loop back from reflection to query generation is where the magic happens. The agent autonomously decides whether to dig deeper.

## Configurable Depth: Effort Levels

Not every question needs exhaustive research. Sometimes you want a quick answer. I added effort levels to let users control the tradeoff:

```python
EFFORT_CONFIGS = {
    "low": {"initial_queries": 1, "max_loops": 1},
    "medium": {"initial_queries": 3, "max_loops": 3},
    "high": {"initial_queries": 5, "max_loops": 10}
}
```

Low effort gives you a fast, surface-level answer. High effort sends the agent down rabbit holes for comprehensive research. You choose based on your needs.

## The Search Strategy: DuckDuckGo with Fallbacks

I used DuckDuckGo's API for search because it's free and doesn't require authentication. But free APIs aren't always reliable, so I built in fallbacks:

```python
async def search(query: str) -> List[SearchResult]:
    try:
        return await duckduckgo_search(query)
    except Exception as e:
        logger.warning(f"DuckDuckGo failed: {e}")
        return mock_results(query)  # Better than nothing
```

The mock results aren't ideal, but they let development and testing continue even when the API is down. In production, you'd swap in a paid search API.

## Real-Time Visibility: Streaming the Research Process

The React frontend uses LangGraph's streaming SDK to show the research process as it happens:

```typescript
const { messages, status } = useStream({
    threadId,
    onEvent: (event) => {
        if (event.type === 'query_generated') {
            setCurrentPhase('Generating search queries...');
        } else if (event.type === 'researching') {
            setCurrentPhase(`Searching: ${event.query}`);
        } else if (event.type === 'reflecting') {
            setCurrentPhase('Analyzing findings...');
        }
    }
});
```

Users can watch the agent work—see which queries it's running, when it decides to dig deeper, what gaps it's trying to fill. This transparency builds trust. You're not just getting an answer; you're seeing how the answer was constructed.

## Structured Output for Reliability

LLM outputs can be unpredictable. I used Pydantic models with structured output to ensure reliable parsing:

```python
class SearchQueryList(BaseModel):
    queries: List[str] = Field(
        description="Search queries to investigate the topic"
    )

response = await model.with_structured_output(SearchQueryList).invoke(prompt)
queries = response.queries  # Guaranteed to be a list of strings
```

No more wrestling with JSON parsing or handling malformed outputs. The model either returns valid structured data or the call fails cleanly.

## Source Deduplication

After multiple search iterations, you often end up with duplicate sources. The finalization step cleans this up:

```python
def deduplicate_sources(sources: List[Source]) -> List[Source]:
    seen_urls = set()
    unique = []
    for source in sources:
        if source.url not in seen_urls:
            seen_urls.add(source.url)
            unique.append(source)
    return unique
```

The final answer only cites unique sources, and only sources that were actually used in constructing the response.

## What I Learned

**Reflection is underrated.** The simple act of asking "is this sufficient?" transforms a one-shot tool into an iterative researcher. Most agent frameworks skip this step.

**Streaming isn't just UX—it's debugging.** Watching the agent work in real-time helped me identify issues I never would have caught from final outputs alone.

**Configuration beats hardcoding.** Making effort levels configurable instead of hardcoded let me quickly experiment with different research depths without changing code.

## The Bigger Picture

Vortex represents a shift in how I think about AI tools. Instead of asking "what's the answer?", we can ask "investigate this for me." The agent handles the tedious parts—searching, reading, synthesizing—while surfacing its process for human oversight.

The future isn't AI that replaces researchers. It's AI that researches alongside us.

---

*Built with LangGraph, React, and a healthy skepticism of first-pass answers.*
