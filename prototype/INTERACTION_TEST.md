# Interaction Experiment — Test Sheet

**The question:**

> Does interacting with the world feel satisfying?

**Answered: yes.** Owner verdict, 2026-07-25 — the interaction prototype passes.
The click-object → navigate → enter range → face → interact → complete flow feels
good, and the combined prototype makes the owner want to continue playing.

Two future-facing observations were recorded at the same time. **Neither has been
applied to this build, and neither is a decision.** See
[Future-facing observations](#future-facing-observations-provisional).

Not "can we build an RPG". There is **one interaction**, and it deliberately
produces nothing: no resource, no item, no number, no progress toward anything.
Completion itself is the thing being evaluated. If the click → walk → turn →
work → done loop is not satisfying when it rewards nothing, adding rewards will
not fix it — it will only hide the answer.

**This implementation is disposable and is not production interaction
architecture.**

---

## Running it

```
godot --path /home/commander/Documents/umbral/prototype
```

| Input | Action |
| --- | --- |
| Hover an object | It brightens |
| Left click an object | Walk into range, turn to it, work, complete |
| Left click the ground | Cancels any interaction and walks there |
| WASD | Cancels any interaction and takes manual control |
| **F5** | Show each object's interaction radius |
| F4 / F3 / F2 / F1 | Path debug / cameras / control mode / reset |
| **F7** | Hide/show the debug readout |

Three objects sit near spawn: a **tree** at `(-9, 4)` — the primary test object —
a **rock** at `(7, -1)` and a **campfire** at `(0, 0)`. The rock and campfire run
the same interaction with different timings; they exist to check that the flow is
not accidentally tree-shaped.

Objects return to available a few seconds after completing, so repeated
interaction can be tested. That timer is a testing convenience, **not** a
respawn rule.

---

## What each part owns

- **Objects own their behaviour and their feedback.** An `Interactable` tints
  itself, pulses itself, grows its own progress ring and plays its own
  completion pop. It knows nothing about the player, the camera or navigation.
- **The player owns orchestration.** It decides whether to walk, when it is in
  range, when it is aimed well enough to start, when work completes, and what
  cancels it.
- **`main.gd` only routes the click** and relays feedback signals.
- There is no interaction manager, no registry and no global state.

Tuning lives in `interaction/profiles_*.tres` and can be edited while running.

---

## Owner playtest checklist

**The core loop**

- [ ] Click the tree from across the map. Watch the whole trip. Does the
      character look like it *decided* to go and do something?
- [ ] Does it stop at a sensible distance, or does it stand awkwardly close /
      far?
- [ ] Does the turn-to-face read as deliberate, or as a snap?
- [ ] Is the pause before completion too long, too short, or right?
- [ ] **Does completion land?** This is the whole question. Is the pop plus the
      colour change enough, or does it feel like nothing happened?
- [ ] Do it ten times in a row. Does it get boring at three, or is it still
      pleasant at ten?

**Control and trust**

- [ ] Click the tree while already walking somewhere else.
- [ ] Click the rock halfway through walking to the tree.
- [ ] Click the tree while standing right next to it — it should not walk.
- [ ] Click the ground mid-interaction. Does cancelling feel responsive?
- [ ] Press WASD mid-interaction. Same question.
- [ ] Stand on the raised platform and click the tree. It should refuse.
- [ ] Zoom right in and right out, orbit behind the tree, then click it.

**Feedback**

- [ ] Is hover obvious enough to tell you an object is clickable?
- [ ] Press F5. Are the interaction radii the right size?
- [ ] Can you tell the difference between "walking to it" and "working on it"
      without reading the debug text?

---

## Known limitations

1. **There is no animation.** The character stands still and turns; the pulse is
   on the *object*, not the character. A real interaction would have the body
   do something, and its absence probably makes completion feel flatter than it
   would in production. Judge the timing and the flow, not the performance.
2. **No sound.** Interaction feedback is the single place where audio does the
   most work per unit of effort, and there is none here. Expect the loop to feel
   noticeably better once it exists.
3. **Hover uses a per-frame mouse raycast.** Fine for three objects, wrong for a
   world. Not production code.
4. **Objects reset after a few seconds.** A test convenience so repeats can be
   tried. It is not a resource or respawn decision.
5. **The character can be interrupted into an odd pose.** Cancelling mid-turn
   leaves it facing part-way. Harmless, but visible.
6. **Approach points are geometric, not tactical.** The character walks to the
   near side of the object in a straight line from wherever it stands; it does
   not prefer a nicer side, avoid standing on a slope, or care what is behind
   it.
7. **Nothing is produced.** Deliberate. See the top of this document.
8. **Interaction range is per-object, not per-verb.** There is only one verb.

---

## Unresolved questions

- Does completion need a reward to feel satisfying, or is that the trap the
  first-hour framework warns about ("treating ordinary work as inherently fun")?
- Should interaction time be fixed, or should skill/tools/state change it?
- Should the character be interruptible mid-work, or should work commit once
  started?
- Should a second click on the same object queue, repeat, or cancel?
- Should objects show their range permanently, on hover, or never?
- What happens when two interactions are possible at the same spot?
- Does any of this survive a server-authoritative design, where the client
  cannot decide that work finished?

None of these should be answered from this prototype alone.

---

## Result — owner verdict, 2026-07-25

**PASSES.**

- **Does completion feel satisfying?** Yes.
- **Does the flow hold together?** Yes — click, navigate, enter range, face,
  interact, complete all read as one intentional action.
- **Does it make you want to keep playing?** Yes, in combination with the
  movement, camera and navigation work.

Nothing in the prototype was changed as a result of this verdict. The timings,
ranges, tints and placeholder shapes recorded above are exactly what was judged.

---

## Future-facing observations (provisional)

Recorded 2026-07-25 alongside the verdict. **These are directional notes for
later evaluation, not decisions, and not canon.** Nothing here has been applied
to the prototype, and nothing here should be cited as precedent.

### 1. Intended production pacing should feel slower, heavier, more deliberate

The current prototype timings are not the target. **Do not simply lengthen the
prototype timers** — a longer progress bar is not weight, and stretching
`duration` now would only make the prototype worse while teaching nothing.

Pacing should be evaluated later, once the things that actually carry weight
exist:

- character animation
- sound
- anticipation (wind-up before the action)
- impact (the moment the action lands)
- world response (what the world does back)

This is deliberately left open. The prototype's known limitations already record
that it has no animation and no sound, and that their absence probably makes
completion feel flatter than production would. Pacing cannot be judged honestly
until that is no longer true.

### 2. Intended visual direction is darker, more grounded, less toy-like

Directional inspiration:

- **Ultima Online** — environmental readability and world-oriented presentation;
  the world reads as a place rather than a stage for the avatar.
- **Diablo I** — darkness, material age, localised lighting, oppressive mood.

**This is inspiration, not a decision to build a literal pixel-art or
fixed-isometric clone.** It does not decide art style, rendering technique,
resolution, palette or projection. In particular it does **not** override the
provisional Hybrid World camera, which is a free-orbit perspective camera and
not a fixed isometric one.

The current greybox is placeholder and was never intended to represent the
visual target. It stays as it is.

---

## What is still not decided

Everything in [Unresolved questions](#unresolved-questions) above remains open,
plus the two observations here. The next prototype question has not been chosen,
and gathering, inventory and crafting remain deliberately unbuilt.
