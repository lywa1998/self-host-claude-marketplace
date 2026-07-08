---
name: isaac-camera
description: >
  UsdGeomCamera setup, render products, intrinsics, AOVs,
  OpenCV/fisheye distortion.
---

# Isaac Camera

> Source: `isaac-sim/IsaacSim/skills/isaac-camera/SKILL.md`
> https://github.com/isaac-sim/IsaacSim/blob/main/skills/isaac-camera/SKILL.md

## Overview

UsdGeomCamera configuration and integration in Isaac Sim. Covers:

- **Camera setup** — creating and positioning `UsdGeomCamera` prims
- **Render products** — linking cameras to render pipelines
- **Intrinsics** — focal length, sensor width, field of view
- **AOVs (Arbitrary Output Variables)** — depth, normals, segmentation, motion vectors
- **Distortion** — OpenCV fisheye distortion model, lens profiles

## When to Use This Skill

- Setting up a new camera for rendering or perception
- Configuring camera intrinsics for a robot
- Adding AOVs to a render pipeline
- Applying lens distortion effects

For the complete camera setup procedures and distortion configuration, refer to the source file above.
