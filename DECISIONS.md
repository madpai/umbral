# Decision Log

Record consequential technical, process, and repository decisions here. Design decisions belong in the Design Bible. Detailed architectural decisions that need durable context, alternatives, and consequences live in [docs/decisions/](docs/decisions/README.md) as ADRs.

## Template

### YYYY-MM-DD — Title

- **Status:** proposed | accepted | superseded | rejected
- **Context:** What requires a decision?
- **Decision:** What was decided?
- **Consequences:** What changes or trade-offs follow?
- **References:** Related issue, PR, or Design Bible section.

## 2026-07-24 — Dependency-free bootstrap validation

- **Status:** accepted
- **Context:** The repository requires immediately runnable validation without selecting an engine or package manager.
- **Decision:** Use Python 3.11+ standard library tooling for the Milestone 000 validation command.
- **Consequences:** CI has no third-party dependency. Engine-specific tooling needs a later decision.

## 2026-07-24 — UMBRAL design philosophy adopted

- **Status:** accepted
- **Context:** UMBRAL needs a governing creative constitution before cosmology and world lore are developed.
- **Decision:** Adopt `docs/design/DESIGN_PHILOSOPHY.md` as the immutable principles used to judge design decisions, beneath the Vision and above the Game Design Document and world documentation.
- **Consequences:** Future design proposals must be evaluated against the philosophy. Changes to it require deliberate documentation because they affect the project’s identity.
- **References:** [Design Philosophy](docs/design/DESIGN_PHILOSOPHY.md), [Design Bible](docs/design/README.md).

## 2026-07-24 — Foundational laws of reality established

- **Status:** accepted
- **Context:** Cosmology and world lore require canonical laws governing reality before further foundations are developed.
- **Decision:** Adopt [Foundational Laws of Reality](docs/design/world/FOUNDATIONAL_LAWS.md) as immutable world foundations, including Resonance, the Umbral, consequence, and the relationship between permanence and change.
- **Consequences:** Future cosmological, historical, cultural, technological, and supernatural documents must remain compatible with these laws. Cosmology is the next major world-foundation step.
- **References:** [World Documentation](docs/design/world/README.md), [Roadmap](ROADMAP.md).

## 2026-07-24 — World knowledge framework established

- **Status:** accepted
- **Context:** UMBRAL needs a canonical account of how knowledge is discovered, preserved, distorted, forgotten, and rediscovered before cosmology is developed.
- **Decision:** Adopt [How We Know](docs/design/world/HOW_WE_KNOW.md) as the epistemological foundation for future cultures, religions, institutions, philosophies, and scholarly traditions.
- **Consequences:** Future world documents must treat reality as independent of belief, preserve partial and fallible perspectives, and keep cosmology as the next major world-foundation step.
- **References:** [World Documentation](docs/design/world/README.md), [Foundational Laws of Reality](docs/design/world/FOUNDATIONAL_LAWS.md), [Roadmap](ROADMAP.md).

## 2026-07-24 — Resonance framework canonicalized

- **Status:** accepted
- **Context:** UMBRAL requires a formal definition of Resonance before further world foundations are developed.
- **Decision:** Define Resonance as the universal behavior governing continuity through meaningful participation.
- **Consequences:** Future systems, cultures, mechanics, philosophies, and historical events must remain compatible with the Resonance framework. Cosmology is the next major milestone.
- **References:** [Resonance](docs/design/world/RESONANCE.md), [World Documentation](docs/design/world/README.md), [Roadmap](ROADMAP.md).

## 2026-07-25 — Canonical cosmology established

- **Status:** accepted
- **Context:** UMBRAL requires an objective account of reality from which future world foundations can be derived.
- **Decision:** Reality is participatory: to exist is to participate, participation transforms relationships, identity emerges from continuity, consciousness emerges from integrated life, and death ends autonomous participation but not consequence.
- **Consequences:** Manifest and Umbral are inseparable aspects of one reality rather than separate realms. Future world documents must derive life, identity, consciousness, death, and time from participation and continuity without introducing creators, souls, afterlives, or arbitrary exceptions.
- **References:** [Cosmology](docs/design/world/COSMOLOGY.md), [Foundational Laws of Reality](docs/design/world/FOUNDATIONAL_LAWS.md), [Resonance](docs/design/world/RESONANCE.md), [Roadmap](ROADMAP.md).

## 2026-07-25 — Participation framework canonicalized

- **Status:** accepted
- **Context:** Cosmology establishes participation as fundamental, but the progression from existence to life, reflection, collective continuity, and emergence requires a precise intermediate framework.
- **Decision:** Define a participant as an enduring entity whose existence necessarily enters relationships with reality. Distinguish passive, autonomous, reflective, and collective participation without treating any mode as separate from reality or assuming that collective continuity is a unified consciousness.
- **Consequences:** Relationships create continuity, continuity allows identity, and organized participation can produce emergent capabilities. Cooperation and competition are structural outcomes rather than moral categories. Life, consciousness, and emergence must be derived from this framework.
- **References:** [Participation](docs/design/world/PARTICIPATION.md), [Cosmology](docs/design/world/COSMOLOGY.md), [Resonance](docs/design/world/RESONANCE.md), [Roadmap](ROADMAP.md).

## 2026-07-25 — Constitutional canon established

- **Status:** accepted
- **Context:** The repository requires a durable process for preserving coherence as foundational truth becomes design, implementation, and practical worldbuilding.
- **Decision:** Adopt [CANON](docs/CANON.md) as the constitutional document governing how UMBRAL truth is derived, recorded, challenged, and carried into future work. Contributions must derive before inventing, preserve continuity and consequence, and resolve contradictions before implementation.
- **Consequences:** The Canon Keeper must identify terminology drift and contradictions. Implementation agents may translate approved canon but may not alter foundational truth through convenience. Future foundational work alternates with practical worldbuilding during the Validation Phase.
- **References:** [CANON](docs/CANON.md), [Design Philosophy](docs/design/DESIGN_PHILOSOPHY.md), [Roadmap](ROADMAP.md).

## 2026-07-25 — First Valley validation initiated

- **Status:** accepted
- **Context:** The First Principles Sprint requires practical validation before further foundational philosophy expands the repository.
- **Decision:** Begin the First Valley Initiative as a controlled derivation and validation record. Its geographic and settlement statements remain hypotheses until physical constraints and their consequences are established.
- **Consequences:** The initiative tests whether UMBRAL's first principles produce a coherent place without feature-first invention. The next gate is geology, watershed, climate, seasons, soil, and natural hazards; settlement history, species, cultures, inhabitants, quests, and magic remain unfinalized.
- **References:** [The First Valley Initiative](docs/design/world/FIRST_VALLEY.md), [CANON](docs/CANON.md), [Roadmap](ROADMAP.md).

## 2026-07-25 — First-hour gameplay framework established

- **Status:** accepted
- **Context:** UMBRAL must remain satisfying for players who skip dialogue, lore, or authored narrative while preserving world coherence.
- **Decision:** Treat dialogue and authored story as optional engagement layers. Every major design receives both a coherence test and a gameplay test. Begin paper vertical-slice design for the first hour.
- **Consequences:** Gameplay must remain satisfying when narrative content is skipped. Validation alternates with world derivation, beginning with a 10–15 minute playable micro-slice; no first-hour sequence is finalized by the framework.
- **References:** [Design Philosophy](docs/design/DESIGN_PHILOSOPHY.md), [Gameplay Direction](docs/design/GAMEPLAY_DIRECTION.md), [First-Hour Design Framework](docs/design/experience/FIRST_HOUR.md), [First Valley Initiative](docs/design/world/FIRST_VALLEY.md), [Roadmap](ROADMAP.md).

## 2026-07-25 — Technical planning directory established

- **Status:** accepted
- **Context:** The micro-slice requires engine-specific implementation planning, but `docs/architecture/` is declared technology-neutral and records approved system boundaries rather than deliverable-scoped plans.
- **Decision:** Add `docs/technical/` for engine-specific, deliverable-scoped implementation planning. Documents there make no design decisions and must name a neutral placeholder, with its corresponding open decision, wherever a plan would otherwise require one.
- **Consequences:** `docs/architecture/` remains technology-neutral. Technical planning documents may be superseded or deleted when their deliverable completes, without affecting approved architecture. Placeholders recorded in technical planning do not become design precedent.
- **References:** [Technical Planning](docs/technical/README.md), [Architecture Documentation](docs/architecture/README.md), [CANON](docs/CANON.md).

## 2026-07-25 — Feel Prototype 01 scope proposed

- **Status:** proposed
- **Context:** The First Valley Initiative requires a 10–15 minute playable micro-slice to test mechanical quality before further design work proceeds. Every first-hour beat remains unresolved, so a prototype must be scoped without inventing gameplay direction.
- **Decision:** Propose a one-week, single-player, single-map throwaway prototype answering one question: is UMBRAL enjoyable to control and interact with? It implements movement, camera, one repeatable interaction verb, carry, one environmental hazard, one persistent visible consequence, and a feedback layer. The interaction verb, carry, and hazard are neutral placeholders mapped to unresolved first-hour decisions. Persistent path wear from repeated traversal is derived from established canon rather than invented.
- **Consequences:** Roughly forty percent of the week is allocated to movement and camera tuning before any content exists. No gameplay system, geography, name, or production architecture is decided. Prototype code is expected to be deleted; its deliverable is tuned values, playtest recordings, and a written verdict against recorded kill criteria. Client-authoritative feel may not survive later server authority; this is knowingly deferred.
- **References:** [Prototype Architecture](docs/technical/PROTOTYPE_ARCHITECTURE.md), [Implementation Plan](docs/technical/IMPLEMENTATION_PLAN.md), [ADR-001](docs/decisions/ADR-001-prototype-engine.md), [First-Hour Design Framework](docs/design/experience/FIRST_HOUR.md), [Gameplay Direction](docs/design/GAMEPLAY_DIRECTION.md).

## 2026-07-25 — Godot 4.x proposed as prototype engine

- **Status:** proposed
- **Context:** No engine decision is recorded and `TODO.md` lists it as open. The project owner directed that the prototype be designed around Godot 4.x without engine comparison.
- **Decision:** Record the owner's direction as [ADR-001](docs/decisions/ADR-001-prototype-engine.md), scoped to Feel Prototype 01 only. Production engine selection remains open.
- **Consequences:** Prototype work may begin against Godot 4.7.1. `game/`, `server/`, and `shared/` remain empty and unclaimed. `TODO.md` item 3 remains open; production confirmation requires recorded persistence, networking, authority, and platform requirements in a separate ADR.
- **References:** [ADR-001](docs/decisions/ADR-001-prototype-engine.md), [Client Architecture](docs/architecture/CLIENT.md), [TODO](TODO.md).
