---
name: isaac-sim-rendering
description: >
  Headless Kit 110 production rendering: SimulationApp + Replicator capture,
  RT2 vs PathTracing, ACES tone mapping (filmIso 200/400/600), multi-layer
  warehouse lighting, deep-aisle solutions, validation thresholds.
---

# Isaac Sim Rendering

> Source: `isaac-sim/IsaacSim/skills/isaac-sim-rendering/SKILL.md`
> https://github.com/isaac-sim/IsaacSim/blob/main/skills/isaac-sim-rendering/SKILL.md

## Overview

Headless production rendering with Isaac Sim Kit 110. Covers:

- **SimulationApp + Replicator capture** — rendering without UI
- **RT2 vs PathTracing** — real-time ray tracing vs offline path tracing
- **ACES tone mapping** — film ISO (200/400/600), exposure
- **Lighting** — multi-layer warehouse lighting (DomeLight, Fill SphereLights, RectLights)
- **Deep-aisle solutions** — lighting for narrow warehouse aisles
- **Validation thresholds** — rendering quality checks

## When to Use This Skill

- Setting up headless rendering for a warehouse scene
- Choosing between RT2 and PathTracing
- Debugging black frames or overexposed images
- Tuning lighting for a specific environment

## Key Lighting Settings

| Parameter | Value |
|---|---|
| filmISO | 100-120 (200 overexposes, 80 too dark in aisles) |
| DomeLight intensity | 150 |
| Fill SphereLights intensity | 1200, color (1.0, 0.95, 0.85) |

For the complete rendering pipeline, lighting recipes, and validation thresholds, refer to the source file above.
