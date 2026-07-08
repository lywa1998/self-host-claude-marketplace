---
name: usd-articulation
description: >
  Multi-link / multi-arm articulation validation. ArticulationRootAPI,
  FixedJoint, flatten-before-deploy. Read after URDF conversion.
---

# USD Articulation

> Source: `isaac-sim/IsaacSim/skills/usd-articulation/SKILL.md`
> https://github.com/isaac-sim/IsaacSim/blob/main/skills/usd-articulation/SKILL.md

## Overview

Validate and assemble multi-link/multi-arm articulations for Isaac Sim. Ensures correct joint hierarchy, root API application, and flatten-before-deploy optimization.

## When to Use This Skill

- Validating a URDF-imported robot's joint structure
- Assembling multi-arm robots (e.g., dual-UR5, dual-KUKA)
- Applying `ArticulationRootAPI` to root prim
- Checking for incorrect `FixedJoint` usage
- Preparing assets for deployment with USD flattening

## Integration Points

- RECEIVES from: `urdf-mjcf-to-usd-conversion` (imported robot USD)
- PRODUCES for: `physics-simulation` (scene setup), `isaac-sim-orchestrator` (validated robot assets)

For the complete validation procedures, joint hierarchy checks, and deploy optimizations, refer to the source file above.
