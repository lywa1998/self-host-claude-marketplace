---
name: usd-pipeline
description: >
  Asset discovery, bbox/shader measurement, placeholder-to-asset placement,
  headless render compatibility (MDL vs UsdPreviewSurface).
---

# USD Pipeline

> Source: `isaac-sim/IsaacSim/skills/usd-pipeline/SKILL.md`
> https://github.com/isaac-sim/IsaacSim/blob/main/skills/usd-pipeline/SKILL.md

## Overview

USD asset pipeline operations in Isaac Sim. Covers:

- **Asset discovery** — scanning directories for valid USD assets
- **Bounding box / shader measurement** — automated asset analysis
- **Placeholder-to-asset placement** — dynamic asset insertion
- **Headless render compatibility** — MDL vs UsdPreviewSurface material handling

## When to Use This Skill

- Building a pipeline to automatically discover and load USD assets
- Measuring asset bounding boxes for placement
- Converting assets for headless rendering compatibility
- Material pipeline optimization

For the complete asset discovery algorithms and MDL compatibility patterns, refer to the source file above.
