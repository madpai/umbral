# Prototype Architecture — Feel Prototype 01

> **Status:** Proposed. Engineering plan only.
> **Authority:** This document makes no design decisions. Where a design
> decision is required, it names a neutral placeholder and records the
> unresolved decision it stands in for. See
> [Design Inputs Required](#2-design-inputs-required).
> **Scope:** One week. One map. One player. 10–15 minutes of play.

Companion document: [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md).

Governing sources, not restated here:
[CANON](../CANON.md) ·
[Design Philosophy](../design/DESIGN_PHILOSOPHY.md) ·
[Gameplay Direction](../design/GAMEPLAY_DIRECTION.md) ·
[First-Hour Framework](../design/experience/FIRST_HOUR.md) ·
[First Valley Initiative](../design/world/FIRST_VALLEY.md)

---

## 1. The One Question

The prototype exists to answer one question:

> **Would this be enjoyable to control and interact with?**

It is the pillar-three test from
[Gameplay Direction](../design/GAMEPLAY_DIRECTION.md): responsive controls,
readable feedback, satisfying movement and interaction. Pillars one and two are
not on trial this week.

Everything in this document is subordinate to that question. Any recommendation
that does not shorten the path to answering it has been removed.

### What the prototype is not

It is not the first hour. It is not a vertical slice. It is not the beginning
of the production codebase. **The prototype is expected to be deleted.** Its
output is knowledge and a set of tuned numbers, not source code. Architecture
recommendations below are calibrated for a throwaway artifact, which is why
several of them would be wrong in production and are marked as such.

### What this document does not consume

[ROADMAP](../../ROADMAP.md) and
[FIRST_VALLEY](../design/world/FIRST_VALLEY.md) both name the valley's physical
constraints — geology, watershed, climate, seasons, soil, hazards — as the next
world-derivation gate. This plan does not touch that gate. The greybox uses the
recorded **working hypothesis** geometry (enclosed valley, river from the north,
a natural crossing) purely as disposable level layout. No greybox decision
becomes geography.

---

## 2. Design Inputs Required

[FIRST_HOUR](../design/experience/FIRST_HOUR.md) leaves every beat
`_Unresolved._`, and its Open Decisions list reserves precisely the decisions a
prototype would otherwise be tempted to invent. Per
[AGENTS.md](../../AGENTS.md) and [CANON §Implementation Agents](../CANON.md),
this plan holds a neutral boundary at each of them.

| Prototype placeholder | Open decision it stands in for | How design later replaces it |
| --- | --- | --- |
| **Verb A** — press-and-hold contextual work at a fixed site, with an aim requirement and a resistance curve | "The first repeatable activity" | Swap the `InteractionProfile` resource and the site scene. Verb A's controller code never names a fiction. |
| **Verb B** — pick up a prop, carry it encumbered, place it | "How gathering and crafting are introduced" | Delete, or reskin the carried prop. Carry is a locomotion modifier, not an inventory. |
| **Hazard A** — an environmental force volume at the crossing | "When danger appears" / "When combat appears" | Replaced by whatever danger design selects. Deliberately *not* a creature (see §14). |
| **Site A / Site B** — two greybox interaction locations ~35 s apart | "The first controllable action", "What creates the first strong reward" | Level geometry is disposable by definition. |
| **Path wear** — repeated traversal darkens the ground | *Derived, not placeholder.* See below. | Retained if design wants it; the mechanic is canon-compatible as built. |

**Path wear is the one prototype element that is derived rather than
invented.** [FIRST_VALLEY §Community Memory](../design/world/FIRST_VALLEY.md)
records "Every road began as repeated movement" as an **established design
rule**, and [RESONANCE §Second Law](../design/world/RESONANCE.md) states that
repeated participation strengthens continuity. A ground surface that visibly
remembers where the player walked is the cheapest possible expression of both.
It is included because it costs almost nothing and is the only thing in the
prototype that could not have come from any other game.

Everything else above is a stand-in awaiting a design decision. **No placeholder
in this plan should be cited later as precedent.**

---

## 3. Prototype Architecture

The whole prototype is one Godot project, one main scene, roughly eight scripts,
and under ~900 lines of GDScript. There is no framework layer.

```
Player input ──► player.gd (CharacterBody3D)
                   │
                   ├─► camera rig (SpringArm3D child)  ← no camera manager
                   ├─► interactor (RayCast3D child)    ← finds Interactable
                   └─► carry anchor (Node3D child)     ← reparents props
                          │
Interactable (Area3D + script) ◄── holds an InteractionProfile resource
   │  emits `completed`
   └─► its own visual response (mesh swap, Tween, AudioStreamPlayer3D)

Hazard (Area3D + script) ──► applies force / interrupt to whatever enters

Ground (MeshInstance3D + ShaderMaterial) ◄── WearMap writes an ImageTexture
```

Three rules hold the whole thing together:

1. **Nodes own their own behaviour and their own feedback.** An interactable
   plays its own sound and runs its own tween. No presentation layer.
2. **Signals go up; nothing reaches down.** The player never queries a specific
   interactable by name; interactables never query the player's internals.
3. **Numbers live in exported variables and Resources.** Code is edited in the
   script; feel is edited in the Inspector while the game is running.

> **Why is this the smallest implementation capable of proving the design?**
> Feel is proven by a human holding a controller, not by a system diagram. Every
> layer between the input event and the visible response is a layer that has to
> be re-tuned when the feel is wrong. This has none.

---

## 4. Godot Folder Structure

The repository already reserves `game/` for client implementation
([README](../../README.md)). The prototype goes in a sibling directory so that
its disposability is structural rather than a promise:

```
prototype/                       # Godot project root — expected to be deleted
├── project.godot
├── main.tscn                    # the only scene you run
├── player/
│   ├── player.tscn
│   └── player.gd
├── interaction/
│   ├── interactable.tscn
│   ├── interactable.gd
│   ├── interaction_profile.gd   # class_name InteractionProfile extends Resource
│   └── profiles/                # .tres files — the tuning surface
├── world/
│   ├── hazard.gd
│   ├── wear_map.gd
│   └── ground.gdshader
├── ui/
│   └── hud.tscn                 # one prompt label, one progress bar
└── art/                         # greybox only: CSG, GridMap, 3 materials
```

`game/`, `server/`, and `shared/` stay empty. `.gitignore` already excludes
`.godot/`.

> **Why smallest:** four feature folders, no `src/`, `core/`, `systems/`, or
> `autoload/` tiers. A directory tree deeper than the call stack is a cost with
> no payer.

---

## 5. Scene Hierarchy

One runnable scene. No scene management, no loading screens, no transitions.

```
Main (Node3D)                      main.gd — ~40 lines, wires signals, nothing else
├── Environment (WorldEnvironment)  one directional light, one sky
├── Terrain (Node3D)
│   ├── Ground (MeshInstance3D)     PlaneMesh + ground.gdshader + StaticBody3D
│   ├── Blockout (Node3D)           CSGBox3D / GridMap slopes, ledges, the crossing
│   └── WearMap (Node)              wear_map.gd — owns the ImageTexture
├── Sites (Node3D)
│   ├── SiteA (Interactable)        profile: verb_a_long.tres
│   └── SiteB (Interactable)        profile: verb_a_short.tres
├── Props (Node3D)                  3–5 carryable RigidBody3D/StaticBody3D
├── Hazards (Node3D)
│   └── Crossing (Hazard, Area3D)
├── Player (instanced player.tscn)
└── HUD (CanvasLayer)
```

```
Player (CharacterBody3D)
├── Collision (CollisionShape3D)    capsule
├── Body (MeshInstance3D)           capsule mesh + a nose cone for facing
├── CameraRig (Node3D)              yaw
│   └── SpringArm3D                 pitch + automatic wall avoidance, free
│       └── Camera3D
├── Interactor (RayCast3D)          from the camera, ~2.5 m
├── CarryAnchor (Node3D)            reparent target for Verb B
├── GroundCheck (RayCast3D)         coyote time + slope readout
└── Sfx (AudioStreamPlayer3D)
```

> **Why smallest:** `SpringArm3D` is a built-in that already solves camera
> collision — the single most common reason a homemade third-person camera feels
> bad. Using it removes a day of work and a class of bugs.

---

## 6. Autoload Strategy

**Recommendation: zero autoloads. One is acceptable; two is a smell.**

If one becomes genuinely necessary, it should be `Debug` — an on-screen readout
of speed, state, and slope, plus a hotkey to reset the player to spawn. That is
a tooling autoload, not an architectural one.

Explicitly **do not** create: `GameManager`, `EventBus`, `SignalBus`,
`Globals`, `AudioManager`, `SaveManager`, `SceneManager`, `Settings`.

> **Why smallest:** an event bus is a solution to cross-scene coupling. This
> prototype has one scene. `main.gd` can connect every signal in the project in
> about ten lines, and a reader can follow the entire data flow by reading one
> file. Autoloads also persist state across `F6` restarts, which makes feel
> iteration harder, not easier.

---

## 7. Input Architecture

Godot's `InputMap` in Project Settings **is** the input architecture. Nothing
wraps it.

| Action | Keyboard | Gamepad |
| --- | --- | --- |
| `move_left/right/forward/back` | WASD | left stick |
| `look_*` | mouse motion (read directly, not as actions) | right stick |
| `jump` | Space | A / cross |
| `interact` | E (**hold**) | X / square (hold) |
| `sprint` | Shift | left stick click |
| `debug_reset` | F1 | — |

Read with `Input.get_vector()` in `_physics_process`, mouse in
`_unhandled_input`. `Input.get_vector()` gives correct diagonal normalisation
and deadzone handling free.

**Bind a gamepad from day one.** A controller exposes acceleration curves and
camera-speed problems that keyboard input hides, and it is nearly zero extra
work if done at the start.

> **Why smallest:** any input abstraction layer written this week would be
> written before its requirements are known. Remapping UI, input contexts,
> action buffering, and rebinding persistence are all §13 items.

---

## 8. Interaction Architecture

One interface, expressed as duck typing rather than a class hierarchy.

**`interaction_profile.gd`** — a `Resource`, the entire tuning surface for a verb:

```gdscript
class_name InteractionProfile
extends Resource

@export var prompt_text: String = "Hold to work"
@export var hold_seconds: float = 2.0        # 0.0 = instant
@export var requires_facing_degrees: float = 45.0
@export var interrupt_on_move: bool = true
@export var progress_decay_per_second: float = 0.5   # punishes stop/start
@export var repeats_to_complete: int = 3     # the repeatable-activity dial
@export var completed_mesh: Mesh             # the visible state change
@export var sfx_tick: AudioStream
@export var sfx_complete: AudioStream
```

**`interactable.gd`** — `Area3D`, ~80 lines:

```gdscript
signal focus_changed(is_focused: bool)
signal progress_changed(t: float)
signal completed()

@export var profile: InteractionProfile
```

**Discovery:** the player's `Interactor` `RayCast3D` reports its collider each
physics frame. If it has a `profile`, it is interactable. That is the whole
detection system — no interaction manager, no proximity sorting, no priority
resolution.

**Flow:** ray hits → `focus_changed(true)` → HUD shows `prompt_text` → player
holds `interact` → `progress_changed` drives the HUD bar and a tick sound →
release or move breaks it (progress decays) → on completion the interactable
swaps its own mesh, plays its own sound, and emits `completed`.

> **Why smallest:** a `Resource` per verb means the entire feel of the
> repeatable activity — how long, how punishing, how many repeats, how it
> sounds — is tunable in the Inspector **while the game runs**, with no
> recompile and no code change. That is the difference between five tuning
> passes this week and fifty.

**Verb B (carry)** is not a separate system: pressing `interact` on a prop
reparents it to `CarryAnchor` and applies a speed multiplier and a camera-sway
change on the player. Releasing reparents it back to the world. Roughly 25
lines. It exists because carrying is what makes the player walk the same route
repeatedly (§10) and what gives Hazard A something to threaten.

---

## 9. Player Controller Architecture

One script. `CharacterBody3D`. Roughly 200 lines including the camera.

```gdscript
extends CharacterBody3D

enum State { GROUNDED, AIRBORNE, WORKING, STAGGERED }
var state: State = State.GROUNDED
```

Every tunable is `@export` with a `@export_range` so it has a slider:

```
walk_speed · sprint_speed · carry_speed_mult · acceleration · deceleration
air_acceleration · jump_velocity · gravity_scale · coyote_time · jump_buffer
turn_smoothing · camera_distance · camera_height · camera_pitch_limits
look_sensitivity · camera_lag · fov_base · fov_sprint_add
```

**These exported values are the prototype's actual deliverable.** The code is
disposable; a tuned `player.tscn` is the artifact production inherits.

Required from day one, because they are the difference between "responsive" and
"floaty" and cost about ten lines each:

- **Coyote time** (~0.1 s) and **jump buffering** (~0.12 s).
- **Separate ground and air acceleration.**
- **Camera-relative movement** with smoothed character turn.
- **`move_and_slide()` with `floor_max_angle` and `floor_snap_length` set.**

Deliberately excluded: root motion, animation blending, IK, step-up solvers,
ledge grabs, crouch, dodge, stamina, footstep raycasts against material types.

> **Why smallest:** feel lives in acceleration curves, camera lag, and input
> forgiveness. It does not live in animation. A capsule with a nose cone, tuned
> well, feels better than a rigged character tuned badly — and reveals the
> tuning problem instead of hiding it behind animation.

---

## 10. The Consequence: Path Wear

The one persistent change in the prototype, derived in §2.

**Implementation, ~55 lines total:**

- `wear_map.gd` holds a 128×128 `Image` (`FORMAT_R8`) and an `ImageTexture`.
- Every ~0.15 s, if the player is grounded and moving, map world XZ to pixel
  coordinates and brighten a 3×3 neighbourhood with a falloff. Call
  `ImageTexture.update()` at most a few times per second.
- `ground.gdshader` samples the mask and blends between two colours/roughness
  values. ~15 lines of shader.

**Layout requirement this imposes:** wear is only visible if the player crosses
the same ground several times within 10–15 minutes. **Site A and Site B must
form an out-and-back loop, ~30–40 seconds apart, with a natural narrowing
between them** (the crossing). Verb B provides the reason to make the trip
repeatedly. If the map is laid out as a wander rather than a loop, this feature
ships and teaches nothing.

**Fallback if it exceeds a day:** delete the wear map and make the persistent
change a mesh-state swap on Site A that stays swapped. Weaker, but it still
satisfies "one meaningful consequence." **Do not** reach for a terrain plugin,
a decal system, or mesh deformation. If the cheap version does not work, the
expensive version does not belong in a feel prototype.

> **Why smallest:** an `Image` + `ImageTexture` + two-texture blend is the
> shortest path in Godot from "the player walked here" to "you can see that the
> player walked here." It needs no save system, no persistence layer, and no
> chunking.

---

## 11. Component Recommendations

**Recommendation: almost none.** Composition earns its cost when behaviours
recombine across many entity types. This prototype has three entity types.

| Extract as a component? | Verdict |
| --- | --- |
| Health / damage | No — the prototype has no health |
| Hitbox / hurtbox | No — no combat |
| State machine node | No — see §12 |
| Interactable | **Yes** — already a reusable scene + Resource (§8) |
| Hazard | **Yes** — one `Area3D` script, reused by every hazard volume |
| Camera rig | No — it is a child of exactly one scene |

> **Why smallest:** two reusable pieces, both of which are already reused within
> the prototype. Everything else would be a component with one consumer, which
> is a longer way to write a method.

---

## 12. State-Machine Recommendations

**Recommendation: an `enum` and a `match` block inside `player.gd`.**

```gdscript
func _physics_process(delta: float) -> void:
    match state:
        State.GROUNDED:  _grounded(delta)
        State.AIRBORNE:  _airborne(delta)
        State.WORKING:   _working(delta)
        State.STAGGERED: _staggered(delta)
```

Four states, roughly thirty lines of transition logic. Do **not** use a node
FSM, a `Resource`-based state machine, LimboAI, or a behaviour tree. Those tools
are correct for AI agents with a dozen states and designer-authored logic; this
is one script with four.

> **Why smallest:** with four states, a `match` block fits on one screen and can
> be read top to bottom. A node FSM would replace thirty readable lines with
> four files and an indirection, and would make it *harder* to answer the
> question you are actually asking, which is "why did movement feel wrong for
> 200 ms after landing."

---

## 13. Data-Driven vs Hardcoded

The dividing line: **data-drive what you will tune more than five times this
week; hardcode everything else.**

| Data-driven (`@export` / `Resource`) | Hardcoded |
| --- | --- |
| Every movement and camera number (§9) | Scene structure and node wiring |
| `InteractionProfile` per verb (§8) | Which verb the player has |
| Hazard force, radius, stagger duration | Number of hazards |
| Wear rate, radius, falloff | Ground shader logic |
| Site placement (editor transforms) | The loop's shape |

**No JSON. No CSV. No config files. No content database. No custom importer.**
Godot's Inspector plus `.tres` files is the data layer, and it has live editing,
undo, and type checking already.

> **Why smallest:** any external data format needs a loader, a schema, and an
> error path — code that exists to serve content that does not exist yet.
> `@export` costs one word per number and works while the game is running.

---

## 14. What Can Wait

The most important section. Everything below is **intentionally not built.**

**Explicitly out of scope by directive:** inventory, quests, dialogue,
networking, multiplayer, economy, crafting trees, skill trees, save/load,
procedural generation, NPC schedules, AI civilizations, reputation, UI
frameworks, content pipelines, live service, modding, production asset
workflows, optimization beyond defaults.

**Also deferred, and the reason each defers cleanly:**

*Design decisions that must not be pre-empted*

1. **Combat of any kind.** [GDD §13](../design/GAME_DESIGN_DOCUMENT.md) lists
   combat implementation as an open design question and
   [FIRST_HOUR](../design/experience/FIRST_HOUR.md) leaves "when combat appears"
   unresolved. Building it would decide it. Danger is environmental instead.
2. **Any creature or NPC.** A single enemy costs a creature design, an AI state
   machine, combat verbs, animations, and balance — a week by itself, and every
   piece is a design decision this role may not make.
3. **Death, respawn, and death penalty.** "Death philosophy" is an open design
   question. The prototype's failure state is losing carried progress.
4. **Named places, characters, species, or factions.**
   [FIRST_VALLEY §Current Geographic Hypothesis](../design/world/FIRST_VALLEY.md)
   forbids assigning final names at this stage.
5. **Character creation, stats, classes, levels, XP.**

*Systems that are cheaper to add after feel is known*

6. **Animation, rigs, blend trees, root motion, IK.** Adding animation to tuned
   movement is normal work; tuning movement through an animation layer is not.
7. **Footstep audio keyed to surface material.** One placeholder step sound.
8. **Save/load of any kind.** The wear map dies with the process, and 12 minutes
   of play never needs a save.
9. **A settings menu, pause menu, or main menu.** The game starts in the world.
10. **Audio mixing, buses, occlusion, reverb zones.** Five raw sounds.
11. **Day/night, weather, seasons.** One fixed directional light. Seasons in
    particular are gated behind the world's physical-constraints derivation.
12. **Level streaming, LOD, occlusion culling, GPU profiling.** One small map.
13. **Localisation.** Five strings.
14. **Accessibility options.** Genuinely important; genuinely not this week.
15. **Controller rebinding and input contexts.**

*Architecture that would be premature*

16. **Any autoload beyond `Debug`** (§6).
17. **An event bus or message queue** (§6).
18. **A component/entity framework** (§11).
19. **A node-based or resource-based FSM** (§12).
20. **Server authority, prediction, reconciliation, tick-rate discipline.** See
    §16, risk R4 — this is knowingly deferred, not overlooked.
21. **A shared-code boundary between `game/`, `server/`, and `shared/`.**
22. **Automated gameplay tests, CI for the Godot project, headless test runs.**
23. **Editor plugins, custom inspectors, custom gizmos, level-authoring tools.**
24. **An asset naming convention, import presets, or a materials library.**
25. **`.gitattributes` / LFS for binary assets.** Greybox art is kilobytes.
26. **Performance work of any kind** beyond leaving VSync on.

**If a week runs short, cut from the bottom of Phase 3 upward**
([IMPLEMENTATION_PLAN §Phases](IMPLEMENTATION_PLAN.md)). Movement, camera, and
interaction feel must be finished. A beautiful consequence layered on mushy
movement answers the prototype's one question with "no."

---

## 15. Godot Workflow Recommendations

**Verified locally: Godot 4.7.1 stable.** Pin the whole team to one patch
version for the week; feel tuning across engine versions wastes comparisons.

**Editor workflow**

- **Tune while running.** Run the game, then change `@export` values in the
  Inspector on the running instance. This is the single highest-leverage habit
  in the whole week. Copy the final values back to the saved scene before
  quitting — remote-inspector edits are not persisted automatically.
- **Two-window setup.** Editor on one monitor, game on the other. Never tune
  feel through a "run, quit, edit, run" cycle.
- **`F6` runs the current scene.** Keep `main.tscn` as the only thing you run.
- **Remote scene tree** while playing, to watch state and transforms live.
- **Bind a hotkey to reset the player to spawn.** You will use it hundreds of
  times.

**Scene composition**

- Scenes are prefabs. `player.tscn` and `interactable.tscn` are instanced;
  everything else is authored directly in `main.tscn`.
- Use **editable children** sparingly and **scene inheritance** not at all this
  week.
- Greybox with **CSG nodes** (`CSGBox3D`, `CSGCylinder3D`) for terrain features
  and a **GridMap** if the layout stabilises. Both are built in, both are
  instantly editable, both are meant to be thrown away.
- Three materials total: ground, structure, interactable. Interactables get a
  visibly different colour so the tester can find them without a tutorial.

**Testing workflow**

- **The test is a human with a controller and an observer taking notes.** There
  is no automated test that can answer "does this feel good."
  [IMPLEMENTATION_PLAN §Playtest Protocol](IMPLEMENTATION_PLAN.md) defines it.
- The only automation worth writing: a headless smoke check that the project
  opens and `main.tscn` loads —
  `godot --headless --quit-after 2 --path prototype/` (`--quit-after` counts
frames, not seconds). One CI step, five
  minutes of work, catches broken resource references.
- **Record every session** (OBS or similar). Watching a tester's hesitation at
  1× is worth more than their post-session opinion.
- Keep a `TUNING.md` in `prototype/` — one dated line per meaningful value
  change and what it fixed. This is the actual research output of the week.

### Recommended plugins — one, not five

Each must pass: *does this remove code I would otherwise write this week?*

1. **Phantom Camera** — declarative camera rigs, follow/look targets, damping,
   and blending as editor-tunable resources. *Passes:* camera lag, framing, and
   follow damping are half of third-person feel, and this makes them Inspector
   sliders instead of a script. If day-two `SpringArm3D` results already feel
   acceptable, **skip it** — the built-in is not far behind for one camera, and
   then the prototype has zero dependencies.

**Not a plugin — a project setting.** If the default physics produces character
jitter on slopes or against `CSGBox3D` collision, switch
`physics/3d/physics_engine` to **Jolt Physics**. Verified present in the
installed Godot 4.7.1 binary; no installation required. Do not change it
pre-emptively — changing physics engines mid-week invalidates every movement
value already tuned.

**Deliberately not recommended:** Dialogue Manager (no dialogue), LimboAI /
Beehave (no AI, and §12), any inventory or quest plugin (§14), Terrain3D (§10's
fallback exists precisely to avoid this), GUT / gdUnit (see testing workflow
above), any asset-pipeline or localisation tooling. Every plugin is a
dependency, a version pin, and an upgrade obligation. **"Up to five" is a
ceiling, not a target.**

---

## 16. Technical Risks

| # | Risk | Likelihood | Mitigation |
| --- | --- | --- | --- |
| **R1** | **Camera feel eats the week.** Third-person cameras are notoriously the largest hidden cost, and a bad one makes good movement feel bad. | High | Start with `SpringArm3D` on day one, not day four. Timebox to one day; adopt Phantom Camera if the box is blown. |
| **R2** | **Wear map turns into a terrain project.** §10 tempts scope: bigger textures, blending, normal maps, decals. | Medium | Hard cap: 128×128, one channel, ~55 lines. If day 5 ends without it working, take the mesh-swap fallback and move on. |
| **R3** | **The verb has no skill in it.** A hold-to-complete bar is a progress bar, not a mechanic. If Verb A has no aim, timing, or resistance component, the prototype cannot answer its question — it will only prove that walking feels acceptable. | **High — the single biggest design-adjacent risk** | `InteractionProfile` ships with `requires_facing_degrees`, `progress_decay_per_second`, and `repeats_to_complete` on day one specifically so that "is there a skill here" is tunable, not a rewrite. If no tuning makes it interesting, that is a **finding**, and an important one. |
| **R4** | **Client-authoritative feel may not survive server authority.** [GDD §1](../design/GAME_DESIGN_DOCUMENT.md) describes a persistent online world. Instant, unvalidated movement and interaction will later meet latency, prediction, and reconciliation. Feel numbers tuned locally may not reproduce. | Certain, deferred | **Knowingly accepted.** Networking is correctly out of scope, and no prototype code survives to production anyway. Recorded here so it is not rediscovered as a surprise. The mitigation is the ADR gate before production, not anything built this week. |
| **R5** | **Placeholder becomes precedent.** Someone cites Verb A or the crossing as an established design decision. | Medium | §2 exists for this. Every placeholder is labelled in code and docs. No `DECISIONS.md` entry or ADR asserts a gameplay decision. |
| **R6** | **Greybox ugliness contaminates the verdict.** Testers say "it looks bad" and mean "it feels bad," or vice versa. | Medium | Script the playtest to separate the questions explicitly. State the visual disclaimer aloud before the session. |
| **R7** | **No external tester is available.** A solo verdict on one's own controls is close to worthless. | Medium | Secure at least three testers **before** the week starts. If none can be found, this is a scheduling blocker, not a reason to proceed. |
| **R8** | **A gamepad is added late** and exposes acceleration or camera-speed problems on day six. | Low | Bind it on day one (§7). |

---

## 17. Definition of Done

The prototype is done when **all** of the following are true.

**Buildable**

- [ ] `godot --headless --quit-after 2 --path prototype/` (`--quit-after` counts
frames, not seconds) exits 0.
- [ ] `main.tscn` runs from a clean clone with no manual steps.
- [ ] No script errors or warnings in the output panel.

**Playable**

- [ ] A first-time player, given no instructions, moves, finds Site A, and
      completes Verb A within 90 seconds.
- [ ] A complete session lasts 10–15 minutes without repeating identical
      content more than three times.
- [ ] Keyboard+mouse and gamepad are both fully playable.
- [ ] Stable frame rate on the target machine, with no stutter during
      interaction or hazard events.

**Complete against the brief** — each of these exists and is reachable:

- [ ] Movement and camera.
- [ ] One repeatable activity (Verb A).
- [ ] One meaningful consequence (path wear, or the §10 fallback).
- [ ] One danger (Hazard A).
- [ ] One satisfying reward (site completion: mesh change + sound + camera kick).
- [ ] Readable feedback for every player action.

**Evaluated** — the actual deliverable

- [ ] At least three external testers have played, unassisted, recorded.
- [ ] The [playtest protocol](IMPLEMENTATION_PLAN.md) was run and answers
      written down.
- [ ] `prototype/TUNING.md` records the final tuned values and what changed.
- [ ] A written verdict against the [kill
      criteria](IMPLEMENTATION_PLAN.md), including the honest answer if it is
      "no."

**Explicitly not required for done:** art quality, animation, audio quality,
performance beyond stability, code cleanliness, test coverage, documentation
beyond `TUNING.md`.

---

## Related

- [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) — phases, playtest protocol,
  kill criteria, and the one-week answer.
- [ADR-001: Prototype engine selection](../decisions/ADR-001-prototype-engine.md)
- [DECISIONS.md](../../DECISIONS.md)
