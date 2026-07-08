---
name: urdf-mjcf-to-usd-conversion
description: >
  URDF/MJCF → USD for Isaac Sim & Isaac Lab. config.yaml schema,
  make_instanceable, RL vs teleop drives, instanceable meshes.
  XACRO must be pre-expanded. Every new robot starts here.
---

# URDF/MJCF → USD Conversion

> Source: `isaac-sim/IsaacSim/skills/urdf-mjcf-to-usd-conversion/SKILL.md`
>
> Full documentation available in the Isaac Sim source repo at:
> https://github.com/isaac-sim/IsaacSim/blob/main/skills/urdf-mjcf-to-usd-conversion/SKILL.md

## Overview

Bring any robot from URDF/MJCF into Isaac Sim and Isaac Lab. The converter handles:

- URDF with XACRO (must be pre-expanded)
- MJCF models
- Configuration via `config.yaml` for RL vs teleop drives
- Instanceable mesh generation for efficient parallel environments

## When to Use This Skill

- Importing a new robot into Isaac Sim for the first time
- Converting URDF/MJCF to USD for simulation
- Setting up RL training assets with `make_instanceable: true`
- Configuring drive modes (RL torque commands vs teleop position commands)

## Key Concepts

### Config.yaml Schema

```yaml
# Key configuration options
make_instanceable: true    # CRITICAL for RL parallel envs (share mesh data)
fix_base: false            # true for fixed-base arm; false for mobile/legged
drive_type:
  - name: "all"            # apply to all joints
    type: "none"           # RL: none (direct torque); teleop: position/velocity
    stiffness: 0.0
    damping: 0.0
import_inertia_tensor: true  # use URDF inertia tensor (recommended)
```

### Drive Types

| Type | Use case | Description |
|---|---|---|
| `none` | RL training | Agent commands torques directly |
| `position` | Teleop / scripted | PD position control (stiffness/damping) |
| `velocity` | Teleop / scripted | Velocity control with limits |

### Workflow

1. Pre-expand XACRO macros into a single URDF
2. Write `config.yaml` with appropriate settings
3. Run the conversion command:
   ```bash
   python isaacsim_assets/scripts/urdf_to_usd.py \
     --urdf <path/to/robot.urdf> \
     --output <path/to/robot.usd>
   ```
4. Validate with `usd-articulation` skill

## Integration Points

- RECEIVES from: (raw URDF/MJCF files from robot manufacturer, URDF export tools)
- PRODUCES for: `usd-articulation` (validation), `physics-simulation` (joint drives), `isaac-sim-orchestrator` (scene composition)

For the complete reference, consult the source file linked above.
