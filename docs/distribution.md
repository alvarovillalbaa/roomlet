# Roomlet preview distribution

Last updated: 2026-11-12

The current release is **`v0.1.1-preview.1`**, app **0.1.1** (build2), macOS15+.
[Current-app universal packaging passed](results/2026/11-12/preview-refresh-package.md)
at source `d7ba615aae33cb8a2d06a9c878278c6df59137a1`: native Release compilation,
both slices' sandbox-signature metadata and exact ZIP round-trip checks.
The [developer preview is public](https://github.com/alvarovillalbaa/roomlet/releases/tag/v0.1.1-preview.1),
published12November at03:27:17UTC. The [publication record](results/2026/11-12/preview-refresh-publication.md)
binds its tag to the actual packaged source and verifies server pins plus all
three anonymous downloads. It includes the accepted Files navigation repair and
updated bundled guide. The older0.1.0 release/tag/assets remain unchanged; its
[original record](results/2026/11-08/preview-package-publication.json) is retained.
Public download is not fresh-Mac/Gatekeeper proof.

## Artifacts and trust

- [Roomlet-0.1.1-macos-universal.zip](https://github.com/alvarovillalbaa/roomlet/releases/download/v0.1.1-preview.1/Roomlet-0.1.1-macos-universal.zip)
- [Roomlet-0.1.1-macos-universal.zip.sha256](https://github.com/alvarovillalbaa/roomlet/releases/download/v0.1.1-preview.1/Roomlet-0.1.1-macos-universal.zip.sha256)
- [Roomlet-preview-manifest.json](https://github.com/alvarovillalbaa/roomlet/releases/download/v0.1.1-preview.1/Roomlet-preview-manifest.json)

The ZIP is528,861bytes; all original payload sizes/hashes are in the
[accepted package record](results/2026/11-12/preview-refresh-package.md).
The published assets retain those exact bytes. Earlier failed packaging/native
activations keep their original outcomes; none are converted into a pass.

The executable targets arm64 and x86_64. No external runtime, dependency,
model or service is required or bundled. `LICENSE.txt` and the exact
[preview guide](preview-setup.md), copied as Resources/`PREVIEW.md`, join the
existing generated-output marker **before signing**.
The accepted archive contains seven files and five directories. Its source-exact
guide is SHA-256 `acb5c5e1d338fa9b4805c1064e22110db17d145c1428bccea4d52a967c6809f2`.

Signing stays ad-hoc, with exactly the existing App Sandbox and user-selected
read/write entitlements. No network entitlement, Developer ID, TeamIdentifier,
certificate, Apple account, paid enrollment or notarization is added. A valid
signature and checksum establish neither publisher trust nor Gatekeeper,
fresh-Mac, picker/sandbox interaction or native UI acceptance. See Apple's
[code-signing trust explanation](https://developer.apple.com/library/archive/technotes/tn2206/_index.html).

For published assets, compare the ZIP digest with its sidecar and manifest:

```sh
shasum -a 256 Roomlet-0.1.1-macos-universal.zip
```

Extract using Finder's Archive Utility and read the bundled guide. If macOS
refuses the download, stop and inspect source or wait for a trusted release.
No quarantine-removal or security-bypass instruction is part of this preview.

## Build the preview from source

Use a reviewed checkout, macOS 15+, a compatible Swift/Xcode toolchain with a
macOS 15+ SDK, Apple's packaging tools and Python 3's standard library. No
package install is required. Respect Storage Guard and close Roomlet yourself:

```sh
./script/build_and_run.sh --build-preview
```

This mode must neither launch nor quit the app. Native SwiftPM Release builds
use separate arm64/x86_64 scratch paths and no local build rpath; `lipo` joins
the slices before the existing sandbox packager signs the complete bundle.
Outputs are `dist/Roomlet.app`, the ZIP and checksum; the separate CI controller
produces the manifest. Existing archive/sidecar paths are refused. ZIP bounds
are 8 MiB archived, 32 MiB expanded and 512 members. Metadata-preserving `ditto`
and fresh extraction are checked separately from application behavior.

The [completed refresh scope](proposals/preview-refresh.md) excludes app launch,
folder selection, scanning, Trash and tests. The [closed 29-case result](results/2026/11-05/native-checks.md)
is preserved and is not repeated. Universal compilation does not validate
runtime behavior on both architectures. The earlier generated-folder native UI
workflow remains carried at its actual debug/arm64 source, with26 protected
inputs unchanged; it was not rerun for this Release build/version metadata.
Full product acceptance, private folders, other providers/denied access, physical
devices, reclaimed space and trusted distribution remain open.

The refresh run's nine periodic storage samples saw no disappearing entries;
the sampler's nonzero tolerance/rejection branches remain unexercised. Existing
concurrency warnings remain. Empty observed bundle xattrs do not establish
nonempty resource-fork transport. Fresh-output packaging also leaves the
existing-output replacement and rollback paths unexecuted. Refresh workflow
415450805 and its exact two QA/work controls are retired; previous controls
remain retired. Main contains no active preview workflow.
