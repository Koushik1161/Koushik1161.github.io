---
layout: post
title: "PhantomCore Shell: AI Meets the Desktop"
subtitle: "Building an OS-integrated AI assistant with streaming responses"
date: 2025-04-30
---

Web apps are great, but there's something unsatisfying about alt-tabbing to a browser every time you want AI help. PhantomCore Shell was my experiment in bringing AI assistance directly into the desktop experience.

## The Vision: Always Available, Never Intrusive

I wanted an AI assistant that felt native to the operating system. Not a browser tab you have to find, not an app you have to launch—just always there, ready when you need it.

The solution: a Tauri-based desktop app with a FastAPI backend. Tauri gives you native desktop capabilities with web technologies. FastAPI provides a fast, streaming-capable backend. Together, they create something that feels like it belongs on your machine.

## Streaming: The Key to Responsiveness

Nobody wants to wait 10 seconds staring at a spinner. With streaming responses, the AI starts "typing" immediately:

```python
@app.post("/intent")
async def process_intent(request: IntentRequest):
    async def generate():
        async for chunk in openai_client.chat.completions.create(
            model="gpt-4.1-mini",
            messages=[{"role": "user", "content": request.intent}],
            stream=True
        ):
            if chunk.choices[0].delta.content:
                yield f"data: {chunk.choices[0].delta.content}\n\n"

    return EventSourceResponse(generate())
```

The frontend consumes this stream and updates the UI in real-time:

```javascript
const eventSource = new EventSource('/intent', {
    method: 'POST',
    body: JSON.stringify({ intent: userMessage })
});

eventSource.onmessage = (event) => {
    appendToResponse(event.data);
};
```

The difference in feel is dramatic. Instead of waiting for a complete response, you see the AI "thinking" in real-time. It's the difference between a conversation and a query.

## Model Fallbacks: Resilience by Design

API services fail. Rate limits happen. PhantomCore handles this gracefully with a fallback chain:

```python
MODELS = ["gpt-4.1-mini", "gpt-4.1-nano", "gpt-3.5-turbo"]

async def get_response(prompt: str):
    for model in MODELS:
        try:
            return await call_model(model, prompt)
        except Exception as e:
            logger.warning(f"{model} failed: {e}, trying next")
    raise AllModelsFailedError()
```

If the primary model is overloaded, we try the next one. If that fails, we try the fallback. The user gets a response even when the best model isn't available.

## The Frontend: Three Panels, Three Purposes

The UI is organized around three distinct modes of interaction:

**AssistantPanel**: The conversational interface. Type your intent, see the streaming response. Conversation history is maintained so you can scroll back.

**SemanticExplorer**: For when you want to search rather than chat. Query your knowledge base, see ranked results with relevance scores.

**TaskBoard**: Simple task management. Add tasks, check them off, keep track of what you're working on alongside your AI conversations.

All three share state through Zustand:

```javascript
const useStore = create((set) => ({
    messages: [],
    tasks: [],
    searchResults: [],

    addMessage: (msg) => set((state) => ({
        messages: [...state.messages, msg]
    })),

    toggleTask: (id) => set((state) => ({
        tasks: state.tasks.map(t =>
            t.id === id ? {...t, done: !t.done} : t
        )
    }))
}));
```

Zustand keeps state management simple while allowing any component to access and update shared state.

## Dark Mode: Not an Afterthought

I built in dark mode from the start using CSS custom properties and Tailwind's dark mode utilities:

```css
:root {
    --bg-primary: #ffffff;
    --text-primary: #1a1a1a;
}

.dark {
    --bg-primary: #1a1a1a;
    --text-primary: #ffffff;
}
```

The app respects system preferences by default but allows manual override. Small touches like this make a tool feel polished.

## The Semantic Search Stub

The semantic search endpoint is currently a placeholder:

```python
@app.post("/semantic-search")
async def semantic_search(query: SearchQuery):
    # TODO: Integrate ChromaDB for real vector search
    return {
        "results": [
            {"content": "Mock result", "score": 0.95}
        ],
        "message": "Integration pending"
    }
```

The infrastructure is ready for a proper vector database. When I add ChromaDB, the frontend won't need any changes—it's already wired up to display search results with scores.

## Lessons Learned

**Streaming changes everything.** The same underlying AI capabilities feel completely different when responses stream in real-time versus arriving all at once.

**Desktop apps still matter.** There's something about an app that lives in your dock, that you can summon with a keyboard shortcut, that a browser tab can't match.

**Build stubs for future features.** The semantic search endpoint doesn't work yet, but having the placeholder made me think through the API design. When I implement it, I won't need to refactor.

---

*Built with Tauri, FastAPI, and the conviction that AI assistants should meet you where you work.*
