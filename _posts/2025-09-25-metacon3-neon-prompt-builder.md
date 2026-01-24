---
layout: post
title: "NEON: A Gamified CLI for Prompt Engineering"
subtitle: "Making developer workflows feel like quests"
date: 2025-09-25
---

What if crafting prompts for AI felt less like filling out forms and more like embarking on quests? That's the premise behind NEON, a CLI tool that transforms prompt engineering into a gamified experience with an animated mascot and colorful terminal interface.

## The Quest Metaphor

NEON offers five "quest" types, each framing a common developer interaction:

**Bug Hunt** helps you track down issues. The wizard collects: problem description, error messages, project path. Output: a structured debugging request.

**Build New** is for feature creation. Collect: goal, requirements, project path. Output: a feature implementation request.

**Seek Wisdom** is for understanding. Collect: topic, confusion points. Output: an explanation request.

**Enhance** is for optimization. Collect: target, reason for improvement, project path. Output: a refactoring request.

**Free Talk** is the catch-all. Collect: question, context. Output: an open-ended prompt.

Each quest follows the same pattern: multi-step wizard → structured prompt → clipboard copy. The structure isn't arbitrary—it reflects prompt engineering best practices disguised as game mechanics.

## The NEON Character

NEON is an ASCII art character with five emotional states:

```
IDLE:       THINKING:    SUCCESS:
 ╔═══╗       ╔═══╗        ♥╔═══╗♥
 ║ ◉ ║       ║ ~ ║        ♥║ ★ ║♥
 ╚═══╝       ╚═══╝        ♥╚═══╝♥
```

The character responds to context: ALERT state (tense, red) for confirmations, THINKING state (animated) during processing, SUCCESS state (hearts) on completion. It's a small touch that makes the tool feel alive.

## The Color Palette

Terminal UIs often feel utilitarian. NEON embraces color aggressively:

- Neon cyan for primary elements
- Magenta for accents
- Green for success states
- Orange for warnings
- Red for errors
- Yellow for highlights

The 256-color ANSI palette enables rich visuals without external dependencies. ASCII box drawing creates structure. The result feels more like a game UI than a developer tool.

## The Prompt Templates

Each quest generates a specifically formatted prompt. Bug Hunt produces:

```markdown
# 🐛 Bug Hunt Quest

## The Bug
[Description]

## Error Messages
[Errors]

## Project
[Path]

Please help me investigate and fix this bug...
```

The templates encode good prompt practices: clear sections, context provision, specific asks. Users learn structure by using it, not by studying it.

## Cross-Platform Clipboard

One small but important detail: the generated prompt copies to clipboard automatically. NEON detects the OS and uses the appropriate command:

- macOS: `pbcopy`
- Linux: `xclip`
- Windows: `clip`

This removes friction from the workflow. Generate prompt → paste into Claude/GPT → get answer.

## State Persistence

NEON remembers your project path between sessions, stored in `~/.prompt-builder-config.json`. Small conveniences accumulate into significant time savings.

## Why Gamification Works Here

Prompt engineering is inherently creative but often feels tedious. The quest framing recontextualizes the work:

- Bug Hunt implies investigation, discovery
- Build New implies creation, adventure
- Seek Wisdom implies growth, learning
- Enhance implies leveling up, improvement

These aren't just labels—they put developers in appropriate mindsets for each task type. Framing affects performance.

## The Documentation Connection

MetaCon3 pairs NEON with a comprehensive Claude Code architecture document. The combination is intentional: understand how AI coding assistants work (documentation), then interact with them effectively (tool).

The documentation covers Claude Code's agent loop, tool system, permission model, subagent architecture, hooks, skills, and MCP integration. It's the theory behind the practice.

## Technical Implementation

NEON is a single Python file (~45KB) with no external dependencies. The structure separates concerns clearly:

- **Colors class**: ANSI color management
- **Neon class**: Character state and rendering
- **UI components**: Menus, progress bars, boxes
- **Quest workflows**: Multi-step input collection
- **Prompt generators**: Template population
- **Main loop**: State machine for navigation

The code is clean enough to serve as a template for similar CLI tools.

## What I Learned

Emotional feedback in CLIs matters more than expected. The NEON character's state changes provide non-verbal communication that reduces cognitive load.

Color in terminals is underutilized. Modern terminals support 256 or true color. Using monochrome is a choice, not a constraint.

Gamification isn't about adding points and badges. It's about framing work in motivating contexts. "Bug Hunt" is more engaging than "Debug Request" even though they're the same thing.

Single-file Python distribution has the same benefits as single-file HTML: no installation friction, easy sharing, view-source transparency.

Developer tools don't have to feel utilitarian. They can be playful while remaining useful. NEON proves that fun and function aren't opposites.
