---
layout: post
title: "PersonaForge: A Backend for AI Characters"
subtitle: "Building the infrastructure for persistent, reusable AI personalities"
date: 2025-04-30
---

Every AI chatbot project I built had the same problem: where do the characters live? I'd hardcode personality traits into prompts, copy-paste backstories between projects, and lose track of which version of a character was which. PersonaForge was my answer—a proper backend for managing AI personalities.

## The Problem: Characters Need a Home

Think about what defines an AI character:

- **Name**: Who they are
- **Personality Summary**: Core traits and disposition
- **Backstory**: History that shapes their perspective
- **Tone Description**: How they communicate
- **Initial Greeting**: How they start conversations

Without a central system, this information gets scattered across codebases, config files, and half-forgotten prompts. PersonaForge gives characters a proper database home.

## The Data Model

I spent more time on the schema than you might expect, because getting it right matters:

```python
class Character(Base):
    __tablename__ = "characters"

    id = Column(UUID, primary_key=True, default=uuid4)
    name = Column(String(100), nullable=False, index=True)
    personality_summary = Column(String(2000), nullable=False)
    backstory = Column(String(10000))
    tone_description = Column(String(1000))
    initial_greeting = Column(String(500))
    is_public = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, onupdate=datetime.utcnow)
```

The field lengths are intentional. Personality summary gets 2000 characters—enough for nuance, not enough for rambling. Backstory gets 10000 because history is complex. Initial greeting is capped at 500 because first impressions should be punchy.

The `is_public` flag enables future marketplace features—imagine browsing and importing characters other people have created.

## The API: RESTful and Async

FastAPI made this almost too easy:

```python
@router.post("/characters", response_model=CharacterResponse)
async def create_character(
    character: CharacterCreate,
    db: AsyncSession = Depends(get_db)
):
    db_character = Character(**character.dict())
    db.add(db_character)
    await db.commit()
    await db.refresh(db_character)
    return db_character

@router.get("/characters/{character_id}")
async def get_character(
    character_id: UUID,
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(Character).where(Character.id == character_id)
    )
    character = result.scalar_one_or_none()
    if not character:
        raise HTTPException(status_code=404, detail="Character not found")
    return character
```

Everything is async because database operations shouldn't block. SQLAlchemy 2.0's async support makes this clean and performant.

## Pydantic for Validation

Input validation happens at the API boundary:

```python
class CharacterCreate(BaseModel):
    name: str = Field(..., max_length=100)
    personality_summary: str = Field(..., max_length=2000)
    backstory: Optional[str] = Field(None, max_length=10000)
    tone_description: Optional[str] = Field(None, max_length=1000)
    initial_greeting: Optional[str] = Field(None, max_length=500)
```

If someone tries to submit a 50,000 character backstory, they get a clear error before it ever hits the database. Good APIs fail fast and fail clearly.

## The OpenAI Integration (Coming Soon)

The codebase includes an LLM service stub that hints at future features:

```python
class LLMService:
    def __init__(self):
        self.client = OpenAI()
        self.model = "gpt-4o"

    async def generate_response(self, character: Character, message: str):
        # TODO: Implement character-aware generation
        pass
```

The vision is that PersonaForge doesn't just store characters—it helps them come alive. Feed it a character and a message, get a response that authentically represents that character's personality and tone.

## Infrastructure Choices

I chose PostgreSQL over SQLite because characters deserve a real database. Redis is in the dependencies for future caching—when you're generating responses for the same character repeatedly, caching the character data saves database roundtrips.

The whole thing is designed to scale. Not because I expect millions of characters tomorrow, but because good architecture decisions early save painful migrations later.

## What This Enables

With PersonaForge as a backend, building AI applications becomes much simpler:

1. Create your characters once, through the API
2. Fetch character details whenever you need them
3. Use those details to construct prompts for any LLM
4. Never copy-paste a personality description again

Want to A/B test different personality variants? Create two characters, fetch them by ID, compare results. Want to let users customize their AI assistant? Expose a character creation form that posts to PersonaForge.

## Lessons Learned

**Start with the data model.** I sketched the Character schema before writing any API code. Once the data model was right, everything else fell into place.

**Async from the start.** Converting a sync codebase to async is painful. Starting async is easy.

**Field limits are UX.** Those character limits aren't arbitrary—they guide users toward concise, effective character definitions. Constraints can be features.

---

*Built with FastAPI, SQLAlchemy, and the belief that AI characters deserve better than hardcoded strings.*
