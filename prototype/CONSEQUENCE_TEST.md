# First Consequence Experiment — Test Sheet

**The question:**

> Does interacting with the world feel more satisfying when the player's action
> creates a clear, visible consequence?

The previous experiment established that the interaction *flow* is satisfying
when it produces nothing. This one adds exactly one consequence and asks whether
that is better. If it is not, the answer matters more than the feature.

**All causal state here — `has_log`, the tree's depleted flag, the campfire's lit
flag — is disposable prototype scaffolding. It is NOT inventory architecture, not
a resource model, and not a gathering or crafting decision.** There is one
boolean on the player and one boolean on each object. Nothing else.

---

## The causal loop

```
click tree  →  walk into range  →  face it  →  work 1.8 s  →  complete
                                                                 ↓
                                    tree loses its canopy, darkens, stays bare
                                                                 ↓
                                                        player has_log = true
                                                                 ↓
click campfire  →  walk into range  →  face it  →  work 1.1 s  →  complete
                                                                 ↓
                                          log consumed, has_log = false
                                                                 ↓
                                 flame appears, light switches on, fire flickers
```

The player clicks once per step. Navigation, range handling, facing,
cancellation and the interaction state machine are the existing ones, unchanged.

---

## Running it

```
godot --path /home/commander/Documents/umbral/prototype
```

| Input | Action |
| --- | --- |
| Click the tree | Fetch one log (if you are not already carrying one) |
| Click the campfire | Burn the log, light the fire |
| **F6** | Reset the whole scenario: log, tree, campfire |
| F5 / F4 / F3 / F2 / F1 | Ranges / path debug / cameras / control mode / respawn |
| **F7** | Hide/show the debug readout |

The debug HUD shows `log: yes / no` and, briefly, the reason an interaction was
refused.

---

## Ownership

| State | Lives on | Values |
| --- | --- | --- |
| `has_log` | Player | true / false |
| `depleted` | Tree | available / depleted |
| `lit` | Campfire | unlit / lit |

No manager, no global state, no shared store. The object decides whether it will
accept work (`refusal_reason`), taking the player's log state as a plain bool so
it never learns what a player is. The player applies the consequence, in exactly
one function, reached only from the completion branch.

---

## Two deliberate choices

**1. The tree refuses when you already carry a log, rather than completing and
granting nothing.**

The brief described completing and granting only if empty. With a single tree in
the scene, that reading means one careless click while already carrying wastes
the only log source and dead-ends the test until F6. Refusing keeps the rule
identical from the player's side — you can never hold two logs — while removing
the dead end. If the literal behaviour is wanted, it is a one-line change in
`refusal_reason()`.

**2. A lit campfire refuses further clicks rather than running a placeholder
interaction.**

This is the smaller implementation: it reuses the refusal path that already
existed for "no log", and adds nothing. A harmless placeholder interaction would
have needed its own completion branch that deliberately does nothing, which is
more code for a weaker signal.

---

## Owner playtest checklist

**The loop**

- [ ] Click the tree from across the map, watch the whole thing. Does the
      completion land harder now that the tree visibly changes?
- [ ] **Compare against the rock**, which still produces nothing. Same flow, no
      consequence. Is the tree meaningfully better, or about the same?
- [ ] Walk to the campfire and light it. Does the fire appearing feel like
      *your* doing?
- [ ] Press F6 and run the whole loop again. Does it hold up the second time?
      The fifth?

**Readability**

- [ ] Can you tell the tree is spent without reading the HUD?
- [ ] Can you tell you are carrying a log without reading the HUD? (You cannot —
      that is a finding, not a bug. See limitations.)
- [ ] Is the lit fire unmistakable?
- [ ] Click the campfire with no log. Is the refusal readable, or does it feel
      like the click was dropped?

**Trust**

- [ ] Cancel while walking to the tree. Nothing should be granted.
- [ ] Cancel mid-chop with WASD. Nothing should be granted.
- [ ] Cancel while walking to the fire, and mid-lighting. The log must survive.
- [ ] Click the depleted tree, and the lit fire. Both should refuse clearly.
- [ ] Switch targets rapidly. Nothing should duplicate.
- [ ] Zoom and orbit during both interactions.

---

## Known limitations

1. **Carrying a log is invisible.** The character does not hold anything and
   nothing changes on screen; `log: yes` appears only in the debug HUD. This is
   deliberate — a carried-object visual is an art and animation task — but it
   means the middle of the causal chain is the weakest link, and that will
   colour the verdict. Judge it knowingly.
2. **No animation and no sound**, exactly as in the previous experiment. The
   tree pops and changes colour; nothing swings, nothing lands, nothing is
   heard. Consequence is being tested through geometry and colour alone.
3. **The tree does not regrow.** Depleted is permanent until F6. There is no
   regeneration rule, deliberately.
4. **One log, one fire, one use.** No stacking, no counting, no second recipe.
5. **The depleted tree is still solid** and still blocks navigation. Only the
   canopy hides and the trunk darkens.
6. **The fire light is a single `OmniLight3D` with a sine flicker.** Placeholder
   readability, not atmosphere. It is not the visual direction recorded after
   the last playtest, and no art pass was started.
7. **Interaction durations are unchanged from the interaction experiment**
   (tree 1.8 s, campfire 1.1 s). They were **not** lengthened to simulate
   weight. A longer timer is not weight; final pacing stays deferred until
   animation, sound, anticipation, impact and world response can be tested
   together.
8. **Refusal feedback is a 0.5 s red flash plus a debug line.** No tooltip, no
   floating text, no UI.

---

## Unresolved questions

- Does the consequence actually improve satisfaction, or does the *flow* carry
  it and the consequence merely confirm what already worked?
- Would a visible carried log change the answer more than anything else here?
- Should a spent resource ever return, and on what basis?
- Should refusal be a flash, a sound, a character reaction, or nothing at all?
- Should the character auto-chain — click the fire while unequipped and have it
  fetch a log first? That is a large design question, not a small one.
- Is a one-step causal chain enough to judge, or does the question only really
  open up at two or three steps?
- Does any of this survive server authority, where the client cannot decide that
  a log was granted?

None of these should be answered from this prototype alone.

---

## Result

Record the outcome here after testing.

- **Is the consequence version more satisfying than the rock?**
- **What was missing at the moment the tree depleted?**
- **What was missing at the moment the fire lit?**
- **Did carrying an invisible log undermine the chain?**
- **What should be tested next?**
