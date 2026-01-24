---
layout: post
title: "Navigating Without GPS: Visual Odometry from First Principles"
subtitle: "Building a computer vision system for when satellites aren't an option"
date: 2025-11-17
---

GPS is everywhere until it isn't. Underground tunnels, indoor spaces, urban canyons between tall buildings, GPS-jammed environments—there are plenty of scenarios where satellites can't help you. How do robots navigate when GPS goes dark?

Visual odometry. Use what you can see.

## The Core Idea: Track Your Movement Through Images

Imagine walking through a forest while taking photos. Each photo captures your view at that moment. By comparing consecutive photos, you can figure out how you moved between them. That's visual odometry in essence.

More formally: we detect distinctive features in images, match them across frames, and compute the camera's motion from those correspondences.

## Feature Detection: Finding Landmarks

The first step is identifying points in an image that are distinctive enough to track:

```python
import cv2

# ORB: Oriented FAST and Rotated BRIEF
orb = cv2.ORB_create(nfeatures=1000)

# Detect keypoints and compute descriptors
keypoints1, descriptors1 = orb.detectAndCompute(frame1, None)
keypoints2, descriptors2 = orb.detectAndCompute(frame2, None)
```

ORB finds corners, edges, and other visually distinctive points. Each keypoint gets a descriptor—a numerical fingerprint that describes what that point looks like. These descriptors let us recognize the same point in different images.

## Feature Matching: Connecting the Dots

With features detected, we match them across frames:

```python
# Brute force matcher
bf = cv2.BFMatcher(cv2.NORM_HAMMING, crossCheck=True)

# Match descriptors
matches = bf.match(descriptors1, descriptors2)

# Sort by quality (lower distance = better match)
matches = sorted(matches, key=lambda x: x.distance)

# Keep best matches
good_matches = matches[:50]
```

Each match tells us: "This point in frame 1 corresponds to this point in frame 2." With enough good matches, we can compute how the camera moved.

## Why This Matters

Visual odometry enables:

**Underground robotics**: Mining robots, sewer inspection drones, tunnel mapping—anywhere satellites can't reach.

**Indoor navigation**: Warehouses, factories, large buildings where GPS is unreliable or unavailable.

**GPS-denied operations**: Military applications, jamming-resistant systems, backup navigation.

**Space exploration**: Rovers on other planets navigate visually—Mars doesn't have GPS satellites.

## The TUM Dataset: Benchmarking Reality

I tested against the TUM dataset, a standard benchmark for visual odometry research. It provides:

- RGB images captured from a moving camera
- Ground truth poses (where the camera actually was)
- Challenging scenarios: motion blur, varying light, texture-less regions

```python
def evaluate_trajectory(estimated_poses, ground_truth):
    """Compare our estimates against reality"""
    errors = []
    for est, gt in zip(estimated_poses, ground_truth):
        translation_error = np.linalg.norm(est[:3] - gt[:3])
        errors.append(translation_error)

    return {
        'mean_error': np.mean(errors),
        'max_error': np.max(errors),
        'rmse': np.sqrt(np.mean(np.array(errors)**2))
    }
```

Benchmarking against ground truth is crucial. Without it, you're just hoping your system works.

## Challenges and Limitations

**This is the simple version.** Real visual odometry systems include:

- RANSAC for outlier rejection (bad matches happen)
- Bundle adjustment (optimize over many frames simultaneously)
- Loop closure detection (recognize when you've returned somewhere)
- Sensor fusion (combine vision with IMU, wheel encoders)

My implementation is deliberately minimal—a foundation to understand the concepts before adding complexity.

**Feature-poor environments are hard.** Blank walls, snow-covered fields, fog—anywhere without distinctive features breaks feature-based approaches. That's why production systems often use dense methods or learning-based approaches.

**Scale ambiguity.** A single camera can't know absolute scale. Moving 1 meter looks the same as moving 10 meters if all distances scale proportionally. You need either stereo cameras, IMU data, or known object sizes to recover true scale.

## What I Learned

**Start simple.** Frame-to-frame matching is the atom of visual odometry. Everything else builds on this foundation.

**Visualization is debugging.** Plotting matches and trajectories catches problems that raw numbers hide. Always visualize.

**Papers are aspirational, code is real.** Research papers report results on clean datasets with tuned parameters. Getting those results yourself requires more work than the papers suggest.

## Where This Goes

This project was a foundation—proof that I understand the basics. The next steps would be:

1. Add motion estimation from matched points (Essential matrix, decomposition)
2. Implement RANSAC for robust estimation
3. Build a sliding window optimizer
4. Integrate IMU for scale and drift correction

Visual odometry is a deep field. This was just breaking ground.

---

*Built with OpenCV, NumPy, and a healthy respect for how hard robotics actually is.*
