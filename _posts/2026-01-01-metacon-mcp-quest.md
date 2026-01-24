---
layout: post
title: "MCP Quest: Teaching Protocols Through Pokemon-Style RPGs"
subtitle: "How I turned a technical spec into an adventure game"
date: 2026-01-01
---

Technical documentation is boring. I don't say this to be provocative—it's just true. Even well-written docs struggle to hold attention. So when I needed to teach people about the Model Context Protocol (MCP), I decided to try something different.

I built an RPG.

## The Idea: Protocol Village

MCP Quest drops players into Protocol Village, a Pokemon Emerald-style world where AI agents have lost their connection to tools. Your mission: learn from three masters and pass the final trial to become a Protocol Master.

It sounds silly. That's the point. Learning happens when you're engaged, and games are engaging.

## The Three Masters

Each NPC teaches a different aspect of MCP:

**Elder Proto** teaches the WHY. He tells the story of the Integration Nightmare—a world where 5 AIs and 10 tools meant maintaining 50 custom integrations. MCP solved this with a universal translator.

**Guide Aria** teaches the WHAT. She explains the three-part architecture: Hosts (like Claude Desktop), Clients (bridges), and Servers (tool providers). After her lesson, players take a quiz.

**Smith Bolt** teaches the HOW. He's a craftsman who "forges connections" using STDIO for local tools and HTTP+SSE for remote ones. JSON-RPC 2.0 is the message format.

Each master won't talk to you until you've completed the previous one. Forced progression ensures sequential learning.

## The Tech Stack: RPG-JS

I built the game using RPG-JS, a framework specifically designed for Pokemon-style games:

```typescript
import { RpgPlayer, RpgPlayerHooks, Control } from '@rpgjs/server';

const player: RpgPlayerHooks = {
    onConnected(player: RpgPlayer) {
        player.setVariable('QUEST_ELDER_COMPLETE', false);
        player.setVariable('QUEST_ARIA_COMPLETE', false);
        player.setVariable('QUEST_BOLT_COMPLETE', false);
    }
};
```

The framework handles sprite rendering, tile maps, NPC interactions, and dialogue trees. I just needed to write the educational content and quiz logic.

## The Quiz System

Each master administers a quiz after their lesson:

```typescript
async function ariaQuiz(player: RpgPlayer): Promise<boolean> {
    const questions = [
        {
            prompt: "What are the three components of MCP architecture?",
            options: ["Host, Client, Server", "API, SDK, CLI", "Frontend, Backend, Database"],
            correct: 0
        },
        // ... more questions
    ];

    let score = 0;
    for (const q of questions) {
        const answer = await player.showChoices(q.prompt, q.options);
        if (answer.value === q.correct) {
            score++;
            await player.showNotification({ message: "[OK] Correct!" });
        } else {
            await player.showNotification({ message: "[X] Not quite..." });
        }
    }

    return score >= 3; // Need 3/4 to pass
}
```

The final trial with the Connection Guardian is harder: 6 questions covering all three pillars, 5 correct needed to earn the Protocol Master badge.

## State Management: Variable Tracking

Players can leave and return. Their progress persists:

```typescript
// Check prerequisites before allowing conversation
if (!player.getVariable('QUEST_ELDER_COMPLETE')) {
    await player.showText("You must speak with Elder Proto first.");
    return;
}

// Track learning achievements
player.setVariable('LEARNED_ARCHITECTURE', true);
player.setVariable('HAS_ARCHITECT_BADGE', true);
```

This enables contextual dialogue—NPCs reference what you've already learned.

## The Design Philosophy

Games teach through metaphor. Abstract concepts become concrete:

- **Hosts** are "AI applications that need to access the world"
- **Servers** are "tool providers sharing capabilities"
- **STDIO** is "a direct pipe, like two people in the same room"
- **HTTP+SSE** is "passing messages across distance"

The smith "forges" connections. The guardian "tests" your knowledge. The elder shares "origin stories." Every interaction reinforces the learning through narrative.

## What Worked

**Forced progression ensures sequence.** You can't learn about transport before understanding architecture. The game enforces prerequisite knowledge.

**Quizzes provide feedback.** Immediate right/wrong responses help retention. The requirement to pass before proceeding ensures comprehension.

**Narrative creates engagement.** Players remember Protocol Village. They might forget paragraph 3 of a spec doc.

## What I'd Do Differently

**More zones.** The current version has one zone with four NPCs. The design doc planned five zones covering the full MCP spec. Scope constraints won.

**Better failure handling.** If you fail a quiz, you just retry. More sophisticated pedagogy might offer remedial content or adaptive difficulty.

**Multiplayer learning.** Imagine learning MCP alongside others, helping each other through challenges. RPG-JS supports multiplayer; I just didn't build it.

## The Bigger Picture

Technical education is stuck in a rut. Docs, tutorials, videos—the same formats, the same engagement problems. Games offer something different: active participation, narrative stakes, earned progression.

Not every protocol needs an RPG. But for foundational concepts that many people need to learn, gamification might be more effective than we think.

---

*Built with RPG-JS, TypeScript, and the conviction that learning should be fun.*
