# Roomlet

A native Mac utility for finding large local files, reviewing what to remove,
and tracking available disk space. SwiftUI, AppKit and Foundation; no account,
network service, model call, runtime dependency or cloud upload.

**Source implementation; native build, tests, sandbox, UI and
distribution are not yet verified.** This is not a released Mac application.

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
The Codex Run action uses this helper. Optional modes are `--debug`, `--logs`,
`--telemetry` (a local unified-log filter) and `--verify`. Packaging is also
available as `script/package_app.sh /path/to/already-built/Roomlet`.

The sandbox permits user-selected read/write access; it has no network
entitlement. The selected folder's access is retained only for the current app
session. No full-disk access request or persisted folder bookmark is required.
The intended bundle behavior needs native acceptance; an entitlement file alone
does not prove permissions work.

Ad-hoc signing is for a local development artifact. Developer ID, notarization,
installer/store distribution and a downloadable release are not provided or
verified. No certificate, Apple account or paid enrollment was created.

## Ownership and evidence

- [Product scope and source brief](docs/specs/product.md)
- [Core/app contract](docs/specs/core-contract.md)
- [Architecture](docs/architecture.md)
- [Native-check proposal](docs/proposals/native-checks.md)
- [Initial implementation receipt](docs/results/2026/10-27/initial-source.md)

This native local app needs neither Vercel nor Supabase. Source publication and
native/runtime proof are separate requirements; the all-project goal remains
active.
