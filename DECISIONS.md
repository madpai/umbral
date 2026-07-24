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
