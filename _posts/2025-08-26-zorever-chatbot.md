---
layout: post
title: "Building a Real Estate Chatbot That Actually Works"
subtitle: "Combining FAQ automation, property search, and booking flows"
date: 2025-08-26
---

Real estate companies answer the same questions hundreds of times. "Where's your office?" "What are your hours?" "Do you have properties in Dubai?" These repetitive queries consume human time that could go toward actual sales.

I built a chatbot for Zorever EcomTech that handles FAQs, property search, and visit booking—all in a conversational interface.

## Three Capabilities, One Interface

The chatbot needs to handle fundamentally different request types:

**FAQs**: Static information about the company. Pattern matching works fine.

**Property Search**: Dynamic queries against a database. Needs fuzzy matching.

**Visit Booking**: Multi-step flow requiring information collection. Needs state management.

The challenge is routing incoming messages to the right handler.

## Intent Detection

Every message gets classified:

```python
def detect_intent(message: str) -> Intent:
    message_lower = message.lower()

    # Check for booking keywords
    if any(kw in message_lower for kw in ['book', 'visit', 'schedule', 'appointment']):
        return Intent.BOOKING

    # Check for property search patterns
    if any(kw in message_lower for kw in ['property', 'show me', 'available', 'p00']):
        return Intent.PROPERTY_SEARCH

    # Check for FAQ patterns
    for faq in FAQ_DATABASE:
        if any(trigger in message_lower for trigger in faq.triggers):
            return Intent.FAQ

    return Intent.GENERAL
```

Simple keyword matching handles 90% of cases. For ambiguous queries, OpenAI provides fallback classification.

## Property Search: Fuzzy Matching

Users don't type perfect property IDs. They say "show me the Dubai apartment" or "what about P003." I needed flexible matching:

```python
from difflib import SequenceMatcher

def search_properties(query: str) -> List[Property]:
    results = []

    # Try exact ID match first
    id_match = re.search(r'P0*(\d+)', query, re.IGNORECASE)
    if id_match:
        property_id = f"P{int(id_match.group(1)):03d}"
        if property_id in properties:
            return [properties[property_id]]

    # Fall back to fuzzy name matching
    for prop in properties.values():
        similarity = SequenceMatcher(None, query.lower(), prop.name.lower()).ratio()
        if similarity > 0.5:
            results.append((similarity, prop))

    return [p for _, p in sorted(results, reverse=True)[:3]]
```

P003, P3, and "property 3" all find the same listing. "Dubai marina" matches "Dubai Marina Penthouse" even with imperfect input.

## Booking Flow: Stateful Conversation

Visit booking requires collecting multiple pieces of information across several turns:

```python
class BookingSession:
    def __init__(self):
        self.state = BookingState.INITIAL
        self.property_id = None
        self.visitor_name = None
        self.phone = None
        self.preferred_date = None

    def process_input(self, message: str) -> str:
        if self.state == BookingState.INITIAL:
            return self.ask_property()

        elif self.state == BookingState.AWAITING_PROPERTY:
            self.property_id = self.extract_property(message)
            return self.ask_name()

        elif self.state == BookingState.AWAITING_NAME:
            self.visitor_name = message.strip()
            return self.ask_phone()

        # ... continue through states
```

Each response advances the state and prompts for the next piece of information. The session persists across messages.

## Graceful AI Degradation

The chatbot should work even without an API key:

```python
def get_response(message: str, intent: Intent) -> str:
    # Try AI-enhanced response first
    if os.getenv("OPENAI_API_KEY"):
        try:
            return ai_enhanced_response(message, intent)
        except Exception as e:
            logger.warning(f"AI failed: {e}, falling back")

    # Fallback to pattern matching
    return pattern_based_response(message, intent)
```

FAQs and property search work perfectly without AI. Only general conversation suffers—and even then, there's a polite fallback: "I'm focused on property questions. How can I help with that?"

## The UI: Streamlit for Speed

I built two versions: CLI for assessment requirements, Streamlit for real users. The Streamlit version adds:

- Property cards with availability status
- Interactive booking forms
- Chat history with proper formatting
- Sidebar with quick actions

```python
st.set_page_config(page_title="Zorever Assistant", page_icon="🏠")

# Chat history
for msg in st.session_state.messages:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])

# Input
if prompt := st.chat_input("Ask about properties or book a visit"):
    response = process_message(prompt)
    st.session_state.messages.append({"role": "assistant", "content": response})
```

Session state persists chat history across rerenders. The interface feels conversational, not transactional.

## What I Learned

**Intent detection is solved.** For domain-specific chatbots, keyword matching handles most cases. Save the LLM for edge cases, not every message.

**State machines work for flows.** Multi-step processes like booking need explicit state tracking. Session-based state machines are simple and debuggable.

**Fallbacks are features.** AI-enhanced responses are nice, but the bot should work without them. Reliability beats capability for user trust.

---

*Built with Streamlit, Python, and the belief that chatbots should save time, not waste it.*
