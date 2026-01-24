---
layout: post
title: "Uniq: When Ramanujan's Math Meets Game AI"
subtitle: "Exploring q-series exploration bonuses in Monte Carlo Tree Search"
date: 2025-06-15
---

What happens when you apply century-old mathematical insights from Srinivasa Ramanujan to modern game-playing AI? That question drove the Uniq project—an experimental study of whether q-series mathematics could improve exploration in reinforcement learning.

The results were striking: a 356% improvement in Connect Four against standard algorithms, but zero improvement in simple bandits. The pattern taught me something fundamental about when mathematical intuition translates to practical advantage.

## The Core Innovation

The Ramanujan factor modifies the exploration term in Upper Confidence Bound (UCB) algorithms:

```python
def ramanujan_factor(n, q=0.9, alpha=1.0):
    q_pow = q ** n
    geom = 1.0 / (1.0 - q_pow)
    return 1.0 + alpha * (geom - 1.0)
```

For low visit counts, this factor is enormous—130x amplification when n=1 with q=0.97 and α=4. As visits increase, it decays smoothly toward 1, eventually becoming standard UCB.

The q-geometric series at the heart of this comes from Ramanujan's work on infinite products. I didn't expect century-old partition theory to be relevant to game AI, but the mathematical structure is surprisingly appropriate for exploration schedules.

## The Experiments

I tested across five domains:

**Simple bandit**: Ten arms, one good (60% reward), nine poor (10%). Both algorithms performed identically—about 5,400 cumulative reward. When the optimal action is easily discoverable, extra exploration doesn't help.

**Deceptive bandit**: The best arm (90% reward) is hidden 95% of the time. Neither algorithm could reliably find it. Over-exploration actually hurt slightly, wasting resources on arms that appeared promising but weren't.

**3×3 Tic-Tac-Toe**: Ramanujan-UCB won 59.5% vs 24.5% for standard UCB—a 143% improvement. The game tree has enough depth that enhanced exploration finds better lines.

**4×4 Tic-Tac-Toe**: Complete dominance. Standard UCB won zero games; Ramanujan-UCB won 34%. The larger state space amplifies the exploration advantage.

**Connect Four**: Maximum effect. 82% vs 18%—a 356% improvement. In a game with 4.5 trillion possible positions, aggressive exploration of unusual move sequences pays dividends.

## The Scaling Phenomenon

The most interesting finding wasn't any single result—it was the pattern across problems:

- Flat problems (bandits): No advantage
- Shallow trees (3×3): Moderate advantage
- Deep trees (4×4, Connect Four): Overwhelming advantage

The Ramanujan factor is specifically suited for tree search, not flat optimization. Each action in a game leads to a subtree of possibilities; the q-series structure matches this hierarchical exploration need.

## Parameter Sensitivity

Different domains needed different tuning:

- **Bandits**: q=0.9, α=1.0 (fast decay)
- **3×3**: q=0.97, α=4.0 (slower decay, stronger boost)
- **Connect Four**: q=0.97, α=5.0 (maximum boost)

The pattern makes sense: deeper problems need more persistent exploration. Quick convergence works for simple problems; complex problems need sustained pressure to explore unusual branches.

## Why It Works in Game Trees

Standard UCB suffers from premature convergence. If an early simulation happens to favor a suboptimal move, UCB can lock onto that branch, never exploring alternatives that might be better.

The Ramanujan factor prevents this by providing massive exploration bonuses for rarely-visited nodes, even deep in the tree. It forces examination of unusual move sequences that standard UCB would neglect.

The smooth decay is crucial. A harsh transition from exploration to exploitation can cause instability. The q-geometric series provides graceful decay—exploration pressure that fades naturally as visit counts grow.

## Limitations

This is research-grade code, not production AI. Single runs, hand-tuned parameters, classical board games only. I haven't proven theoretical regret bounds or measured computational overhead rigorously.

The technique also doesn't help when optimal actions are easily discoverable (simple bandits) or fundamentally hidden (deceptive bandits). It's specifically for problems where tree structure matters and sufficient exploration reveals better solutions.

## What I Learned

Mathematical intuition from unexpected sources can inform algorithm design. Ramanujan wasn't thinking about game AI—he was thinking about partitions and infinite products. But the mathematical structure he discovered has properties that happen to be useful for exploration schedules.

The complexity scaling result was the biggest surprise. I expected benefits to be roughly constant across problem types. Instead, the advantage increases with problem complexity. This suggests the technique might be even more valuable for truly challenging domains like Go or chess.

The project taught me to pay attention to problem structure. Not all exploration strategies work everywhere. Understanding why something works (tree depth, not just randomness) is as important as knowing that it works.

Classical mathematics and modern AI aren't as separate as they might seem. Sometimes the best insights come from unexpected connections across centuries of human thought.
