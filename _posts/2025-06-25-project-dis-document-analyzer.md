---
layout: post
title: "Two Paths to Document Analysis: Local vs Cloud"
subtitle: "Building a dual-mode PDF analyzer with spaCy, BART, and OpenAI"
date: 2025-06-25
---

When I started building Project Dis, I had a simple question: should document analysis run locally or in the cloud? The answer turned out to be "both," and the project became an exploration of two fundamentally different approaches to the same problem.

## The Same Goal, Different Paths

Both the CLI and web interface extract text from PDFs, identify named entities, detect mathematical expressions, and generate summaries. But they do it completely differently.

The CLI uses local models. PyMuPDF for text extraction, spaCy's `en_core_web_sm` for NER, Facebook's BART (`bart-large-cnn`) for summarization. Everything runs on your machine. No API keys, no network calls, no ongoing costs.

The web API uses OpenAI. Same PDF extraction, but NER and summarization happen through GPT-3.5-turbo. The prompt asks for structured output: summary in 100-150 words, mathematical expressions, named entities categorized by type.

## The Tradeoffs

Local processing offers privacy and predictability. Your documents never leave your machine. Costs are fixed—download the models once, run forever. But you need compute resources, and the models are heavier to set up.

Cloud processing offers simplicity and capability. No model downloads, minimal local compute. GPT-3.5-turbo can handle edge cases that BART struggles with. But you're sending documents to an external API, paying per token, and dependent on network availability.

Neither is strictly better. The right choice depends on your constraints.

## Mathematical Expression Detection

One surprisingly complex feature is detecting mathematical expressions. Academic PDFs often contain LaTeX notation: inline math like `$x^2$`, display equations like `$$\sum_{i=1}^n$$`, or environment blocks like `\begin{equation}`.

The regex pattern `(\${1,2})((?:\\.|[^\$])*)\1` handles the first two cases elegantly. It captures single or double dollar signs, then everything between them (accounting for escaped characters), then the matching delimiters.

This works well for papers that use standard LaTeX conventions. It fails for scanned documents, alternative notation, or equations in images. But for the 80% case—machine-generated PDFs with proper markup—it's robust.

## The FastAPI Backend

The web interface uses FastAPI, which has become my default for Python APIs. The async support matters for file uploads—you don't want synchronous processing blocking other requests while a large PDF analyzes.

The upload endpoint saves to `/tmp/`, processes, and returns results. Temporary file storage means automatic cleanup, though production would need more careful lifecycle management.

One nice FastAPI feature: automatic OpenAPI documentation. The `/docs` endpoint gives you an interactive API explorer without writing any documentation code.

## Entity Visualization

The CLI outputs NER results as an HTML visualization. SpaCy's `displacy.render()` produces colored spans showing entity boundaries and types. It's a simple addition, but having visual output makes debugging and verification much easier.

The web interface returns entities as structured JSON instead, letting the frontend render them however it wants. Different outputs for different contexts.

## Docker Deployment

The Dockerfile captures everything needed to run the local version: Python dependencies, spaCy model download, entry point configuration. This matters because ML model setup is notoriously finicky—version mismatches, missing libraries, GPU driver issues.

A working Docker image means anyone can run the tool without fighting dependency hell. It's extra effort upfront that saves significant frustration downstream.

## What I Learned

Building both paths taught me that the "AI" part is often the easy part. PDF extraction, file handling, result formatting, error handling, deployment—these "boring" problems consume most of the development time.

The models themselves are increasingly commoditized. Whether you use BART or GPT-3.5 for summarization, the results are reasonable. What differentiates tools is the surrounding infrastructure: how easily users can get documents in, how clearly results are presented, how reliably the system handles edge cases.

Project Dis isn't production software. The API key is hardcoded (placeholder, but still), error handling is minimal, there's no authentication. But as an exploration of two architectural approaches to the same problem, it clarified my thinking about when to choose local versus cloud processing for ML tasks.
