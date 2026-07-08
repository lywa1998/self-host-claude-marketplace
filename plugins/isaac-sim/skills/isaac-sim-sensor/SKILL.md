---
name: isaac-sim-sensor
description: >
  Replicator sensor suite: RGB/depth/seg/optical-flow, LiDAR, IMU, contact,
  ultrasonic, DR. Vendor LiDAR/radar/acoustic catalog (Ouster, Hesai, Velodyne,
  Robosense, SICK, Zvision, NVIDIA), USDA mount attachment, custom emitter-state
  scan-pattern authoring.
---

# Isaac Sim Sensors

> Source: `isaac-sim/IsaacSim/skills/isaac-sim-sensor/SKILL.md`
> https://github.com/isaac-sim/IsaacSim/blob/main/skills/isaac-sim-sensor/SKILL.md

## Overview

Replicator-based sensor suite for Isaac Sim. Covers:

- **Visual sensors**: RGB, depth, segmentation, optical flow
- **LiDAR sensors**: vendor LiDAR catalog (Ouster, Hesai, Velodyne, Robosense, SICK, Zvision, NVIDIA)
- **Physics sensors**: contact, IMU, raycast (see `isaac-sim-orchestrator` Part 6)
- **Other sensors**: ultrasonic, distance, Doppler radar
- **Sensor mounting**: USDA attachment pattern, custom emitter-state scan-patterns

## When to Use This Skill

- Adding sensors to a robot for data collection
- Setting up LiDAR with realistic vendor parameters
- Creating sensor pipelines for SLAM or perception
- Configuring Replicator sensors (RGB, depth, segmentation)

## Vendor LiDAR Catalog (supported configs)

Ouster, Hesai, Velodyne, Robosense, SICK, Zvision, NVIDIA — with custom emitter-state scan patterns.

For the complete sensor creation APIs, Replicator annotator setup, and USDA attachment patterns, refer to the source file above.
