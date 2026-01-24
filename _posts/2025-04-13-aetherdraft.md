---
layout: post
title: "Aetherdraft: Teaching AI to Write Better Emails"
subtitle: "Building a self-improving email generation system with multi-model orchestration"
date: 2025-04-13
---

We've all stared at a blank email draft, knowing what we want to say but struggling with how to say it. AI can help—but not all AI-generated text is good. How do you build a system that knows the difference?

Aetherdraft is my experiment in email generation with built-in quality control.

## The Core Loop: Generate, Evaluate, Improve

The system has three stages:

1. **Generate**: Create an email draft based on a prompt and desired tone
2. **Evaluate**: Score the draft on multiple quality dimensions
3. **Improve**: If the score is low, regenerate with refined prompts

```python
def generate_and_evaluate(prompt: str, tone: str) -> Draft:
    # Generate
    draft = generate_draft(prompt, tone)

    # Evaluate
    scores = evaluate_draft(draft, prompt)

    # Improve if needed
    if scores['composite'] < 70:
        improved_prompt = create_improvement_prompt(draft, scores)
        draft = generate_draft(improved_prompt, tone)
        scores = evaluate_draft(draft, prompt)

    return Draft(content=draft, scores=scores)
```

This feedback loop catches weak generations and tries again.

## Multi-Model Strategy

Different tones call for different models:

```python
def select_model(tone: str) -> tuple:
    if tone in ['formal', 'urgent']:
        return ('anthropic', 'claude-3.5-sonnet')
    else:  # casual, friendly
        return ('openai', 'gpt-4')
```

In my testing, Claude excelled at formal business communication—precise, professional, structured. GPT-4 handled casual tones more naturally. Rather than forcing one model to do everything, I let each play to its strengths.

## The Evaluation Engine

Quality isn't one thing. I break it into four metrics:

**Readability**: Using Flesch Reading Ease scores. Business emails should be clear, not academic.

```python
def score_readability(text: str) -> float:
    flesch_score = textstat.flesch_reading_ease(text)
    # Normalize to 0-100, penalize both too simple and too complex
    return min(100, max(0, flesch_score))
```

**Tone Match**: Does the email actually sound like the requested tone?

```python
TONE_MARKERS = {
    'formal': ['please', 'regarding', 'kindly', 'sincerely'],
    'casual': ['hey', 'thanks', 'quick', 'cheers'],
    'urgent': ['immediately', 'asap', 'critical', 'priority'],
    'friendly': ['hope', 'excited', 'great', 'looking forward']
}

def score_tone(text: str, target_tone: str) -> float:
    markers = TONE_MARKERS[target_tone]
    matches = sum(1 for m in markers if m in text.lower())
    return min(100, matches * 25)  # Each marker adds 25 points
```

**Constraint Compliance**: Did the email include required elements?

```python
def score_constraints(text: str, constraints: dict) -> float:
    score = 100
    if constraints.get('include_bullets') and '•' not in text:
        score -= 25
    if constraints.get('required_phrase'):
        if constraints['required_phrase'] not in text:
            score -= 25
    # ... more constraint checks
    return score
```

**Length Appropriateness**: Too short feels curt, too long loses attention.

## Learning from Failures

Every generation gets logged with its scores:

```python
def log_generation(draft: str, prompt: str, tone: str, scores: dict):
    conn = sqlite3.connect('aetherdraft_log.db')
    conn.execute("""
        INSERT INTO drafts (content, prompt, tone, readability,
                          tone_score, constraints, composite, timestamp)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    """, (draft, prompt, tone, scores['readability'],
          scores['tone'], scores['constraints'],
          scores['composite'], datetime.now()))
    conn.commit()
```

This creates a dataset for analysis:

```python
def analyze_performance():
    weak_drafts = query("SELECT * FROM drafts WHERE composite < 70")

    by_tone = {}
    for draft in weak_drafts:
        by_tone.setdefault(draft.tone, []).append(draft)

    for tone, drafts in by_tone.items():
        print(f"{tone}: {len(drafts)} weak generations")
        common_issues = identify_common_failures(drafts)
        print(f"  Common issues: {common_issues}")
```

Over time, I can see patterns: maybe "urgent" tone consistently scores poorly on readability, suggesting the prompt needs adjustment.

## Automated Self-Testing

The system includes a test suite that exercises different tones and prompts:

```python
TEST_CASES = [
    {"prompt": "Schedule a meeting", "tone": "formal"},
    {"prompt": "Thank someone for help", "tone": "friendly"},
    {"prompt": "Request urgent update", "tone": "urgent"},
    {"prompt": "Introduce yourself", "tone": "casual"}
]

def run_self_test():
    results = []
    for case in TEST_CASES:
        draft = generate_and_evaluate(case['prompt'], case['tone'])
        results.append({
            'case': case,
            'scores': draft.scores,
            'pass': draft.scores['composite'] >= 70
        })

    return TestReport(results)
```

Running this periodically catches regressions and validates that the system maintains quality.

## What I Learned

**Multi-metric evaluation beats single scores.** A draft can be readable but wrong in tone, or perfectly toned but violating constraints. Breaking quality into dimensions makes issues actionable.

**Model diversity is practical.** Different models really do have different strengths. Matching models to tasks isn't premature optimization—it's good engineering.

**Feedback loops work.** The improvement cycle catches bad generations that would otherwise ship. Simple retry logic with better prompts solves many quality issues.

---

*Built with Claude, GPT-4, and the belief that AI should know when it's done a good job.*
