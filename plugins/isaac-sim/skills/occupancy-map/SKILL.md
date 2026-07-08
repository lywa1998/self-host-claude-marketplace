---
name: occupancy-map
description: >
  Generate ROS-compatible map.yaml from USD warehouses for Nav2 / MobilityGen / A*.
---

# Occupancy Map

> Source: `isaac-sim/IsaacSim/skills/occupancy-map/SKILL.md`
> https://github.com/isaac-sim/IsaacSim/blob/main/skills/occupancy-map/SKILL.md

## Overview

Generate ROS-compatible occupancy maps (`map.yaml`) from Isaac Sim USD warehouse environments. Produces grid maps suitable for:

- **Nav2** — ROS 2 Navigation2 stack
- **MobilityGen** — synthetic data generation for mobile robots
- **A*** — grid-based path planning

## When to Use This Skill

- Converting a warehouse USD environment to a ROS-compatible map
- Generating floor plans for robot navigation
- Preparing map files for Nav2 integration
- Creating input for MobilityGen trajectory generation

For the complete map generation procedure and grid parameter tuning, refer to the source file above.
