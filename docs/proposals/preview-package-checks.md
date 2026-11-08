# Roomlet universal preview packaging scope

Last updated: 2026-11-08

**Attempt 2 passed packaging; unchanged preview assets are public.** The
[actual result](../results/2026/11-08/preview-package-attempt-2.md) preserves
the failed first observer run and records all 22 fresh commands. The accepted
preview scope is closed; the old 29 cases were not repeated.
The user's standing “I approve
everything / Keep going / Do all the work” authorizes this separate current-app
preview scope and publication of unchanged accepted assets. It does not reopen
the [closed 29-case packet](../results/2026/11-05/native-checks.md) or authorize
native interaction, scanning private folders, permission prompts or real Trash.
Its failures and acceptance remain preserved.

The original immutable preparation directly descended from baseline
`a76f38383c4cbd0c9f49a676394252a8d30b4149`. The changed preparation follows
`6a30df478d0401f8722ce606830cba3d538723bf`, as specified below. Publish the reviewed controller and
[inactive workflow example](preview-package.workflow.yml.example) before
activation. The original owned ref was **`qa/roomlet-preview-20261108-1`**; only its
temporary `.github/workflows/preview-package.yml` activates one free public
`macos-15` job with `contents: read`, no persisted checkout credentials and a
**20-minute** limit. Checkout the exact preparation commit, not a mutable ref.
No dependency/toolchain install, paid runner, provider, model, account, artifact
action, registry/store publication or security-setting change belongs here.
Retire the owned workflow after its terminal run; preserve any failed originals
before considering a changed scope or another immutable candidate.

## Source and package contract

The [controller](../../Tests/ci/run-preview-package.py) must guard immutable
HEAD, direct parent, full index and every tracked file's mode/native Git blob,
length and SHA-256 before and after work and teardown. App/core, Package.swift,
resources, entitlements and existing tests remain byte-identical to baseline;
only preview packaging helpers, controls and documentation change. No active
workflow is tracked by the preparation. Export only required tracked build
inputs into private owned scratch; tests may be present for SwiftPM discovery,
but no `swift test` or application execution is allowed. Do not copy Git,
previous audit trees or unrelated output.

Build the current full app in Release with native SwiftPM, separately for
arm64/x86_64, dedicated scratch paths and disabled local rpaths; join with
`lipo`. `--build-preview` must not launch or quit Roomlet. The existing packager
accepts the universal executable with `--preview`, placing root LICENSE as
Resources/`LICENSE.txt` and the exact `docs/preview-setup.md` as
Resources/`PREVIEW.md` before its unchanged ad-hoc sandbox signing. Keep the
Resources/`.roomlet-generated` marker sealed. Effective entitlements must be
exactly `com.apple.security.app-sandbox` and
`com.apple.security.files.user-selected.read-write`, both true, on **both**
slices before and after extraction; reject any other key or type.

Verify bundle identity/version 0.1.0/build 1, macOS 15.0 minimum, both actual
architectures, source-exact Info/icon/notices/marker, strict all-slice signature,
ad-hoc identity/no team, and bounded per-slice load commands/system dependencies.
Keep exact bundle entry sets, modes, hashes and xattrs. Preserve metadata in
`Roomlet-0.1.0-macos-universal.zip`, limited to 8 MiB, 32 MiB expanded and 512
members; reject unsafe entries. Fresh `ditto` extraction must match the complete
bundle manifest and strict signature/entitlements. Empty observed xattrs do
not prove nonempty resource-fork preservation.

## Budgets, receipts and teardown

Reserve **900 seconds work + 150 seconds cleanup + 30 seconds margin** within
the job. Private runner scratch/caches are bounded to **4 GiB**, with sampled
owned RSS at most **4 GiB** and **64 attributable processes**. Preserve HOME;
scope temporary/cache paths and an owner nonce to the private tree. Do not
forward provider credentials. Bound child CPU/file size/FD/core resources;
attribute/reap children, inherited owner markers and process groups, including
detached descendants. Preserve cancellation and failure through bounded
TERM/KILL, pipe drainage, EOF/descriptor closure and original exit recording.
An interruption, required termination or uncertain owned closure cannot pass.

Each stdout/stderr stream is at most **1 MiB**; retained gzip originals are at
most **9 MiB** combined and the final report **16 MiB**. Record actual toolchain,
source vector, command argv/exits/original stream hashes, artifact checksum,
bundle/entitlement observations, resource peaks and teardown on success/failure.
Retain the actual ZIP, `.zip.sha256` and `Roomlet-preview-manifest.json` bytes
for data-only audit and unchanged `v0.1.0-preview.1` publication after acceptance.
Cleanup only owned entries after matching identities, modes, hashes and entry
sets; require owned processes gone, scratch absent and unchanged source/index.
Bound receipt transport; blocked kernel operations remain outside timer proof.

Local Storage Guard fails at **8.9 GiB free versus 34 GiB required**. No local
build, app/test/native API execution or install is authorized. This packet
proves only the observed source-to-universal-package boundary. Picker/security
scope, UI, scans, private folders, filesystem providers, Trash, reclaimed space,
Gatekeeper, fresh-Mac installation and full acceptance remain separate.

## Changed attempt 2 — live storage sampling

The [first attempt](../results/2026/11-08/preview-package-attempt-1.md) failed
when live storage sampling encountered a missing compiler `.pcm.tmp` path.
The build was terminated (-15); no package or application outcome was accepted.
The exact temporary-file removal mechanism was not observed. All 12 original
streams and verified teardown are retained as failure evidence, not a pass.

Standing owner approval covers one changed candidate and one fresh invocation
of this same bounded preview packet. Its preparation must directly follow
`6a30df478d0401f8722ce606830cba3d538723bf`; the fixed QA ref becomes
**`qa/roomlet-preview-20261108-2`**. The active workflow path and 20-minute job
profile stay unchanged. The controller continues comparing protected app inputs
against original baseline `a76f38383c4cbd0c9f49a676394252a8d30b4149`, admitting
only the explicit controller/documentation/failed-receipt additions for this
changed source. Pin the first JSON's 18,602 bytes/SHA-256
`41eba161a8abf6c1aed1fc14bd431a6611a05ee2d44e4196ff385d308994abd7`
and log's 35,643 bytes/SHA-256
`19fd9fc5a1cdce10d34101cb5ef630e2b6f7c07e19520fdf4cb7a4bf92758532`;
verify their result parity and retain their failed/zero-artifact state.

The sole execution-policy repair replaces separate `is_file()`/`stat()` probes
with one `lstat` per observed entry in the existing five-second **live** sample.
Count regular bytes from that same result. Only during `preview-build`, ENOENT
under descendants of `export/.build/`, `cache/` or `tmp/` may be counted and
skipped, with frozen prefixes explicitly excluded. All other paths/errors,
source reads, frozen package data, stopped snapshots and cleanup stay strict.

Cap each sample at 60,000 entries, 512 MiB per regular file and 4 GiB total;
retain at most 192 samples and eight global disappearance examples. Each sample
records command, observed entries, regular files/bytes and disappearances, with
an aggregate count. Examples contain a relative path capped at 512 characters,
the complete relative-path SHA-256 and truncation flag. These are periodic
observations, not an atomic size measurement or instantaneous storage quota.
Do not replace strict ownership guards with an unbounded best-effort walk.

Keep both build/package helpers, app/core, Package.swift, resources, existing
tests and bundled guide unchanged. `docs/preview-setup.md` remains frozen at
SHA-256 `29125065669aec2ad3425b71558258a4916d039357c2b852a7f1536d2e66f15a`.
All 22 planned commands and 44 streams belong to the fresh invocation; the
first five metadata successes are not reused as new-run results. Do not rerun
the closed 29 cases. Publish originals and changed preparation before workflow
activation, then preserve the actual outcome and retire the owned control.
No app launch, picker, private-folder scan, Trash or trusted-distribution proof
is added, and failed local Storage Guard still blocks native execution here.

## Actual closure

[Run 42474856669](https://github.com/alvarovillalbaa/roomlet/actions/runs/42474856669)
accepted the full preview packet at source
`ee3b98772e150b6c8e9c332954705ee3a49b9ecd`, with all 22 command exits zero,
44 complete original streams, exact metadata/entitlements on both slices and
verified owned teardown. All three retained artifacts were published unchanged
as [`v0.1.0-preview.1`](https://github.com/alvarovillalbaa/roomlet/releases/tag/v0.1.0-preview.1).
The [publication record](../results/2026/11-08/preview-package-publication.json)
verifies the actual public/tag state and all three server sizes/digests.
The first failed outcome is not overwritten.

The five live storage samples observed zero disappearances. Neither nonzero
ENOENT handling nor rejection branches were exercised; periodic samples are
not an instantaneous quota. Empty bundle xattrs do not prove nonempty forks,
and fresh outputs do not exercise existing-output replacement/rollback.
Existing concurrency diagnostics remain; no unrelated source fix or Swift 6
language-mode acceptance is claimed. Both temporary QA workflows are disabled
and retired. No native app, picker, scan, Trash, download/fresh installation or
trusted-distribution acceptance follows from packaging.
