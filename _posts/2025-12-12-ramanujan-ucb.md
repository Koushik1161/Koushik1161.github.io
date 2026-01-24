---
layout: post
title: "When 100-Year-Old Math Beats Modern AI"
subtitle: "Using Ramanujan's q-series to improve exploration in Monte Carlo Tree Search"
date: 2025-12-12
---

Here's an unlikely connection: Srinivasa Ramanujan's early 20th century work on q-series—exotic mathematical objects from partition theory—can dramatically improve how AI agents explore game trees. The project started as a curiosity and ended with an 82% win rate in Connect Four.

## The Exploration Problem

Think about how MCTS works. You're building a tree of possible moves, and at each node you must decide: explore a new move, or exploit one that's worked well so far? The standard solution is UCB (Upper Confidence Bound), which adds a bonus to less-visited nodes.

The problem is that UCB's exploration bonus is fixed. Early in tree expansion, when estimates are noisy and unreliable, you might want aggressive exploration. Later, when you've gathered more data, you want to trust your estimates and exploit.

## The Ramanujan Insight

Ramanujan's q-series have a beautiful property: they produce massive values for small inputs that decay smoothly toward 1 as inputs grow. This is exactly the behavior pattern you want for exploration: aggressive early, conservative late.

The Ramanujan factor I implemented is simple:

```
R(n) = 1 + α * (1/(1-q^n) - 1)
```

For visit count 1 with q=0.97 and α=4, this gives 130x amplification. At visit 10, it's 12x. At visit 100, it's 1.2x. At visit 200, you're back to standard UCB.

Multiply the standard exploration bonus by this factor, and you get a UCB variant that explores aggressively when uncertainty is high, then gracefully reverts to normal behavior.

## The Surprising Results

I tested across five domains: simple bandits, deceptive bandits, 3×3 Tic-Tac-Toe, 4×4 Tic-Tac-Toe, and Connect Four.

In simple bandits, Ramanujan-UCB showed no improvement. Fair enough—flat problems don't benefit from sophisticated exploration.

In deceptive bandits (where the optimal arm is hidden 95% of the time), Ramanujan-UCB was slightly worse. Aggressive exploration wasted samples on confirmed-bad arms.

But in games, the results were dramatic. 3×3 Tic-Tac-Toe: 24.5% → 59.5% win rate (+143%). 4×4 Tic-Tac-Toe: 0% → 34% (from complete failure to competitive). Connect Four: 18% → 82% (+356%).

## Why Complexity Matters

The pattern is clear: Ramanujan-UCB's advantage scales with problem complexity. But why?

Bandits are flat—each arm is independent. Early estimates converge quickly because you're sampling direct rewards. Standard UCB's fixed exploration is sufficient.

Games are deep. Each move leads to a subtree of possibilities. Early evaluations are noisy because they depend on random rollouts through the entire subtree. Standard UCB's fixed exploration often locks onto early winners that turn out to be losers deeper in the tree.

Ramanujan-UCB's sustained exploration discovers winning strategies that standard UCB misses. The aggressive early exploration is precisely what you need when you're uncertain whether a move leads to victory or disaster.

## The Implementation

The actual code change is two lines. Define the Ramanujan factor function, then multiply the exploration term by it. The elegance is almost unfair—centuries-old mathematics, minimal code, dramatic improvement.

Parameter tuning matters though. For bandits, q=0.9 and α=1.0 work best (fast decay, mild boost). For games, q=0.97 and α=4-5 (slow decay, strong boost). The harder the problem, the more sustained exploration you want.

## The Broader Lesson

What I love about this project is the unexpected connection between domains. Ramanujan wasn't thinking about game-playing AI—he was exploring the structure of integer partitions. But the mathematical properties he discovered turn out to be exactly what you need for a seemingly unrelated problem.

This happens more often than you'd expect. Exponential decay, logarithmic growth, geometric series—these patterns recur across domains because they're fundamental to how uncertainty and information work.

The project has obvious limitations. Single-seed experiments need statistical validation. The games are relatively simple. There's no theoretical regret analysis. But as a proof of concept, it demonstrates that looking outside your domain—way outside, to 100-year-old pure mathematics—can yield practical improvements.

Sometimes the best ideas are very old ones, waiting for new applications.
