---
layout: post
title: "PodScribe: Building a Local-First Podcast Notes Generator"
subtitle: "How I combined Parakeet MLX transcription with GPT-4o-mini to create a privacy-respecting podcast processing pipeline"
date: 2026-01-24
---

There's something deeply satisfying about building tools that keep your data local. When I set out to create PodScribe—an AI-powered podcast show notes generator—I made a deliberate choice: transcription would happen entirely on my machine, with only the final text leaving for AI processing. The result? A system that costs about $0.01-0.03 per episode while keeping audio files private.

## The Problem: Podcast Notes Are Tedious

If you've ever tried to create comprehensive show notes for a podcast episode, you know the pain. Listen to an hour of content, timestamp key moments, write a summary, pull social-friendly quotes, suggest SEO-optimized titles. It's easily 2-3 hours of work per episode.

Cloud transcription services solve part of this—but they're expensive, require uploading your audio to third-party servers, and still leave you with raw transcripts that need manual processing. I wanted something different: a pipeline where audio never leaves my machine, but I still get polished, publication-ready content.

## The Architecture: Two Layers of Intelligence

PodScribe operates in two distinct phases. Think of it like a relay race—local transcription hands off to cloud generation.

**Phase 1: Local Transcription (Parakeet MLX)**

The first phase uses NVIDIA's Parakeet TDT 0.6B model, optimized for Apple Silicon through MLX. This was a game-changer—transcription runs 30x faster than real-time on an M-series Mac. A 60-minute podcast transcribes in about 2 minutes.

The key insight was handling long audio gracefully. Podcasts often run 1-2 hours, which can overwhelm memory if processed as a single chunk. My solution: intelligent chunking.

```python
CHUNK_DURATION_SECONDS = 300  # 5 minutes per chunk
MAX_DURATION_WITHOUT_CHUNKING = 600  # 10 minutes threshold

def transcribe_audio(file_path: str) -> dict:
    duration = get_audio_duration(file_path)

    if duration <= MAX_DURATION_WITHOUT_CHUNKING:
        return transcribe_single_file(file_path)

    # Chunk processing for long files
    chunks = split_audio_into_chunks(file_path, CHUNK_DURATION_SECONDS)
    results = []
    for i, chunk_path in enumerate(chunks):
        print_status(f"Transcribing chunk {i+1}/{len(chunks)}...")
        result = transcribe_single_file(chunk_path)
        results.append(result)

    return merge_transcription_results(results)
```

Files under 10 minutes process directly. Longer files get split into 5-minute chunks, transcribed sequentially, then merged with proper timestamp alignment. This approach keeps memory usage constant regardless of podcast length.

**Phase 2: AI Content Generation (GPT-4o-mini)**

Once I have a transcript, GPT-4o-mini transforms it into structured content. The prompt engineering here was crucial—I needed consistent, parseable output across diverse podcast topics.

```python
def generate_content(transcript: str) -> dict:
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": CONTENT_GENERATION_PROMPT},
            {"role": "user", "content": f"Generate content for:\n\n{transcript}"}
        ],
        response_format={"type": "json_object"}
    )
    return json.loads(response.choices[0].message.content)
```

The `response_format={"type": "json_object"}` parameter ensures I always get valid JSON back—no regex parsing of prose responses. The AI returns a structured object with summary, show_notes, timestamps, blog_post, social_quotes, title_suggestions, and tags.

## The Dual-Model Fallback Pattern

Real-world systems need graceful degradation. Not everyone has Parakeet installed, and even when available, edge cases can cause failures. PodScribe implements a fallback chain:

```python
if PARAKEET_AVAILABLE:
    try:
        model = get_parakeet_model()
        result = model.transcribe(file_path)
        return {
            "text": result.text,
            "segments": segments,
            "model": "parakeet-tdt-0.6b-v2"
        }
    except Exception as e:
        print_status(f"⚠️ Parakeet failed: {e}, trying Whisper...", "yellow")

if WHISPER_AVAILABLE:
    result = mlx_whisper.transcribe(
        file_path,
        path_or_hf_repo="mlx-community/whisper-large-v3-turbo"
    )
    return {"text": result["text"], "model": "whisper-large-v3-turbo"}
```

Parakeet is preferred for speed, but MLX-Whisper serves as a capable backup. The system tracks which model processed each file, useful for debugging quality issues.

## Two Interfaces: CLI and Web

PodScribe ships with dual interfaces for different workflows.

**The CLI Tool** (`podscribe.py`) is perfect for batch processing or scripting. Drop it into a cron job or shell script:

```bash
python podscribe.py episode.mp3 --output ./notes/
```

**The Web Server** (`server.py`) provides a drag-and-drop interface for occasional use. This was where I invested the most design effort—following Dieter Rams' principle of "less, but better."

The entire UI lives in a single Python file. No separate HTML templates, no CSS files, no JavaScript bundles. Everything is inline, making deployment trivial:

```python
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <style>
        :root {
            --bg-primary: #0a0a0a;
            --bg-secondary: #141414;
            --accent: #6366f1;
        }
        /* Linear/Spotify-inspired dark theme */
    </style>
</head>
<body>
    <div class="drop-zone" id="dropZone">
        <p>Drop your podcast here</p>
    </div>
    <script>
        // Drag-drop handling + progress UI
    </script>
</body>
</html>
"""
```

The aesthetic draws from Linear and Spotify—dark backgrounds, subtle gradients, indigo accents. The drop zone pulses gently while processing, and results render in collapsible sections for each content type.

## Lessons from the Trenches

**Chunking granularity matters.** My first implementation used 10-minute chunks, which occasionally caused memory pressure on longer models. Dropping to 5 minutes added minimal overhead while ensuring stability across all hardware configurations.

**Inline everything for simple deployments.** Separating HTML, CSS, and JavaScript feels "cleaner" but creates deployment complexity. For single-purpose tools, a monolithic server file is actually easier to maintain and share.

**JSON mode is underrated.** Before using `response_format={"type": "json_object"}`, I spent hours crafting prompts that would produce parseable output. The structured response mode eliminated an entire class of bugs.

**Track your models.** Including the transcription model in output metadata saved me hours of debugging. When a transcript seemed off, I could immediately check whether Parakeet or Whisper processed it.

## The Economics

At ~$0.01-0.03 per episode (just the GPT-4o-mini call for content generation), PodScribe costs less than a single cup of coffee to process a month's worth of podcasts. The transcription is free—it runs locally on your hardware.

Compare this to commercial podcast transcription services charging $0.10-0.25 per minute. A 60-minute episode at $0.15/minute costs $9. PodScribe does the same job—plus generates all the derivative content—for roughly $0.02.

## What I'd Do Differently

If I were starting over, I'd add speaker diarization. Knowing who said what transforms podcast notes from a wall of text into a readable conversation. Parakeet supports this, but I haven't integrated it yet.

I'd also consider streaming the transcription results. Currently, users wait for full transcription before seeing any output. Progressive display would improve perceived performance for longer files.

Finally, a proper queue system would enable batch processing through the web interface. Right now, it's one file at a time—fine for personal use, limiting for production workflows.

PodScribe represents a pattern I keep returning to: local processing where privacy matters, cloud AI where intelligence is needed, and thoughtful interface design throughout. The podcast notes themselves are useful, but the architecture is the real product—a template for privacy-respecting AI tools.
