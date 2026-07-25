# Camera & Perspective Laboratory — Test Sheet

**Phase 1.2 question (answered):** from what perspective should the player
experience UMBRAL? → A too close and avatar-focused for click-to-move; B and C
both promising; C somewhat too distant as a fixed default. Strongest direction
lies between B and C.

**Phase 1.3 question (answered provisionally):** does a freely adjustable
elevated camera, bounded between an Adventure view and a High Strategy view,
make click-to-move feel natural, comfortable, and suited to UMBRAL? → Yes,
provisionally. Hybrid World framing is substantially closer to the intended
UMBRAL experience than any fixed preset.

---

## Provisional direction

Recorded 2026-07-25 after the Phase 1.3 owner playtest. **Provisional means
adopted for continued prototyping, not production canon.**

- **Hybrid World is the provisional camera direction** for continued
  prototyping.
- **Click-to-walk is the provisional primary movement direction.**
- **Mouse-wheel zoom and right-mouse-drag orbit are part of the current
  prototype direction.**
- All of the above **remain subject to later playtesting and are not yet
  permanent production canon.** Any of them may still be revised or dropped.

**Still unresolved, and deliberately unbuilt:**

- Sprint behaviour (hold-to-sprint may be wrong for this control model; a
  run/walk toggle may fit better).
- Jumping (manual jumping may be unnecessary at all).
- Automated or path-driven traversal.
- Touch gestures.
- Pathfinding and obstacle avoidance.

WASD remains a debug comparison mode only. Presets A, B and C remain available
for re-anchoring and are unchanged.

This is a design experiment, not a feature. Only presentation changes between
the four presets; the controller, movement tuning, click-to-move, step-up and
physics are identical in all of them and were re-verified unchanged after every
phase.

**This document deliberately contains no answers and no recommendation.** The
observations below are measurements, not opinions.

---

## Running it

```
godot --path /home/commander/Documents/umbral/prototype
```

| Key | Action |
| --- | --- |
| **Mouse wheel** | Zoom the Hybrid World camera (up = in, down = out) |
| **Hold right mouse + drag** | Orbit — horizontal yaws, vertical pitches |
| **Arrow keys** | Orbit without the mouse (same speed as gamepad look) |
| **F3** | Next camera preset (cycles H → A → B → C → H) |
| F2 | Switch control mode (click-to-move ↔ WASD) |
| F1 | Reset to spawn |
| Left click | Set destination (click-to-move mode) |
| Hold right mouse | Orbit camera (click-to-move mode) |
| Esc | Release mouse for Inspector edits (WASD mode) |

The build opens on **H · Hybrid World**. The active preset, live distance,
pitch, FOV and control mode are on the debug HUD. Switching is instant — no
reload, no fade, no second camera. Zoom is preserved while orbiting.

A, B and C are unchanged from Phase 1.2 and remain available for comparison.

**Tune while running.** Select `Player` in the remote scene tree, open
`Camera Laboratory → Camera Presets`, and edit any preset's values live. Godot
does not save edits made to a running instance; copy keepers back into
`camera/presets/*.tres`.

---

## Measured framing

Taken from the running build, not estimated. "Character height share" is how
much of the screen's vertical the 1.8 m capsule occupies at rest.

### Hybrid World across its zoom range

| | Fully zoomed IN | Default (launch) | Fully zoomed OUT |
| --- | --- | --- | --- |
| Distance | **7.50 m** | **13.00 m** | 20.00 m |
| Pitch | −23.9° | **−35.4°** | −50.0° |
| Elevation | 23.9° | 35.4° | 50.0° |
| Field of view | 63.6° | **57.6°** | 50.0° |
| **Character height share** | ~16.7% | **~11.5%** | ~8.8% |

The close bound was moved in from 9.00 m to 7.50 m at the owner's request. It
now sits at roughly **Adventure's elevation angle (23.9° vs B's 24.0°) but a
full metre closer than Adventure's distance** — closer than the Adventure limit,
while remaining clearly distinct from Classic Third Person, which is 2.5 m
nearer still, 10° lower, and puts the character at 21.1% of screen height.

The zoom-out end still matches C exactly. The camera cannot reach A's framing,
by design, and the −18° pitch ceiling prevents zooming into an over-the-shoulder
view.

### Fixed comparison presets (unchanged)

| | A · Classic Third Person | B · Adventure | C · High Strategy |
| --- | --- | --- | --- |
| Camera distance from pivot | 5.00 m | 8.50 m | 20.00 m |
| Camera height above pivot | 1.21 m | 3.46 m | 15.32 m |
| Elevation angle | 14.0° | 24.0° | 50.0° |
| Field of view | 75° | 65° | 48° |
| **Character height share** | **~21%** | **~15%** | **~9%** |

---

## Phase 1.3 procedure — Hybrid World

Spend most of the session in **H**. Use A/B/C only to re-anchor.

1. **Find your resting zoom.** Play normally for a few minutes and let your hand
   settle wherever it wants. Note the distance shown on the HUD. That number is
   the single most valuable output of this test.
2. **Zoom while travelling.** Click a far destination, then zoom in and out
   during the walk. Does the coupled pitch help or fight you?
3. **Orbit while travelling.** Right-drag during a walk. The character must keep
   moving toward its destination and the camera must not auto-recentre.
4. **Zoom, then click.** Confirm the click lands where you expected at both
   extremes. (Measured error is 0.0000 m — if it ever feels wrong, that is a
   perception problem, which is itself worth reporting.)
5. **Orbit 180°, then click.** Same question with the world behind you.
6. **Use only the arrow keys** for a minute. Does keyboard orbit feel viable as
   a fallback, or as a mobile-shaped control?
7. **Do the stairs and ramps** at a few zoom levels. Where does terrain stop
   being readable?

### Phase 1.3 questions

- Does a single adjustable camera remove the need to choose between B and C?
- Where does your hand settle, and does it stay there or keep moving?
- Is coupling pitch and FOV to zoom helpful, or would you rather they were
  independent?
- Are the zoom limits in the right place? Do you ever want to go closer or
  further than allowed?
- Does right-drag orbit ever get confused with clicking to move?
- Does the cursor jumping back after a right-drag feel right?
- Is the zoom response speed (`zoom_response`, currently 9.0) too fast or slow?

---

## Phase 1.2 procedure — preset comparison

Do the same five things in each preset before forming any opinion, and do them
in a different preset order the second time round — first impressions favour
whichever you saw first.

1. **Cross open ground.** Click a far destination and watch the whole trip.
2. **Short hops.** Click three or four nearby points in quick succession.
3. **Navigate scenery.** Send the character toward the ramps, the staircase and
   between the two pillars.
4. **Turn the camera.** Hold right mouse and orbit while moving and while still.
5. **Sit still and look.** Spend fifteen seconds not playing, just looking.

Then repeat step 1 and 2 on WASD (F2) in each preset.

---

## Questions

Answer per preset. There is no scoring; prose is more useful than numbers.

### Control

- Which camera makes click-to-move feel most natural?
- Where do you *want* to click in each preset — near the character, or far ahead?
- Can you tell where the character will end up before it gets there?
- Does any preset make you misjudge a click? Where does the error come from —
  the angle, the distance, or the lens?
- Does any preset make WASD feel worse than click-to-move, or vice versa?

### World versus avatar

- Which camera emphasises the world instead of the player?
- In which preset do you look at the character, and in which do you look past it?
- Does the character stop feeling like "you" at any distance? Where?
- Which preset makes the greybox look biggest? Which makes it look smallest?

### Exploration

- Which camera makes exploration more inviting?
- In which preset do you notice scenery you had not noticed before?
- Which one makes you want to go somewhere specific rather than wander?
- Does any preset make the space feel more or less enclosed than it is?

### Endurance

- Which camera feels appropriate for long play sessions?
- Which would tire you first, and why — motion, framing, or having to adjust it?
- How often did you feel the need to move the camera manually in each preset?
  (Needing to adjust constantly is a finding.)

### Mobile

- Which camera best supports eventual mobile play?
- Where would your thumb sit, and would it cover anything that matters?
- At phone size, would you still be able to see the character?
- Which preset needs the least camera control from the player? (On touch,
  camera control is expensive.)

### Identity

- Which camera feels most like UMBRAL?
- Which one best suits a world that is meant to feel older than the player and
  to continue without them?
- Which one would you be happy looking at for a hundred hours?

### Disqualifying

- Is there anything in any preset you could not live with?
- Did anything break, pop, clip or obscure the character?
- Did any preset make you feel motion discomfort?

---

## Things worth watching for

Not answers — known places where a preset could mislead you.

- **H disables obstruction avoidance**, like C. At 9–20 m the spring arm would
  otherwise punch through terrain while zooming. The cost is the same: the
  camera can end up behind tall geometry.
- **H's pitch ceiling is −18°**, so zooming all the way in still cannot produce
  an over-the-shoulder view. Zooming in is not a route back to preset A.
- **A is the Phase 1.2 control group** and remains available. It has already
  been judged too close for click-to-move; it is kept only for re-anchoring.
- **C has camera obstruction avoidance switched off** (`avoid_obstructions =
  false`). At 20 m the arm would otherwise slam through terrain constantly, and
  that popping would be mistaken for the perspective feeling bad. The trade is
  that near tall geometry the camera can end up behind something. If that
  happens often, note it — it is a genuine cost of the high view.
- **C's pitch is clamped to −30°..−72°** so it cannot be levelled out into a
  third-person camera mid-test. Same for B's +18° ceiling. If a limit feels
  wrong, that is itself worth reporting.
- **Sprint FOV punch is reduced in B and removed in C.** A speed cue that works
  at 5 m does almost nothing at 20 m. If C feels like it lacks a sense of speed,
  that may be the cause, and it is one slider away.
- **Distance and FOV trade off.** A far camera with a wide lens looks different
  from a near camera with a narrow one even at identical character size. If a
  preset is close but not right, try changing FOV before distance.
- **Damping differs by design** (14 / 10 / 7). Higher cameras are given a
  looser follow because a distant camera that tracks tightly reads as rigid.

---

## Unresolved control questions (owner observations, not decisions)

Recorded during the Phase 1.2 test. **Nothing here has been changed in the
build** — the controls are exactly as they were.

- **Shift-to-sprint may be inappropriate for the intended control model.** Hold
  to run assumes a hand parked on the keyboard, which a click-to-move game does
  not.
- **A run/walk toggle may fit better than hold-to-sprint.**
- **Manual jumping may be unnecessary.** With destination-based movement there
  may be nothing for a jump button to express.
- **Traversal jumps may eventually be automatic or path-driven, if jumping
  exists at all.** A character that decides for itself how to cross a gap is a
  different design from one the player pilots over it.

These are open design questions. They belong to a later phase, and they interact
with pathfinding — which is also deliberately not built yet.

---

## Likely future touch mappings (note only — not implemented, not canon)

Recorded so the desktop controls do not accidentally foreclose them. None of
this is built, and none of it is a decision.

- **Single tap:** destination or interaction.
- **One-finger drag / screen-edge gesture:** unresolved.
- **Pinch:** likely zoom.
- **Two-finger drag:** possible orbit.

Touch currently maps only to destination requests, exactly as a left click does.
No touch camera gestures exist.

---

## Result

Record the outcome here after testing. A tie or "none of these" is a valid
result; so is "B, but at C's distance".

- **Does the Hybrid World camera settle the B-versus-C question?**
- **Resting distance your hand chose:**
- **What would have to change about it:**
- **Should zoom-coupled pitch and FOV stay coupled?**
- **Are the zoom limits right?**
- **Is a fixed preset still preferable to an adjustable one?**
