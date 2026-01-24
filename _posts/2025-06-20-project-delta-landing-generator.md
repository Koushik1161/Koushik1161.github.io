---
layout: post
title: "AI Landing Page Generator: From Prompt to Preview"
subtitle: "Building a full-stack app that converts natural language to live HTML"
date: 2025-06-20
---

There's something deeply satisfying about seeing natural language transform into working code. You type "a modern SaaS landing page with a hero section, pricing table, and contact form" and seconds later, there it is—rendered in your browser, ready to inspect and iterate.

Project Delta is my exploration of this idea, built as a clean React + Express stack with OpenAI in the middle.

## The Simple Architecture

The architecture is intentionally minimal. A React frontend with a textarea and two display areas. An Express backend with a single POST endpoint. OpenAI's Chat API does the actual generation.

When you type a prompt and click "Generate," the frontend sends it to the backend. The backend wraps it in a system instruction that says "respond only with HTML and CSS code, no explanations," sends it to GPT-3.5-turbo, and returns whatever comes back. The frontend displays both the raw code (in a scrollable pre block) and the rendered result (in an iframe with srcDoc).

No database, no authentication, no complex state management. The simplest thing that could work.

## The System Prompt Trick

The key to getting usable output is the system prompt. Without constraints, GPT will happily explain what it's doing, offer alternatives, ask clarifying questions. For code generation, you want none of that—just the code.

"You are a web developer. Respond only with valid HTML and CSS code. Do not include any explanations, comments about the code, or markdown formatting. Only output the raw HTML and CSS that can be directly rendered."

This instruction produces clean, injectable HTML. The model still occasionally adds commentary, but the success rate is high enough for an interactive tool.

## The iframe Pattern

Rendering arbitrary HTML safely in a React app is tricky. You can't just use dangerouslySetInnerHTML—that exposes your app to XSS vulnerabilities. But an iframe with srcDoc creates a sandboxed context where the generated HTML runs in isolation.

```jsx
<iframe
  srcDoc={generatedCode}
  title="Preview"
  style={{ width: '100%', height: '500px', border: '1px solid #ddd' }}
/>
```

The generated code can do whatever it wants inside the iframe without affecting the parent application. It's not perfect security—a determined attacker could still cause problems—but it's appropriate for a personal tool.

## Why GPT-3.5-turbo?

I experimented with GPT-4 early on. The generated code was marginally better—more semantic HTML, cleaner CSS—but not dramatically so. GPT-3.5-turbo is faster and cheaper, and for landing page HTML, it's good enough.

The iteration cycle matters more than per-generation quality. When you can regenerate in two seconds, you try more variations. When it takes ten seconds and costs more, you try fewer. Speed enables exploration.

## The Dual Display Pattern

Showing both raw code and rendered preview serves two purposes. The preview gives immediate gratification—you see what you asked for. The raw code enables debugging when something's wrong and learning for people studying how HTML/CSS achieves visual effects.

I could have shown only the preview, hiding the implementation. But this is a developer tool, and developers want to understand what's generated, not just consume it.

## Limitations and Honesty

This tool generates static HTML. No JavaScript logic, no interactive components, no data binding. For landing pages, that's often fine. For actual applications, it's just a starting point.

The generated code is also inconsistent in quality. Sometimes you get beautiful, well-structured HTML. Sometimes you get nested divs with inline styles. The variance reflects GPT's training data, which includes both excellent and terrible web code.

I don't try to hide these limitations. The tool does one thing—converts descriptions to HTML quickly—and it does that well. Pretending it's more would set false expectations.

## The Development Experience

Building this was a lesson in full-stack simplicity. React's Create React App handles frontend tooling. Express needs no configuration for simple APIs. Environment variables keep the API key out of the repository. CORS middleware enables cross-origin requests in development.

Total development time was a few hours. Most of that was prompt engineering—figuring out what system instructions produced the best results. The code itself is under 200 lines total.

## What I'd Add Next

If I were productizing this, I'd add template categories (SaaS, portfolio, e-commerce), style options (minimalist, bold, playful), and history to revisit previous generations. I'd probably also add a code editor for tweaking the generated HTML before export.

But as a proof of concept, Project Delta demonstrates that AI-generated code is useful today for specific, bounded use cases. Not replacing developers—accelerating them.
