---
layout: post
title: "Building a Multi-Model Research Assistant"
subtitle: "How I orchestrated Perplexity, Grok, and Gemini to create a smarter research pipeline"
date: 2025-04-21
---

There's something fundamentally broken about how we do research online. You search, you click, you read, you search again. Rinse and repeat until you've either found what you need or given up in frustration. I wanted to fix that—or at least make it less painful.

## The Problem: Research is a Multi-Step Dance

When I research a topic, I'm actually doing several distinct things: searching for relevant sources, synthesizing what I find, identifying what I still don't know, and then going deeper. Each step requires different cognitive modes. What if I could build an AI system that mirrors this natural workflow?

That's how the Gemini Agentic Research Assistant was born. The core insight was simple: different AI models excel at different tasks. Perplexity is incredible at live web search. Grok has a knack for synthesis and summarization. Gemini thinks well about follow-up directions. Why not use all three?

## The Architecture: Agents with Specialties

Think of it like assembling a research team where each member has a specific role:

```python
# The Search Agent fetches live web data
class PerplexitySearchAgent:
    def search(self, query):
        # Uses Perplexity's Sonar API for real-time results
        response = self.client.chat.completions.create(
            model="sonar",
            messages=[{"role": "user", "content": query}]
        )
        return response.choices[0].message.content
```

The Perplexity agent handles the initial search, pulling in fresh data from the web. But raw search results are like unrefined ore—valuable, but not immediately useful.

That's where Grok comes in. I built three specialized synthesis agents that take those raw results and transform them:

1. **Refinement Agent**: Distills results into the top 5 key bullet points
2. **Summarization Agent**: Creates concise paragraph summaries
3. **Question Generator**: Suggests 3-5 follow-up research questions

The clever bit? All three use OpenAI's SDK with custom base URLs. This means I can swap between Perplexity, Grok, and other OpenAI-compatible APIs without rewriting my code:

```python
self.client = OpenAI(
    api_key=os.getenv("XAI_API_KEY"),
    base_url="https://api.x.ai/v1"  # Grok's endpoint
)
```

Finally, Gemini takes the synthesized results and suggests new research directions—questions I might not have thought to ask.

## The Gradio Interface: Making It Usable

I wrapped everything in a Gradio interface because I wanted this to be actually usable, not just a cool proof-of-concept. Type in a research topic, and you get:

- Initial search results from Perplexity
- Refined bullet points from Grok
- A summary paragraph
- Follow-up questions for deeper investigation

The whole pipeline runs in about 10-15 seconds for most queries—fast enough to feel responsive, thorough enough to be useful.

## What I Learned

**Model diversity is a feature, not a bug.** Each model brings its own biases and strengths. Perplexity's live search compensates for static training data. Grok's synthesis catches patterns that search might miss. Using multiple models creates a more robust system than any single model could provide.

**API compatibility matters.** By standardizing on OpenAI's SDK interface, I made it trivial to add new models or swap existing ones. When a better search API comes along, I can integrate it in minutes.

**The reflection loop is key.** The most valuable part of this system isn't any single agent—it's the question generation. By automatically identifying what I don't yet know, the system extends my research in directions I might not have considered.

## Where This Could Go

Right now, this is a single-query system. But imagine extending it to maintain research sessions, building up a knowledge graph over multiple queries. Or connecting it to a vector database to remember past research and surface relevant context automatically.

The real promise of agentic systems isn't replacing human research—it's augmenting it. By handling the mechanical parts of searching, synthesizing, and questioning, we free ourselves to do what humans do best: make connections, spot patterns, and ask the questions that matter.

---

*Built with Python, Gradio, and a healthy appreciation for the fact that no single AI has all the answers.*
