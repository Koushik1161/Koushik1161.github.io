---
layout: post
title: "Ramanujan's Math Meets the Multi-Armed Bandit"
subtitle: "Exploring whether number theory can improve exploration in reinforcement learning"
date: 2025-12-11
---

Sometimes the best ideas come from unexpected places. What does Srinivasa Ramanujan's number theory have to do with game-playing AI? More than you'd think.

This project explores whether mathematical structures from Ramanujan's q-series can improve exploration strategies in multi-armed bandits and Monte Carlo Tree Search.

## The Exploration-Exploitation Dilemma

Imagine you're at a casino with 10 slot machines. Each has a different (unknown) payout probability. How do you maximize your winnings?

Pull the same lever repeatedly? You might miss a better machine.
Try every machine equally? You waste pulls on bad machines.

The optimal strategy balances **exploration** (trying uncertain options) and **exploitation** (using what you know works). This is the multi-armed bandit problem, and it's fundamental to reinforcement learning.

## UCB: The Standard Solution

Upper Confidence Bound (UCB) is the classic approach:

```python
def ucb_score(arm):
    exploitation = arm.mean_reward
    exploration = c * sqrt(log(total_pulls) / arm.pulls)
    return exploitation + exploration
```

The exploration term shrinks as you pull an arm more (you become more confident in your estimate). The exploitation term uses your current best estimate. UCB balances both.

It works well, but can we do better?

## Enter Ramanujan

Ramanujan's q-series appear throughout number theory. The key property I exploited: they create smoothly decaying multipliers.

```python
def ramanujan_factor(n, q=0.95, alpha=2.0):
    """
    R(n) approaches 1 as n grows large
    R(n) is very large when n is small
    """
    return 1 + alpha * (1/(1 - q**n) - 1)
```

When an arm has few pulls (n is small), the Ramanujan factor is large—strongly boosting exploration. As pulls increase, it decays toward 1, shifting emphasis to exploitation.

The Ramanujan-UCB score becomes:

```python
def ramanujan_ucb_score(arm):
    R = ramanujan_factor(arm.pulls)
    return arm.mean_reward + R * c * sqrt(log(total_pulls) / arm.pulls)
```

It's UCB with a mathematically-motivated exploration amplifier.

## Testing on Bandits

I tested against standard bandit problems:

```python
# 10 arms: one good (0.8 probability), nine mediocre (0.3)
arms = [BernoulliArm(0.8)] + [BernoulliArm(0.3) for _ in range(9)]

ucb_cumulative = run_experiment(arms, UCBPolicy())
ramanujan_cumulative = run_experiment(arms, RamanujanUCBPolicy())
```

And on deceptive bandits—where the best arm reveals itself rarely:

```python
# The good arm only pays out 1 in 25 times, but pays big
deceptive_arms = [DeceptiveArm(p_reveal=0.04, reward=25)] + [BernoulliArm(0.5) for _ in range(9)]
```

In deceptive environments, aggressive exploration matters more. Ramanujan-UCB's amplified early exploration helps discover hidden gems.

## Scaling to Games: MCTS

Multi-armed bandits are simple. Real decisions involve sequences of choices with delayed rewards. Enter Monte Carlo Tree Search (MCTS).

MCTS builds a game tree by:
1. **Selection**: Walk down the tree using UCB to choose moves
2. **Expansion**: Add a new node when you reach the frontier
3. **Simulation**: Play randomly to game end
4. **Backpropagation**: Update statistics along the path

I integrated Ramanujan-UCB into the selection phase:

```python
def select_child(node):
    best_score = -inf
    best_child = None

    for child in node.children:
        R = ramanujan_factor(child.visits)
        score = (child.wins / child.visits) + R * c * sqrt(log(node.visits) / child.visits)

        if score > best_score:
            best_score = score
            best_child = child

    return best_child
```

Tested on Tic-Tac-Toe, Connect Four, Othello, and Minichess.

## The Ablation Study

With two parameters (q and alpha), I needed to understand their effects:

```python
for q in [0.90, 0.91, ..., 0.99]:
    for alpha in [1, 2, ..., 10]:
        win_rate = run_mcts_tournament(q, alpha)
        results[q][alpha] = win_rate
```

The resulting heatmap showed:
- **q around 0.95-0.97** works well (fast enough decay, not too fast)
- **alpha around 2-3** provides meaningful amplification without going overboard
- Sweet spots vary by game complexity

## What Worked, What Didn't

**Worked**: In deceptive bandits and games with rare but valuable strategies, Ramanujan-UCB's amplified exploration found good moves that standard UCB missed.

**Didn't work**: In straightforward environments where good options are obvious, the extra exploration was wasted. You can't beat UCB when UCB is already finding the best arm quickly.

**Insight**: The value of amplified exploration depends on how hidden the good options are. Ramanujan-UCB is a tool for hard exploration problems, not a universal improvement.

## The Bigger Picture

This project was an experiment in cross-pollination. Can structures from pure mathematics improve practical algorithms? Sometimes, yes.

Ramanujan wasn't thinking about slot machines or game trees. But the mathematical properties he explored—smooth decay, controlled amplification—turn out to be exactly what exploration strategies need.

There's a lesson here about looking for solutions in unexpected places.

---

*Built with Python, NumPy, and a fascination with what a self-taught mathematician from a century ago can still teach us.*
