---
name: usd-composition-architecture
description: >
  NVIDIA-style layered USD (root + physics + appearance payloads).
  Skip appearance for load-time optimization.
---

# USD Composition Architecture

> Source: `isaac-sim/IsaacSim/skills/usd-composition-architecture/SKILL.md`
> https://github.com/isaac-sim/IsaacSim/blob/main/skills/usd-composition-architecture/SKILL.md

## Overview

NVIDIA's layered USD composition pattern. Separates scene into independent layers:

- **Root layer** — stage topology, prim layout
- **Physics payload** — RigidBodyAPI, ArticulationRootAPI, collision shapes
- **Appearance payload** — materials, lights, shaders (optional, skipped for load-time optimization)

## When to Use This Skill

- Designing a layered USD asset for fast loading
- Separating physics and appearance concerns in a robot model
- Optimizing scene load times by skipping appearance payloads
- Implementing NVIDIA's recommended USD organization pattern

For the complete layer structure and optimization patterns, refer to the source file above.
