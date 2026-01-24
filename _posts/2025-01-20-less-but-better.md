---
layout: post
title: "Less, But Better"
subtitle: "What Dieter Rams taught me about building AI systems"
date: 2025-01-20
---

Dieter Rams designed products for Braun for over thirty years. His work influenced everything from Apple's aesthetic to modern minimalism. But his most important contribution wasn't a product—it was a principle.

*Weniger, aber besser.* Less, but better.

I think about this constantly when building AI systems.

## The Temptation of More

The default mode in AI engineering is accumulation. More data. More parameters. More features. More tools. More complexity.

This works—until it doesn't.

At some point, every system hits a wall where adding more makes things worse. More data introduces noise. More parameters cause overfitting. More features create confusion. More tools create decision paralysis.

The systems that actually work in production aren't the most complex. They're the ones where every component earns its place.

## Rams' Ten Principles

Rams codified his philosophy into ten principles of good design. I've adapted them for AI systems:

1. **Good AI is innovative.** It solves problems in new ways, not just faster ways.

2. **Good AI is useful.** It does something people actually need, not something that sounds impressive.

3. **Good AI is understandable.** Users can form mental models of how it works.

4. **Good AI is unobtrusive.** It helps without demanding attention.

5. **Good AI is honest.** It doesn't pretend to capabilities it lacks.

6. **Good AI is long-lasting.** It works reliably over time, not just in demos.

7. **Good AI is thorough.** Every detail matters—edge cases, error handling, recovery.

8. **Good AI is environmentally conscious.** It uses only the compute it needs.

9. **Good AI is minimal.** It has only what's necessary, nothing more.

10. **Good AI is built to last.** It's designed for maintenance and evolution.

## Applying This to Agents

I'm currently building autonomous agents. The temptation is overwhelming: add more tools, more capabilities, more reasoning steps.

But I've learned to ask different questions:

- What can I remove?
- What's the simplest version that works?
- What complexity isn't earning its place?

The best agent architecture I've built has fewer components than my first attempt. It's not less capable—it's more reliable because there's less to break.

## The Discipline of Subtraction

Addition is easy. Subtraction requires judgment.

Every feature you add is a feature you must maintain, debug, and explain. Every tool you give an agent is a tool it might misuse. Every parameter is a potential failure mode.

The discipline is asking: does this earn its complexity cost?

Usually, the answer is no.

## Less, But Better

Rams spent his career removing the unnecessary until only the essential remained. His products don't feel minimal—they feel complete.

That's the goal for AI systems too. Not minimal for its own sake, but minimal because everything unnecessary has been removed.

What remains is exactly what's needed. Nothing more.

Less, but better.
