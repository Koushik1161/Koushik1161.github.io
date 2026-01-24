---
layout: post
title: "10x Token Compression: Vision-Based Document Processing"
subtitle: "How optical compression achieves 97% accuracy at 10% of the cost"
date: 2025-07-10
---

Here's a problem I kept running into: processing long documents with LLMs is expensive. A 100-page PDF might contain 60,000-120,000 tokens of text. At current API prices, that's real money for each query—and traditional RAG systems often truncate to 4K tokens anyway, losing most of the document's context.

The insight that changed my approach: vision models have different token economics than text models. What if we converted documents to images and let the model "see" them instead of "read" them?

## The Compression Breakthrough

CompressChatOCR implements this idea using DeepSeek-OCR, a vision transformer that compresses document images into compact visual representations. The numbers are striking: a page of text that would require 12,000 tokens as raw text becomes 256 vision tokens as a compressed image. That's a 47x compression ratio.

But compression is worthless if it destroys information. The research behind DeepSeek-OCR shows 97% accuracy preservation at 10x compression, dropping to 60% at 20x. There's a sweet spot where you get dramatic cost savings without sacrificing answer quality.

## The Three-Mode Comparison

The system runs queries in two modes side by side. Traditional RAG takes the document text, truncates to 4,000 tokens (simulating real-world context limits), and sends to GPT-4. Optical compression converts pages to compressed images and sends the visual representation.

The results are illuminating. On a 50-page document, Traditional RAG sees maybe 20-30% of the content before hitting token limits. Optical compression sees everything—all 50 pages in a single API call. The answers reflect this: traditional gives partial, hedged responses while optical gives comprehensive, confident ones.

## The Technical Pipeline

The pipeline has four stages. PyMuPDF extracts pages as images at 200 DPI—a balance I tuned between quality and file size. Higher DPI didn't improve OCR accuracy but increased processing time and memory usage.

DeepSeek-OCR runs on GPU (RTX 4080 in my setup, requiring flash-attention 2 for memory efficiency). It supports five compression modes from "tiny" (64 tokens, fastest) to "gundam" (dynamic tiling for large documents). I defaulted to "base" (256 tokens per page) as the best tradeoff.

The compressed images go to OpenAI's vision endpoint. The model sees visual representations of each page and can reason about their contents. Finally, a metrics calculator tracks everything: original text tokens, vision tokens, compression ratio, actual costs.

## Cost Economics at Scale

For a single query, the savings might not seem dramatic—$0.010 traditional versus $0.0006 optical. But multiply by enterprise scale. If you're processing 100,000 queries monthly against a document corpus, that's the difference between $1,000 and $60. Annual savings approach $11,280 on that single use case.

The metrics dashboard breaks this down: cost per query, batch operation ROI, monthly projections. It's not just a demo—it's a business case calculator.

## The Image-as-Context Paradigm

What fascinated me about this project is the paradigm shift it represents. We've been treating documents as text to be tokenized. But documents are fundamentally visual artifacts: layouts, formatting, tables, diagrams. Converting to text loses structural information that the visual representation preserves.

There's something almost heretical about it. We spent years perfecting OCR to convert images to text. Now we're converting documents to images to bypass text tokenization entirely. But the economics and quality metrics don't lie: for many use cases, this approach is simply better.

## Hardware Requirements

This isn't a project you run on a laptop. DeepSeek-OCR needs a serious GPU—12GB VRAM minimum, 16GB recommended. The flash-attention compilation takes 5-10 minutes and can fail on some CUDA configurations. It's production-viable but requires investment in hardware or cloud GPU instances.

I documented the setup extensively because I hit every possible installation issue: Python version mismatches, CUDA driver problems, flash-attention build failures. The troubleshooting guide is as long as the feature documentation.

## What This Means for RAG

Traditional RAG systems are hitting a wall. You can only embed so many chunks, retrieve so many matches, and fit so many tokens in context. Optical compression offers a different path: instead of cleverly selecting which parts of documents to show the model, show it everything through efficient visual encoding.

I'm not saying this replaces traditional RAG for all use cases. Full-text search, semantic similarity, citation extraction—these still benefit from text-based approaches. But for question-answering against long documents, especially ones with complex layouts, optical compression is a genuine breakthrough.

The project includes everything needed to evaluate this yourself: upload a PDF, run queries both ways, see the results side by side with full cost breakdowns. The best arguments are empirical ones.
