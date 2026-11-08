# Roomlet preview distribution

Last updated: 2026-11-08

The prepared target is **`v0.1.0-preview.1`**, app **0.1.0** (build 1), for
macOS 15+. Fresh universal Release compilation, sandbox-signature inspection
and ZIP round-trip acceptance are pending. No successful preview receipt or
downloadable release is asserted by this preparation.

## Artifacts and trust

- `Roomlet-0.1.0-macos-universal.zip`
- `Roomlet-0.1.0-macos-universal.zip.sha256`
- `Roomlet-preview-manifest.json`

The executable targets arm64 and x86_64. No external runtime, dependency,
model or service is required or bundled. `LICENSE.txt` and the exact
[preview guide](preview-setup.md), copied as Resources/`PREVIEW.md`, join the
existing generated-output marker **before signing**.

Signing stays ad-hoc, with exactly the existing App Sandbox and user-selected
read/write entitlements. No network entitlement, Developer ID, TeamIdentifier,
certificate, Apple account, paid enrollment or notarization is added. A valid
signature and checksum establish neither publisher trust nor Gatekeeper,
fresh-Mac, picker/sandbox interaction or native UI acceptance. See Apple's
[code-signing trust explanation](https://developer.apple.com/library/archive/technotes/tn2206/_index.html).

For published assets, compare the ZIP digest with its sidecar and manifest:

```sh
shasum -a 256 Roomlet-0.1.0-macos-universal.zip
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

The [prepared CI scope](proposals/preview-package-checks.md) excludes app launch,
folder selection, scanning, Trash and tests. The [closed 29-case result](results/2026/11-05/native-checks.md)
is preserved and is not repeated. Universal compilation does not validate
runtime behavior on both architectures. Full product acceptance, user/private
folders, real Trash, reclaimed space and trusted distribution remain open.
