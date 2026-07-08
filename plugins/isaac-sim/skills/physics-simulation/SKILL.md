---
name: physics-simulation
description: >
  Single source of truth for physics in Isaac Sim 6.0+ / Kit 110. Covers PhysicsScene
  config (gravity, Hz, CCD, stabilization, solver type), per-prim setup (RigidBodyAPI,
  MassAPI, CollisionAPI, kinematic bodies, joint drives), contact materials with
  friction/restitution reference tables, Newton solver selection (Featherstone, MuJoCo,
  XPBD, SemiImplicit, VBD) vs PhysX, physics sensors (contact, IMU, raycast),
  physics-to-USD readback (RigidPrim vs XformCache vs DC).
---

# Physics Simulation in Isaac Sim

> Source: `isaac-sim/IsaacSim/skills/physics-simulation/SKILL.md`
> Targets Isaac Sim 6.0+ / Kit 110.

## Backend selection (Kit 110)

The `isaacsim.physics.newton` extension defaults `auto_switch_on_startup = true`, so any app that enables it ends up with **Newton active** at startup.

```python
from isaacsim.core.simulation_manager import SimulationManager

SimulationManager.switch_physics_engine("newton")   # or "physx"
print(SimulationManager.get_active_physics_engine())
```

Force the engine explicitly when launching:

```bash
--/exts/isaacsim.core.simulation_manager/default_engine=newton     # or =physx
--/exts/isaacsim.physics.newton/auto_switch_on_startup=false        # opt out of auto-switch
```

### Newton Solvers

| Solver | Coordinates | Differentiable | Best For |
|---|---|---|---|
| **SolverFeatherstone** | Generalized | Yes (Warp) | Articulated robots (default) |
| **SolverMuJoCo** | Generalized | Yes (mujoco-warp) | Validated locomotion, MuJoCo policy ports |
| **SolverXPBD** | Maximal | Partial | Soft constraints, cables, ropes |
| **SolverSemiImplicit** | Maximal | Yes (Warp) | Fast prototyping, simple rigid bodies |
| **SolverVBD** | (deformable) | Yes | Soft bodies, deformables |

### Newton vs PhysX Differences

| Aspect | PhysX | Newton |
|---|---|---|
| Backend | Closed C++/CUDA | Warp/CUDA (open, JIT) |
| Coordinates | Maximal (6DoF per body) | Generalized or maximal |
| Differentiable | No | Yes (native Warp autodiff) |
| Multi-GPU | Limited | Yes (Warp device abstraction) |
| Performance ceiling | Good < 4096 envs | Designed for 10K+ envs |

**CRITICAL**: Never `import torch` before Newton physics settles — CUDA context conflict hangs Kit. Defer torch imports until after `timeline.play()` + settle loop.

---

## Part 1 — Scene-Level Configuration

### PhysicsScene Setup

```python
from pxr import UsdPhysics, PhysxSchema

ps = UsdPhysics.Scene.Define(stage, "/World/PhysicsScene")
ps.CreateGravityDirectionAttr().Set((0, 0, -1))
ps.CreateGravityMagnitudeAttr().Set(9.81)

px = PhysxSchema.PhysxSceneAPI.Apply(ps.GetPrim())
px.CreateTimeStepsPerSecondAttr().Set(240)
px.CreateEnableCCDAttr().Set(True)
px.CreateEnableStabilizationAttr().Set(True)
px.CreateSolverTypeAttr().Set("TGS")   # TGS preferred for articulations
```

### Physics Hz Selection

| Scenario | Hz | Notes |
|---|---|---|
| Standard rigid-body scenes | 60–120 | Default for warehouse, general sim |
| Stacking / contact-rich | 240 | Tight contact resolution |
| High-velocity impacts | 120 with 2–4 substeps | Pair with CCD |
| Small-part vibration (feeders) | ≥ 4× vibration freq, typically 480 | |
| Spinning bodies / gyros | 480 | Numerical precision for angular momentum |
| Stiff contact chains (cradles, escapements) | 480 | Solver needs many sub-iterations |

**Rule of thumb:** physics timestep must be > 4× the highest frequency in the system.

### Solver Iteration Counts (per-body)

Set on `PhysxRigidBodyAPI` per body that needs it.

| Scenario | Position iters | Velocity iters |
|---|---|---|
| Simple rigid bodies, tumbling | 16 | 4 |
| Stacking | 32 | 8 |
| Complex joints / articulations | 64 | 16 |
| Stiff contact chains (cradle, escapement) | 64 | 32 |

```python
pxrb = PhysxSchema.PhysxRigidBodyAPI.Apply(prim)
pxrb.CreateSolverPositionIterationCountAttr().Set(32)
pxrb.CreateSolverVelocityIterationCountAttr().Set(8)
```

### When to Disable Stabilization

Disable `EnableStabilizationAttr` for: spinning tops, gyros, flywheels, pendulum mechanisms, anything where angular momentum must be conserved.

---

## Part 2 — Per-Prim Physics Setup

### RigidBody / Collision / Static / Kinematic

```python
from pxr import UsdPhysics, Gf

def setup_dynamic_body(stage, prim_path, mass_kg=1.0, com_offset=None):
    """Movable, simulated body. RigidBodyAPI + CollisionAPI on the same prim."""
    prim = stage.GetPrimAtPath(prim_path)
    UsdPhysics.RigidBodyAPI.Apply(prim)
    mass_api = UsdPhysics.MassAPI.Apply(prim)
    mass_api.CreateMassAttr().Set(mass_kg)
    if com_offset:
        mass_api.CreateCenterOfMassAttr().Set(Gf.Vec3f(*com_offset))
    UsdPhysics.CollisionAPI.Apply(prim)
    return prim

def setup_static_collider(stage, prim_path):
    """Immovable terrain, walls, fixed obstacles."""
    prim = stage.GetPrimAtPath(prim_path)
    UsdPhysics.CollisionAPI.Apply(prim)
    return prim

def setup_kinematic_body(stage, prim_path):
    """Scripted motion: conveyors, elevators, vibrating bowls."""
    prim = stage.GetPrimAtPath(prim_path)
    UsdPhysics.RigidBodyAPI.Apply(prim)
    UsdPhysics.RigidBodyAPI(prim).CreateKinematicEnabledAttr().Set(True)
    UsdPhysics.CollisionAPI.Apply(prim)
    return prim
```

**Rule:** `RigidBodyAPI` + `CollisionAPI` on the **same prim**. Splitting them across parent/child causes intermittent collision failures.

### Contact Materials

| Material pairing | Static μ | Dynamic μ | Restitution |
|---|---|---|---|
| Concrete on concrete | 0.6 | 0.5 | 0.05 |
| Steel on steel | 0.74 | 0.57 | 0.6 |
| Rubber on rubber | 0.8 | 0.7 | 0.5 |
| Rubber on concrete | 1.0 | 0.8 | 0.3 |
| Wood on wood | 0.5 | 0.3 | 0.2 |
| Plastic (dice) | 0.4 | 0.3 | 0.3 |

### Joint Drives

```python
joint = stage.GetPrimAtPath("/World/Robot/joint_arm")
drive = UsdPhysics.DriveAPI.Apply(joint, "angular")    # "angular" | "linear"
drive.CreateTypeAttr().Set("force")                    # "force" | "acceleration"
drive.CreateStiffnessAttr().Set(1000.0)                # Kp (Nm/rad)
drive.CreateDampingAttr().Set(100.0)                   # Kd (Nm·s/rad)
drive.CreateMaxForceAttr().Set(500.0)                  # torque/force limit
drive.CreateTargetPositionAttr().Set(0.0)              # target
```

**For RL training**, set drive_type to `none` and stiffness/damping to 0. Active PD drives fight the RL agent.

---

## Part 5 — Physics Sensors

### Contact

```python
from isaacsim.sensors.experimental.physics import Contact, ContactSensor
import isaacsim.core.experimental.utils.app as app_utils

contact = Contact.create(
    path="/World/Robot/foot/contact",
    min_threshold=0.0, max_threshold=1e6, radius=-1,
)
sensor = ContactSensor(contact)
app_utils.play(commit=True)            # required before get_data()
reading = sensor.get_data()            # ContactSensorReading
```

### IMU

```python
from isaacsim.sensors.experimental.physics import IMU, IMUSensor

imu = IMU.create(path="/World/Robot/imu", tick_rate=200.0)
sensor = IMUSensor(imu, annotators=["linear_acceleration", "angular_velocity", "orientation"])
app_utils.play(commit=True)
frame = sensor.get_data()
```

### Effort / joint state

```python
from isaacsim.sensors.experimental.physics import EffortSensor, JointStateSensor

effort = EffortSensor("/World/Robot/joint_arm_1")
joint  = JointStateSensor("/World/Robot/joint_arm_1")
app_utils.play(commit=True)
reading = effort.get_data()
```

---

## Part 7 — Physics-to-USD Readback (CRITICAL)

The most common silent bug: reading authored USD transforms instead of simulated state.

| Source | Returns | When to use |
|---|---|---|
| `UsdGeom.XformCache.GetLocalToWorldTransform()` | **Authored** USD transform | Editor-time queries, before play |
| `RigidPrim.get_world_pose()` | **Simulated** state | Always during simulation |
| `Articulation.get_world_poses()` (Kit 110) | **Simulated** state | Articulated robots |

### RigidPrim pattern (Kit 110)

```python
from isaacsim.core.experimental.prims import RigidPrim
import isaacsim.core.experimental.utils.app as app_utils

rp = RigidPrim(paths="/World/Dice/Die_*")
app_utils.play(commit=True)
pos_wp, quat_wp = rp.get_world_poses()
positions  = pos_wp.numpy()              # (N, 3)
quaternions = quat_wp.numpy()            # (N, 4) [w, x, y, z]
```

### Quaternion Convention

USD/Isaac uses `[w, x, y, z]`; scipy uses `[x, y, z, w]`. Convert:

```python
from scipy.spatial.transform import Rotation
r = Rotation.from_quat([quat[1], quat[2], quat[3], quat[0]])
euler = r.as_euler('xyz', degrees=True)
```

---

## Common Gotchas

1. **`CollisionAPI` alone = static collider**; `RigidBodyAPI` + `CollisionAPI` = dynamic.
2. **Same-prim requirement**: both APIs must be on the **same prim**.
3. **Kinematic bodies**: use `CreateKinematicEnabledAttr().Set(True)`, not enable/disable on RigidBodyAPI.
4. **`Cube.size=1.0`** = half-extent 0.5. Use `size=2.0` if you want scale ops to equal half-extents.
5. **`physics:velocity` USD attributes are ignored** by PhysX at runtime. Use `RigidPrim.set_linear_velocities()` **after `timeline.play()`**.
6. **`physics:angularVelocity` is in DEGREES/second**, not rad/s. Convert with `math.degrees()`.
7. **Experimental sensors need `app_utils.play(commit=True)`** before `get_data()`.
8. **PhysX cannot resolve sequential momentum transfer** in same-island contact chains (cradles, escapements).
