# Raven's Hollow — Atmosphere Test Sheet

**The prototype question:**

> Can atmosphere transform Raven's Hollow from a functional layout into a
> place players emotionally want to return to?

This is **not** an art pass. The layout experiment (`RAVENS_HOLLOW_LAYOUT_TEST.md`)
passed owner review — "the layout is easy to learn" — and every road, the
bridge, the stream, the buildings, the gates, the terrain and the watchtower
are **frozen**. Nothing in this pass moves geometry. Every technique below is
lighting, fog and flat emissive colour laid over the existing greybox.

The target feeling, in the owner's words for this pass:

> "I'm safer inside than outside."

---

## Running it

```
godot --path /home/commander/Documents/umbral/prototype
```

Village is still the project's main scene. Controls are unchanged: click to
walk, wheel to zoom, right-drag to orbit, F7 hides the debug readout.

---

## Techniques used

All changes are lighting, fog and unlit-emissive materials. No mesh moved, no
collision shape moved, no new StaticBody3D was added to the terrain.

**1. Dusk sky and ambient.**
`ProceduralSkyMaterial` reworked: a deep blue-violet zenith
(`sky_top_color`), a warm orange horizon (`sky_horizon_color`), and a dark,
desaturated ground. `Environment.ambient_light_energy` dropped to `0.6` and
`background_energy_multiplier` to `0.85` so the world reads dim by default —
everywhere is a little dark unless something local is lighting it.

**2. Warm, low sun.**
`DirectionalLight3D` energy cut from `0.95` to `0.5` and its colour warmed
from near-white to amber (`Color(1, 0.72, 0.48)`). The sun still throws
shadows; it just no longer reads as midday.

**3. Cold fog.**
`fog_density` raised (`0.0018` → `0.0035`) and `fog_light_color` shifted
toward a cool blue-grey (`Color(0.34, 0.37, 0.47)`), with a small amount of
`fog_sun_scatter` (`0.15`) so the horizon still catches a little dusk colour.
Depth fog only — no volumetric fog, no GPU-heavy features. This is the
"colder outside" read: distance now visibly desaturates and cools.

**4. Warm light spilling from the inn.**
Two small unlit-emissive quads (`WindowL`, `WindowR`) on the Inn's front
face, plus two `OmniLight3D` (`WindowGlowL`/`R`, no shadows, range 6 m)
positioned just outside the wall so the glow actually falls on the ground and
road in front of the inn, not just the wall texture.

**5. Smithy forge glow.**
One larger, hotter-coloured emissive quad (`ForgeGlow`, orange-red rather
than the inn's amber) beside the smithy door, plus one `OmniLight3D`
(`ForgeLight`, no shadows, range 7 m) — reads as a working forge rather than
a lit window.

**6. Village-square campfire.**
A second campfire — visual only, not an `Interactable`, no collision — sits
near the well (`Atmosphere/VillageCampfire`, world `12, 0, 25`). Same stones
+ flame look as the existing spawn campfire, with its own warm `OmniLight3D`
(shadows off, to keep this pass cheap). This is the heart-of-the-village glow
distinct from the spawn campfire outside the palisade.

**7. Four lanterns along the main paths.**
Simple post + lamp + `OmniLight3D` (no shadows, range 6 m, warm amber),
placed at:

| Lantern | World position | Marks |
| --- | --- | --- |
| 1 | (7.5, 0, 118) | South road, before the south gate |
| 2 | (16.5, 0, 52) | Approach from the main bridge |
| 3 | (21, 0, 22) | The square, near the well |
| 4 | (23, 0, -4) | North road — **the last lit point before the trail goes dark** |

Lantern 4 is deliberately short of the north gate (gate posts sit at
`z ≈ -63`). The lit road runs out roughly 60 m before the palisade ends and
the forest begins — the light does not follow you out.

**8. Darker forest by omission, not by new geometry.**
No tree material changed, no tree moved. The forest reads darker purely
because it sits outside every light pool placed above and gets nothing but
the dim, cool dusk ambient and the low warm sun. The contrast is the effect —
built entirely from where light *isn't*, not from new dark materials.

All new lights have `shadow_enabled = false` except the sun and the original
spawn campfire (which already had shadows before this pass). Nine new lights
total across the village; nothing added is a particle system or a
post-process (no glow/bloom, no volumetrics).

---

## Where the atmosphere nodes live

- Inn windows/lights: children of `NavRegion/Terrain/Buildings/Inn_RavensRest`
  (coincide with the inn's own footprint, so they cannot change navmesh
  parsing — they're inside an obstacle that already exists).
- Forge glow/light: children of `NavRegion/Terrain/Buildings/Smithy`, same
  reasoning.
- Village campfire and all four lanterns: under a new **`Atmosphere`** node,
  a sibling of `NavRegion` under the scene root — **outside** the
  `NavigationRegion3D` subtree entirely, so none of it is parsed as
  navigation source geometry regardless of Godot's default parse mode.

This was verified, not assumed: baking `NavRegion`'s navmesh after loading the
edited scene still produces **7,696 polygons** — identical to the number
recorded in `RAVENS_HOLLOW_LAYOUT_TEST.md` before this pass. The atmosphere
pass has zero effect on pathfinding.

---

## Things intentionally omitted

Per the brief, none of the following were added:

- No NPCs, dialogue, quests, or combat.
- No inventory or crafting.
- No weather system.
- No particle effects (no smoke, embers, or fireflies).
- No glow/bloom, volumetric fog, SSAO, or other expensive rendering
  features — depth fog and emissive materials only.
- No final art — every new material is a flat `StandardMaterial3D` with
  optional emission, matching the existing greybox style exactly.
- No sound or music.
- No home windows, no gate torches, no watchtower light. The brief named
  the inn, the smithy, a village campfire, and "a few lanterns" — that is
  what's implemented, nothing more, so the answer to the prototype question
  isn't muddied by extra light sources.

---

## Validation

**Navigation regression:** confirmed by script — navmesh bakes to the same
7,696 polygons as the pre-atmosphere layout. Movement, camera, interaction
and consequence systems are untouched (no scripts changed).

**Walk: south road → bridge → square → inn → north gate**

| Leg | What should be visible now |
| --- | --- |
| South road (spawn, z≈124, beside the spawn campfire) | Warm campfire glow already existed here; now framed by a dimmer, cooler dusk sky instead of flat daylight. Lantern 1 visible ahead on the approach. |
| South gate (z≈94) | Passing from open, fog-cooled ground into the palisade. |
| Main bridge (z≈74) | Lantern 2 visible on the far bank, pulling the eye toward the village rather than the dark tree line to either side. |
| Square (well at 16,0,29) | Village campfire and Lantern 3 both visible; this is the brightest, warmest point on the route. |
| Inn (33,0,37) | Two lit windows visible the moment you clear the bridge, exactly where the layout doc says the inn should read as the first destination — now it reads as one *visually*, not just spatially. |
| North road (north1–north4, z from -4 to -73) | Lantern 4 is the last light; the trail beyond it runs into the cooler, foggier, unlit stretch toward the north gate and watchtower. |

Because none of the new nodes carry collision and the freestanding ones sit
outside the `NavigationRegion3D` subtree, this route is guaranteed to be
exactly as walkable as before. What still needs a human is whether it *feels*
different — that's the owner playtest below.

---

## Owner playtest checklist

**Contrast**

- [ ] Standing at the south gate looking in, does the village read as warmer
      than the ground you just crossed?
- [ ] Standing at the north gate looking out, does the forest read as colder
      / darker than the square you just left?
- [ ] Is there a moment on the walk where you *feel* the shift from outside
      to inside, or does it feel uniform throughout?

**Landmarks and orientation**

- [ ] With the new lighting, can you still tell where you are without a map,
      the same as in the layout pass?
- [ ] Do the inn's windows read as "the inn" before you're close enough to
      see its shape, the way the brief asks for?
- [ ] Does the smithy's glow read as *forge*, distinct from the inn's window
      glow, or do they look the same?
- [ ] Do the lanterns help you follow the road at a glance, or are they too
      sparse / too dim to register?

**Does it change how the place feels**

- [ ] Does the village feel like somewhere you'd want to return to, more
      than it did in the flat-lit layout pass?
- [ ] Is the effect too subtle, about right, or overdone for a prototype?
- [ ] Does anything about the new lighting fight the layout — a light that
      makes a landmark harder to read, a dark patch that obscures a turn?

**Regression**

- [ ] Movement, camera, zoom, orbit, click-to-walk, pathfinding, and
      interacting with the tree/rock/spawn campfire all still behave as
      they did before this pass.

---

## Known limitations

1. **Only two buildings have interior-implied light.** Homes, the general
   store, the stable, the mill and the lumber shed are still flat and dark.
   If the owner wants "the whole village feels lived-in," that is a bigger
   pass than this question asked for.
2. **The lanterns don't flicker.** They are static `OmniLight3D`s at a fixed
   energy — a placeholder for "there is light here," not a campfire-light
   simulation.
3. **No bloom.** Windows and the forge glow are bright flat emissive
   surfaces; without glow enabled they don't visually "bleed" into the dark
   the way a finished light pass would. Deliberately left out as an
   expensive rendering feature the question didn't need answered.
4. **Fog is uniform depth fog, not height fog.** It cools distant objects
   evenly rather than pooling in the stream bed or thickening in the forest
   specifically — a coarser tool than the brief's "gentle fog... if it
   improves depth" ideally wants, but cheap and sufficient to test the
   question.
5. **The village campfire is decorative only.** Unlike the spawn campfire,
   it is not an `Interactable` — it has no collision, no progress ring, no
   profile. If the owner wants it to behave like the other campfire, that's
   a follow-up, not part of this atmosphere question.
6. **Sun shadow direction unchanged.** Only the sun's colour and energy were
   tuned, not its angle — a true "low dusk sun" would rake shadows further
   and might sell the time of day more. Left alone to avoid touching a value
   that also determines readability of the terrain's gentle rises.

---

## Result

**Verdict: PASS.**

The atmosphere prototype successfully transforms Raven's Hollow from a
functional greybox into a place that feels inhabited and comparatively safe.
The intended emotional contrast is present:

- The settlement interior reads warm.
- The wilderness reads colder and less welcoming.
- Local light sources make destinations legible.
- Landmarks and navigation remain readable.
- The village square reads as a natural social centre.
- The lighting makes the owner want to see the settlement developed further.

**Owner observations:**

- The lantern route supports orientation without resembling explicit game UI.
- Inn windows successfully imply life inside.
- Forge glow communicates building function.
- The village campfire strengthens the square as the settlement's heart.
- **Dark gaps between lights should be preserved — do not uniformly
  illuminate the village.** The contrast is the point; closing the dark
  gaps would undo the pass.
- The closest lantern fixture (Lantern 1, south road) is visually crude and
  too bright. This is a placeholder presentation issue, not a failure of
  the atmosphere direction — the fixture mesh and its energy value are
  candidates for tuning, not the technique.
- Final window-light placement and falloff may need adjustment during a
  later presentation pass.

**No further atmosphere features are authorized now.** This experiment is
closed pending a dedicated presentation/art pass; do not add more lights,
props, or effects to Raven's Hollow off the strength of this result alone.
