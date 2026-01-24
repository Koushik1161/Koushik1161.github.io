---
layout: post
title: "The Anthropic Skills Framework: Extending Claude with Domain Expertise"
subtitle: "Building modular capabilities for document processing and specialized tasks"
date: 2026-01-20
---

How do you give an AI assistant domain expertise without bloating its context window? The Anthropic Skills Framework answers this with progressive disclosure: metadata always available, detailed documentation loaded on-demand, executable scripts invoked when needed.

This project contains seven production-ready skills that transform Claude from a general-purpose assistant into a specialist for document processing, spreadsheet operations, and technical tasks.

## The Progressive Disclosure Pattern

Every skill follows a three-tier structure:

**Tier 1 - Metadata** (always loaded): Name and description in YAML frontmatter. This triggers skill activation based on user requests.

**Tier 2 - SKILL.md** (loaded when triggered): Detailed instructions, workflows, and examples. Provides the knowledge Claude needs to use the skill effectively.

**Tier 3 - Bundled resources** (loaded on-demand): Executable scripts, reference documentation, templates. Used during actual task execution.

This hierarchy means Claude doesn't carry the weight of every skill's documentation in every conversation. A user working on spreadsheets loads the XLSX skill; PDF capabilities stay dormant until needed.

## Document Processing Suite

Three skills handle Microsoft Office formats:

**PDF Skill**: Extract text and tables, create new PDFs, merge and split documents, fill forms, OCR scanned pages. Uses pypdf, pdfplumber, and reportlab under the hood.

**DOCX Skill**: Create and edit Word documents with tracked changes, comments, and formatting preservation. Handles the complexity of Office Open XML through python-docx and pandoc.

**PPTX Skill**: Create and edit PowerPoint presentations with precise layout control. Uniquely uses an HTML-to-PowerPoint workflow—design slides as HTML, convert with accurate positioning.

Each skill understands that .docx, .xlsx, and .pptx files are ZIP archives containing XML. Complex operations become: unpack → modify XML → repack. The framework handles secure XML parsing with defusedxml to prevent XXE attacks.

## The XLSX Skill Deep Dive

Spreadsheet handling deserves special attention. The skill emphasizes a formula-first philosophy:

```
❌ Wrong: Hardcode calculated values
✅ Right: Use formulas that recalculate when inputs change
```

Professional financial modeling conventions are documented:

| Color | Meaning |
|-------|---------|
| Blue | Input values (user-editable) |
| Black | Formulas (calculated) |
| Green | Links to other sheets |
| Red | External file references |
| Yellow | Assumptions |

Formula recalculation requires LibreOffice automation. Excel formulas are stored as text; LibreOffice's macro engine actually computes values. The skill includes scripts that auto-configure this on first run, handling macOS and Linux path differences.

Quality assurance validates outputs: check for #REF!, #DIV/0!, and other formula errors; detect overflow; convert to PDF and JPEG for visual verification.

## DeepSeek-OCR Skills

Two specialized skills handle optical text compression using vision-language models:

**DeepSeek-OCR Windows**: Setup and usage guide for NVIDIA GPU systems. Covers CUDA 11.8 configuration, Flash Attention 2 installation, and troubleshooting common issues.

**DeepSeek-OCR Batch Processing**: Large-scale document processing pipelines. Compression benchmarks, memory system integration, and batch workflow orchestration.

The compression results are significant:

| Approach | Tokens | Accuracy |
|----------|--------|----------|
| Traditional OCR | 6,000+ | ~95% |
| DeepSeek (10x compression) | 600 | 97% |
| DeepSeek (20x compression) | 300 | 60% |

For long-context LLM applications, reducing token count by 90% while maintaining accuracy transforms economics.

## The Skill Creator Meta-Skill

The framework includes a skill for creating new skills. It documents:

- Directory structure conventions
- YAML frontmatter requirements
- SKILL.md content guidelines
- How to bundle scripts and references
- Testing and validation procedures

This enables the framework to extend itself. Users with domain expertise can encode it as skills, making Claude more capable for their specific workflows.

## Architecture Insights

**Skill metadata is the triggering mechanism**. The description field drives when Claude activates the skill. Writing good descriptions is as important as writing good documentation.

**Office files are XML transformations**. Understanding this unlocks manipulation capabilities. The framework abstracts the complexity but doesn't hide the underlying model.

**LibreOffice bridges capability gaps**. Native Python libraries can't recalculate Excel formulas. LibreOffice's macro integration fills this gap, enabling true spreadsheet operations rather than just data manipulation.

**Security requires active defense**. XML parsing vulnerabilities (XXE) are real. Using defusedxml instead of standard libraries prevents an entire class of attacks.

## What I Learned

**Progressive disclosure scales expertise**. Loading everything upfront wastes context. Loading nothing requires users to specify what they need. Progressive disclosure finds the balance—metadata triggers detailed loading automatically.

**Format expertise is valuable**. Office file formats are complex. Skills that handle this complexity reliably save hours of manual work and debugging.

**Bundled scripts enable actions**. Knowledge alone isn't enough; Claude needs executable capabilities. Scripts bridge the gap between understanding and doing.

**Quality assurance must be automated**. Formula errors, formatting issues, and structural problems are easy to introduce and hard to spot. Validation scripts catch issues before users do.

**Meta-skills accelerate growth**. A skill for creating skills means the framework improves through use. Each new skill becomes available for future conversations.

The Anthropic Skills Framework demonstrates that AI capability isn't just about model size or training data. It's about modular expertise—domain knowledge packaged for efficient loading and reliable execution. Skills transform Claude from knowing about things to doing things.
