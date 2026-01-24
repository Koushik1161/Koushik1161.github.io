---
layout: post
title: "Learning Reinforcement Learning Through Play"
subtitle: "Building interactive simulations that teach RL concepts experientially"
date: 2025-06-01
---

Reinforcement learning is taught backwards. Textbooks start with Bellman equations, Markov Decision Processes, policy gradients. By the time you understand the math, you've forgotten why any of it matters.

I built RL Adventure to invert this: play first, theory emerges naturally. Watch an agent learn. Observe what helps it. Discover principles through experimentation. Then—and only then—attach the formal vocabulary.

## Phase 1: The Five Magic Words

Before any math, learners need vocabulary: Agent, Environment, State, Action, Reward.

The simulation is simple: a 5×5 grid, a mouse, some cheese. The mouse moves randomly. Sometimes it finds the cheese quickly; usually it wanders for 50-150 steps when optimal is 8.

The insight lands immediately: random behavior is inefficient. There must be a better way. Now the learner wants to know what that way is.

No equations yet. Just observation and intuition.

## Phase 2: Q-Learning Visualized

Phase 2 expands to a 7×7 grid with obstacles. Traps (−10 reward), coins (+10), diamonds (+50). The mouse now learns.

The visualization is the key innovation: every cell shows four arrows (up, down, left, right) representing Q-values. Arrow size indicates preference strength. Arrow color shows value: red for bad, green for good, gray for unknown.

Watch the arrows evolve over episodes. Initially all gray—the agent knows nothing. After 50 episodes, patterns emerge. Arrows near the diamond point toward it. Arrows near traps point away. The grid becomes a heatmap of learned knowledge.

Now the Bellman equation makes sense:

```
Q(s,a) ← Q(s,a) + α[r + γ·max(Q(s',a')) − Q(s,a)]
```

It's not abstract—it's describing exactly what you just watched happen. Values propagate backward from goals. Learning rate α controls update speed. Discount factor γ weights future rewards.

Interactive controls let learners tinker: adjust learning rate (0.1, 0.3, 0.5), watch how it changes convergence. Adjust exploration (epsilon), watch the trade-off between trying new things and exploiting known paths.

## Phase 3: The Exploration Problem

A casino with five slot machines. Each has different (hidden) win probabilities. Which should you pull?

Four strategies compete in real-time:

**Random**: Pulls any machine equally. Baseline performance, rarely finds the best.

**Greedy**: Tries each once, then always pulls the "best" found. Fast to commit, often wrong.

**Epsilon-Greedy**: 90% best known, 10% random. Balances exploitation with exploration.

**UCB (Upper Confidence Bound)**: Mathematically tracks uncertainty. Prioritizes machines we're unsure about. Theoretically optimal for this problem.

The visualization shows cumulative wins over time. UCB and epsilon-greedy consistently outperform. Greedy sometimes wins (lucky first sample), usually loses. Random is reliably mediocre.

The exploration-exploitation trade-off becomes visceral. You see it happen. You feel the frustration when greedy commits to the wrong machine. You appreciate UCB's clever uncertainty tracking.

## The Pedagogical Pattern

Every phase follows the same structure:

1. **Story Time**: Narrative context (why does this matter?)
2. **Play the Game**: Interact before understanding
3. **Watch AI Learn**: Observe the learning process
4. **Tinker with Parameters**: Experiment with controls
5. **Extract Key Concepts**: Formalize what you've discovered

This sequence respects how humans actually learn. We need concrete experience before abstraction. We need to care about the outcome before investing in the mechanism.

## Technical Implementation

All simulations use Pygame for visualization. The choice was deliberate: Pygame is simple enough that the code itself is educational. Students can read `treasure_hunter.py` (614 lines) and understand every component.

State management is explicit. The Q-table is a NumPy array—you can print it, visualize it, manipulate it. No hidden layers, no black boxes.

Animation runs at configurable speed. Slow motion lets you trace individual updates. Fast forward reveals emergent patterns.

## What's Missing (And Why)

Phase 4 (Deep RL) and Phase 5 (Policy Gradients) aren't implemented yet. This is intentional—the project prioritizes depth over breadth.

Better to deeply understand Q-learning than superficially survey PPO. The foundations must be solid before the extensions make sense.

When Phase 4 arrives, it will show why Q-tables fail for complex problems (too many states) and how neural networks approximate what tables can't memorize. The lesson will land because learners will have felt the limitation.

## What I Learned

**Visualization is explanation**. The arrow grid communicates Q-learning better than any equation. The slot machine race demonstrates exploration-exploitation better than any textbook.

**Interactivity creates ownership**. When learners adjust parameters and see consequences, they're not memorizing—they're discovering. Discovery sticks.

**Vocabulary follows experience**. Teach "agent" after students have watched something learn. Teach "reward shaping" after students have experimented with different reward values. The term becomes a name for something already understood.

**Simplicity enables focus**. A 5×5 grid is enough to demonstrate fundamental RL. Complexity can come later. Start minimal.

**Games are serious learning tools**. The mouse-cheese scenario is trivial, but the learning is real. Treat play as pedagogy, not decoration.

RL doesn't have to be intimidating. It can be a game you play, an agent you watch, a system you tinker with. The math comes last—after intuition is already built.
