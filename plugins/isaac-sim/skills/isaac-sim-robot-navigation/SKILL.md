---
name: isaac-sim-robot-navigation
description: >
  Runtime navigation in custom scripts: RL policy, physics-vs-baked-vs-per-frame,
  GPU OOM avoidance, Kit 110 gotchas.
---

# Isaac Sim Robot Navigation

> Source: `isaac-sim/IsaacSim/skills/isaac-sim-robot-navigation/SKILL.md`
> https://github.com/isaac-sim/IsaacSim/blob/main/skills/isaac-sim-robot-navigation/SKILL.md

## Overview

Runtime navigation strategies for mobile robots in Isaac Sim scripts. Covers:

- **RL policy** — learned navigation policies
- **Navigation approaches**: physics-based, baked, per-frame
- **GPU memory management** — OOM avoidance strategies
- **Kit 110 specifics** — compatibility gotchas

## When to Use This Skill

- Implementing live navigation for a mobile robot
- Choosing between physics-based and baked navigation
- Debugging GPU memory issues with large-scale navigation
- Working with RL-trained navigation policies

## Integration Points

- RECEIVES from: `navigation-primitives` (A*, kinematics, footprint data)
- PRODUCES for: `isaac-sim-ros2-bridge` (Nav2 integration), `mobility-gen` (SDG)

For the complete navigation approach comparisons and GPU OOM mitigation strategies, refer to the source file above.
