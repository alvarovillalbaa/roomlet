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

## Current-app universal preview scope — 2026-11-08

The standing “I approve everything / Keep going / Do all the work” instruction
authorizes Roomlet's separate [preview packet](docs/proposals/preview-package-checks.md):
publish reviewed preparation source, one free public macOS 15 job capped at
20 minutes, then unchanged accepted preview assets at `v0.1.0-preview.1`.
The first owned QA ref was `qa/roomlet-preview-20261108-1`; its preparation
directly followed `a76f38383c4cbd0c9f49a676394252a8d30b4149`. The changed
second invocation is recorded below. Both temporary workflow controls are now
disabled and retired. Preserve the failed first outcome and successful second
receipt; no active workflow belongs on main.

Only current full-app native Release arm64/x86_64 compilation, `lipo`, ad-hoc
sandbox packaging, source-exact bundled license/guide, per-slice entitlements
and ZIP round-trip evidence belong here. Preserve exactly App Sandbox and
user-selected read/write entitlements and the sealed Resources ownership marker.
Keep Package.swift, app/core source, resources and existing tests byte-identical;
only packaging helpers, controls and docs change. No dependency or entitlement
change is authorized. Keep the closed 29 cases unrun; no launch/quit, picker,
scan, permission prompt, real Trash, private folder, network service or model.

Local Storage Guard is **8.9 GiB free/34 GiB required: failed**. No local native
build, app/test/API execution or install; source/static and bounded data-only
evidence handling only. CI uses immutable tracked inputs and private owned
scratch/caches, bounded to 4 GiB storage/RSS, 64 attributable processes and
900-second work/150-second cleanup budgets. Require complete bounded originals,
source/index integrity, owned children gone and verified scoped teardown.

The [second invocation passed packaging](docs/results/2026/11-08/preview-package-attempt-2.md)
at source `ee3b98772e150b6c8e9c332954705ee3a49b9ecd`; release publication is
still pending. This scope is closed: do not repeat unchanged app builds or the
old 29 cases without a concrete concern or a new scope. Universal slices and
sandbox keys do not prove interactive behavior, access enforcement on a user's Mac,
reclaimed space, Intel runtime acceptance, Gatekeeper, fresh installation or
trusted distribution. No paid signing/account/certificate/notarization is added.

### Changed preview attempt 2 — live storage sampling

The [first preview failure](docs/results/2026/11-08/preview-package-attempt-1.md)
is preserved with its original JSON/log hashes. A compiler temporary path
disappeared during the live storage observer; the controller terminated the
build with four SIGTERM signals and retained exit -15. No preview artifact or
application verdict exists. Complete streams and verified cleanup do not
convert that failed run into acceptance.

Standing approval covered one changed source candidate directly following
`6a30df478d0401f8722ce606830cba3d538723bf`, then one bounded job on the owned
`qa/roomlet-preview-20261108-2` ref. Preserve canonical app-input baseline
`a76f38383c4cbd0c9f49a676394252a8d30b4149` and first-original identity pins.
Only the controller's live compiler-path sample changes: use one `lstat` per
entry. Admit ENOENT only during `preview-build` under nonfrozen descendants of
`export/.build/`, `cache/` or `tmp/`, with bounded counts/examples. Keep source,
frozen outputs and stopped snapshots strict. These samples are periodic
observations, not an instantaneous storage quota. Preserve all
storage/RSS/process/stream/deadline/teardown bounds; other errors remain failures.

Publish the failed receipt and reviewed changed scope before activation. Run
the preview packet fresh; carry no successful package claim from attempt 1.
Keep app/core/Package/resources/tests, both build helpers and bundled guide
unchanged. The guide SHA remains
`29125065669aec2ad3425b71558258a4916d039357c2b852a7f1536d2e66f15a`.
No local native execution, test rerun, app launch, picker, scan or Trash action.

The actual changed run completed all 22 commands with 44 complete streams and
verified owned cleanup. Its five periodic storage samples observed zero
disappearances; nonzero ENOENT and rejection branches were not exercised.
Preserve the existing captured concurrency warnings; no Swift 6 language-mode
or runtime race repair was part of this package. The unchanged ZIP, checksum
and manifest await publication as `v0.1.0-preview.1`; packaging success is not
download, fresh installation, trusted distribution or full-product acceptance.
