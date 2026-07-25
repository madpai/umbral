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

## 2026-07-25 — Godot 4.x accepted as prototype engine

- **Status:** accepted (supersedes the proposal below)
- **Context:** The project owner approved Godot 4.7.1 for Feel Prototype 01.
- **Decision:** [ADR-001](docs/decisions/ADR-001-prototype-engine.md) moves to Accepted, bounded to the disposable prototype. Production engine selection remains open.
- **Consequences:** Prototype implementation may proceed at `prototype/`. `TODO.md` item 3 remains open because it requires engine, server, package-management, formatting, and release decisions; only a prototype-scoped engine decision is now recorded. `game/`, `server/`, and `shared/` remain empty and unclaimed. Gameplay-related proposed decisions remain proposed and are unaffected.
- **References:** [ADR-001](docs/decisions/ADR-001-prototype-engine.md), [TODO](TODO.md).

## 2026-07-25 — Feel Prototype 01 Phase 0 and Phase 1 implemented

- **Status:** accepted
- **Context:** The implementation plan gates all later phases behind a movement and camera laboratory that must feel good before any content is built.
- **Decision:** Implement Phase 0 (setup) and Phase 1 (feel) only, at `prototype/`. No interaction, carry, hazard, path wear, or feedback layer. No autoload, no event bus, no component framework, no plugins. All movement and camera values are exported and re-read every frame so they can be tuned in the Inspector while running.
- **Consequences:** Phase 2 remains gated on the owner playing the build. Godot's `CharacterBody3D` provides no step-up, and the architecture document excludes step-up solvers, so a 0.20 m step blocks the character; this is recorded in `prototype/TUNING.md` as a known problem for the owner to rule on. All camera values remain unverified because they cannot be evaluated headlessly.
- **References:** [Implementation Plan](docs/technical/IMPLEMENTATION_PLAN.md), [Prototype Architecture](docs/technical/PROTOTYPE_ARCHITECTURE.md), `prototype/TUNING.md`.

## 2026-07-25 — Provisional movement and camera direction

- **Status:** accepted as **provisional prototype direction**; explicitly **not** production canon
- **Context:** The Phase 1.3 owner playtest found the Hybrid World framing substantially closer to the intended UMBRAL experience than any fixed preset. A closer minimum zoom was requested before checkpointing.
- **Decision:** Adopt, for continued prototyping only: Hybrid World as the camera direction; click-to-walk as the primary movement direction; mouse-wheel zoom and right-mouse-drag orbit as part of that direction. Move the Hybrid World minimum zoom from 9.0 m to 7.5 m, re-solving the zoom curve endpoints (`pitch_at_min_zoom` −27.0° → −23.9°, `fov_at_min_zoom` 62.0° → 63.6°) so the approved 13.0 m default framing stays at exactly −35.4° / 57.6°.
- **Consequences:** This direction remains subject to later playtesting and may still be revised or dropped; it establishes no production canon and no gameplay decision. The new close bound is 7.50 m at 23.9° elevation with the character at 16.7% of screen height — closer than B · Adventure (8.50 m, 24.0°, 14.8%) at essentially the same angle, and clearly distinct from A · Classic Third Person (5.00 m, 14.0°, 21.1%). Maximum distance, coupled pitch/FOV behaviour, orbit controls, pitch limits, movement tuning and step-up are unchanged and were re-measured as identical. Sprint behaviour, jumping, automated or path-driven traversal, touch gestures, and pathfinding all remain unresolved and unbuilt. WASD remains a debug comparison mode only; presets A, B and C are retained unchanged for re-anchoring.
- **References:** `prototype/CAMERA_TEST.md`, `prototype/TUNING.md`, [Gameplay Direction](docs/design/GAMEPLAY_DIRECTION.md), [First-Hour Design Framework](docs/design/experience/FIRST_HOUR.md).

## 2026-07-25 — Hybrid World orbit and zoom camera (Phase 1.3)

- **Status:** accepted (engineering); the perspective remains **unresolved design**
- **Context:** The Phase 1.2 camera test found preset A too close and avatar-focused for click-to-move, and both B and C promising, with C somewhat too distant as a fixed default. The owner located the strongest direction between B and C and asked whether a freely adjustable elevated camera bounded by those two makes click-to-move feel natural.
- **Decision:** Add a fourth preset, `H · Hybrid World`, as the launch default: 13.0 m at −35.4° and 57.6° FOV, wheel-zoomable between 9.0 m and 20.0 m with pitch and FOV coupled to the zoom position, right-drag orbit, and arrow-key orbit as a fallback. A, B and C are retained unchanged for comparison. Pitch is applied as a moving baseline so zooming preserves rather than overwrites a manual orbit; the pitch ceiling of −18° prevents zooming into an over-the-shoulder view.
- **Consequences:** No perspective is recorded as canon; the hybrid is an experiment awaiting owner playtest via `prototype/CAMERA_TEST.md`. Destination-click accuracy was verified by round trip at six camera extremes with 0.0000 m error, and movement, stopping, stairs, slopes, jumping, step-up and physics interpolation were re-measured as identical. Preset H disables spring-arm obstruction avoidance for the same reason C does. Sprint and jump remain unchanged despite owner doubts about their fit; those are recorded as open design questions only. Pathfinding, navigation, orthographic projection and gameplay remain deliberately unbuilt.
- **References:** `prototype/CAMERA_TEST.md`, `prototype/TUNING.md`, [Gameplay Direction](docs/design/GAMEPLAY_DIRECTION.md).

## 2026-07-25 — Camera & Perspective Laboratory (Phase 1.2)

- **Status:** accepted (engineering); the perspective itself remains **unresolved design**
- **Context:** After the Phase 1.1 playtest the highest-priority design question became "from what perspective should the player experience UMBRAL?" rather than "does click-to-move work?". Movement was judged validated enough to continue; the camera was not.
- **Decision:** Move all camera framing, pitch, lens and response values out of `player.gd` into `CameraPreset` resources, and add three switchable presets — A Classic Third Person (control group), B Adventure, C High Strategy — cycled with F3. One rig, one camera, one controller; only the data changes. Input rates (`mouse_sensitivity`, `gamepad_look_speed`, `invert_pitch`, `fov_lerp_speed`) stay on the player so they are held constant across the comparison.
- **Consequences:** No perspective is recorded as canon; the experiment is decided by owner playtest using `prototype/CAMERA_TEST.md`. Movement, click-to-move, step-up, jumping and physics were re-measured after the change and are identical on every metric. Three preset choices are deliberate biases documented for the owner to discount: preset C disables spring-arm obstruction avoidance, presets B and C clamp pitch so they cannot be levelled into third person, and sprint FOV punch is reduced or removed at distance. No camera shake, cinematic effects, bloom, depth of field, motion blur or screen effects were added.
- **References:** `prototype/CAMERA_TEST.md`, `prototype/TUNING.md`, [Gameplay Direction](docs/design/GAMEPLAY_DIRECTION.md).

## 2026-07-25 — Feel Prototype 01 Phase 1.1 corrections and control-model experiment

- **Status:** accepted (engineering); the control model itself remains **unresolved design**
- **Context:** The owner played Phase 1 and passed it provisionally, reporting visible character shakiness and a staircase that could not be walked up. Separately, the current design direction is that click or tap should express destination and interaction intent rather than continuous WASD locomotion.
- **Decision:** (1) Enable `physics/common/physics_interpolation`; the shakiness was a render/physics rate mismatch, measured at 59% duplicate render frames, not a camera fault. (2) Add a ~30-line step-up local to `player.gd` with a configurable `max_step_height`, default 0.25 m. (3) Add a click-to-move experiment using a direct ground target — no navigation mesh, no agent, no pathfinding — with WASD retained behind an F2 toggle as the comparison baseline.
- **Consequences:** Neither WASD nor click-to-move is recorded as UMBRAL canon; click-to-move is the leading direction under test and requires an owner playtest before any further work. Click-to-move has no obstacle avoidance and walks into pillars; `NavigationAgent3D` is the obvious next step only if the direction is adopted. Step-up rejects a step with an obstruction within ~0.45 m behind it, because the clearance probe must exceed the capsule radius to avoid catching a step's leading corner. Phase 2 remains gated.
- **References:** `prototype/TUNING.md`, [Implementation Plan](docs/technical/IMPLEMENTATION_PLAN.md), [First-Hour Design Framework](docs/design/experience/FIRST_HOUR.md).

## 2026-07-25 — Godot 4.x proposed as prototype engine

- **Status:** superseded by the accepted entry above
- **Context:** No engine decision is recorded and `TODO.md` lists it as open. The project owner directed that the prototype be designed around Godot 4.x without engine comparison.
- **Decision:** Record the owner's direction as [ADR-001](docs/decisions/ADR-001-prototype-engine.md), scoped to Feel Prototype 01 only. Production engine selection remains open.
- **Consequences:** Prototype work may begin against Godot 4.7.1. `game/`, `server/`, and `shared/` remain empty and unclaimed. `TODO.md` item 3 remains open; production confirmation requires recorded persistence, networking, authority, and platform requirements in a separate ADR.
- **References:** [ADR-001](docs/decisions/ADR-001-prototype-engine.md), [Client Architecture](docs/architecture/CLIENT.md), [TODO](TODO.md).
