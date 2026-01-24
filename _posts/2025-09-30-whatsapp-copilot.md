---
layout: post
title: "Building a WhatsApp Sales Copilot"
subtitle: "How I combined intent classification with RAG to automate sales workflows"
date: 2025-09-30
---

Sales teams drown in messages. Every day brings a flood of inquiries, follow-ups, scheduling requests, and status questions. What if an AI could handle the routine stuff—classifying intents, answering common questions, extracting lead information—so humans could focus on actual selling?

That's what I built with WhatsApp Copilot.

## The Problem: Not All Messages Are Equal

A sales WhatsApp inbox might contain:

- "What's your pricing for 100 seats?"
- "Can we schedule a call for Thursday?"
- "Hi, I'm John from Acme Corp, interested in your enterprise plan"
- "What's the status of my proposal?"
- "Hey, how's it going?"

Each requires different handling. Pricing questions need knowledge base lookup. Scheduling needs calendar integration. New leads need CRM capture. Small talk needs... well, polite deflection.

The first step is figuring out what each message actually wants.

## Intent Classification: Understanding the Ask

I built an intent classifier using Claude that categorizes messages into seven buckets:

```python
INTENTS = [
    "knowledge_qa",      # Questions answerable from docs
    "lead_capture",      # New prospect information
    "proposal_request",  # Asking for a formal proposal
    "next_step",         # Scheduling follow-ups
    "status_update",     # Deal status inquiries
    "smalltalk",         # Greetings and chitchat
    "unknown"            # Everything else
]
```

The classifier doesn't just categorize—it extracts relevant entities too:

```python
def classify(message: str) -> dict:
    response = claude.messages.create(
        model="claude-sonnet-4-20250514",
        messages=[{"role": "user", "content": f"""
            Classify this sales message and extract entities:
            Message: {message}

            Return JSON with:
            - intent: one of {INTENTS}
            - confidence: 0.0-1.0
            - entities: relevant extracted data
        """}]
    )
    return json.loads(response.content)
```

For a lead capture message like "Hi, I'm John from Acme, budget around $50k, looking to deploy Q2", the classifier returns:

```json
{
    "intent": "lead_capture",
    "confidence": 0.95,
    "entities": {
        "name": "John",
        "company": "Acme",
        "budget": "$50k",
        "timeline": "Q2"
    }
}
```

Now downstream systems know exactly what to do with this message.

## Knowledge Agent: RAG for Sales Questions

When the intent is `knowledge_qa`, we need to answer from company documents. I built a RAG pipeline using LangChain and Chroma:

```python
class KnowledgeAgent:
    def __init__(self, docs_path: str):
        # Load and chunk documents
        loader = PyPDFLoader(docs_path)
        docs = loader.load()

        splitter = RecursiveCharacterTextSplitter(
            chunk_size=1000,
            chunk_overlap=200
        )
        chunks = splitter.split_documents(docs)

        # Create vector store
        self.vectorstore = Chroma.from_documents(
            chunks,
            OpenAIEmbeddings()
        )

    def answer(self, question: str) -> dict:
        # Retrieve relevant chunks
        relevant = self.vectorstore.similarity_search(question, k=3)

        # Generate answer with citations
        response = claude.messages.create(
            model="claude-sonnet-4-20250514",
            messages=[{
                "role": "user",
                "content": f"""
                    Answer this question using only the context provided:
                    Question: {question}
                    Context: {relevant}
                    Include citations with page numbers.
                """
            }]
        )

        return {
            "answer": response.content,
            "sources": [{"page": c.metadata["page"]} for c in relevant],
            "confidence": 0.85
        }
```

The key insight is the chunk overlap. With 200 characters of overlap between chunks, we avoid losing context at chunk boundaries. A sentence that spans two chunks will appear in full in at least one of them.

## The Dual-Model Strategy

I made a deliberate choice to use different providers for different tasks:

- **Claude** for reasoning (intent classification, answer generation)
- **OpenAI Embeddings** for vector search

Why? Claude's reasoning is excellent, but OpenAI's embeddings have become an industry standard. Using both lets me leverage each provider's strengths.

```python
# Claude for reasoning
claude = anthropic.Anthropic()

# OpenAI for embeddings (industry standard)
embeddings = OpenAIEmbeddings(model="text-embedding-3-small")
```

This isn't vendor lock-in—it's vendor optimization.

## Confidence Scores: Knowing What You Don't Know

Both the classifier and knowledge agent return confidence scores:

```python
if classification["confidence"] < 0.7:
    return "I'm not sure I understood. Could you rephrase?"

if answer["confidence"] < 0.6:
    return "I don't have enough information to answer that. Let me connect you with a human."
```

Low confidence triggers human handoff. This is crucial for sales—a wrong answer to a prospect is worse than no answer at all.

## What This Enables

With classification and knowledge retrieval in place, you can build sophisticated workflows:

1. **Auto-respond to FAQs**: Knowledge questions get instant, accurate answers
2. **CRM integration**: Lead capture intents trigger automatic record creation
3. **Calendar booking**: Next step intents can offer scheduling links
4. **Prioritization**: High-value leads (big budget, short timeline) surface immediately

The copilot doesn't replace salespeople—it handles the routine so they can focus on relationship building and closing.

## Lessons Learned

**Classification before action.** Don't try to handle everything with one prompt. Classify first, then route to specialized handlers.

**Citations build trust.** When the knowledge agent cites "Employee Handbook, page 23", users can verify. Trust but verify applies to AI too.

**Confidence thresholds matter.** Set them too high and you miss opportunities. Set them too low and you give bad answers. I landed on 0.7 for classification, 0.6 for knowledge answers, after testing on real message samples.

---

*Built with Claude, LangChain, and the belief that AI should augment salespeople, not replace them.*
