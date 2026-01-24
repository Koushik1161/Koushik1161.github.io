---
layout: post
title: "Less is More: Why Tiny Recursive Networks Beat Giant LLMs"
subtitle: "Exploring a research paper that challenges our assumptions about model scale"
date: 2025-10-13
---

Here's a counterintuitive result: a 7 million parameter model outperforms trillion-parameter LLMs on hard reasoning tasks. Not by a little—by a lot. On Sudoku-Extreme, the tiny model scores 87.4% while Claude, GPT-4, and DeepSeek score 0%.

How is this possible?

## The TRM Paper

"Less is More: Recursive Reasoning with Tiny Networks" by Alexia Jolicoeur-Martineau presents the Tiny Recursive Model (TRM). The key insight: instead of making models bigger, make them think longer.

## The Architecture: Depth Through Iteration

TRM maintains two internal states:

- **y**: The current proposed answer (decodable)
- **z**: A latent reasoning state (like chain-of-thought memory)

The model iteratively refines both:

```
For each step t:
    z ← f(x, y, z)    # Update reasoning based on problem + current answer
    y ← g(y, z)       # Update answer based on reasoning
```

This continues for up to 16 steps. The final y is the output.

Think of it like a human solving a puzzle: you make an initial guess, think about what's wrong, update your guess, think more, update again. The model does this explicitly.

## Why Shallow Networks Work

Here's the surprising finding: 2-layer networks with many iterations beat 8-layer networks with fewer iterations.

```python
# Better: shallow + recursive
model = TRM(layers=2, iterations=16)  # 5M params, 87% accuracy

# Worse: deep + single-pass
model = DeepNet(layers=8, iterations=1)  # 20M params, 45% accuracy
```

The hypothesis: deep networks overfit on small datasets. Shallow networks with explicit iteration are more constrained, forcing general reasoning strategies.

## Data Augmentation: 1000x Expansion

TRM trains on just 1,000 Sudoku examples—then augments to 1 million:

```python
def augment_sudoku(puzzle, solution):
    augmented = []
    for _ in range(1000):
        # Permute numbers (1↔3, 2↔7, etc.)
        perm = random_permutation([1,2,3,4,5,6,7,8,9])
        p, s = apply_permutation(puzzle, solution, perm)

        # Rotate/flip
        p, s = random_transform(p, s)

        augmented.append((p, s))
    return augmented
```

The augmentations preserve Sudoku rules while creating novel instances. This is domain-aware augmentation—random pixel shuffling wouldn't work.

## The Halting Mechanism

When should the model stop iterating? TRM uses a simple binary classifier:

```python
def should_halt(z: Tensor) -> bool:
    halt_prob = sigmoid(self.halt_head(z))
    return halt_prob > 0.5
```

If the model is confident in its answer, it stops early. Hard puzzles use more iterations. This is adaptive compute allocation without explicit training for it.

## Results That Challenge Assumptions

On ARC-AGI (a benchmark designed to test genuine reasoning):

| Model | Parameters | Score |
|-------|-----------|-------|
| TRM | 7M | 44.6% |
| Gemini 2.5 Pro | 32B+ | 37% |
| DeepSeek R1 | 671B | ~40% |
| Grok-4 | 1.7T | 66.7% |

TRM achieves competitive results with 0.01% of the parameters. It doesn't beat everything, but it's in the conversation.

On constrained reasoning (Sudoku-Extreme, Maze-Hard), TRM wins outright:

| Task | TRM (7M) | LLMs |
|------|----------|------|
| Sudoku-Extreme | 87.4% | 0% |
| Maze-Hard | 85.3% | 0% |

Zero. Trillion-parameter models score zero on tasks a tiny recursive network handles easily.

## Why LLMs Fail Here

Autoregressive generation is the wrong inductive bias for these tasks. LLMs generate tokens left-to-right; they can't easily "go back" and revise earlier predictions based on later constraints.

Sudoku requires global constraint satisfaction. A digit placed in row 1 affects valid placements in row 9. Token-by-token generation doesn't capture this structure.

TRM's iterative refinement naturally handles global constraints. Each pass through the network can revise the entire answer based on full context.

## What This Means

**Scale isn't everything.** For certain problem types, architectural inductive biases matter more than parameter counts.

**Iteration beats depth.** Shallow networks with explicit reasoning loops can outperform deep networks that process in one pass.

**Domain matters.** These results apply to constrained reasoning tasks. LLMs still win at open-ended language generation. The lesson isn't "TRM is better" but "different architectures for different problems."

## The Takeaway

We've assumed that general-purpose scaling is the path to artificial general intelligence. This paper suggests that specialized architectures with the right inductive biases can dramatically outperform at specific reasoning tasks.

Maybe the path to AGI isn't one giant model, but a toolkit of specialized reasoners with different strengths.

---

*Exploring research that reminds us model architecture still matters in the era of scale.*
