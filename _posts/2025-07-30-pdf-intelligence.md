---
layout: post
title: "PDF Intelligence: Extracting Meaning from Documents"
subtitle: "Combining OCR, NLP, and LLMs for comprehensive document analysis"
date: 2025-07-30
---

PDFs are everywhere—contracts, research papers, invoices, reports. But they're notoriously difficult to work with programmatically. PDF Intelligence is my attempt at comprehensive document analysis: extract text, find mathematical expressions, identify entities, and generate summaries, all through a unified interface.

## The Extraction Challenge

PDFs weren't designed for content extraction. They're designed for precise visual rendering. A PDF knows where every character goes on the page, but it doesn't necessarily know what a "paragraph" is or where a "table" starts.

PyMuPDF (fitz) handles extraction better than most alternatives because it preserves layout information. When I extract text, I get page numbers and rough positioning, not just a blob of characters. This matters when correlating mathematical expressions with their context or when highlighting entities back in the original document.

## Mathematical Expression Detection

Finding math in documents combines regex patterns with domain knowledge. Simple cases—arithmetic, basic algebra—are straightforward. Complex cases—LaTeX notation, integral symbols, multi-line equations—require layered pattern matching.

I implemented ten distinct regex patterns covering LaTeX inline and display math, mathematical symbols (∫, ∑, √, π, ∞), function notation (sin, cos, log), and basic arithmetic. The patterns are ordered by specificity; later patterns catch what earlier ones miss.

Duplicates are common—the same expression might match multiple patterns. I deduplicate while preserving order, since order often reflects document structure.

## Named Entity Recognition

SpaCy's en_core_web_sm model extracts fifteen entity types: people, organizations, locations, dates, monetary amounts, and more. For documents, this creates a structured index of everything mentioned.

The challenge is scale. A 200-page PDF might have a million characters. SpaCy handles this, but processing time matters. I truncate at one million characters and warn users when truncation occurs.

Entities are grouped by type and deduplicated. A document mentioning "Apple" fifty times should report one "ORG: Apple" with context about how it's used, not fifty identical entries.

## The Summarization Pipeline

Summarization uses a three-tier fallback strategy:

**Primary**: OpenAI's GPT-3.5-Turbo via LangChain when an API key is available. This produces the best summaries—coherent, appropriately scoped, genuinely useful.

**Secondary**: Facebook's BART-large-CNN transformer model. This runs locally, produces reasonable summaries, but lacks the contextual understanding of GPT.

**Tertiary**: Basic extractive summarization—literally the first three sentences. It's crude but never fails.

This layered approach means the system always produces something useful, degrading gracefully when resources are unavailable.

## OCR for Images

Documents often contain mathematical expressions as images rather than text. A scanned paper, a screenshot embedded in a report, a hand-drawn diagram—these need different treatment.

I implemented dual-engine OCR: Tesseract and EasyOCR working together. The image preprocessing pipeline includes grayscale conversion, Gaussian blur for noise reduction, binary thresholding with Otsu's method, and morphological operations. Small images are upscaled for better recognition.

Both engines run on each image, and results are merged with confidence scores. When Tesseract and EasyOCR agree, confidence is high. When they disagree, the higher-confidence result wins but with appropriate uncertainty.

## The Visualization Layer

Analysis results are more useful when you can see them in context. The visualization system highlights entities and mathematical expressions directly on the PDF pages, using sixteen distinct colors for different entity types.

Accompanying the highlighted PDF are charts: entity distribution bar graphs, mathematical expression summaries, and analysis dashboards. These provide at-a-glance understanding before diving into details.

## Three Interfaces, One Engine

The core analyzer powers three interfaces:

**CLI** with argparse for scripted workflows: `python -m src.cli analyze document.pdf --visualize --ocr-math`

**REST API** with FastAPI for integration into larger systems: POST to `/analyze` with a file upload

**Python module** for embedding in other code: `from src import PDFAnalyzer`

The same analysis engine, the same configuration options, three deployment patterns. Users choose what fits their workflow.

## What I Learned

PDF parsing is harder than it looks. Layout preservation, encoding handling, image extraction—each has edge cases that only appear with real documents.

Fallback strategies are essential for AI-powered tools. When the API is unavailable or rate-limited, having a local alternative keeps the system useful.

OCR accuracy varies wildly with image quality. The preprocessing pipeline matters more than the OCR engine choice. Clean input → good output.

Multi-format output (CLI, API, library) multiplies utility with minimal extra effort. Once the core logic is solid, exposing it through different interfaces is straightforward.

Document intelligence is genuinely useful. Finding every date in a contract, extracting all the equations from a textbook, summarizing a lengthy report—these are real problems that technology can meaningfully address.
