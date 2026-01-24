---
layout: post
title: "Two Faces of Product Design: Supermemory Landing Pages"
subtitle: "Creating both a Jony Ive-inspired showcase and a practical developer onboarding experience"
date: 2025-10-01
---

Product marketing has two audiences that want different things. Executives want vision and emotion. Developers want code and implementation details. For Supermemory—a memory layer for AI systems—I built two distinct landing pages for these distinct needs.

## The Jony Ive Edition

The first page is pure design philosophy. Massive breathing typography ("Memory" at 8rem). Generous white space (40-80px between sections). Glass morphism effects that create depth without clutter. Every element serves a purpose or doesn't exist.

This follows Jony Ive's principle: the product is the hero, not the design. The page showcases three claims (Instant at <400ms, Intelligent at 10x faster, Infinite scale) without overwhelming with technical details. It's emotional rather than logical.

The animation approach uses Apple's signature easing curve: `cubic-bezier(0.16, 1, 0.3, 1)`. This creates motion that feels natural—quick to start, gentle to finish. Scroll-triggered animations with viewport margins prevent jarring pop-ins.

Color palette is deliberately restrained: white, off-white, light gray, dark gray, black, and a single accent (Apple blue #0071e3). The constraint forces clarity.

## The Onboarding Experience

The second page flips the script. It's functional, educational, code-focused. The hero has a gradient background with energy, but the real content is the DecisionGuide component: an interactive comparison of three integration methods.

Memory Router (proxy approach): one line change, zero refactoring. AI SDK Integration: built-in memory tools for Vercel's AI SDK. Memory API: full SDK control for advanced use cases.

Each option shows setup time, code complexity, and actual code examples. Developers can make informed decisions without reading documentation pages.

The QuickStart component provides progressive steps across languages (TypeScript and Python), with copy-to-clipboard functionality. A six-stage "How It Works" visualization shows the processing pipeline from input to retrieval.

## Same Product, Different Storytelling

Both pages describe the same product: Supermemory captures conversations and context, understands semantically, and enables sub-400ms recall. But they tell the story differently.

The Ive edition asks: "Don't you want AI that remembers?" It's aspirational, creating desire before explanation.

The onboarding page asks: "How do you integrate memory into your AI?" It's practical, assuming intent and focusing on execution.

Neither is complete alone. Marketing needs the vision; implementation needs the detail. The mistake would be mixing them—aspirational language in onboarding creates friction, technical detail in marketing creates confusion.

## The Technical Foundation

Both pages share a foundation: Next.js 14 with App Router, Tailwind CSS, and Framer Motion. The design system—colors, typography scales, glass classes—is consistent. This makes visual coherence possible even as content differs dramatically.

The Ive page runs on port 3001 (to avoid conflicts), while the onboarding page takes the default 3000. Both can be developed simultaneously, sharing assets but serving different purposes.

## Responsive Typography Strategy

Heavy use of CSS `clamp()` enables fluid scaling without breakpoint gymnastics. Headlines might range from 3rem to 8rem based on viewport, with the browser calculating intermediate values. This creates smooth responsive behavior rather than jarring size jumps.

The Ive page takes this further with deliberately massive type—sizes that feel almost uncomfortable on desktop but establish hierarchy unmistakably.

## Glass Morphism as Information Layer

Both pages use glass morphism, but differently. The Ive page uses it for floating code examples—they hover above the background, readable but not primary. The onboarding page uses it for interactive elements—the decision guide cards have that frosted effect to create container boundaries.

The implementation is consistent: `backdrop-filter: blur()` with `saturate(180%)` for that premium feel. The effect works because it's used sparingly; an entire page of glass would feel muddy.

## The Animation Philosophy

Both pages use Framer Motion's `whileInView` for scroll-triggered animations, but with different emotional goals. The Ive page animations are slow and graceful—elements float in with long durations, creating contemplative pacing.

The onboarding page animations are snappier—quick enough to feel responsive without getting in the way of reading. Developers don't want to wait for animations; they want information.

## The Deployment Story

Both projects are production-ready: TypeScript configured, build scripts in place, Vercel or any Node.js host will work. The single-page structure means fast loading and simple caching.

But they're not the same deployment. The Ive page might live at the root marketing URL; the onboarding page at /docs or /getting-started. Different entry points for different user intents.

## What I Learned

Building both forced clarity about audience. When designing for executives, I found myself adding emotional weight—larger type, more motion, evocative language. When designing for developers, I found myself adding utility—code examples, comparison tables, copy buttons.

The temptation is always to merge them: "What if we had the beautiful design AND the technical depth?" But attention has limits. A page optimized for two audiences often serves neither well.

Better to build two pages, each excellent for its purpose, than one page that compromises for everyone.
