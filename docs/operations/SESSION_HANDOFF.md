# Session Handoff — Milestone 000 Publish

## Current state

Milestone 000 repository infrastructure is complete locally and uncommitted on branch `main`. It contains only the infrastructure work created in this session:

- Repository layout: `docs/`, `assets/`, `game/`, `server/`, `shared/`, `tools/`, `scripts/`, and `prompts/`.
- Core project files: README, Charter, contributing guide, code of conduct, roadmap, changelog, decision log, TODO, editor settings, ignore rules, and a license placeholder.
- GitHub issue templates, pull-request template, and repository-validation workflow.
- Dependency-free Python repository checker at `tools/umbral.py`; `scripts/check` wraps it.

No gameplay, world, content, or Design Bible decisions were implemented.

## Standing agent role

`AGENTS.md` at the repository root preserves the repository-engineer mandate for future sessions: infrastructure only; no gameplay or design invention; ask the owner when a decision is not recorded.

## Verification already completed

```bash
python3 -m py_compile tools/umbral.py
python3 tools/umbral.py check
scripts/check
git diff --check
```

All commands passed.

## Known pending decision

`LICENSE` is intentionally a non-granting placeholder. The project owner must select a license before accepting external contributions or publishing a release.

## Publishing blocker

Remote: `https://github.com/madpai/umbral.git`

GitHub CLI (`gh`) reported the active `madpai` token as invalid. The owner should authenticate in the same terminal/session:

```bash
gh auth login -h github.com
gh auth status
```

## Next-session publish steps

1. Confirm `gh auth status` succeeds.
2. Inspect scope with `git status --short --branch` and `git diff --check`. The untracked files listed should be only the Milestone 000 work described above.
3. From `main`, create branch `agent/studio-bootstrap`.
4. Stage the scoped files, commit with `Add studio bootstrap infrastructure`, and run `python3 tools/umbral.py check`.
5. Push with tracking:

   ```bash
   git push -u origin agent/studio-bootstrap
   ```

6. Open a **draft** pull request into the repository's default branch. Its summary should state that it adds repository infrastructure only, and its verification should cite `python3 tools/umbral.py check` and `git diff --check`.

Do not add gameplay implementation or make Design Bible decisions while publishing.
