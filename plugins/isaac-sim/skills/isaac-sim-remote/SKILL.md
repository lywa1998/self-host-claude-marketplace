---
name: isaac-sim-remote
description: >
  Connect to a running Isaac Sim via the `isaacsim.code_editor.python_server`
  TCP socket (port 8226) to execute Python remotely. Launch Isaac Sim, send
  code, create/modify USD stages, run simulations, take viewport or full-app
  screenshots, inspect/modify prims, control the camera, step physics, read
  console logs, execute Kit commands. Works in `--no-window` headless mode.
---

# Isaac Sim Remote

> Source: `isaac-sim/IsaacSim/skills/isaac-sim-remote/SKILL.md`

Execute Python inside a running Isaac Sim via the `isaacsim.code_editor.python_server` TCP socket.

## Launching Isaac Sim

```bash
cd _build/linux-x86_64/release

# Headless — supports all features: code execution, viewport screenshots,
# full-app screenshots, menu clicks, and widget interaction
bash isaac-sim.sh --no-window --no-ros-env \
    --enable isaacsim.code_editor.python_server

# With display (optional — only needed if you want to visually observe the UI)
DISPLAY=:99 bash isaac-sim.sh --no-ros-env \
    --enable isaacsim.code_editor.python_server

# With --reset-user to clear persistent user settings (recommended for clean state)
DISPLAY=:99 bash isaac-sim.sh --reset-user --no-ros-env \
    --enable isaacsim.code_editor.python_server
```

Wait for `app ready` in the output before sending commands. The TCP server listens on `127.0.0.1:8226`.

**Extension enable flags (important):**
- Use `--enable isaacsim.code_editor.python_server` — this is the **only** way to enable it.
- `--/exts/isaacsim.code_editor.python_server/enabled=true` does **NOT** work.
- Full-app screenshots require a display (`DISPLAY` env var). Viewport screenshots work headless.

## Asset Root Configuration

Isaac Sim assets require either a Nucleus server or S3 cloud fallback:

```bash
python scripts/isaacsim_send.py --file scripts/set_asset_root.py --arg asset_root=staging
```

**Asset servers:** `staging` (S3, Isaac 6.0 paths), `production` (S3, Isaac 5.0 paths), `nucleus` (default).

## Sending Code

```bash
python scripts/isaacsim_send.py --file scripts/app_screenshot.py \
    --arg output_path=/tmp/shot.png
```

**Response format:**
```json
{"status": "ok", "output": "hello", "result": null}
{"status": "error", "output": "", "ename": "NameError", "evalue": "name 'x' is not defined", "traceback": ["..."]}
```

### Named Contexts (state persistence)

Variables set in `--context A` are invisible in `--context B`:

```bash
python scripts/isaacsim_send.py --context rec 'fc = 0; frames = []'
python scripts/isaacsim_send.py --context browser 'detail = None; cat = None'
```

### Execution Timeouts

Async code is cancelled cleanly via `asyncio.wait_for()`:

```bash
python scripts/isaacsim_send.py --execution-timeout 30 'await long_operation()'
```

### Fire-and-Forget

For deferred UI clicks, background data loading:

```bash
ack=$(python scripts/isaacsim_send.py --raw --fire-and-forget 'load_large_usd()')
task_id=$(echo "$ack" | python3 -c "import sys,json; print(json.load(sys.stdin)['task_id'])")
```

## Screenshots

```bash
# Full-app (UI chrome + viewport, requires DISPLAY)
python scripts/isaacsim_send.py --file scripts/app_screenshot.py --arg output_path=/tmp/full.png

# Viewport only (3D render, works headless)
python scripts/isaacsim_send.py --file scripts/viewport_screenshot.py --arg output_path=/tmp/vp.png
```

## Stage Management

```bash
# Create new empty stage
python scripts/isaacsim_send.py --file scripts/open_stage.py --arg action=new

# Open a USD file
python scripts/isaacsim_send.py --timeout 120 --file scripts/open_stage.py \
    --arg usd_path=/path/to/scene.usd

# Save stage
python scripts/isaacsim_send.py --file scripts/open_stage.py \
    --arg action=save --arg usd_path=/tmp/saved.usd
```

## Scene Inspection

```bash
# Stage tree
python scripts/isaacsim_send.py --file scripts/stage_info.py

# Detailed prim view
python scripts/isaacsim_send.py --file scripts/stage_info.py --arg prim_path=/World/Cube

# List/read/set prim attributes
python scripts/isaacsim_send.py --file scripts/prim_properties.py \
    --arg prim_path=/World/Cube --arg action=list
```

## Transform Control

```bash
python scripts/isaacsim_send.py --file scripts/prim_transform.py \
    --arg prim_path=/World/Cube --arg action=set --arg "position=3,0,1"
```

## Camera Control

```bash
python scripts/isaacsim_send.py --file scripts/camera_control.py \
    --arg action=set --arg "position=1.5,1.5,1.2" --arg "target=0,0,0.5"
```

**Inline camera control** (recommended):

```python
from isaacsim.core.rendering_manager import ViewportManager
import isaacsim.core.experimental.utils.app as app_utils

ViewportManager.set_camera_view("/OmniverseKit_Persp", eye=[1.5, 1.5, 1.0], target=[0.0, 0.0, 0.4])
app_utils.update_app(steps=30)
```

## Simulation Control

```bash
python scripts/isaacsim_send.py --file scripts/simulation_control.py --arg action=play
python scripts/isaacsim_send.py --file scripts/simulation_control.py --arg action=step --arg num_steps=100
```

## Moving Prims (Setting World Pose)

**Do NOT use** `xform.set_world_pose()` — it raises `NotImplementedError`.

**Before simulation starts**, use `XformPrim`:

```python
import numpy as np
from isaacsim.core.experimental.prims import XformPrim

target = XformPrim(paths="/World/TargetCube")
target.set_world_poses(positions=np.array([[0.3, 0.2, 0.5]]))
```

**During simulation**, use raw USD:

```python
from pxr import UsdGeom, Gf
import omni.usd

stage = omni.usd.get_context().get_stage()
prim = stage.GetPrimAtPath("/World/TargetCube")
xformable = UsdGeom.Xformable(prim)
for op in xformable.GetOrderedXformOps():
    if op.GetOpType() == UsdGeom.XformOp.TypeTranslate:
        op.Set(Gf.Vec3d(0.3, 0.2, 0.5))
        break
```

## Common Patterns

### Create a new stage with objects

```python
import numpy as np
from isaacsim.core.experimental.objects import Cube, DomeLight
import isaacsim.core.experimental.utils.stage as stage_utils

await stage_utils.create_new_stage_async(template="empty")
stage_utils.define_prim("/World", "Xform")
DomeLight("/World/DomeLight").set_intensities(np.array([3000.0]))
Cube("/World/RedCube", sizes=1.0, colors="red", positions=(0, 0, 0.5))
```

### Step the renderer / simulation

**Prefer `await update_app_async()` over `update_app()`** when running code that uses `await`:

```python
import isaacsim.core.experimental.utils.app as app_utils

await app_utils.update_app_async(steps=120)  # Render frames (warm-up)
app_utils.play()
await app_utils.update_app_async(steps=100)
app_utils.stop()
```

## Key APIs

**Isaac Sim APIs (preferred):**
- `isaacsim.core.experimental.utils.stage` — stage ops
- `isaacsim.core.experimental.utils.app` — `update_app()`, `play()`, `stop()`, `enable_extension()`
- `isaacsim.core.experimental.utils.prim` — prim queries
- `isaacsim.core.experimental.objects` — `Cube`, `Sphere`, `DomeLight`, `GroundPlane`
- `isaacsim.core.experimental.prims` — `XformPrim`, `RigidPrim`, `GeomPrim`

## Important Notes

- **Lighting in headless mode**: No lights = black image. Always add a `DomeLight` with intensity 1000–5000.
- **Renderer warm-up**: After new stage, call `app_utils.update_app(steps=120)` before rendering.
- **Connection errors**: Ensure Isaac Sim shows `app ready` and python_server is `--enable`d.
- **Server hangs**: Crashed examples can wedge the server. Restart Isaac Sim.
- **Assets not found**: Configure S3 fallback with `set_asset_root.py`.
