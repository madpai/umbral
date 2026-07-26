# Feel Prototype 01 — Tuning Log

Phase 1 (movement and camera), Phase 1.1 (jitter correction, step-up,
click-to-move experiment), Phase 1.2 (camera & perspective laboratory),
Phase 1.3 (Hybrid World orbit + zoom camera), Phase 1.4 (navigation experiment
— see `NAVIGATION_TEST.md`) and Phase 1.5 (interaction experiment — see
`INTERACTION_TEST.md`). This file is the actual research output of the
prototype. The code is disposable; these numbers are not.

Phase 1 has been played by the owner and passed provisionally. **Nothing in the
Phase 1.1 section has been played yet** — it is measured, not judged. Whether
click-to-move is pleasant is a human judgement no harness can make.

## How to use this file

Run the prototype, press `Esc` to release the mouse, edit exported values on the
running `Player` node in the Inspector, and play. Godot does **not** save
Inspector edits made on a running instance — copy any value you want to keep
back into `player/player.tscn`, then add an entry below.

Entry format: date/time · property · old → new · observed problem · reason.

---

## Measurement method

Values were measured by a temporary headless harness that drove the real
controller through `Input.action_press()` and recorded the results across
physics frames at 60 Hz. Each probe ran from a cleared position on open ground
so terrain could not contaminate the reading. The harness was deleted after the
pass; it was a measuring instrument, not part of the build.

Command used:

```
godot --headless --path prototype res://dev_measure.tscn   # Phase 1 values
godot --headless --path prototype res://dev_jitter.tscn    # Phase 1.1 jitter
godot --headless --path prototype res://dev_verify.tscn    # Phase 1.1 behaviour
godot --headless --path prototype res://dev_step.tscn      # step-up dissection
```

All four harnesses were deleted after use. Recreate them from the numbers in
this file if a claim here ever needs re-checking.

This measures **quantities**, not feel. It tells us a jump reaches 1.176 m. It
cannot tell us whether that jump is satisfying.

---

## Baseline before tuning (2026-07-25)

| Measurement | Value |
| --- | --- |
| Rest height on flat ground | y = 0.0003 (capsule origin sits at the feet) |
| Walk: 0 → 90% of 4.50 m/s | 0.133 s (8 frames) |
| Sprint: walk → 90% of 7.60 m/s | 0.083 s (5 frames) |
| Stop: sprint → rest | 0.183 s, **0.579 m of slide** |
| Jump apex | **1.362 m** at 0.317 s, airtime 0.617 s |
| Coyote jump 0.067 s after ledge | fired |
| Jump buffered 0.033 s before landing | honoured |
| Stale buffered press (> 0.12 s) | correctly expired |
| Idle on 30° ramp for 0.5 s | 0.0000 m of drift |
| Floor angle readout on 15° / 30° / 50° ramps | 15.00 / 30.00 / 50.00 |
| 50° ramp walkable with `floor_max_angle` 46° | no (correct) |
| Walking into a 0.20 m step | **blocked** |
| `F1` reset | returns to (0.00, 0.00, 8.00) |

---

## Changes

### 2026-07-25 — `ground_deceleration`

- **Old:** 45.0 m/s²
- **New:** 80.0 m/s²
- **Observed problem:** releasing the stick at sprint speed slid the character
  0.579 m before stopping — about a third of the 1.8 m character's own height.
- **Reason:** UMBRAL's planned activities put the player near ledges, slopes and
  (in Phase 3) a hazard volume at a crossing. Momentum that carries a third of a
  body length past the intended stopping point converts precision into a
  gamble. Slide is now 0.300 m in 0.100 s. This is a deliberate trade of weight
  for precision and is the most likely value in this file to be argued with —
  if the result feels robotic rather than controlled, move it back toward 55–65
  rather than all the way to 45.

### 2026-07-25 — `jump_velocity`

- **Old:** 8.2 m/s (apex 1.362 m)
- **New:** 7.6 m/s (apex 1.176 m)
- **Observed problem:** a 1.362 m apex is 76% of the character's 1.8 m height.
- **Reason:** UMBRAL is a game about inhabiting and maintaining a place, not an
  action platformer. A jump that clears three quarters of your own height reads
  as arcade and quietly sets an expectation about traversal that the rest of the
  design has not made. 1.176 m still clears every test feature. This is a feel
  value, not a design decision, and reverting it constrains nothing.

### 2026-07-25 — test platform height (`main.tscn`, `Terrain/Blockout/Platform`)

- **Old:** top at 1.10 m
- **New:** top at 0.90 m
- **Observed problem:** after the `jump_velocity` change the apex cleared the
  platform by only 0.076 m, making a routine jump read as a near miss.
- **Reason:** geometry change, not a feel change. The lab should not make the
  controller look worse than it is. Clearance is now 0.276 m.

---

## Values after this pass

Copied from `player/player.tscn` / `player/player.gd` defaults.

| Group | Property | Value |
| --- | --- | --- |
| Speed | `walk_speed` | 4.5 m/s |
| Speed | `sprint_speed` | 7.6 m/s |
| Acceleration | `ground_acceleration` | 32.0 |
| Acceleration | `ground_deceleration` | 80.0 |
| Acceleration | `air_acceleration` | 14.0 |
| Acceleration | `air_deceleration` | 3.0 |
| Turning | `turn_smoothing` | 14.0 |
| Gravity and Jump | `gravity` | 26.0 |
| Gravity and Jump | `fall_gravity_multiplier` | 1.45 |
| Gravity and Jump | `jump_velocity` | 7.6 |
| Gravity and Jump | `max_fall_speed` | 45.0 |
| Gravity and Jump | `coyote_time` | 0.10 s |
| Gravity and Jump | `jump_buffer_time` | 0.12 s |
| Floor | `floor_max_angle_degrees` | 46.0 |
| Floor | `floor_snap_length_m` | 0.40 |
| Floor | `max_step_height` | 0.25 m |
| Control Mode | `control_mode` | CLICK_TO_MOVE |
| Control Mode | `arrival_radius` | 0.35 m |
| Camera Look | `mouse_sensitivity` | 0.0032 |
| Camera Look | `gamepad_look_speed` | 3.0 |
| Camera Look | `invert_pitch` | false |
| Camera Look | `fov_lerp_speed` | 6.0 |

Framing, pitch, lens and response moved into camera presets in Phase 1.2; see
the table in that section and `camera/presets/*.tres`.

---

## Phase 1.1 — 2026-07-25 (after owner playtest)

Owner verdict on Phase 1: **passes provisionally.** Movement, acceleration,
deceleration, slopes, jumping and the mouse camera all judged good. Two defects
reported: visible shakiness while moving, and a staircase that could not be
walked up. Both are addressed below. A click-to-move experiment was added
alongside them.

### 2026-07-25 — visible shakiness: `physics/common/physics_interpolation`

- **Old:** `false` (engine default)
- **New:** `true`
- **Diagnosed cause:** render/physics rate mismatch, not the camera. Measured at
  144 fps against a 60 Hz physics tick: **59% of render frames showed the
  character at exactly the same position as the previous frame**, then it jumped
  0.075 m. Jitter ratio (sd/mean of per-render-frame movement) was **1.192**.
  The camera meanwhile measured **0.067** with zero duplicate frames, because it
  is driven in `_process` with exponential damping. So the camera glided while
  the character stepped — and a smooth reference frame makes stepping far more
  visible than it would be against a stepping background. The camera was not the
  fault; it was the thing that exposed the fault.
- **Ruled out by measurement:** `CameraRig.top_level`, `SpringArm3D`, character
  rotation smoothing, floor snapping and geometry collision. All of these were
  candidates. None of them produce duplicate render frames, and the duplicate
  frames were the whole signal.
- **After:** jitter ratio **0.001**, duplicate frames **0%**, character and
  camera now advancing in lockstep (both 0.031248 m per render frame).
- **Why this is safe for a disposable prototype:** it is a stock engine feature,
  one project setting, and it changes nothing about the physics simulation — the
  measured jump apex, airtime, stop distance and slope readings are all
  unchanged afterwards. No damping was increased and no motion blur was added,
  so nothing is hidden.

Two code changes were required to make it correct rather than merely enabled:

- `CameraRig.physics_interpolation_mode = OFF` — the rig is positioned by hand
  every render frame, so the engine must not interpolate it as well.
- `_camera_target()` now uses `get_global_transform_interpolated().origin`
  instead of `global_position`. `global_position` still only changes at 60 Hz;
  chasing it would have reintroduced the stepping the setting exists to remove.
- `_reset_to_spawn()` calls `reset_physics_interpolation()`, or the engine
  interpolates across the teleport and smears the character across the map.

### 2026-07-25 — `max_step_height` (new property)

- **Old:** no step-up; any vertical lip blocked the character completely
- **New:** `0.25` m
- **Observed problem:** the owner could not walk up a staircase whose steps were
  0.20 m; each one required a jump.
- **Reason:** a character that jumps 1.18 m but cannot cross a kerb reads as
  broken. `PROTOTYPE_ARCHITECTURE.md` §9 excludes step-up *solvers*, and this is
  not one: it is three shape tests and a placement, about 30 lines, local to
  `player.gd`, with no component, no animation and no plugin.
- **Non-obvious detail worth keeping if this code is ever rewritten:** the
  forward probe used to measure the step must be **at least the capsule radius**,
  not one frame of motion. Measured on the 0.20 m step: probing 0.075 m forward
  made the capsule catch the step's leading *corner*, reporting a 42.8° slope
  and a 0.094 m landing — which then failed the walkable test and silently did
  nothing. Probing 0.45 m forward lands on the flat top: 0.0° and 0.2002 m. The
  probe is used for measurement only; the character is still advanced by one
  frame of motion.

### 2026-07-25 — staircase geometry (`main.tscn`, `StepB` / `StepC`)

- **Old:** tops at 0.20 / 0.45 / 0.75 m (rises of 0.20, 0.25, 0.30)
- **New:** tops at 0.20 / 0.40 / 0.60 m (uniform 0.20 m rises)
- **Observed problem:** the original stack had uneven rises, so with any single
  step limit part of it would climb and part would not — which reads as a bug
  rather than as a limit.
- **Reason:** the owner reported these surfaces "visually read as stairs". They
  should behave as stairs. Geometry change, not a feel change.

### 2026-07-25 — click-to-move experiment (new)

Not a tuning change; a new control model added for evaluation. `control_mode`
defaults to **CLICK_TO_MOVE** because that is the direction under test.
`arrival_radius` defaults to 0.35 m.

Neither control model is canon. WASD remains as the comparison baseline.

### Phase 1.1 verification (headless, driving the real controller)

| Check | Result |
| --- | --- |
| Stair ascent, ordinary walking, no jumps | y = 0.200 → 0.401 → 0.601, exact step tops |
| Stair descent | y = 0.401 → 0.201 → 0.001, grounded throughout |
| Pillar (6 m wall) | y = −0.002, not climbed |
| 50° ramp | not climbed, still rejected |
| 30° slope readout | 30.00°, unchanged |
| Jump | apex 1.176 m, airtime 0.583 s, unchanged |
| Click travel 12 m | arrived in 2.68 s, cleared at 0.23 m |
| Click arrival settle | rest 0.188 m short of target, 0.000 m/s, **no overshoot** |
| New click replaces old | accepted immediately, character turned |
| Click filter: flat / 30° | clickable |
| Click filter: 50° ramp / pillar face | rejected |

---

## Phase 1.2 — 2026-07-25 (camera & perspective laboratory)

The highest-priority design question changed from "does click-to-move work" to
"from what perspective should the player experience UMBRAL". The camera became
the variable and everything else was frozen.

### Structural change — camera settings became data

`camera_distance`, `camera_height`, `camera_damping`, `pitch_min_degrees`,
`pitch_max_degrees`, `fov_base` and `fov_sprint_add` were removed from
`player.gd` and moved into `CameraPreset` resources under
`camera/presets/`. The controller now reads whichever preset is active. There is
one rig, one camera and one controller; only the numbers feeding them change.

`mouse_sensitivity`, `gamepad_look_speed`, `invert_pitch` and `fov_lerp_speed`
stayed on the player: they are input and response rates, not perspectives, and
holding them constant is what keeps the comparison clean.

### Preset defaults

| Property | A · Classic Third Person | B · Adventure | C · High Strategy |
| --- | --- | --- | --- |
| `distance` | 5.0 | 8.5 | 20.0 |
| `height` | 1.5 | 2.1 | 2.5 |
| `pitch_degrees` | −14.0 | −24.0 | −50.0 |
| `pitch_min_degrees` | −68.0 | −70.0 | −72.0 |
| `pitch_max_degrees` | 32.0 | 18.0 | −30.0 |
| `fov` | 75.0 | 65.0 | 48.0 |
| `fov_sprint_add` | 9.0 | 6.0 | 0.0 |
| `damping` | 14.0 | 10.0 | 7.0 |
| `shoulder_offset` | 0.0 | 0.0 | 0.0 |
| `avoid_obstructions` | true | true | **false** |

Measured in the running build: elevation 14° / 24° / 50°, camera height above
the pivot 1.21 m / 3.46 m / 15.32 m, and the 1.8 m character occupying **~21% /
~15% / ~9%** of screen height. That progression is the experiment.

Three choices in that table are judgement calls, not neutral defaults, and each
could bias the result:

- **C's obstruction avoidance is off.** A 20 m spring arm slams through terrain
  constantly, and the popping would be blamed on the perspective rather than on
  the arm. The cost is that the camera can end up behind tall geometry.
- **C's pitch ceiling is −30° and B's is +18°**, so neither can be levelled out
  into a third-person camera mid-test. Without this, all three presets converge
  on whatever the tester is used to.
- **Sprint FOV punch is reduced in B and removed in C.** A lens cue worth 9° at
  5 m is nearly invisible at 20 m. If C feels slow, this is the first thing to
  try changing.

All three are noted in `CAMERA_TEST.md` so the owner can discount them.

### Non-regression check

The camera work must not have moved anything else. Re-measured after the change:

| Measurement | Phase 1.1 | Phase 1.2 |
| --- | --- | --- |
| Walk 0 → 90% | 0.133 s | 0.133 s |
| Steady sprint | 7.600 m/s | 7.600 m/s |
| Stop from sprint | 0.100 s / 0.300 m | 0.100 s / 0.300 m |
| Jump apex / airtime | 1.176 m / 0.583 s | 1.176 m / 0.583 s |
| Staircase top | y = 0.601 | y = 0.601 |
| Click-to-move rest | 0.188 m / 0.000 m/s | 0.188 m / 0.000 m/s |

Identical on every line.

### Not changed

No camera shake, cinematic effects, bloom, depth of field, motion blur or screen
effects were added. The experiment is about perspective only.

---

## Phase 1.3 — 2026-07-25 (Hybrid World camera)

Owner verdict on Phase 1.2: A is too close and avatar-focused for click-to-move
and is retained only as a debug comparison; B and C are both promising; C is
somewhat too distant as a fixed default. **The strongest direction is between B
and C.** Phase 1.3 builds that space as a single adjustable camera.

`H · Hybrid World` is added as a fourth preset and made the launch default.
A, B and C are untouched and still reachable with F3.

### Hybrid World values

| Property | Value | Note |
| --- | --- | --- |
| `distance` | 13.0 m | starting point; also seeds the zoom position |
| `height` | 2.3 m | between B (2.1) and C (2.5) |
| `pitch_degrees` | −35.4° | matches the zoom curve at the start position |
| `pitch_min_degrees` | −70.0° | orbit floor |
| `pitch_max_degrees` | **−18.0°** | orbit ceiling — cannot become third person |
| `fov` | 57.6° | matches the zoom curve at the start position |
| `fov_sprint_add` | 4.0° | small; a lens cue is worth little at 13 m |
| `damping` | 9.0 | between B (10) and C (7) |
| `zoom_min_distance` | 7.5 m | closer than B; see the closer-zoom entry below |
| `zoom_max_distance` | 20.0 m | equals C |
| `zoom_step` | 0.08 | fraction of the range per wheel notch (~12 notches end to end) |
| `zoom_response` | 9.0 | exponential; one notch settles in about 0.3 s |
| `pitch_at_min_zoom` | −23.9° | |
| `pitch_at_max_zoom` | −50.0° | |
| `fov_at_min_zoom` | 63.6° | |
| `fov_at_max_zoom` | 50.0° | |
| `avoid_obstructions` | false | same reasoning as preset C |

Measured across the zoom range after the closer-zoom adjustment below:
distance 7.50 / 13.00 / 20.00 m, pitch −23.9 / −35.4 / −50.0°, FOV 63.6 / 57.6 /
50.0°, character occupying **16.7% / 11.5% / 8.8%** of screen height.

### Distance, pitch and FOV are coupled

One normalised zoom value drives all three. Pulling in shortens the distance,
flattens the pitch and widens the lens; pushing out does the reverse. Coupling
exists because a distant camera at a shallow pitch shows mostly horizon, and a
close camera at a steep pitch shows mostly the character's head — the readable
combinations sit on a diagonal, not in a rectangle.

**Manual orbit survives zooming.** Pitch is applied as a moving baseline: when
zoom shifts the baseline, the player's own pitch adjustment is carried along
rather than overwritten. Without this, every wheel notch would undo whatever the
player had just set with the mouse. The sum is clamped to the preset's pitch
limits.

Whether coupling is *wanted* is an open question for the owner; the alternative
(independent pitch) is a one-line change.

### Orbit

Right-mouse-drag only. Horizontal drag yaws, vertical drag pitches, release
stops immediately. Mouse motion without right mouse held does not rotate the
camera in click-to-move mode. The cursor is captured during the drag and warped
back to where the drag started on release, so a right-drag never moves the
player's aim. Arrow keys provide the same orbit without the mouse; they were
added to the existing `look_*` actions rather than as new ones, so they share
`gamepad_look_speed`.

The camera never auto-rotates toward the direction of travel, and no
recentring, cinematic tracking, shake or blur was added.

### Verification

| Check | Result |
| --- | --- |
| Hybrid World is the launch default | index 0 of 4, `H · Hybrid World` |
| Zoom respects minimum | 40 wheel-up notches → `zoom_t` = 0.000, 9.00 m |
| Zoom respects maximum | 40 wheel-down notches → `zoom_t` = 1.000, 20.00 m |
| Zoom interpolation is smooth | one notch = 0.86 m travelled, largest single frame 0.148 m |
| Orbit respects pitch ceiling | forced up → stopped at exactly −18.0° |
| Orbit respects pitch floor | forced down → stopped at exactly −70.0° |
| Right-drag issues no destination | press + drag + release → 0 destinations |
| Wheel issues no destination | 0 destinations |
| Click accuracy, default framing | error **0.0000 m** |
| Click accuracy, max zoom in | error **0.0000 m** |
| Click accuracy, max zoom out | error **0.0000 m** |
| Click accuracy, after 180° orbit | error **0.0000 m** |
| Click accuracy, at minimum pitch | error **0.0000 m** |
| Click accuracy, at maximum pitch | error **0.0000 m** |
| Rapid destination replacement | immediate |
| A / B / C values | unchanged |

Click accuracy was measured by round trip: a known ground point was projected to
screen through the live camera, that screen position was pushed through the real
click pipeline, and the resulting destination compared with the original point.

### Non-regression

| Measurement | Phase 1.2 | Phase 1.3 |
| --- | --- | --- |
| Walk 0 → 90% | 0.133 s | 0.133 s |
| Steady sprint | 7.600 m/s | 7.600 m/s |
| Stop from sprint | 0.100 s / 0.300 m | 0.100 s / 0.300 m |
| Jump apex / airtime | 1.176 m / 0.583 s | 1.176 m / 0.583 s |
| Staircase top | y = 0.601 | y = 0.601 |
| 30° slope readout | 30.00°, grounded | 30.00°, grounded |
| Click-to-move rest | 0.188 m / 0.000 m/s | 0.188 m / 0.000 m/s |

Identical on every line. Physics interpolation from Phase 1.1 is untouched.

---

### 2026-07-25 — closer minimum zoom (owner request)

- **Old:** `zoom_min_distance` 9.0 m, `pitch_at_min_zoom` −27.0°, `fov_at_min_zoom` 62.0°
- **New:** `zoom_min_distance` **7.5 m**, `pitch_at_min_zoom` **−23.9°**, `fov_at_min_zoom` **63.6°**
- **Observed problem:** the owner adopted Hybrid World as the provisional
  direction but wanted to be able to get somewhat closer than 9.0 m.
- **Reason for changing three values rather than one:** the zoom position of the
  13.0 m default is `(13 − min) / (max − min)`, so moving the close bound alone
  would have slid the default framing along the curve to −37.1° / 56.7° — and
  the 13.0 m framing is precisely what the owner had just approved. The two
  curve endpoints were re-solved so that the default lands on exactly −35.4° /
  57.6° as before. Measured after the change: 13.00 m, −35.4°, 57.6°. Unchanged.
- **Composition at the new close bound:** 7.50 m, 23.9° elevation, 63.6° FOV,
  character at 16.7% of screen height. For comparison, B · Adventure is 8.50 m
  at 24.0° elevation and 14.8%, and A · Classic Third Person is 5.00 m at 14.0°
  elevation and 21.1%. The new bound is therefore **closer than Adventure at
  essentially Adventure's angle**, and remains clearly distinct from Classic
  Third Person. The maximum bound, coupled pitch/FOV behaviour, orbit controls
  and pitch limits are untouched.

Re-verified after the change: zoom clamps at exactly 0.000 and 1.000; one wheel
notch from the close bound travels 0.99 m with a largest single-frame change of
0.170 m; destination-click error is **0.0000 m** at the new minimum zoom,
maximum zoom, after a 180° orbit, at minimum pitch and at maximum pitch; the
pitch ceiling still holds at −18.0°. Movement, stopping, jumping, stairs, slopes
and click-to-move arrival are all identical to Phase 1.2 values.

---

## Phase 1.4 — 2026-07-25 (navigation experiment)

Built on top of the provisional direction without altering it. Movement,
step-up, camera, zoom and orbit are untouched and were re-measured as identical.
The implementation is disposable; see `NAVIGATION_TEST.md`.

### Navigation mesh

| Property | Value | Why |
| --- | --- | --- |
| `cell_size` | 0.15 | fine enough to resolve the 0.8 m test walls |
| `cell_height` | **0.05** | see the `agent_max_climb` note below |
| `agent_radius` | 0.45 | capsule radius 0.40 plus clearance, so paths stand off walls |
| `agent_height` | 1.8 | capsule height |
| `agent_max_climb` | 0.25 | matches the player's `max_step_height` |
| `agent_max_slope` | 46.0 | matches the player's `floor_max_angle_degrees` |
| `parsed_geometry_type` | mesh instances | the greybox is CSG; collider parsing does not see CSG |
| `source_geometry_mode` | root node children | `Terrain` now sits under `NavRegion` |

Result: 342 polygons, 316 vertices, baked in ~250 ms.

### Two settings that had to match something else

- **`cell_height` 0.10 → 0.05.** At 0.10 the engine warned that
  `agent_max_climb` is floored to whole voxels: 0.25 / 0.10 floors to **0.20 m**
  — exactly the staircase step height, so stair connectivity was decided by
  rounding. 0.05 divides 0.25 into five whole voxels with no precision loss.
- **`navigation/3d/default_cell_size` and `default_cell_height`** in
  `project.godot` were set to 0.15 / 0.05 to match the mesh. Left at the
  defaults, the navigation map rasterises the baked mesh at a different
  resolution and warns about edge errors.

### Agent

| Property | Value | Note |
| --- | --- | --- |
| `radius` | 0.45 | matches the bake |
| `height` | 1.8 | matches the bake |
| `path_desired_distance` | 0.6 | the look-ahead: how close before advancing a waypoint |
| `target_desired_distance` | 0.35 | equals the existing `arrival_radius` |
| `path_max_distance` | 3.0 | repath threshold |
| `avoidance_enabled` | false | one character, no NPCs |
| `stuck_timeout` | 1.5 s | abandons a destination after no progress |

### Two engine behaviours worth keeping if this is ever rewritten

Both cost real time to find, and both fail *silently* — the navmesh reports a
healthy polygon count while every query returns the origin.

1. **Do not bake inside `_ready()`.** `CSGShape3D` builds its mesh on a deferred
   call, so an early bake parses a scene containing only the ground plane.
   Measured: 126 polygons instead of 342, and straight-line paths through every
   wall.
2. **`bake_navigation_mesh()` does not push the result to the navigation
   server.** It fills the `NavigationMesh` resource only. The region must be
   updated explicitly with
   `NavigationServer3D.region_set_navigation_mesh(region.get_rid(), mesh)`, and
   that call is discarded if it happens before the map's first synchronisation.
   The bake therefore waits two physics frames, which satisfies both conditions
   at once.

### Validation

| Case | Result |
| --- | --- |
| 1 Direct unobstructed, 16 m | arrived 4.23 s, 0.21 m from target |
| 2 Around a pillar | arrived 3.83 s, 0.19 m, 13 waypoints |
| 3 Around the wall | arrived 5.87 s, 0.25 m — routed around the west end |
| 4 Into the U obstacle | arrived 7.37 s, 0.24 m — went 6 m *away* first, then in |
| 5 Stair ascent | arrived 2.35 s, mesh climbs 0.1 → 0.7 |
| 6 Stair descent | arrived 2.35 s |
| 7 30° ramp ascent | arrived 4.53 s (route is odd — see limitation 1) |
| 8 30° ramp descent | arrived 4.60 s |
| 50° ramp click | refused (3.96 m off mesh) |
| Pillar top click | refused |
| Platform top click | refused — on mesh but disconnected by a 0.9 m lip |
| Rapid replacement | immediate |
| WASD cancellation | destination cleared |
| Arrival | 0.19–0.25 m from target, speed 0.000, no oscillation |
| Pressing into an obstacle | direct steering gave up after 1.98 s |
| Click accuracy at 5 camera extremes | **0.0000 m** every time |

### Non-regression

| Measurement | Phase 1.3 | Phase 1.4 |
| --- | --- | --- |
| Walk 0 → 90% | 0.133 s | 0.133 s |
| Steady sprint | 7.600 m/s | 7.600 m/s |
| Stop from sprint | 0.100 s / 0.300 m | 0.100 s / 0.300 m |
| Staircase top | y = 0.601 | y = 0.601 |

---

## Phase 1.5 — 2026-07-25 (interaction experiment)

One interaction, three objects, nothing produced. Movement, camera, zoom, orbit
and navigation are untouched and were re-measured as identical. Disposable; see
`INTERACTION_TEST.md`.

### Interaction profiles

| Property | Tree | Rock | Campfire |
| --- | --- | --- | --- |
| `interaction_range` | 2.6 m | 2.2 m | 2.0 m |
| `approach_fraction` | 0.70 | 0.70 | 0.65 |
| `facing_tolerance_degrees` | 20° | 25° | 30° |
| `duration` | 1.8 s | 1.2 s | 0.9 s |
| `reset_seconds` | 3.0 | 3.0 | 3.0 |
| `pulse_speed` / `pulse_amount` | 2.4 / 0.06 | 3.0 / 0.05 | 4.0 / 0.04 |

Player-side: `completed_hold` 0.45 s (holds the COMPLETED state long enough to
be visible), `show_interaction_ranges` false (F5).

### Two values that are doing real work

- **`approach_fraction` 0.7, not 1.0.** The character aims for a point *inside*
  interaction range rather than exactly on its edge. Aiming at the edge means any
  drift re-triggers the approach, and the character shuffles. Measured: it now
  stops 2.46 m from a tree whose range is 2.6 m.
- **`facing_tolerance_degrees`.** Progress does not advance until the character
  is aimed within this angle, which is what produces "arrive → turn → work"
  without needing a fifth state in the machine. Measured facing error at
  completion: 0.0°.

### Validation

| Case | Result |
| --- | --- |
| Click tree from 16 m | completed in 4.87 s, stopped 2.46 m away, facing 0.0° |
| Click tree while already walking elsewhere | completed, 4.95 s |
| Switch to the rock midway | 1 cancel fired, rock completed in 6.13 s |
| Click campfire from 26 m (outside range) | completed, 6.30 s |
| Click campfire from 1.2 m (inside range) | completed in 0.97 s, **never walked** |
| WASD during MOVING | state IDLE, target cleared |
| WASD during INTERACTING | state IDLE, object back to available |
| Ground click during INTERACTING | state IDLE, object back to available |
| Unreachable (stood on the platform) | refused, 1 rejection, state IDLE |
| After max zoom + 180° orbit | completed, 4.87 s |
| Three repeats in a row | all completed; later repeats skipped walking correctly |
| Hover on / off | object reports hovered / available |
| Hover while working | stays active, hover does not clobber it |

### Non-regression

| Measurement | Phase 1.4 | Phase 1.5 |
| --- | --- | --- |
| Walk 0 → 90% | 0.133 s | 0.133 s |
| Steady sprint | 7.600 m/s | 7.600 m/s |
| Stop from sprint | 0.100 s / 0.300 m | 0.100 s / 0.300 m |
| Staircase top | y = 0.601 | y = 0.601 |

---

## Known problems

1. **Interaction has no character animation and no sound.** The pulse is on the
   object, not the body. Both absences make completion feel flatter than it
   would in production; judge the timing and flow, not the performance.
2. **Interaction produces nothing, by design.** No resource, item or number.
   Whether completion needs a reward to satisfy is the open question, not a
   defect.
3. **The 30° ramp is entered from its side rather than its foot.** Technically
   valid, visibly odd; a greybox rasterisation artefact, recorded and
   deliberately not papered over. Full explanation in `NAVIGATION_TEST.md`.
4. **The navmesh is baked at startup (~250 ms) and never rebuilt.** Nothing in
   the scene moves, so this is correct here and wrong for anything dynamic.
5. **Camera presets C and H have obstruction avoidance disabled.** At 9–20 m the
   spring arm punches through terrain constantly and the popping would be blamed
   on the perspective rather than on the arm. The trade is that the camera can
   end up behind tall geometry.
6. **A click is resolved against the previous frame's camera transform.** Input
   is handled before `_process` moves the camera, so a click made during a fast
   zoom or orbit uses a camera pose one frame old. Measured error is 0.0000 m at
   rest, and at 60+ fps this is far below the click's own precision — but it is a
   real ordering detail worth knowing if aiming ever feels off during motion.
7. **Routing has no dynamic obstacle handling.** The navmesh is static and
   `avoidance_enabled` is off. Correct for one player in a fixed greybox; wrong
   for anything that moves. Straight-line steering is still available via the
   `Use Navigation` checkbox as the A/B comparison.
8. **Step-up rejects a step that has a wall close behind it.** The clearance test
   probes forward by the capsule radius (0.45 m), so a 0.20 m step with an
   obstruction within ~0.45 m beyond it reads as a wall and will not be climbed.
   Acceptable for a greybox; would need the probe split into two tests if it ever
   mattered.
9. **Step-up is not swept.** It is evaluated once per physics frame against the
   frame's motion, so at very high speed against a step the character could in
   principle tunnel. Not observed at sprint speed (7.6 m/s = 0.127 m per frame).
10. **Every camera value remains a judgement, not a measurement.** Distances,
   pitches, lenses, damping and the zoom curve across all four presets were
   chosen from convention and then checked for geometry, not for how they look.
   That is precisely what `CAMERA_TEST.md` exists to resolve.
11. **No gamepad has been exercised.** Bindings exist for both sticks,
   `A`/cross, left-stick-click, Start, Select and right shoulder, but no
   controller was connected, so deadzones and look speed are unverified. There is
   no gamepad binding for zoom.
12. **Frame rate is unmeasured under load.** Only headless runs were performed.
   Presets C and H draw considerably more of the scene than A; these are the
   first presets where framerate could plausibly differ.
13. **The 50° ramp is a dead end by design.** It is above `floor_max_angle` so the
   character slides off. That is the intended demonstration, not a bug.
14. **Air control may be too weak or too strong.** `air_acceleration` 14.0 and
    `air_deceleration` 3.0 preserve most momentum through a jump. Untested by
    hand.
15. **Sprint and jump may not belong in this control model at all.** Owner
    observations recorded in `CAMERA_TEST.md`; nothing changed in the build.

---

## What the owner should try first

**Start with `CAMERA_TEST.md`.** The camera question is now the highest-priority
one, and that sheet is the procedure for it. The list below is the movement and
click-to-move checklist from Phase 1.1, still valid, and best run inside
whichever camera preset you are evaluating.

Hybrid World and click-to-walk are now the **provisional** direction — adopted
for continued prototyping, not production canon. See `CAMERA_TEST.md`.

The build opens in **click-to-move** mode on preset **H · Hybrid World**.
Mouse wheel zooms, right-drag orbits, `F3` cycles presets, `F2` switches to WASD.

**The question this build exists to answer:** does issuing a destination feel
trustworthy and pleasant when the character underneath it is the tuned physical
one you already approved?

1. Click somewhere far away on open ground. Watch the turn, the acceleration and
   the stop. Does the character feel like it is obeying you or ignoring you?
2. Click a new spot while it is already walking. Replacement is immediate.
3. Click short distances repeatedly. This is where click-to-move usually feels
   worst, and where `arrival_radius` matters most.
4. Try to click on the red 50° ramp and on a pillar. Both are refused, and no
   marker appears. Judge whether a refused click reads as a rule or as the game
   ignoring you — that is a real design signal.
5. Hold right mouse to orbit the camera, then click. Does aiming a destination
   past the character feel natural?
6. Walk the staircase in both directions. It should need no jumps at all now.
7. Press `F2` and repeat 1–6 on WASD for comparison.
8. Watch the character while moving. The shake should be gone. If any remains,
   say where — the cause measured here was engine-level and is now fixed, so a
   residual would be something new.
9. Set `max_step_height` to 0 in the Inspector while running to feel the
   difference the step-up makes, then back to 0.25.
10. Change `camera_damping` between about 6 and 25 and `camera_distance` between
    3 and 8. These remain the two least-verified camera values.
