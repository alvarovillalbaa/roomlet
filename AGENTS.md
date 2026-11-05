# Roomlet

- Native, local macOS disk-space utility. SwiftUI/AppKit and Foundation only; no account, telemetry, model, server or external dependency.
- Read `docs/specs/product.md` and `docs/specs/core-contract.md` before editing.
- Scan only a folder explicitly selected by the user. Do not follow symlinks, cross volumes, read file contents, or scan excluded/protected locations. Cloud exclusion covers known paths and OS-marked items; never certify arbitrary files as unsynced.
- Never infer that a large file is disposable. Selection starts empty. Review exact file names and paths before moving selected regular files to Trash.
- Recheck root, ancestors and file fingerprints immediately before each Trash operation. Do not move directories, packages, aliases, recognized cloud-managed items, or changed files.
- Moving files to Trash is not reclaimed space. Show measured volume availability separately and preserve partial failure/cancellation results.
- Never scan this Mac, launch permission prompts, move real files to Trash, or run UI automation as an incidental check. Authored filesystem fixtures require a bounded execution scope.
- Run Storage Guard before native builds/tests. A failed preflight blocks those operations; source parsing is not compilation or runtime proof.
- Dependency/CI/signing/distribution changes follow workspace gates. Source publication is authorized by the owning all-project task.
- Manual edits use apply_patch. Run git diff --check and focused syntax checks. Keep evidence in docs/results/.

## Approved native verification scope — 2026-11-05

The user's standing approval to continue and finish the all-project task covers
the [v2 native proposal](docs/proposals/native-checks-v2.md): one temporary public
`macos-15` job, capped at 15 minutes, compiling the app, running the 29 authored
core cases with disposable filesystem fixtures, and checking an ad-hoc package.
The controller and inactive workflow example must be published before activation.
Keep the active workflow on its owned QA branch, check out the immutable source
commit, preserve failed outcomes, then retire the workflow after its run is
terminal. Do not launch the app, scan personal folders, use real Trash, install
dependencies, upload artifacts, enroll in a paid service or publish a release.
This approval does not override a failed local Storage Guard.

This packet is [verified and retired](docs/results/2026/11-05/native-checks.md).
Keep its failed outcomes and proof limits; rerun only after a relevant change
or an explicitly requested new acceptance scope.
