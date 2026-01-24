---
layout: post
title: "Human-Centered Web Automation with Magentic-UI"
subtitle: "Building a multi-agent browser automation platform with approval gates and visual grounding"
date: 2025-08-15
---

The dream of web automation has always been seductive: describe what you want, and an AI does it for you. But the reality has been fraught with danger. Give an AI agent a browser and tell it to "book a flight," and you might find yourself with three reservations, a newsletter subscription, and a drained credit card.

Magentic-UI is my exploration of a different approach: human-centered automation where you maintain control throughout the process.

## The Control Problem

Traditional web agents operate in one of two modes: fully autonomous (scary) or fully manual (pointless). The autonomous agent might fill out forms, click buttons, and make purchases without asking—exactly what you want until it does something wrong. The manual approach requires so much oversight that you might as well do it yourself.

The insight behind Magentic-UI is that control should be granular and context-aware. Some actions are safe (scrolling, reading). Some are dangerous but reversible (navigating away). Some are irreversible and expensive (form submission, purchases). The system treats these differently.

## The Multi-Agent Team

Rather than one monolithic agent, Magentic-UI uses specialized team members orchestrated by a coordinator. The WebSurfer handles browser interactions—clicking, typing, navigating. The Coder writes and executes scripts in isolated Docker containers. The FileSurfer analyzes documents. The UserProxy handles human input.

This separation matters for more than just organization. Each agent has domain-specific prompts, tools, and safety constraints. The Coder can't accidentally click purchase buttons. The WebSurfer can't execute arbitrary code. Specialization enables safety.

## Set of Mark: Visual Grounding

One of the cleverest patterns in the system is "Set of Mark" visual grounding. Instead of giving the LLM raw HTML selectors (which can be fragile and confusing), the system takes screenshots, identifies interactive elements, and overlays numbered markers.

Now the model can reason visually: "Click the button marked 7" instead of parsing complex CSS selectors. It even tracks which elements are above or below the current viewport, helping the model understand when to scroll.

## The Three-Tier Approval System

Actions require different levels of oversight based on their risk profile:

"Always" approval: form submissions, purchases, authentication—anything irreversible or expensive gets explicit human confirmation.

"Maybe" approval: an LLM evaluates whether the specific action in context seems risky. Navigating to a known site? Probably fine. Navigating to a URL extracted from an email? Better ask.

"Never" approval: scrolling, reading, taking screenshots. These can happen automatically without interrupting the flow.

The system generates human-readable descriptions of pending actions: "I'm about to submit the contact form with your email address. Should I proceed?" This isn't just a yes/no prompt—it's informed consent.

## Plan Before Execute

Perhaps the most important UX decision: agents propose plans before executing them. You ask "Help me book a flight to New York," and the system shows you its intended steps: search on Kayak, filter for nonstop flights, sort by price, select the cheapest option, fill in passenger details.

You can review, edit, regenerate, or approve this plan before anything happens. This cognitive overhead upfront saves the frustration of watching an agent do the wrong thing for thirty seconds before you can stop it.

The plan is structured data—step titles, details, assigned agents—not just free text. This enables the system to track progress, adapt to obstacles, and provide meaningful status updates.

## Learning from Success

Here's what excites me most: the system learns from successful executions. After you complete a task, the Learner agent extracts a generalizable plan from the conversation history. This becomes a template for future similar tasks.

It's not memorizing specific XPath selectors or URLs—those break constantly. It's extracting the high-level flow: the pattern of actions that achieved the goal. This feels like the beginning of genuine skill acquisition for web agents.

## The Safety Stack

Multiple layers protect against dangerous actions. Docker isolation means code execution can't affect the host system. Approval guards catch risky actions before execution. Plan review enables human oversight at the strategic level. Audit logging creates accountability.

But I'll be honest: web automation is still risky. Websites change, agents misinterpret, edge cases proliferate. Magentic-UI doesn't eliminate these risks—it manages them through transparency and control. You're still responsible for what you approve.

## Running the Stack

The architecture is substantial: FastAPI backend, Gatsby frontend, Docker containers for browser and code execution, SQLite for persistence, WebSocket for real-time updates. It's not a simple demo; it's infrastructure for serious automation.

The Microsoft AutoGen framework provides the multi-agent orchestration, which means I didn't have to reinvent agent communication patterns. Standing on the shoulders of a solid framework let me focus on the human-centered features that make this approach different.

This project represents my current best thinking on how AI web automation should work. Not fully autonomous—that's premature. Not fully manual—that's pointless. Instead, a thoughtful collaboration where the AI proposes, the human approves, and both learn from the results.
