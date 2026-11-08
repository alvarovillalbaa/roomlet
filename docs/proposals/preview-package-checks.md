# Roomlet universal preview packaging scope

Last updated: 2026-11-08

**Prepared; not executed or accepted.** The user's standing “I approve
everything / Keep going / Do all the work” authorizes this separate current-app
preview scope and publication of unchanged accepted assets. It does not reopen
the [closed 29-case packet](../results/2026/11-05/native-checks.md) or authorize
native interaction, scanning private folders, permission prompts or real Trash.
Its failures and acceptance remain preserved.

The immutable preparation must directly descend from baseline
`a76f38383c4cbd0c9f49a676394252a8d30b4149`. Publish the reviewed controller and
[inactive workflow example](preview-package.workflow.yml.example) before
activation. The owned ref is **`qa/roomlet-preview-20261108-1`**; only its
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
