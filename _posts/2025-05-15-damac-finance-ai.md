---
layout: post
title: "Building Enterprise-Grade Multi-Agent Finance AI"
subtitle: "How I architected a production-ready system for automating DAMAC Properties' financial workflows"
date: 2025-05-15
---

There's something deeply satisfying about building systems that solve real business problems. When I set out to create a multi-agent AI system for finance operations, I wanted to prove that LLM-powered automation could handle the complexity, security, and compliance requirements of enterprise financial workflows.

## The Challenge: Finance Operations at Scale

Think of a large real estate developer like DAMAC Properties in Dubai. Every day, they process hundreds of vendor invoices, track payment plans across multiple property developments, and calculate broker commissions. Each of these workflows involves UAE-specific regulations: 5% VAT, 4% DLD fees, RERA escrow compliance, and tiered approval thresholds.

The traditional approach would be separate systems for each workflow, manual handoffs, and constant context-switching. My goal was different: build a unified AI system where a user could simply ask "What's the status of the retention on the Al Furjan invoices?" and get an accurate, context-aware response.

## The Multi-Agent Architecture

The core insight was that different financial tasks require different reasoning. Invoice processing is about parsing and calculation. Payment plans require temporal reasoning. Commission calculations need relationship mapping. Rather than forcing one agent to do everything, I built specialized agents orchestrated by a central coordinator.

The orchestrator first classifies the user's intent using structured outputs. This isn't free-text classification—it's constrained to specific intents with confidence scores and entity extraction. When the orchestrator identifies "invoice processing," it routes to an agent that knows DAMAC's vendor list, understands retention calculations, and can apply the correct approval thresholds.

What made this click was using PydanticAI for type-safe LLM outputs. Instead of hoping the model returns valid JSON, every response is validated against a schema. If the invoice agent returns a `ParsedInvoice`, I know it has `subtotal`, `vat_amount`, `retention_amount`, and `net_payable` as Decimals—not floats that might have precision issues.

## Security as a First-Class Citizen

Financial systems can't treat security as an afterthought. I implemented a three-layer security pipeline: prompt injection defense, PII detection and masking, and comprehensive audit logging.

The prompt injection defense was particularly interesting. I built a pattern-matching system that detects 16+ attack vectors—instruction overrides, role manipulation, delimiter injection—each with a severity score. The system doesn't just block suspicious input; it sanitizes it while maintaining user intent when possible.

For PII, I needed UAE-specific patterns. Emirates IDs follow a specific format (784-XXXX-XXXXXXX-X), as do IBAN numbers. The system can mask these while preserving enough information for context (showing first and last digits) or fully tokenize them for vault storage during sensitive operations.

## Real-World Validation

Theory is nice, but does it work? I tested the system against 15 real-world queries using actual DAMAC data—real project names, real contractor relationships, realistic financial figures. The results: 93.3% accuracy across invoice processing, payment plans, and commission calculations.

The one failure was illuminating. A complex payment plan query involving multiple milestone triggers and partial payments required reasoning that GPT-5-mini struggled with. The fallback to GPT-4o handled it correctly, validating the tiered model approach where simpler tasks use cheaper models and complex reasoning escalates automatically.

## The MCP Server Pattern

One architectural choice I'm particularly pleased with is exposing the agents through Model Context Protocol. This means Claude Desktop can directly invoke the finance system as tools. A user can have a natural conversation: "I'm preparing the Q4 board report. What's our total outstanding retention across all Lagoons projects?" The MCP server routes this through the invoice agent, aggregates the data, and returns a formatted response.

This pattern—AI agents as MCP tools—feels like the future of enterprise AI integration. Instead of building separate UIs for each capability, you expose them as tools that any MCP-compatible interface can consume.

## Lessons Learned

Building this system reinforced several principles. First, structured outputs are non-negotiable for financial applications. The difference between "probably correct JSON" and "validated against schema" is the difference between prototype and production.

Second, domain expertise must be embedded in prompts, not just hoped for from the LLM. My prompts include specific DAMAC project names, UAE tax rates, and RERA compliance requirements. The model can reason with this knowledge; it can't reliably invent it.

Third, observability isn't optional. Every query is traced through Langfuse with timing, token usage, and cost metrics. When something goes wrong—and it will—you need the instrumentation to debug it.

The system isn't perfect. Production deployment would need real vault integration for PII tokenization, proper database connection pooling, and load testing. But as a demonstration of what's possible with careful architecture, it shows that enterprise-grade AI automation is within reach for teams willing to invest in the foundations.
