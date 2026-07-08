---
name: isaac-sim-orchestrator
description: >
  Top-level dispatcher: turns a natural-language Isaac Sim request into a runnable
  simulation. Owns the env-var contract (`$ISAAC_SIM_DIR`, `$ISAAC_LAB_DIR`,
  `$WORKSPACE_DIR`, `$CIP_ROOT`), decomposes the task into capabilities, routes
  to specialist skills (`usd-pipeline`, `isaac-sim-rendering`,
  `isaac-sim-validator`, `physics-simulation`, `usd-composition-architecture`),
  and validates output before delivery.
  Use when (1) creating a sim scene with robots, objects, environments,
  (2) controlling robots in Isaac Sim, (3) generating renders or camera captures,
  (4) collecting Physical AI training data, (5) running headless sims on GPU,
  (6) orchestrating multi-robot fleets in warehouses.
---

# Isaac Sim Orchestrator

> Source: `isaac-sim/IsaacSim/skills/isaac-sim-orchestrator/SKILL.md`

## Environment contract

Every routed skill assumes these variables; set them in the agent config or shell:

| Variable | Purpose | Example |
|---|---|---|
| `$ISAAC_SIM_DIR` | Isaac Sim install root or built repo path | `$HOME/IsaacSim` or `<this-repo>/_build/linux-x86_64/release` |
| `$ISAAC_LAB_DIR` | Isaac Lab checkout | `$ISAAC_SIM_DIR/IsaacLab` |
| `$WORKSPACE_DIR` | Per-agent outputs, scratch, caches | `~/.cache/<repo>` or project-local path |
| `$CIP_ROOT` (Windows) | Content-pipeline install (CIP/WRAPP) | `C:\_Data` |

Run `nvidia-smi` at session start to size `num_envs` and pick RT2 vs PathTracing.

## Task decomposition

For any request, run all four phases. The specific steps inside each phase depend on the goal.

### Phase 1 — Verify foundations

**1a. Feature/skill mapping** (before any code):
- Cross-check the request against documented Isaac Sim features and APIs.
- For each capability, look up an existing skill. Skill exists -> load it. Skill missing -> build one inline, mark `status: draft`.
- Write the feature -> skill mapping into the task `WORKLOG.md` before 1b.

**1b. Foundation verification** (capability by capability):
- List every capability the task needs (assets, physics, robot control, sensors, rendering, ...).
- Verify each in isolation: does it load, does it behave correctly on its own.

### Phase 2 — Incremental integration

Combine verified foundations one at a time. Re-run stability/correctness checks after each addition.

### Phase 3 — Polish & deliver

- Validate output visually or programmatically.
- Add output-specific requirements (writers, annotations, video capture, DR).
- Package and hand off with a short summary.

### Phase 4 — Distill (mandatory)

- List iterations, failures, workarounds.
- Record user corrections.
- Classify each lesson: new skill, skill update, procedure fix, or `MEMORY.md` fact.
- Update the skill files; re-read to confirm a fresh agent can follow them.

## Sub-agent rules

- Each phase can run as a sub-agent with its own `WORKLOG.md`.
- Sub-agents commit at logical checkpoints, never half-done.
- Large script generation: write incrementally to files. Do not try to produce 200+ lines in one turn.

## Routed skills

| Skill | Use for |
|---|---|
| `usd-pipeline` | Asset insertion, scaling, materials, headless render compatibility |
| `usd-composition-architecture` | Layered USD assets (root + physics + appearance) |
| `isaac-sim-rendering` | Headless Kit 110 capture, RT2/PathTracing, ACES |
| `physics-simulation` | PhysicsScene config, per-prim setup, contact materials, Newton vs PhysX |
| `isaac-sim-validator` | Final QA gate before delivery |

## Multi-robot fleet reference

### Sample robots

| Robot | Start Z | Drive | Notes |
|---|---|---|---|
| Nova Carter | 0.0 | differential | wheel radius 0.14 m, track 0.499 m; damping 100K |
| VSVXL | 0.0 | differential | wheel radius 0.15 m, track 1.52 m |
| Spot | 0.75 | omni-wheel | bbox min Z = -0.69; needs ground clearance |
| FR3 | 0.0 | fixed-base | end-effector only, not mobile |

### Scene setup

- `sim_warehouse_v4.usda` pattern: `shell` + `lights` + `racks` + `PhysicsScene` + ground collision.
- Shell is in cm; robots and equipment in meters.

### PhysicsScene

```python
from pxr import UsdPhysics, PhysxSchema

physics_scene = UsdPhysics.Scene.Define(stage, "/World/PhysicsScene")
physics_scene.CreateGravityDirectionAttr().Set((0, 0, -1))
physics_scene.CreateGravityMagnitudeAttr().Set(9.81)

physx_scene = PhysxSchema.PhysxSceneAPI.Apply(physics_scene.GetPrim())
physx_scene.CreateEnableCCDAttr().Set(True)
physx_scene.CreateEnableStabilizationAttr().Set(True)
physx_scene.CreateSolverTypeAttr().Set("TGS")
physx_scene.CreateTimeStepsPerSecondAttr().Set(60)
physx_scene.CreateGpuMaxNumPartitionsAttr().Set(8)   # 10+ robots
```

### Scaling limits (by VRAM)

| Metric | 12 GB | 24 GB | 48 GB | 96 GB |
|---|---|---|---|---|
| Total prims | ~12K | ~25K | ~50K | ~100K |
| Robots | <= 2 | <= 5 | <= 10 | <= 20 |
| Active rigid bodies per robot | ~200 | ~200 | ~200 | ~200 |
| Articulations (multi-DOF) | <= 2 | <= 5 | <= 10 | <= 20 |
| Render resolution | 1280x720 | 1600x900 | 1920x1080 | 2560x1440 |

## Debug protocol — rendering

| Issue | Action |
|---|---|
| Black frame | DomeLight + DistantLight; force `settings.set("/rtx/rendermode", "RayTracedLighting")`; check `nvidia-smi` |
| Garbled color | ACES tonemap (`/rtx/post/tonemap/op=4`); `filmISO=600`; remove `PathTracing` |
| OOM crash | `pkill -f "kit/kit"`; clean `/dev/shm/carb-*`; reduce num_envs |

## Operating rules

- Never delete work folders; reuse and branch.
- Always save the `.usd` file; never assume it lives only in memory.
- Validate every render; never deliver black frames.
- Every long-running process must be killable.
- No bare `~/` in produced scripts; expand to `$HOME` or `$ENV_VAR`.
- `make_instanceable: true` for all RL robots.
- Call `simulation_app.update()` 5x after a camera switch.
- Never import torch before `timeline.play()`.
- Log GPU memory every epoch.
- Run `skill-distillation` (step 5) at task end. Capture lessons in the relevant SKILL.md.
