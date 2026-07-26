# Raven's Hollow — Layout Test Sheet

**The prototype question:**

> Does Raven's Hollow feel like a believable frontier settlement that players
> naturally want to explore?

This is a **spatial prototype**. It is not an art pass, not a content pass, and
not a level. Every mesh is a primitive; every material is flat colour. The only
thing being evaluated is *shape* — where things are, how they connect, and
whether the place reads as somewhere people actually live.

Source: `assets/concepts/Ravens Hollow/Ravens_Hollow_v001.png`, treated as
**inspiration, not geometry**. The concept's own note says exact locations,
scale, architecture, population and layout are not canon.

---

## Running it

```
godot --path /home/commander/Documents/umbral/prototype
```

The village is now the project's main scene. **The systems test lab still
exists** and is unchanged:

```
godot --path /home/commander/Documents/umbral/prototype res://main.tscn
```

You start on the **south road**, outside the palisade, beside the first
campfire. Walk north. Controls are exactly as before — click to walk, wheel to
zoom, right-drag to orbit, F1–F6 as documented in the other test sheets.
**F7 hides the debug readout** for a clean look at the village.

---

## Layout philosophy

**The stream comes first.** It enters from the north-west, meanders south-east,
and leaves the map. It is a real trench, cut out of the ground, ~8 m across and
2.8 m deep. It is not scenery: it is a genuine barrier, and it decides the shape
of everything else.

**The bridge is the front door.** The south road runs up the west bank, through
the south gate, and crosses the main bridge to reach the square. **Every arrival
crosses it.** Verified: the route from spawn to the square passes over it, and
there is no other crossing anywhere on the main approach.

**One other crossing exists, far from the road.** A narrow footbridge in the
north-west connects the mill and lumber yard to the village. It is a local
convenience for the people who work that side; it is not on the way in.

**The square is where the roads have to meet.** Main road, north road, the lane
to the smithy and the lane to the inn all converge there, and the well sits in
the middle of it. It is the natural gathering point because it is the only place
you can get to everything from.

**Everything is placed for a practical reason:**

| Building | Why it is where it is |
| --- | --- |
| Mill | on the stream — it needs the water |
| Lumber yard | west edge, closest point to the forest, on the lane to the footbridge |
| Smithy | first substantial building past the bridge on the square side — deliveries reach it without crossing the village |
| Inn | facing the square, visible the moment you come off the bridge |
| Stable | beside the road near the bridge, so travellers leave horses on arrival |
| Well | centre of the square |
| Shrine | off the square, on the quiet north lane |
| Watchtower | on a rise **outside** the palisade, north of the north gate, looking up the forest trail |
| Homes | clustered in threes and fours along lanes, not spaced evenly |

**Nothing is on a grid.** Roads are polylines that bend; buildings are rotated to
face the nearest road with a few degrees of scatter; the palisade is an
irregular closed run that follows the ground rather than an oval.

**The two exits say opposite things.** South is open ground, a wide road, and no
trees — civilisation. North is a narrowing trail through a thickening tree line
with a watchtower over it — the dark forest.

**The ruins are bait.** They sit on a low rise to the east on open ground,
plainly visible from the village side, 183 m and 40 s from the square, and
nothing routes you toward them.

---

## Measured (from the running build)

| | |
| --- | --- |
| South gate → north gate | 167 m, 37 s at walking pace |
| Spawn → village square | 109 m, 24 s |
| Square → well / store / smithy | 10 m / 14 m / 17 m |
| Square → inn / stable / shrine | 29 m / 47 m / 40 m |
| Square → ruins | 183 m, 41 s |
| Landmarks unreachable | **0 of 22** |
| Stream crossings outside the two bridges | **0 of 25 sampled** |
| Navmesh | 7,696 polygons, bakes in 0.9 s at launch |
| Buildings / trees | 15 / 150 |

---

## Assumptions

1. **Scale is mine, not the concept's.** The concept's bar suggests a settlement
   roughly 400 m across; that is ~90 s to walk end to end and did not fit
   "small". This is about 170 m inside the palisade. Scale is explicitly listed
   as non-canon in the concept.
2. **The inn was moved to the square side of the stream.** The concept puts it
   on the west bank. The brief says the inn should be the first destination for
   travellers, and travellers arrive over the bridge from the south-east. Being
   across a second water crossing from the arrival road contradicted that.
3. **Two crossings, not several.** The concept implies more; "the bridge should
   matter" implies fewer. One road bridge plus one working footbridge was the
   compromise.
4. **The palisade is complete except at the gates and where the stream passes
   through.** A frontier village would more likely have a partial fence. This
   reads more clearly as an inside/outside boundary for a spatial test.
5. **The general store is included** (it is in the concept's legend) even though
   the brief did not list it.
6. **Population is not represented at all.** No NPCs, no animals, no props.
   A village with nobody in it will feel emptier than the finished place should.

---

## Known limitations

1. **It is empty.** No people, no livestock, no carts, no washing lines, no
   smoke. Fifteen boxes and a lot of grass. Judge the *shape*; the emptiness is
   not the layout's fault, but it will affect your gut reaction.
2. **Buildings are solid blocks with a painted-on door.** Nothing can be entered.
   Interiors do not exist and are not implied.
3. **No interior lighting, no warm windows** — which is precisely the "warm light
   against a dark world" the concept is about. That is a lighting and art pass,
   deliberately not started.
4. **The forest is 150 cone-and-cylinder trees**, dense to the north and thin
   elsewhere. It reads as a tree line; it does not read as a dark forest.
5. **Terrain is nearly flat**, with three gentle rises (watchtower, ruins, one
   knoll). The concept shows a valley with real elevation. Adding that would
   change routing significantly and should be a deliberate later pass.
6. **The stream is a uniform trench**, same width and depth throughout, with a
   flat water plane. No ford, no shallows, no bank variation.
7. **The mill wheel does not touch the water convincingly** and does not turn.
8. **Roads are flat painted strips**, 12 cm proud of the ground. They do not cut
   or wear into the terrain.
9. **The watchtower cannot be climbed.** It is a solid block; there is no
   interior or ladder, so "overlooks the approaches" is currently a claim about
   sight lines from outside, not something you can stand on top of.
10. **The ruins are five walls and three column stubs.** They suggest a
    structure; they do not yet suggest a story.
11. **150 trees and 1,111 nodes** make the navmesh bake take ~0.9 s at launch.

---

## Observations while building it

- **The stream did the most work.** Once it was a genuine trench rather than a
  texture, the village designed itself: the road had to cross somewhere, the
  crossing became the gate, the gate decided which side the square went on, and
  the mill had nowhere to be except on the water.
- **Making the bridge matter required breaking it first.** The bridge decks
  originally sat 0.5 m proud of the bank — above the character's step height —
  so the navmesh treated both bridges as islands and routed a 205 m detour. The
  fix (deck flush at 0.12 m) is also the reason the bridge now reads as a plank
  crossing rather than a raised span.
- **Facing buildings at the nearest road was enough** to stop the village
  looking placed. A few degrees of scatter on top of that did more for
  "naturally grown" than any amount of moving things by hand.
- **The first layout was too symmetrical and I could see it in plan view**
  before ever loading the scene. An oval palisade and evenly-spaced houses read
  as designed; irregular runs and clusters of three or four read as grown.
- **The west bank is thinly settled** — mill, lumber yard, two homes. That is
  honest (it is the far side of the water) but it may read as unfinished rather
  than as periphery.

---

## Questions for owner playtesting

**Arrival**

- [ ] Walk in from the spawn without stopping. Does approaching over the bridge
      feel like arriving somewhere?
- [ ] Is the inn obvious as the first place a traveller would head for?
- [ ] Does the south gate read as a threshold, or just as two posts?

**Legibility**

- [ ] Turn the camera anywhere in the village. Can you always tell where you
      are without a map?
- [ ] Does the stream help you orient, or do you lose track of which bank you
      are on?
- [ ] Could you describe the layout to someone else after one visit?

**The square**

- [ ] Does it feel like the centre, or just like a wide spot in the road?
- [ ] Is it the right size? Too big reads as a plaza; too small reads as a
      junction.

**The two directions**

- [ ] Stand at the north gate. Does it make you want to go out?
- [ ] Stand at the south gate looking away. Does it read as "toward
      civilisation"?
- [ ] Did you notice the ruins on your own? Did you want to go there? Did you
      go?

**Scale and feel**

- [ ] Is the village too big, too small, or right?
- [ ] Are the buildings too far apart?
- [ ] Does anything feel placed rather than grown? Which?
- [ ] Is there anywhere you expected a path and did not find one?
- [ ] Does the west bank feel like periphery, or like an unfinished corner?

**Regression**

- [ ] Movement, camera, zoom, orbit, click-to-walk, pathfinding, the tree and
      the campfire all still behave as they did in the lab.

---

## Result

Record the outcome here after testing.

- **Does it feel like a believable frontier settlement?**
- **Does it make you want to explore?**
- **What is in the wrong place?**
- **What is missing that would change the answer most?**
- **Scale verdict:**
