---
name: navigation-primitives
description: >
  Shared substrate for mobile robot navigation: OccupancyMap, A* planner,
  robot footprints (Spot Z=0.69, Carter, VSVXL, Jetbot, Kaya, H1),
  differential/holonomic kinematics, look-at chase camera math. Read FIRST.
---

# Navigation Primitives

> Source: `isaac-sim/IsaacSim/skills/navigation-primitives/SKILL.md`
> https://github.com/isaac-sim/IsaacSim/blob/main/skills/navigation-primitives/SKILL.md

## Overview

The foundational building block for all mobile robot navigation in Isaac Sim. Contains:

- **OccupancyMap** — grid-based collision representation
- **A* path planner** — discrete path finding
- **Robot footprints** — Spot (Z=0.69), Nova Carter, VSVXL, Jetbot, Kaya, Unitree H1
- **Kinematics** — differential drive, holonomic, ackermann
- **Camera math** — look-at chase camera, overhead, aisle, wide view modes

## When to Use This Skill

- **FIRST** before any mobile robot work (as the SKILLS.md states)
- Setting up A* path planning for a robot
- Understanding kinematic models (differential vs holonomic)
- Designing chase camera behavior
- Validating robot footprint dimensions

## Robot Footprints (sample)

| Robot | Start Z | Wheel radius | Track width |
|---|---|---|---|
| Nova Carter | 0.0 | 0.14 m | 0.499 m |
| VSVXL | 0.0 | 0.15 m | 1.52 m |
| Spot | 0.75 | — | omni-wheel |

For the full A* planner implementation, kinematics equations, and chase camera math, refer to the source file above.
