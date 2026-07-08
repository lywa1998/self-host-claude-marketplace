---
name: profile-isaac-sim
description: >
  Profile and optimize Isaac Sim with the in-repo benchmark scripts
  and Tracy. Compare runs, diff frame times, isolate hot zones.
---

# Profile Isaac Sim

> Source: `isaac-sim/IsaacSim/skills/profile-isaac-sim/SKILL.md`
> https://github.com/isaac-sim/IsaacSim/blob/main/skills/profile-isaac-sim/SKILL.md

## Overview

Profiling and optimization for Isaac Sim using Tracy and in-repo benchmark scripts:

- **Tracy integration** — attach Tracy profiler to running Isaac Sim
- **Frame time analysis** — compare rendering performance across runs
- **Hot zone identification** — isolate rendering, physics, or simulation bottlenecks
- **Benchmark scripts** — standard workload for performance regression testing

## When to Use This Skill

- Diagnosing performance issues in Isaac Sim
- Optimizing a simulation for higher frame rate
- Comparing rendering performance between configurations
- Profile a specific simulation pipeline

For the complete Tracy attachment procedure and frame diff analysis, refer to the source file above.
