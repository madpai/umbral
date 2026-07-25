# Implementation Plan — Feel Prototype 01

> **Status:** Proposed. Engineering plan only. Makes no design decisions.
> **Duration:** 5 working days plus a testing day.
> **Companion:** [PROTOTYPE_ARCHITECTURE.md](PROTOTYPE_ARCHITECTURE.md)

---

## 1. The Smallest Playable Milestone

Not the first hour. **The first enjoyable twelve minutes.**

[FIRST_HOUR §Next Gate](../design/experience/FIRST_HOUR.md) asks for the
smallest segment capable of testing movement, interaction, feedback, one
meaningful activity, and one consequence. This is that segment.

**The loop, in the tester's hands:**

1. The player starts on high ground with the valley visible below. No text, no
   camera pan, no prompt. Control is available in frame one.
2. They walk down. The ground under them is soft and unmarked.
3. They find **Site A** — visibly distinct, no tutorial. Holding `interact`
   while facing it fills a bar. Moving away decays it. It takes three
   completions.
4. Completing a stage changes Site A visibly and audibly. That is the reward.
5. Site A needs material carried from **Site B**, ~35 seconds away across the
   crossing. Carrying is slower and changes how the camera moves.
6. **The crossing is Hazard A.** A force volume pushes the player sideways.
   Crossing while carrying is genuinely harder. Being knocked down drops the
   load, and the load must be recovered.
7. They cross four to six times. **By the fourth crossing, a visible worn path
   has appeared along the route they chose.** Nobody tells them this. It is
   there when they look.
8. Around minute 10–12 the last stage of Site A completes, and the site's final
   state and the worn path they made are both visible in one frame.

**What each brief requirement maps to:**

| Requirement | Implementation | Cost |
| --- | --- | --- |
| Movement | Tuned `CharacterBody3D` | 1.5 days |
| Camera | `SpringArm3D` rig | 0.5 day |
| Interaction | `InteractionProfile` + hold-with-decay | 1 day |
| Feedback | HUD bar, prompt, tween, 5 sounds, camera kick | 0.5 day |
| One repeatable activity | Verb A × 3 stages, gated by Verb B carries | included |
| One meaningful consequence | Path wear | 0.5 day |
| One danger | Crossing force volume | 0.25 day |
| One satisfying reward | Site A stage completion | included |

**Why this and not something else:** it is one loop with three verbs (walk,
work, carry) whose repetition is *demanded by the loop itself*, not by a
tutorial. Repetition is what makes both the wear consequence legible and the
feel question answerable — you cannot judge whether a control scheme is
enjoyable from one traversal.

---

## 2. Learning per Unit of Engineering

Ranked by value returned for effort spent. **Build top-down. Cut bottom-up.**

| Rank | Item | Effort | What it teaches |
| --- | --- | --- | --- |
| 1 | Movement acceleration, deceleration, camera-relative turn | 1 day | Whether UMBRAL is enjoyable to control. **This is the question.** |
| 2 | Camera rig: distance, height, damping, FOV shift | 0.5 day | The other half of the same question. Bad camera invalidates good movement. |
| 3 | Hold-interact with facing requirement and decay | 1 day | Whether the interaction verb has any skill in it. Risk R3. |
| 4 | Feedback layer: prompt, bar, tween, sound, camera kick | 0.5 day | Whether actions read as successful. Cheapest large perceived-quality gain in the project. |
| 5 | Carry + speed/sway modifier | 0.25 day | Whether the world has weight. Creates the traversal loop. |
| 6 | Hazard force volume | 0.25 day | Whether danger without combat produces tension. Highest-value *design* finding of the week. |
| 7 | Path wear | 0.5 day | Whether visible persistence is felt at a 12-minute scale. The only UMBRAL-specific finding available this cheaply. |
| 8 | Greybox layout | 0.5 day | Necessary, teaches little. Timebox hard. |
| 9 | Gamepad | 0.1 day | Exposes curve problems keyboard hides. |

Everything below rank 9 is in
[What Can Wait](PROTOTYPE_ARCHITECTURE.md#14-what-can-wait).

---

## 3. Phases

Each phase ends in a runnable build. **Play at the end of every day.**

### Phase 0 — Setup (half day, Day 1 morning)

- Godot 4.7.1 project at `prototype/`, Forward+ renderer.
- `main.tscn`, a 100×100 `PlaneMesh` ground, one directional light, one
  `WorldEnvironment`.
- `InputMap` actions from
  [§7](PROTOTYPE_ARCHITECTURE.md#7-input-architecture), keyboard **and**
  gamepad.
- `player.tscn` with a capsule, `SpringArm3D`, and `Camera3D`.

**Exit:** a capsule moves on a flat plane and the camera follows.

### Phase 1 — Feel (1.5 days, Day 1 afternoon – Day 2) — *the phase that matters*

- Full movement: acceleration/deceleration, air control, coyote time, jump
  buffer, camera-relative turn with smoothing.
- Camera: damping, pitch limits, distance/height, FOV shift on sprint.
- Debug readout: speed, state, grounded, slope.
- Three CSG ramps and ledges of varying steepness to test against.
- **Spend at least two hours doing nothing but changing exported values while
  running.** Log every change in `TUNING.md`.

**Exit gate — hard stop:** *does moving around an empty box feel good?* If no,
**do not advance.** Spend Day 3 here instead and cut Phase 4. A prototype that
proves movement feels wrong on an empty plane has answered the week's question,
and answered it more cheaply than a full build would have.

### Phase 2 — Interaction (1 day, Day 3)

- `InteractionProfile` resource, `interactable.tscn`, `interactable.gd`.
- `Interactor` raycast, HUD prompt label, HUD progress bar.
- Hold-to-progress with facing requirement and decay on movement.
- Verb B: reparent-carry with speed multiplier and camera sway change.
- Site A (3 stages) and Site B placed roughly.

**Exit:** the player can walk to B, pick up, carry to A, hold to work, and see
the bar fill and the site change.

### Phase 3 — Consequence, Danger, Feedback (1 day, Day 4)

Build in this order; **stop wherever the day ends**:

1. **Feedback pass first** (2 h): 5 placeholder sounds, completion tween, camera
   kick on completion, subtle screen-space nudge on stagger. *Highest
   perceived-quality return in the project; never let it slip to last.*
2. **Hazard A** (2 h): `Area3D` applying lateral force, stagger state, dropped
   carry.
3. **Path wear** (3 h): `wear_map.gd` + `ground.gdshader`. Take the mesh-swap
   fallback ([§10](PROTOTYPE_ARCHITECTURE.md#10-the-consequence-path-wear)) if
   the day runs out.

### Phase 4 — Layout and Polish (1 day, Day 5)

- Shape the greybox into a real loop: the valley slope, the crossing narrowing,
  A and B ~35 s apart. **Layout serves the wear feature; a wander instead of a
  loop wastes it.**
- Tuning pass with fresh eyes.
- Smoke check: `godot --headless --quit-after 2 --path prototype/`.
- Freeze the build. **No code changes after the freeze.**

### Phase 5 — Testing (Day 6)

Run §4. Write the verdict.

---

## 4. Playtest Protocol

**Testers:** minimum three, ideally five. At least two who have never seen the
project. Secure them *before* the week starts (risk R7).

**Setup:** the tester sits down with a gamepad and a keyboard, both available.
The observer says exactly this and nothing more:

> "This is a rough prototype. Everything you see is placeholder art. Play for
> about fifteen minutes. Please think out loud. I won't answer questions while
> you play."

Then **do not speak.** Record screen and audio.

**What the observer writes down, with timestamps:**

- Time to first movement. Time to first jump. Time to find Site A. Time to
  first successful Verb A.
- Every moment of hesitation, every repeated failed input, every time they
  fight the camera.
- Whether they use the gamepad or the keyboard, and whether they switch.
- Whether they ever look at the worn path.
- The point at which they stop trying things and start executing.
- Whether they continue past the point where the loop is complete.

**Post-session questions, in this order** (later questions leak information, so
the order matters):

1. What were you doing?
2. What did you enjoy most? What did you enjoy least?
3. Did anything feel unresponsive or fight you?
4. Did anything about the ground look different at the end than the start?
   *(Only ask this if they never mentioned the path unprompted.)*
5. Would you play another fifteen minutes? Why?
6. What would you want to do next if this were a real game?

**The most important measurement is not an answer to any of these.** It is
whether the tester kept playing after they had seen everything.

---

## 5. Kill Criteria

[FIRST_HOUR §Validation Questions](../design/experience/FIRST_HOUR.md) asks
"what evidence would cause us to remove it?" The same standard applies to the
project.

**Proceed — fund the next stage:**

- Testers describe movement as responsive or better, unprompted.
- At least two testers, having finished the loop, kept playing anyway.
- Verb A produced a visible improvement in tester execution over the session
  (there was something to get better at).
- At least one tester noticed the worn path without being asked, and at least
  three recognised it once asked.
- Testers answer question 6 with something specific.

**Fix and re-test — the concept is sound, an implementation is not:**

- Movement is liked but the camera fights them, or vice versa (isolate and
  re-tune; ~2 days).
- The loop is liked but Verb A is boring (retune the `InteractionProfile`
  before concluding anything; that is a slider change, by design).
- Testers never find Site A (a layout and readability failure, not a design
  failure).

**Stop — this is the honest failure case, and it must be reportable:**

- With a full week of tuning, **basic traversal is not enjoyable**. UMBRAL's
  design depends on the player spending long stretches moving through and
  maintaining a place. If moving through a place is not pleasant, the design's
  central activity has no foundation, and no amount of world derivation repairs
  that.
- **No tuning of Verb A makes the repeatable activity interesting.** The
  philosophy explicitly warns against "treating ordinary work as inherently
  fun." If the prototype demonstrates that warning coming true, that is the most
  valuable finding the week can produce, and it must not be softened.
- **Testers finish and feel nothing at completion.** Reward that lands flat at
  12 minutes will not land better at 60.
- **The consequence is invisible or meaningless to testers.** Persistence is the
  project's core promise ([Vision §The Persistent World
  Promise](../design/UMBRAL_VISION.md)). If the cheapest, most legible form of
  it registers with nobody, the promise needs rethinking before it needs code.

A "stop" result is a successful week. It costs one week instead of a year.

---

## 6. What This Week Does Not Decide

For the record, so nothing here is later cited as precedent:

- No gameplay system is chosen. Verb A, Verb B, and Hazard A are placeholders
  mapped to their open decisions in
  [§2](PROTOTYPE_ARCHITECTURE.md#2-design-inputs-required).
- No geography is established. The greybox uses
  [FIRST_VALLEY](../design/world/FIRST_VALLEY.md) working hypotheses as
  disposable layout.
- No production architecture is chosen. Prototype code is expected to be
  deleted; see [ADR-001](../decisions/ADR-001-prototype-engine.md).
- The world-derivation gate — geology, watershed, climate, seasons, soil,
  hazards — is untouched and remains next.

**How the deferred systems arrive later without being constrained by this
week:** inventory replaces `CarryAnchor`'s single slot; quests attach to
`Interactable.completed` as a listener; dialogue becomes a scene triggered by
the same interaction ray; save/load serialises the `WearMap` image and each
interactable's stage; networking replaces direct `player.gd` input reads with
authoritative input frames. Each is an addition at an existing seam, not a
rewrite — but none of them should be built to preserve that property. They are
listed to show the prototype closes no doors, not to schedule them.

---

## 7. If I Had One Week to Prove UMBRAL Deserves Another Year

**I would build one valley slope, one crossing, and one job — and I would spend
half the week on how it feels to walk.**

Concretely, this is what ships on Friday:

A single greybox valley about 150 metres across. The player starts on the ridge
with the whole space visible, and has control immediately — no camera pan, no
text, no prompt. Down at the water there is a crossing where the current pushes.
On the near side is a structure in three stages of disrepair; on the far side is
the material it needs. The player carries material across the crossing, holds to
work, and does it again. Around minute twelve the structure is whole, and the
route they chose between the two banks is worn visibly into the ground.

Three verbs. No enemies. No inventory. No dialogue. No menus. No save. Roughly
900 lines of GDScript, three materials, five sounds, one map.

**The allocation, and why it is lopsided on purpose:**

| Day | Work | Share |
| --- | --- | --- |
| 1–2 | Movement and camera, tuned live, on an empty plane | **40%** |
| 3 | Interaction and carry | 20% |
| 4 | Feedback, hazard, wear | 20% |
| 5 | Layout and freeze | 20% |
| 6 | Five testers, unassisted, recorded | — |

Two of five days go to a capsule moving on flat ground with no content in it.
That is the correct allocation and it is the recommendation most likely to be
argued with. UMBRAL's design commits the player to spending years walking
through, maintaining, and returning to places. Traversal is not the connective
tissue between the content — in this game it *is* a large fraction of the
content. If it is not pleasant at minute two, no world derivation, no lore, no
system depth repairs it. Every hour spent on a second verb before the first one
feels right is an hour spent decorating an unanswered question.

**What I would refuse to build, and why the refusals matter more than the
build:** no enemy, because an enemy costs a creature design, an AI state
machine, combat verbs, animation, and balance — a week by itself — and every one
of those is a design decision that isn't mine to make. No inventory, because
carrying one object teaches everything about weight that carrying twelve
teaches. No dialogue, because
[FIRST_HOUR](../design/experience/FIRST_HOUR.md) already requires that the game
work with all dialogue skipped, so the prototype should simply be the version
where it is skipped. No save system, because nothing in twelve minutes needs to
survive a restart. No animation, because tuning movement through an animation
layer is how teams ship floaty controls and cannot find out why.

**The one thing in it that is specifically UMBRAL and not any other prototype:**
the worn path. It costs half a day — a 128×128 image, a two-texture shader — and
it is the only element that tests the project's actual thesis, that a world
which remembers participation feels different to inhabit. Everything else in the
build tests whether UMBRAL is a competent game. The path tests whether it is
this game. Notably, it is not an invention:
[FIRST_VALLEY](../design/world/FIRST_VALLEY.md) already records "Every road
began as repeated movement" as an established design rule, and
[RESONANCE](../design/world/RESONANCE.md)'s Second Law already says repeated
participation strengthens continuity. The prototype only makes those two lines
visible on a ground plane.

**And the reason this is worth a year rather than merely encouraging:** on
Friday there are five recordings of strangers playing. Three outcomes are
possible. They enjoy moving and keep playing after the loop is done — then the
mechanical foundation exists, and the next year is spent building the world onto
something that works. They enjoy moving but find the job dull — then the finding
is precise and cheap: the verb is a `.tres` file, and the next iteration is days,
not months. Or nobody enjoys moving through the place, in which case the project
has learned in one week what it would otherwise have learned in year two, when
the world documentation is three hundred pages deep and far more expensive to be
wrong about.

The value of this week is not the build. It is that all three of those answers
cost the same, and only one of them was affordable to discover late.

---

## Related

- [PROTOTYPE_ARCHITECTURE.md](PROTOTYPE_ARCHITECTURE.md)
- [ADR-001: Prototype engine selection](../decisions/ADR-001-prototype-engine.md)
- [First-Hour Design Framework](../design/experience/FIRST_HOUR.md)
- [DECISIONS.md](../../DECISIONS.md)
