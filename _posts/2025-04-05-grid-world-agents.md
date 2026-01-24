---
layout: post
title: "Grid World Agents: Multi-Agent Simulation Basics"
subtitle: "Building the foundation for emergent behavior studies"
date: 2025-04-05
---

Before agents can cooperate, compete, or develop complex social dynamics, they need a world to live in. Grid World Agents is that foundation: a simple 2D environment where multiple agents move, consume resources, and manage energy. It's the starting point for studying emergent behavior.

## The Environment

A 20×10 grid. Ten resources (🍎) scattered randomly. Five agents (🤖) placed avoiding resource locations. Each simulation step, agents move, energy depletes, resources get consumed, and the world updates.

That's it. No complex physics, no elaborate rules. The simplicity is the point—complex behavior should emerge from simple rules, not be engineered in.

## Energy Economics

Agents have 100 energy. Each movement costs 5 energy. Consuming a resource grants 20 energy. When all resources deplete, five new ones spawn.

This creates natural incentive structures without explicit goals. Agents that find resources survive longer. Agents that move efficiently conserve energy. The "purpose" emerges from the economics, not from programmed objectives.

## Random Walk Baseline

Currently, agents move randomly: up, down, left, or right, with boundary checking. This is deliberately stupid. Random walk is the baseline against which smarter behaviors will be compared.

Watching random agents stumble into resources by chance highlights how much room there is for improvement. When I eventually add learning algorithms, the contrast will be stark.

## The Architecture

The `GridWorld` class handles everything:

```python
def __init__(self, width=20, height=10, num_resources=10, num_agents=5):
    self.grid = np.zeros((height, width))
    self.resources = []  # (x, y) positions
    self.agents = []     # {pos: (x,y), energy: 100}
```

NumPy provides efficient grid operations. Resources and agents are tracked in separate lists for easy collision detection. The grid itself is just for visualization—the lists are the source of truth.

Movement validation is explicit:

```python
def move_agent(self, agent):
    direction = random.choice(['up', 'down', 'left', 'right'])
    new_pos = calculate_new_position(agent['pos'], direction)
    if is_valid_position(new_pos):
        agent['pos'] = new_pos
        agent['energy'] -= 5
```

No hidden state, no complex inheritance hierarchies. The code reads like the rules it implements.

## Visualization

Console-based rendering with Unicode:

```
╔════════════════════╗
║🤖    🍎        🍎  ║
║      🤖    🍎      ║
║  🍎    🤖          ║
╚════════════════════╝
```

Clear screen, draw grid, repeat every second. It's not beautiful, but it's immediate and portable. No graphics dependencies, no display configuration.

## The Planned Architecture

The `city_agents/` directory scaffolds a more sophisticated system:

- `agent.py`: Agent classes with behavior systems
- `personality.py`: Trait models affecting decisions
- `interaction.py`: Agent-to-agent communication
- `city.py`: Environment management beyond grids

This structure anticipates agents with distinct personalities, social dynamics, and emergent cultures. The current implementation is Phase 0—prove the simulation loop works before adding complexity.

## Why Start Here

Multi-agent systems research often jumps to sophisticated scenarios: markets, traffic, ecosystems. But complexity obscures fundamentals. Starting with a grid world forces attention to basics:

- How do agents perceive their environment?
- How do they decide what to do?
- How do actions affect the world?
- How does the world affect agents?

Once these loops are clear and working, sophistication can layer on top.

## What's Next

The immediate extensions are clear:

**Perception**: Agents that can "see" nearby resources rather than stumbling into them.

**Memory**: Agents that remember where resources were and return to productive areas.

**Learning**: Q-learning or simple neural networks to develop efficient foraging strategies.

**Social dynamics**: Agents that recognize other agents, cooperate, compete, or develop territories.

Each addition is a lesson in agent-based modeling. The grid world is the laboratory; the experiments come later.

## What I Learned

**Simplicity enables experimentation**. When the simulation is 200 lines of Python, changing anything is trivial. When it's 2000 lines with frameworks, changes become projects.

**Energy systems create behavior without goals**. You don't need to program "find food"—make energy matter, and behavior follows.

**Random baselines are essential**. You can't claim an agent is "smart" without showing what "dumb" looks like. Random walk is the control group.

**Scaffold before building**. The empty `city_agents/` files represent planned architecture. When I'm ready to build, the structure exists. When I'm not, the files don't add complexity.

**Console visualization is underrated**. No graphics library, no display server, no configuration. Print characters, clear screen, repeat. It just works.

Grid world agents won't win any awards. But they're the foundation for studies that might. Every complex emergent behavior simulation starts with something this simple. The art is knowing when to stop adding features and start running experiments.
