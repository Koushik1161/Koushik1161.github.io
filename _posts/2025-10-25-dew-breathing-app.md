---
layout: post
title: "Dew: Neo-Brutalist Breathing Meditation for iOS"
subtitle: "Building a 60-second wellness app with SwiftUI, Combine, and intentional design"
date: 2025-10-25
---

Sometimes the simplest apps are the hardest to get right. Dew is a guided breathing app that does one thing: help you breathe through five cycles in about 60 seconds. No tracking, no gamification, no account creation. Just breath.

The challenge was making something this minimal feel substantial.

## The 4-2-6 Breathing Pattern

The core timing is physiologically intentional. Four seconds inhale, two seconds hold, six seconds exhale. The exhale is longer than the inhale by design—this activates the parasympathetic nervous system, triggering the relaxation response.

There's real research behind this. Harvard Medical School on stress reduction. Stanford on HRV improvement. The American Heart Association on blood pressure effects. I embedded these citations in a "Why This Works" modal because credibility matters for wellness apps.

## Neo-Brutalist Visual Language

The design is aggressively distinctive: thick black borders, hard offset shadows, bold geometric shapes, high-contrast colors. Neo-brutalism feels jarring at first, but it's refreshing in a landscape of soft gradients and rounded edges.

Each breathing phase gets its own color. Yellow for arrival, blue for inhale, purple for hold, orange for exhale, green for stillness. These aren't arbitrary—they create visual rhythm that reinforces the breathing cycle without requiring conscious attention.

The centerpiece is the BoldBreathShape component: a geometric form that scales from 70% to 120% during inhale, rotates through phases, and transitions colors smoothly. It's the visual feedback that replaces the need for counting.

## SwiftUI and Combine Architecture

The state management uses Combine's ObservableObject pattern. The BreathState class tracks current phase and cycle count, publishing changes that drive the UI. A single `nextPhase()` method handles all transitions.

Animation timing uses DispatchQueue.main.asyncAfter for phase transitions. Four seconds of inhale animation, then automatically transition to hold. Two seconds of hold, then exhale. Six seconds of exhale, then back to inhale—unless we've completed five cycles.

SwiftUI's spring animations with phase-specific timing create organic motion. The breath shape doesn't just scale—it breathes.

## Haptic Feedback Layer

Vibration adds a tactile dimension to the experience. When you tap to start, a heavy impact feedback confirms the action. Subtle pulses could mark phase transitions if I chose to add them. The haptics create embodiment—you're not just watching a screen, you're feeling the rhythm.

UIImpactFeedbackGenerator with .heavy style for primary actions, .medium for secondary. It's a small detail that makes the app feel responsive rather than distant.

## The Single-Session Philosophy

Dew has no persistence layer. Sessions aren't saved, streaks aren't tracked, there's no achievement system. This is intentional.

Wellness apps often fall into the trap of gamification—turning a practice of present-moment awareness into a competition with yourself. That's counterproductive. The goal is a 60-second reset, not a streak counter that adds anxiety when broken.

The completion screen says "You're statistically significant"—a bit of humor that validates without pressuring continuation. You did the thing. That's enough.

## Composable Component Design

The architecture supports extension without encouraging it. BoldBreathShape and NeoBrutalistBackground are reusable components. Adding a new breathing pattern would mean creating a new BreathState configuration, not rewriting UI code.

But I resist the temptation to add features. More breathing patterns? More complexity to choose between. Session history? Pressure to maintain consistency. Social features? Comparison with others.

The app is minimal because wellness benefits from minimalism.

## The Completion Ritual

After five cycles, the app transitions to a completion screen. This isn't just a "done" message—it's a moment of acknowledgment. You took 60 seconds for yourself. The visual design celebrates this without overstating it.

There's a restart button if you want another round, but no push to continue. The default action after completion is to close the app and return to life, slightly calmer.

## Lessons from Constraint

Building Dew taught me that constraint is creative fuel. With one minute of content and one interaction (tap to start), every visual and motion decision matters enormously. There's nowhere to hide mediocrity.

The neo-brutalist aesthetic emerged from this constraint. When you can't rely on content variety, you need visual impact. When animation duration is fixed by breathing physiology, timing must be perfect.

The result is an app that feels confident rather than sparse. It knows exactly what it is and doesn't apologize for what it isn't.

## The Wellness App Paradox

Most wellness apps want your attention. They want daily engagement, notifications, premium subscriptions. Dew wants you to use it for 60 seconds and then forget about it until you need it again.

This feels backwards from a business perspective but right from a wellness perspective. The goal isn't app engagement—it's human wellbeing. Sometimes those align; often they don't.

Dew is my small bet that there's space for wellness tools that respect your attention rather than competing for it. Sixty seconds, five breaths, no strings attached.
