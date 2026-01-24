---
layout: post
title: "Mosley: A Minimal Recursive Language Model Runner"
subtitle: "Building agentic AI with nothing but Python's standard library"
date: 2026-01-17
---

What's the simplest possible implementation of an agentic LLM? Not a framework with thousands of lines. Not a system with external dependencies. Just the core loop: reason, execute code, observe results, repeat.

Mosley is that implementation. 272 lines of Python, zero external dependencies beyond the standard library, and it enables LLMs to solve complex problems through iterative reasoning with code execution.

## The Core Insight

The key innovation in Recursive Language Models (RLMs) is keeping the full context outside the model. Traditional LLMs are limited by context windows—feed in too much text, and you hit token limits. RLMs sidestep this by storing context in memory and letting the model query it through code execution.

The model doesn't need to "remember" a 100-page document. It has access to `context` (the full text as a string) and `context_lines` (split by newlines). When it needs information, it writes Python code to search, filter, and extract.

## The Execution Loop

```python
def run_rlm(query, context, root_client, sub_client, max_steps=20):
    # Initialize environment with context access
    env = {
        'context': context,
        'context_lines': context.split('\n'),
        'llm_query': lambda prompt: sub_client.complete(prompt)
    }

    messages = [system_prompt, user_query]

    for step in range(max_steps):
        response = root_client.complete(messages)

        # Check for completion
        if 'FINAL(' in response or 'FINAL_VAR(' in response:
            return extract_answer(response, env)

        # Extract and execute code
        code = extract_repl_blocks(response)
        output = execute_safely(code, env)

        # Feed results back
        messages.append({"role": "assistant", "content": response})
        messages.append({"role": "user", "content": f"REPL output:\n{output}"})

    raise Exception("Max steps exceeded")
```

The model generates Python code in markdown REPL blocks. The code executes in a restricted environment. Output feeds back as the next user message. The loop continues until the model signals completion with `FINAL(answer)` or `FINAL_VAR(variable_name)`.

## Two-Tier Model Architecture

Cost optimization through model tiering:

**Root model**: The orchestrator. More capable, higher cost. Handles reasoning, planning, and code generation. Suggested: GPT-4o or Qwen2.5-Coder:14B.

**Sub model**: The assistant. Faster, cheaper. Handles delegated queries via `llm_query()`. Suggested: GPT-4o-mini or Qwen2.5-Coder:7B.

When the root model needs a quick factual lookup, it calls `llm_query("What is X?")` instead of reasoning through it. The sub model responds, and the answer is available in the execution environment.

Query caching prevents redundant API calls:

```python
cache = {}
def llm_query(prompt):
    if prompt in cache:
        return cache[prompt]
    answer = sub_client.complete(prompt)
    cache[prompt] = answer
    return answer
```

## Safety Through Restriction

The execution environment restricts available builtins:

```python
safe_builtins = {
    'len', 'range', 'min', 'max', 'sum', 'sorted', 'enumerate',
    'list', 'dict', 'set', 'tuple', 'str', 'int', 'float', 'bool',
    'print', 'True', 'False', 'None'
}
```

No `open()`, no `import`, no `exec()`, no `eval()`. The model can process data but can't access the filesystem or load arbitrary code.

This isn't a secure sandbox—determined attacks could probably escape. But it's sufficient for trusted prompts and prevents accidental damage from model mistakes.

## Zero External Dependencies

The LLM client uses only `urllib.request`:

```python
def complete(self, messages):
    data = json.dumps({
        "model": self.model,
        "messages": messages,
        "temperature": self.temperature
    }).encode('utf-8')

    req = urllib.request.Request(
        self.base_url + "/chat/completions",
        data=data,
        headers={"Authorization": f"Bearer {self.api_key}"}
    )

    with urllib.request.urlopen(req) as response:
        return json.loads(response.read())["choices"][0]["message"]["content"]
```

No `requests`, no `httpx`, no `openai` package. Just the standard library. This makes Mosley trivially portable—copy the file, and it runs anywhere Python does.

## Provider Flexibility

The same client interface works for both OpenAI and Ollama:

```python
# OpenAI
client = LLMClient(
    base_url="https://api.openai.com/v1",
    api_key=os.environ["OPENAI_API_KEY"],
    model="gpt-4o"
)

# Ollama (local)
client = LLMClient(
    base_url="http://localhost:11434/v1",
    api_key="ollama",  # Ollama doesn't need real keys
    model="qwen2.5-coder:14b"
)
```

Switch between cloud and local by changing the base URL. No code changes required.

## Document Analysis Workflow

The included shell script demonstrates the primary use case:

```bash
# Extract text from PDF
python3 -c "import fitz; print(fitz.open('$PDF').get_page_text(0))" > context.txt

# Run RLM with the context
python3 rlm.py \
  --context-path context.txt \
  --query "Summarize the key findings" \
  --provider ollama \
  --root-model qwen2.5-coder:14b
```

PDF → text → context → RLM analysis. The model can search the document, extract specific sections, cross-reference claims, and synthesize findings—all through iterative code execution.

## What I Learned

**Minimalism enables understanding**. With 272 lines, every part of the system is comprehensible. No framework magic, no hidden complexity. If something breaks, you can trace through the entire flow.

**The REPL pattern is powerful**. Giving LLMs code execution capabilities transforms them from text generators into problem solvers. The ability to verify, calculate, and explore changes what's possible.

**Context-as-variable bypasses token limits**. Instead of stuffing documents into prompts, make them accessible through code. The model queries what it needs, when it needs it.

**Two-tier models optimize costs**. Expensive reasoning, cheap lookups. The pattern applies broadly to agentic systems.

**Standard library is enough**. Python's `urllib` handles HTTP fine. JSON parsing is built in. File I/O is trivial. External dependencies add convenience but also complexity and fragility.

Mosley isn't a production framework. It's a demonstration that agentic AI doesn't require massive infrastructure. The core pattern—reason, execute, observe, repeat—is simple enough to implement in an afternoon and powerful enough to solve real problems.
