---
name: data-collection-sim
description: >
  Static-scene Replicator SDG: BasicWriter, PoseWriter, KittiWriter.
  Sibling of mobility-gen (mobile-robot SDG).
---

# Data Collection Sim

> Source: `isaac-sim/IsaacSim/skills/data-collection-sim/SKILL.md`
> https://github.com/isaac-sim/IsaacSim/blob/main/skills/data-collection-sim/SKILL.md

## Overview

Static-scene synthetic data generation using Replicator. Covers:

- **BasicWriter** — raw image data writing
- **PoseWriter** — camera pose and object bounding boxes
- **KittiWriter** — KITTI format annotation (object detection)

## When to Use This Skill

- Generating static dataset images with annotations
- Creating labeled images for object detection training
- Producing pose data for SLAM evaluation
- Exporting data in KITTI format

For the complete Replicator pipeline and writer configuration, refer to the source file above.
