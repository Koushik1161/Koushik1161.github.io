---
layout: post
title: "Thinking in Systems"
subtitle: "Why individual components matter less than their connections"
date: 2025-01-05
---

The most important thing I've learned building AI systems isn't about AI.

It's about systems.

## The Component Fallacy

We naturally focus on components. The model. The database. The API. The interface.

But systems fail at boundaries, not centers. The model works. The database works. The API works. What fails is how they connect.

I've debugged more issues caused by mismatched assumptions between components than issues within components themselves.

## Boundaries Are Everything

Every boundary between components is a potential failure point:

- **Data format mismatches.** Component A outputs JSON. Component B expects a specific schema. They drift apart over time.

- **Timing assumptions.** Component A assumes Component B responds in 100ms. Component B occasionally takes 5 seconds.

- **Error propagation.** Component A fails. Component B doesn't know how to handle that failure. The system cascades.

- **State inconsistency.** Component A and B have different views of the same state. They make conflicting decisions.

The more boundaries, the more failure modes. This is why simple systems are more reliable than complex ones.

## The Systems Mindset

Thinking in systems means:

**Map the boundaries.** Before building, draw every connection between components. Each line is a potential failure.

**Define contracts.** Every boundary needs explicit agreements: data formats, timing expectations, error handling.

**Test the connections.** Unit tests verify components. Integration tests verify boundaries. The boundaries need more testing.

**Monitor the flows.** Watch data move through the system. Track latencies at every boundary. Errors often appear as slowdowns first.

## Emergent Behavior

Systems exhibit behaviors that no component possesses individually. These emergent behaviors are often surprising.

A simple example: two services that work perfectly alone can deadlock when connected if they both wait for the other.

A complex example: an AI agent with tools can exhibit behaviors no one designed because the interaction between reasoning and tool use creates emergent capabilities—and emergent failure modes.

## Designing for Connection

The best systems are designed connection-first:

1. **Start with the data flows.** What moves between components? In what format? At what frequency?

2. **Define failure modes.** What happens when each connection fails? How does the system recover?

3. **Build monitoring.** Instrument every boundary. Make the system observable.

4. **Test holistically.** Components work. Do they work together?

Only then do you build the components themselves.

## The Lesson

AI systems fail more often from bad system design than from bad AI.

The model might be state-of-the-art. If the system around it is fragile, the whole thing breaks.

Think in systems. Design the connections. Test the boundaries.

The components are the easy part.
