---
name: isaac-sim-validator
description: >
  Final QA gate before delivery: rejects black frames, hardcoded user paths,
  deprecated omni.isaac.core imports, missing lights, mounting bugs.
---

# Isaac Sim Validator

> Source: `isaac-sim/IsaacSim/skills/isaac-sim-validator/SKILL.md`
> https://github.com/isaac-sim/IsaacSim/blob/main/skills/isaac-sim-validator/SKILL.md

## Overview

Quality assurance gate for all delivered content. Checks for:

- **Black frames** — missing lights in renders
- **Hardcoded user paths** — `~/` in scripts instead of `$HOME`
- **Deprecated imports** — `omni.isaac.core` should be `isaacsim.core`
- **Missing lights** — scenes without light sources
- **Mounting bugs** — incorrect prim attachments

## When to Use This Skill

- Final validation before delivering a simulation
- QA check for any rendered output
- Reviewing scripts for deprecated imports
- Ensuring scripts use environment variables

For the complete validation checks and error reporting, refer to the source file above.
