# Roomlet

Last updated: 2026-11-12

A native Mac utility for finding large local files, reviewing what to remove,
and tracking available disk space. SwiftUI, AppKit and Foundation; no account,
network service, model call, runtime dependency or cloud upload.

**Native compilation, all 29 core checks and strict ad-hoc package verification
passed.** [Results and both earlier failures](docs/results/2026/11-05/native-checks.md)
are preserved. One [actual native macOS workflow now passed](docs/results/2026/11-12/native-ui-acceptance.md):
folder panel, scan/selection, review/Keep Files, authored Trash/restoration,
native report export, same-folder selection and keyboard rescan. Both app
entitlement guards match production. All four required PNGs were inspected.
This generated-folder case does not establish complete access enforcement or
fresh installation; all ten failed activations remain preserved.
Current source also [repairs Files navigation for folder and scan actions](docs/fixes/files-action-navigation.md).
Its separate [app-only native compilation passed](docs/results/2026/11-12/files-navigation-build.md);
the public preview below retains its earlier tested bytes.
A separate [universal preview packaging scope](docs/proposals/preview-package-checks.md)
now [passed its fresh packaging run](docs/results/2026/11-08/preview-package-attempt-2.md):
both Release architectures, signed sandbox metadata and ZIP round-trip checks.
The [developer preview is public](https://github.com/alvarovillalbaa/roomlet/releases/tag/v0.1.0-preview.1).
Download the [universal ZIP](https://github.com/alvarovillalbaa/roomlet/releases/download/v0.1.0-preview.1/Roomlet-0.1.0-macos-universal.zip),
[checksum](https://github.com/alvarovillalbaa/roomlet/releases/download/v0.1.0-preview.1/Roomlet-0.1.0-macos-universal.zip.sha256)
and [manifest](https://github.com/alvarovillalbaa/roomlet/releases/download/v0.1.0-preview.1/Roomlet-preview-manifest.json).
All three server sizes/digests match the passing originals. See
[distribution status](docs/distribution.md) and the self-contained
[preview guide](docs/preview-setup.md).

## Workflow

Choose a local folder, scan its metadata, then sort/filter/search the returned
files. Select individual files and review the complete list before moving them
to Trash. Changed or protected files are skipped with explicit errors. Nothing
is selected or moved automatically. Cancel stops between operations and keeps
the partial outcome.

Moving files to Trash does not reclaim their space. Roomlet opens Finder's Trash
when requested and refreshes observed volume availability. Emptying Trash is a
separate macOS action. Logical file size and on-disk allocation estimates are not
promises of recoverable bytes; snapshots, hard links, APFS sharing/compression
and other activity can change the result.

Scans have explicit entry/depth/result limits and preserve partial-result status.
They do not read file contents, follow symlinks or scan other volumes. Protected
system/credential/known cloud locations and packages are excluded. OS-marked
cloud items are omitted, but arbitrary renamed sync folders cannot be identified
reliably. Roomlet does not certify files as unsynced or
disposable, or offer permanent deletion.

## Local development

macOS 15+, Xcode 16 or newer with a macOS 15+ SDK and Swift toolchain. No package install.
Respect the workspace Storage Guard before native builds or tests.

```sh
./script/build_and_run.sh --build-only
swift test
./script/build_and_run.sh
```

The build helper stages `dist/Roomlet.app`, applies local ad-hoc sandbox signing
and launches the bundle for normal Run. `--build-only` never launches the app.
The separate `--build-preview` mode prepares native Release arm64/x86_64 slices,
a universal app and bounded ZIP/checksum without launching or quitting Roomlet.
Python 3's standard library validates preview packaging; no package install.
The Codex Run action uses this helper. Optional modes are `--debug`, `--logs`,
`--telemetry` (a local unified-log filter) and `--verify`. Packaging is also
available as `script/package_app.sh /path/to/already-built/Roomlet`.

Original icon artwork is in [artwork/app-icon.svg](artwork/app-icon.svg), with a
[1024-pixel reference](artwork/app-icon.png) and ten-representation ICNS resource.
The packager copies that resource before signing. Native checks verified its
exact bytes and ten representations inside the signed package; Finder/Dock
appearance remains unverified.
Python 3's standard library exports the editable source without installing a
package:

```sh
./script/render_app_icon.sh --check
```

Omit `--check` to regenerate PNG/ICNS. See the [icon receipt](docs/results/2026/10-28/app-icon.md)
for format checks and the native-tool encoding limitation observed during setup.

The sandbox permits user-selected read/write access; it has no network
entitlement. The selected folder's access is retained only for the current app
session. No full-disk access request or persisted folder bookmark is required.
The generated-folder workflow passed under those exact entitlements;
denied/protected access, other volumes and fresh installation remain unverified.

The preview retains ad-hoc signing and exactly those existing entitlements;
its bundled guide/license and ownership marker are sealed before signing.
The successful preview run repeated none of the closed 29 cases and performed
no app launch, folder scan or Trash action. Existing Swift concurrency warnings
remain; the build does not establish Swift 6 language-mode readiness.
Developer ID, notarization, Gatekeeper/fresh-Mac installation and installer/store
distribution are not provided or verified. The accepted ad-hoc package does not
establish those claims. No certificate, Apple account or paid enrollment was created.

## Ownership and evidence

- [Product scope and source brief](docs/specs/product.md)
- [Core/app contract](docs/specs/core-contract.md)
- [Architecture](docs/architecture.md)
- [Native-check scope](docs/proposals/native-checks-v2.md)
- [Native build/core/package results](docs/results/2026/11-05/native-checks.md)
- [Actual native workflow, inspected screenshots and retained failures](docs/results/2026/11-12/native-ui-acceptance.md)
- [Universal preview scope and distribution](docs/distribution.md)
- [Passed universal preview packaging and preserved failure](docs/results/2026/11-08/preview-package-attempt-2.md)
- [Verified public release record](docs/results/2026/11-08/preview-package-publication.json)
- [Bundled preview guide](docs/preview-setup.md)
- [Initial implementation receipt](docs/results/2026/10-27/initial-source.md)
- [Icon source and resource wiring](docs/results/2026/10-28/app-icon.md)

This native local app needs neither Vercel nor Supabase. Source publication and
native/runtime proof are separate requirements; the all-project goal remains
active.
