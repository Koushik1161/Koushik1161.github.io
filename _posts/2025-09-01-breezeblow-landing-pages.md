---
layout: post
title: "Testio: Multi-Theme Landing Page Exploration"
subtitle: "Designing four complete visual systems for a voice-to-text AI product"
date: 2025-09-01
---

How many ways can you present the same product? That question drove the Testio project—a design exploration creating four complete visual systems for Breezeblow, a voice-to-text writing tool.

Each theme isn't just a color swap. It's a complete reimagining of how to communicate the same value proposition through different aesthetic languages.

## The Product: Breezeblow

Breezeblow converts natural speech into polished written content. Speak your thoughts, and AI cleans up the filler words, fixes grammar, and produces professional text. The claim: 4x faster than typing (220 WPM spoken vs 45 WPM typed).

It's the kind of product that benefits from demonstration. You need to see the messy input transform into clean output. Each landing page variant tells this story differently.

## Theme One: Clean Professional

The main Breezeblow theme is minimal and modern—Inter typeface, restrained color palette, lots of white space. It targets professional users who value clarity over flash.

The hero section shows a before/after card. Raw transcription with "um"s and false starts on one side, polished prose on the other. The transformation is visual and immediate.

This theme uses GSAP for subtle scroll-triggered animations. Elements fade in as you scroll, but nothing jumps or distracts. The goal is credibility through restraint.

## Theme Two: Comic Book

The comic variant explodes with personality. Bold outlines, halftone patterns, handwriting fonts, POW-style callouts. Same product, completely different emotional register.

Here the transformation is dramatic: scratchy speech bubble becomes clean text block, with visual "magic" effects connecting them. It's playful, approachable, less corporate.

This theme required rethinking every component. Buttons have thick borders and drop shadows. Cards have jagged edges. Progress bars look hand-drawn. Consistency matters even in chaos.

## Theme Three: Synthwave

The synthwave aesthetic goes full retro-futurism: neon grid backgrounds, chrome text, gradient glows, VHS scan lines. It's nostalgic for a future that never happened.

This theme suits a different audience—creators, artists, people who choose tools partly for aesthetic alignment. The product does the same thing, but the vibe says "you're not like everyone else."

Implementing this required heavy use of CSS gradients, shadows, and pseudo-elements. The visual complexity is in styling, not structure. The HTML remains semantic; the CSS does the heavy lifting.

## Theme Four: Aqua

The aqua theme takes a softer direction: ocean gradients, bubble-like elements, rounded edges everywhere. It's calming, organic, approachable.

This theme works well for accessibility-focused messaging—Breezeblow helps people with motor difficulties, non-native speakers, anyone for whom typing is a barrier. The aqua aesthetic feels inclusive without being medical.

## The Animation System

All themes share GSAP's ScrollTrigger for scroll-based animations, but the animation styles differ. Professional uses subtle fades. Comic uses bouncy springs. Synthwave uses glitchy transitions. Aqua uses smooth flows.

This taught me how much animation contributes to brand personality. The same "fade in from bottom" animation feels different with different easing curves and timing.

## The Pricing Model

The pricing section is consistent across themes: Free (2,000 words/week), Pro ($12/month unlimited), Enterprise (custom with SOC 2 and HIPAA compliance). This structures the business model clearly regardless of aesthetic treatment.

The visual presentation varies—comic pricing cards have jagged borders, synthwave cards glow—but the information hierarchy stays constant.

## Responsive Considerations

Each theme required responsive variants. What works at 1400px wide often breaks at 375px. The comic bold outlines become overwhelming on small screens. The synthwave grid background needs to scale differently.

I ended up with significant mobile-specific CSS for each theme. The investment was worth it; a landing page that breaks on mobile loses most visitors immediately.

## What I Learned

This project convinced me that design exploration through complete implementations is valuable. Mockups in Figma can suggest a direction, but building full themes reveals practical challenges and opportunities.

Each theme took roughly the same effort: HTML structure, JavaScript interactions, then CSS styling. The styling dominated time spent—probably 60% of each variant. Good CSS architecture (custom properties, consistent naming) made the theming possible.

Would I recommend building four versions of a landing page? For learning, absolutely. For production, probably pick one or two and focus on content and conversion optimization. But as an exploration of design space, this was invaluable practice.
