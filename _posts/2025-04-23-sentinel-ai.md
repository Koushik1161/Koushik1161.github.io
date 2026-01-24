---
layout: post
title: "Sentinel AI: Building an Autonomous Research Agent"
subtitle: "How I used Google ADK and MCP servers to create a self-directed web research system"
date: 2025-04-23
---

What if you could ask a question and have an AI go off, research it thoroughly, and come back with a comprehensive report—complete with sources? Not just a summarized answer, but actual research with citations you can verify?

That's what I built with Sentinel AI.

## The Vision: Autonomous Investigation

Traditional chatbots answer questions from their training data. That's useful, but limited. I wanted something that could actually investigate—searching the web, reading articles, analyzing content, and synthesizing findings.

The key insight was that research is really several distinct capabilities working together: searching for sources, extracting content from those sources, analyzing what you find, and staying current with news. What if each capability was a separate service that an orchestrating agent could call upon as needed?

## The Architecture: Microservices for AI

Sentinel AI uses Google's Agent Development Kit (ADK) as the brain, coordinating four specialized MCP (Model Context Protocol) servers:

```
User Query
    ↓
Agent Manager (Grok-1 via ADK)
    ↓
    ├→ Search Server (SerpAPI) - finds relevant URLs
    ├→ Scraper Server (BeautifulSoup) - extracts content
    ├→ Analyzer Server (Grok) - summarizes and extracts entities
    └→ News Server (NewsAPI) - gets recent articles
    ↓
Synthesized Research Report
```

Each server runs independently on its own port, exposing specific tools through the MCP protocol:

```python
# Search Server (port 8761)
@app.post("/search")
async def search(query: SearchQuery):
    results = serpapi.search(query.text)
    return [{"url": r.link, "title": r.title, "snippet": r.snippet}
            for r in results]
```

The beauty of this approach is modularity. Want to swap SerpAPI for a different search provider? Just update one server. Want to add PDF parsing? Add a new server. The orchestrating agent doesn't need to know or care about implementation details.

## The Orchestration Layer

The ADK agent is where the magic happens. It receives a query and reasons about which tools to use and in what order:

```python
agent = LlmAgent(
    model="grok-1",
    system_instructions="""
    You are Sentinel AI, an autonomous research agent.
    For any query:
    1. Analyze the intent to understand what information is needed
    2. Use search_tool to find relevant sources
    3. Use scraper_tool to extract content from top results
    4. Use analyzer_tool to summarize and extract key entities
    5. Use news_tool for recent developments
    6. Synthesize everything into a comprehensive report with citations
    Always cite your sources. If a tool fails, continue with available information.
    """
)
```

The agent isn't following a fixed script—it's reasoning about what to do. For a breaking news query, it might prioritize the news server. For a historical question, it might focus on search and scraping. This flexibility is what makes it feel intelligent rather than mechanical.

## Error Resilience: The Unsung Hero

Real-world systems fail. APIs go down, rate limits kick in, content extraction hits edge cases. Sentinel AI is designed to degrade gracefully:

```python
try:
    search_results = await search_server.search(query)
except Exception as e:
    search_results = []
    log.warning(f"Search failed: {e}, continuing with other sources")
```

If search fails, the agent works with what it has from news. If scraping fails, it uses the search snippets. The goal is always to provide the best possible answer with available information, not to throw up its hands at the first obstacle.

## The Frontend: Streamlit for Speed

I wrapped everything in a Streamlit interface because it let me go from concept to usable tool in hours instead of days:

```python
query = st.text_input("What would you like to research?")
if st.button("Investigate"):
    with st.spinner("Researching..."):
        report = agent.investigate(query)
    st.markdown(report.content)
    st.json(report.sources)
```

Is it the prettiest interface? No. But it works, and it let me iterate on the core functionality without getting distracted by frontend polish.

## Lessons Learned

**Separation of concerns pays off.** By keeping each capability in its own server, I could develop, test, and debug them independently. When the scraper had issues with JavaScript-heavy sites, I could fix it without touching search or analysis.

**Async is essential.** With four external services, sequential calls would be painfully slow. Running independent operations concurrently cuts response time dramatically.

**Source citation isn't optional.** The whole point of research is verifiability. Every claim in the final report links back to a source. This isn't just good practice—it's what makes the system trustworthy.

## What's Next

The current version does single-query research. The natural extension is multi-step investigation—where findings from one query inform subsequent queries, building up a comprehensive knowledge base over time.

I'm also interested in adding local document search alongside web search. Imagine asking a question and getting answers that synthesize both public web sources and your private documents.

But even in its current form, Sentinel AI has changed how I research. Instead of spending hours clicking through search results, I ask a question and get a report. Not perfect, but a genuine force multiplier.

---

*Built with Google ADK, FastMCP, and the belief that AI should do the tedious work so we can focus on the interesting questions.*
