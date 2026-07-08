# Isaac Sim Skills Index

This plugin is a curated collection of skills from [isaac-sim/IsaacSim](https://github.com/isaac-sim/IsaacSim), the open-source NVIDIA Isaac Sim repository. Skills are organized by the same capability hierarchy as the source repo.

**Source of truth:** All skills reference `isaac-sim/IsaacSim/skills/<skill>/SKILL.md`. The content in this plugin is either:
- A complete copy of the source SKILL.md (for core skills: orchestrator, remote, physics-simulation, meta-skills, skill-distillation)
- An index SKILL.md that points back to the original file for further reading

## Quick index

| Layer | Purpose |
|---|---|
| **Foundations & operating loop** | Orchestrator, meta-skills, distillation, validator, troubleshooting |
| **Robot asset pipeline** | URDF/MJCF → USD, articulation validation |
| **Physics simulation** | PhysX, Newton, contact, joints, sensors |
| **Mobile robot navigation** | Primitives, occupancy maps, runtime nav, SDG |
| **Manipulation** | IK + grasp |
| **Sensors & perception** | Camera, LiDAR, IMU |
| **Synthetic data generation** | Replicator, MobilityGen |
| **Rendering & lighting** | RT2 production rendering, headless deployment |
| **USD pipeline** | Composition, scaling, material binding |
| **ROS 2 integration** | Nav2, multi-robot bridges |

## Skill reading order

Read in this order for new robotics-sim sessions:

| # | Skill | What it gives you |
|---|---|---|
| 1 | [isaac-sim-orchestrator](isaac-sim-orchestrator/SKILL.md) | Top-level dispatcher; declares the env-var contract |
| 2 | [meta-skills](meta-skills/SKILL.md) | Composition patterns, MSF five phases, SKILL.md template |
| 3 | [skill-distillation](skill-distillation/SKILL.md) | Step 5 of every request loop — capture lessons |
| 4 | [isaac-sim-remote](isaac-sim-remote/SKILL.md) | Remote control via python_server TCP socket |
| 5 | [physics-simulation](physics-simulation/SKILL.md) | Single source of truth for physics scene + per-prim setup |
| 6 | [urdf-mjcf-to-usd-conversion](urdf-mjcf-to-usd-conversion/SKILL.md) | URDF/MJCF → USD for Isaac Sim (source: isaac-sim/IsaacSim/skills/urdf-mjcf-to-usd-conversion/SKILL.md) |
| 7 | [usd-articulation](usd-articulation/SKILL.md) | Multi-link/multi-arm articulation validation (source: isaac-sim/IsaacSim/skills/usd-articulation/SKILL.md) |
| 8 | [navigation-primitives](navigation-primitives/SKILL.md) | Shared substrate for all mobile-robot work (source: isaac-sim/IsaacSim/skills/navigation-primitives/SKILL.md) |
| 9 | [manipulation-ik](manipulation-ik/SKILL.md) | Differential IK, grasp frames, FixedJoint grasping (source: isaac-sim/IsaacSim/skills/manipulation-ik/SKILL.md) |
| 10 | [isaac-sim-sensor](isaac-sim-sensor/SKILL.md) | Sensor primitives for SDG; vendor LiDAR/radar/acoustic catalog (source: isaac-sim/IsaacSim/skills/isaac-sim-sensor/SKILL.md) |
| 11 | [isaac-camera](isaac-camera/SKILL.md) | UsdGeomCamera setup, intrinsics, AOVs, distortion (source: isaac-sim/IsaacSim/skills/isaac-camera/SKILL.md) |
| 12 | [isaac-sim-rendering](isaac-sim-rendering/SKILL.md) | Headless Kit 110 production rendering (source: isaac-sim/IsaacSim/skills/isaac-sim-rendering/SKILL.md) |
| 13 | [isaac-sim-headless-deployment](isaac-sim-headless-deployment/SKILL.md) | --no-window launch modes, SimulationApp batch pattern (source: isaac-sim/IsaacSim/skills/isaac-sim-headless-deployment/SKILL.md) |
| 14 | [spatial-reasoning](spatial-reasoning/SKILL.md) | Transform math cornerstone (source: isaac-sim/IsaacSim/skills/spatial-reasoning/SKILL.md) |
| 15 | [usd-pipeline](usd-pipeline/SKILL.md) | USD asset discovery, bbox/shader measurement, headless compatibility (source: isaac-sim/IsaacSim/skills/usd-pipeline/SKILL.md) |
| 16 | [isaac-sim-robot-navigation](isaac-sim-robot-navigation/SKILL.md) | Runtime navigation in your own scripts (source: isaac-sim/IsaacSim/skills/isaac-sim-robot-navigation/SKILL.md) |
| 17 | [data-collection-sim](data-collection-sim/SKILL.md) | Static-scene Replicator SDG (source: isaac-sim/IsaacSim/skills/data-collection-sim/SKILL.md) |
| 18 | [mobility-gen](mobility-gen/SKILL.md) | Mobile-robot SDG (record → replay + render) (source: isaac-sim/IsaacSim/skills/mobility-gen/SKILL.md) |
| 19 | [isaac-sim-ros2-bridge](isaac-sim-ros2-bridge/SKILL.md) | OmniGraph ROS 2 nodes, Nav2 integration (source: isaac-sim/IsaacSim/skills/isaac-sim-ros2-bridge/SKILL.md) |
| 20 | [usd-composition-architecture](usd-composition-architecture/SKILL.md) | NVIDIA's layered USD pattern (source: isaac-sim/IsaacSim/skills/usd-composition-architecture/SKILL.md) |
| 21 | [occupancy-map](occupancy-map/SKILL.md) | Generate ROS-compatible occupancy maps from USD warehouses (source: isaac-sim/IsaacSim/skills/occupancy-map/SKILL.md) |
| 22 | [isaac-sim-validator](isaac-sim-validator/SKILL.md) | Final QA gate before delivery (source: isaac-sim/IsaacSim/skills/isaac-sim-validator/SKILL.md) |
| 23 | [isaac-sim-troubleshooting](isaac-sim-troubleshooting/SKILL.md) | Kit 110 hang/freeze/perf reference (source: isaac-sim/IsaacSim/skills/isaac-sim-troubleshooting/SKILL.md) |
| 24 | [validation-diff-gifs](validation-diff-gifs/SKILL.md) | Pixel-diff GIFs comparing validation against golden data (source: isaac-sim/IsaacSim/skills/validation-diff-gifs/SKILL.md) |
| 25 | [profile-isaac-sim](profile-isaac-sim/SKILL.md) | Profile and optimize with Tracy (source: isaac-sim/IsaacSim/skills/profile-isaac-sim/SKILL.md) |

## Pipeline diagrams

### Core robotics simulation pipeline

```
URDF / MJCF / CAD source
       │
       ▼
urdf-mjcf-to-usd-conversion
       │
       ▼
usd-articulation        ◄──── usd-composition-architecture
(validate joints)              (root + physics + appearance layers)
       │
       ▼
physics-simulation
       │
       ▼
isaac-sim-orchestrator    →    isaac-sim-sensor
       │
       ▼
       data-collection-sim (SDG)
                │
                ▼
        mobility-gen (mobile-robot variant)
```

### Mobile robot navigation

```
                       navigation-primitives
                  (omap, A*, kinematics, robot footprints, camera math)
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
   isaac-sim-robot-navigation         mobility-gen
   (live RL/baked/per-frame nav)      (record → replay SDG)
              │                               │
              └───────────────┬───────────────┘
                              ▼
              occupancy-map (map.yaml)
                              │
                              ▼
              isaac-sim-ros2-bridge (Nav2 integration)
```

### Rendering & validation pipeline

```
isaac-sim-rendering (RT2 + ACES production)
       │
       ▼
isaac-sim-validator (final QA gate)
```

## Environment variables

All skills assume these shell variables (set in your agent config or shell profile):

| Variable | Purpose | Example |
|---|---|---|
| `$ISAAC_SIM_DIR` | Isaac Sim install root or built repo path | `$HOME/IsaacSim` or `<this-repo>/_build/linux-x86_64/release` |
| `$ISAAC_LAB_DIR` | Isaac Lab checkout root | `$ISAAC_SIM_DIR/IsaacLab` |
| `$WORKSPACE_DIR` | Per-agent workspace (outputs, scratch, caches) | `~/.cache/<repo>` |
| `$CIP_ROOT` (Windows) | Content-pipeline install | `C:\_Data` |

## When stuck

- [isaac-sim-troubleshooting](isaac-sim-troubleshooting/SKILL.md) — Kit 110 hang / freeze / perf issues
- [isaac-sim-validator](isaac-sim-validator/SKILL.md) — refuses bad deliverables before they reach the user

## How to navigate

- **Starting a new sim task?** → meta-skills → isaac-sim-orchestrator → match capability to the category tables above.
- **Bringing in a new robot?** → URDF/MJCF → usd-articulation → physics-simulation.
- **Generating synthetic data?** → data-collection-sim or mobility-gen.
- **Rendering?** → isaac-sim-rendering.
- **Stuck?** → isaac-sim-troubleshooting.
