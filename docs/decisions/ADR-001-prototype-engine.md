# ADR-001: Godot 4.x as the prototype engine

## Status

Proposed — pending project-owner approval.

This ADR scopes **the prototype only.** Production engine selection remains
open ([TODO.md](../../TODO.md), [CLIENT.md](../architecture/CLIENT.md)).

## Date

2026-07-25

## Context

The [First Valley Initiative](../design/world/FIRST_VALLEY.md) requires a
10–15 minute playable micro-slice to validate mechanical quality
([Gameplay Direction](../design/GAMEPLAY_DIRECTION.md), pillar three) before
further design work proceeds. No engine decision is recorded;
[TODO.md](../../TODO.md) lists it as open and
[CLIENT.md](../architecture/CLIENT.md) states engine decisions are recorded only
after approval.

The project owner directed that the prototype be designed around Godot 4.x and
that engine comparison not be performed. This ADR records that direction and
bounds it, rather than allowing an unrecorded decision to become de facto canon
through implementation — as required by
[CANON §Implementation Agents](../CANON.md).

Godot **4.7.1 stable** is installed and verified on the development machine.

## Options Considered

1. **Godot 4.x for the prototype only, production engine deferred.** Records the
   owner's direction at the scope actually authorised.
2. **Godot 4.x for prototype and production.** Exceeds the evidence available.
   Persistent-online-world requirements (server authority, durable data,
   concurrency) have not been specified; deciding a production engine before
   those requirements exist would violate CANON §2 and §5.
3. **Defer all engine selection pending comparison.** Rejected by owner
   direction, and correctly so: engine comparison for a throwaway feel prototype
   costs more than the prototype.

## Decision

Adopt **Godot 4.x (pinned to 4.7.1 stable for the prototype week)** as the
engine for Feel Prototype 01.

Bounds of this decision:

- It authorises one throwaway prototype at `prototype/`, described in
  [PROTOTYPE_ARCHITECTURE.md](../technical/PROTOTYPE_ARCHITECTURE.md).
- Prototype code is **expected to be deleted**. It establishes no production
  architecture, no coding standard, and no asset pipeline.
- It does not select an engine for the client, the server, or production.
- It does not resolve networking, persistence, or data-technology decisions.
- `game/`, `server/`, and `shared/` remain empty and unclaimed.

## Consequences

**Enables:** immediate prototype work; concrete Godot-specific technical
planning; a decision recorded before implementation rather than after.

**Accepts:** the prototype's client-authoritative, single-player construction
will not reflect eventual server-authoritative behaviour. Feel numbers tuned
locally may not reproduce under latency — recorded as risk R4 in
[PROTOTYPE_ARCHITECTURE §16](../technical/PROTOTYPE_ARCHITECTURE.md#16-technical-risks)
and knowingly deferred.

**Costs if superseded:** approximately one week of throwaway prototype code —
already the assumed cost of the artifact, so an engine change later loses
nothing that was not already expendable. The tuned feel values, which are the
week's real output, transfer across engines as numbers.

**Does not decide:** production engine, server technology, networking protocol,
database, asset pipeline, or any gameplay system.

## Future Review Notes

Revisit when a production client is scoped. Production confirmation requires,
at minimum: recorded persistent-world requirements
([DATABASE.md](../architecture/DATABASE.md),
[NETWORKING.md](../architecture/NETWORKING.md)), an authority model
([SERVER.md](../architecture/SERVER.md)), and a target-platform decision. Those
belong in a separate ADR that may confirm, extend, or supersede this one.

Recording this ADR does not close [TODO.md](../../TODO.md) item 3.
