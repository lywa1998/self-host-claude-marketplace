---
name: mobility-gen
description: >
  Two-phase SDG: record trajectories (physics) → replay + render (sensors).
  Custom MobilityGenRobot subclassing.
---

# Mobility Gen

> Source: `isaac-sim/IsaacSim/skills/mobility-gen/SKILL.md`
> https://github.com/isaac-sim/IsaacSim/blob/main/skills/mobility-gen/SKILL.md

## Overview

Mobile robot synthetic data generation with a two-phase workflow:

1. **Record phase** — run physics-based simulation to record robot trajectories
2. **Replay phase** — replay trajectories while capturing sensor data (RGB, depth, LiDAR)

## When to Use This Skill

- Generating training data for mobile robot perception
- Creating labeled datasets for navigation
- Building sensor simulation pipelines
- Subclassing `MobilityGenRobot` for custom robots

## Workflow

```
Phase 1: Physics simulation → record joint positions, poses
Phase 2: Replay + render → capture sensor data with accurate timing
```

For the complete MobilityGenRobot subclassing guide and sensor replay patterns, refer to the source file above.
