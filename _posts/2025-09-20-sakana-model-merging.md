---
layout: post
title: "Merging Intelligence: Combining Qwen and DeepSeek with SLERP"
subtitle: "Experimenting with model merging to create a reasoning-enhanced instruction model"
date: 2025-09-20
---

What if you could combine the best of two language models without training from scratch? Model merging has become a surprisingly effective technique for creating hybrid models that inherit capabilities from their parents. My Sakana project explores this through a specific combination: Qwen's instruction-following ability merged with DeepSeek's reasoning capabilities.

## The Hypothesis

The two models I'm merging have complementary strengths:

**Qwen2.5-7B-Instruct** excels at following instructions, maintaining conversation context, and producing helpful responses. It's a general-purpose assistant optimized for user interaction.

**DeepSeek-R1-Distill-Qwen-7B** is a distilled version of DeepSeek's larger reasoning model. It's specifically optimized for complex problem-solving, multi-step reasoning, and analytical tasks.

The hypothesis: merging them at a 50/50 ratio should produce a model that's both conversational AND capable of deeper reasoning. Cruz-reasoning-7b-v1 is the experiment.

## Why SLERP?

Model merging isn't simple averaging. Weights exist in high-dimensional space where linear interpolation can produce suboptimal results. SLERP (Spherical Linear Interpolation) addresses this by interpolating along the surface of a hypersphere rather than cutting through it.

Think of it like this: if you're traveling between two cities, linear interpolation goes straight through the mountain. SLERP follows the curve of the earth. For model weights, this preserves more of each model's learned structure.

With t=0.5, we're targeting the exact midpoint—equal contribution from both models. This is conservative; later experiments might favor one parent over the other.

## The MergeKit Configuration

The actual merge configuration is surprisingly simple:

```yaml
models:
  - model: Qwen/Qwen2.5-7B-Instruct
    parameters:
      weight: 0.5
  - model: deepseek-ai/DeepSeek-R1-Distill-Qwen-7B
    parameters:
      weight: 0.5
merge_method: slerp
base_model: Qwen/Qwen2.5-7B-Instruct
parameters:
  t: 0.5
dtype: bfloat16
```

Using bfloat16 for the output reduces storage requirements while maintaining reasonable precision. It's a practical choice for deployment on consumer hardware.

## Why These Specific Parents?

Both models share the Qwen architecture, which is essential for layer-wise merging. You can't merge a GPT with a LLaMA—the weight matrices don't align. But DeepSeek's distilled model was specifically trained on the Qwen base, making them merge-compatible.

The DeepSeek model is a distillation of their much larger R1 reasoning model. Distillation compresses the larger model's capabilities into a smaller package, often preserving surprising amounts of capability. By merging this distillate with the instruction-tuned Qwen, we're attempting to inject reasoning capabilities without losing conversational fluency.

## What I'm Watching For

The merged model should demonstrate:

1. **Maintained instruction-following**: Can it still follow complex multi-step instructions?
2. **Enhanced reasoning**: Does it show improved performance on reasoning benchmarks?
3. **Coherence**: Does the merge produce coherent outputs, or are there "seams" where the models conflict?
4. **Novel capabilities**: Does the combination enable anything neither parent could do alone?

The risks are real too. Merged models can exhibit capability degradation, output instability, or strange behavioral artifacts. Not all merges work, and there's no guarantee this one will.

## The Broader Context

Model merging has become a significant technique in the open-source LLM community. The Hugging Face leaderboards include merged models alongside trained ones. Some merges outperform their parents on benchmarks, though the reasons aren't always clear.

What makes this interesting is the efficiency. Training a 7B model from scratch costs significant compute. Merging two existing models takes hours and standard hardware. If the result inherits even a fraction of both parents' capabilities, the ROI is remarkable.

## Next Steps

Phase 1 is configuration. The merge hasn't run yet—the output directory is empty. Running the merge requires downloading both parent models and executing the merge operation.

Phase 2 will be evaluation: running the merged model through benchmarks, testing conversational quality, and probing for reasoning improvements.

Phase 3, if the results are promising, might explore different interpolation weights. Maybe 60/40 favoring reasoning. Maybe 70/30 favoring instruction-following. The configuration space is large.

This is experimental work with uncertain outcomes. But that's the nature of exploring the frontiers of what's possible with language models. Sometimes you find gold; sometimes you find mud. Either way, you learn something.
