---
name: manipulation-ik
description: >
  Differential IK (damped least-squares), grasp frames,
  FixedJoint grasping, hybrid IK + joint-space.
---

# Manipulation IK

> Source: `isaac-sim/IsaacSim/skills/manipulation-ik/SKILL.md`
> https://github.com/isaac-sim/IsaacSim/blob/main/skills/manipulation-ik/SKILL.md

## Overview

Inverse kinematics and grasping for robotic manipulators in Isaac Sim. Covers:

- **Damped least-squares (DLS) IK** — differential inverse kinematics solver
- **Grasp frames** — defining and attaching grasp poses
- **FixedJoint grasping** — simple but effective fixed-joint contact
- **Hybrid IK + joint-space** — combining IK for precision positioning with joint-space for large moves

## When to Use This Skill

- Implementing arm grasp and placement
- Setting up IK solvers for a manipulator robot
- Defining grasp frames for object interaction
- Working with arms that have < 6 DOF (hybrid IK + joint-space approach)

## Key Concept: Hybrid IK

For arms with limited DOF (< 6), pure differential IK cannot achieve lateral transport. Use hybrid approach:

1. **IK** for precision end-effector positioning
2. **Joint-space** moves for large-scale repositioning

For the complete DLS IK implementation and grasp frame patterns, refer to the source file above.
