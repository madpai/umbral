# Navigation Experiment — Test Sheet

**The question:**

> Can the player click a reachable point in the visible world and trust the
> character to find a sensible route there?

**This implementation is disposable and is not production navigation
architecture.** It is the smallest thing that answers the question above: stock
Godot `NavigationRegion3D` + `NavigationMesh` + `NavigationAgent3D`, baked once
at startup, with no navigation manager, no path service, no custom A*, no
hierarchy, no dynamic rebuilding and no crowd avoidance. There is one player and
no NPCs. None of it is a decision about how UMBRAL will navigate later.

The provisional direction from earlier phases is unchanged: Hybrid World camera,
click-to-walk, wheel zoom, right-drag orbit. Movement, step-up, acceleration,
deceleration, turning and slope handling were not touched, and were re-measured
as identical.

---

## Running it

```
godot --path /home/commander/Documents/umbral/prototype
```

| Key | Action |
| --- | --- |
| Left click | Set destination (routes around obstacles) |
| **F4** | Toggle the agent's path debug drawing |
| Hold right mouse | Orbit · Mouse wheel: zoom |
| F3 / F2 / F1 | Cameras / control mode / reset |
| WASD | Debug direct control — **cancels the current path** |

The HUD shows navigation state, remaining path length and waypoint count.
There is also a `Navigation → Use Navigation` checkbox on the `Player` node:
turning it off reverts to the Phase 1.1 straight-line steering, which is the
honest A/B for whether routing is actually earning its place.

---

## What the greybox now contains for routing

Two obstacles were added, and nothing else:

- **A plain wall** — 18 m × 3 m at `(-34, 12)`. Tests going around one end.
- **A U-shaped obstacle** — three walls at `(34, 12)` opening south. Tests a
  route that must first move *away* from the target.

Everything else (pillars, staircase, ramps, platform) is unchanged from earlier
phases.

---

## Owner playtest checklist

Do these in click-to-walk mode. Press **F4** first if you want to see the path.

**Routing**

- [ ] Click across open ground. Does the character go straight, or wander?
- [ ] Click on the far side of a pillar. Does it round the pillar cleanly, or
      clip the corner / swing wide?
- [ ] Click past the long wall. Does the detour read as a decision or as a
      mistake?
- [ ] Click inside the U. The character must first walk *away* from where you
      clicked. **Does that feel intelligent or broken?** This is the single most
      informative click in the whole test.
- [ ] Click part-way up the 30° ramp. See the known limitation below first.
- [ ] Click up and down the staircase.

**Trust**

- [ ] Click somewhere, then immediately click somewhere else. Does it turn at
      once?
- [ ] Click rapidly, five or six times. Does anything stutter or lock up?
- [ ] Click the red 50° ramp, and the top of a pillar. Both should flash a red
      marker and refuse.
- [ ] Does a refused click read as a rule, or as the game ignoring you?
- [ ] Ever feel the character took a route you would not have chosen?

**Non-regression**

- [ ] Zoom fully in, fully out, orbit 180°, then click. Still accurate?
- [ ] Does WASD still cancel a path and take over?
- [ ] Does arrival still stop cleanly, with no oscillation at the marker?

**The comparison worth making**

- [ ] Turn `Use Navigation` off in the Inspector and repeat the pillar and wall
      clicks. How much worse is straight-line steering, really? If the answer is
      "barely", that is a finding about how much navigation the design needs.

---

## Known limitations

1. **The 30° ramp is entered from its side, not from its foot.** The character
   reaches the ramp and can walk up and down it, but the computed route walks
   *past* the ramp, along the ground, and climbs on near the top from the west
   edge. This is technically valid and visibly odd. Cause: the ramp is a 0.5 m
   box rotated 30°, so its lower end is a thin wedge that the voxel rasteriser
   does not connect to the ground plane; the only connection is along the side
   edges. It is a greybox artefact, not a pathfinding fault, and the fix is
   geometry (bury the ramp's foot so it meets the ground cleanly) rather than
   navigation tuning. **Recorded, deliberately not fixed** — changing the
   greybox to flatter its own test would hide the finding.
2. **Paths contain many collinear points.** A straight 16 m run produces ~10
   waypoints. Harmless — the character still moves in a straight line — but the
   waypoint count on the HUD reads higher than the route's complexity.
3. **The navigation mesh is baked at startup, taking ~250 ms.** It is not
   pre-baked into the scene, so greybox edits cannot silently desync from the
   mesh. The cost is a quarter-second before the first click is accepted.
4. **Elevated surfaces that need a jump are unreachable, by design.** The
   platform top is on the mesh but disconnected from the ground by a 0.9 m lip,
   so clicks on it are refused. No navigation links were added.
5. **No dynamic obstacles.** Nothing in the scene moves. Adding anything that
   does would need a rebake or an obstacle, neither of which exists here.
6. **Agent avoidance is off.** There is one character.

---

## Unreachable destinations: why rejection, not nearest-point

A click is refused when it is off the navigation mesh, or on the mesh but not
connected to where the character is standing. The marker turns red for about
0.7 s and no destination is set.

The alternative was to resolve to the nearest reachable point. **Rejection is
the smaller useful test:** it needs no re-resolution logic, and more importantly
it does not hide the failure. If the navigation mesh has a hole, nearest-point
resolution quietly walks the character somewhere adjacent and the hole is never
noticed; rejection puts it on screen immediately. The brief for this experiment
is to learn whether the player can *trust* a click, and a system that silently
substitutes a different destination is exactly the thing that erodes that trust.

If playtesting shows refusals feel punishing rather than informative, switching
to nearest-point is a small change — but it should be made because refusal was
tested and disliked, not assumed.

---

## Unresolved questions

None of these are answered by this experiment, and none should be decided from
it:

- Does click-to-walk with routing actually feel better than straight-line
  steering, or is the greybox too open for the difference to matter?
- Should an unreachable click refuse, resolve to the nearest point, or do
  something else entirely?
- Should the character ever jump, automatically or manually? Navigation links,
  traversal jumps and off-mesh connections are all unbuilt.
- Sprint: hold-to-sprint still sits badly with click-to-walk. Unresolved from
  the camera phase.
- How much of the world will be navmesh-baked at all, and when — this greybox
  is one small region with no streaming.
- Whether any of this survives a server-authoritative design.

---

## Result

Record the outcome here after testing.

- **Does a clicked destination feel trustworthy?**
- **Which route looked wrong, and where were you standing?**
- **Did rejection read as a rule or as being ignored?**
- **Is routing worth it versus straight-line steering in this space?**
- **What should be tested next?**
