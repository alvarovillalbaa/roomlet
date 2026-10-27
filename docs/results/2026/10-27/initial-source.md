# Roomlet initial source implementation

27 October 2026. Status: initial source implemented, statically checked and
published to the personal GitHub repository. Native build/tests/runtime remain
unverified. The all-project goal is active.

## Intent and decisions

The owning [Notion project page](https://app.notion.com/p/311a1ee8bd06805caa21c5306dd315ac)
contains the one-line “(Mac-ext) disk space freer” brief. A fresh fetch exposes
the complete nine-item New list but reports truncation and three unknown blocks
elsewhere; no full-parent completeness claim is made. No detailed cleanup brief
was found. Roomlet, a native window/menu utility and its review/Trash workflow
are implementation choices, documented in the [product scope](../../../specs/product.md).

Connected personal-repository search for `roomlet` returned no result before
creation, the local destination was absent, and CLI identity readback was
`alvarovillalbaa`. SIDE itself is not a Git repository; a separate `roomlet/main`
repository was initialized without altering another checkout. No Vercel or
Supabase service is needed for this local native product.

## Source and verification boundary

The package contains six core files, sixteen app files and one authored test
file. It separates metadata/path/core validation from SwiftUI/AppKit and the
actual Trash boundary. Source includes cancellation, bounded largest-allocation
results, exact file selection/revalidation, partial outcomes, report export and
honest volume readings. Allocation ranking falls back to logical size when
unknown; logical sorting reorders the retained set, not every omitted file.
Native acceptance has not established this behavior yet.

The fresh Storage Guard result was **29.9 GiB free / 34.0 GiB required**, exit 2.
No native build, native test, app launch, permission prompt, real folder scan,
Trash move, dependency installation, certificate, paid plan or model call ran.
No existing worktree/cache/data was removed to bypass the reserve.

The inactive [native-check proposal](../../../proposals/native-checks.md) scopes
a standard public macOS runner, authored temporary fixtures, app compilation and
ad-hoc package verification. It will not execute until approved under the
workspace CI gate. No active workflow or hosted application is claimed.

## Static evidence and remaining proof

All **24 Swift files**, including the package manifest, passed individual
`xcrun swiftc -frontend -parse` syntax parsing. This does not typecheck modules,
macOS API use, actor isolation or package linkage. Both helper shell files passed
`bash -n`; both plist files passed `plutil -lint`; Run-action TOML parsed and its
executable target exists. The inactive workflow parsed with no YAML errors and
all five embedded shell blocks passed syntax checks. All 39 owned text files
passed whitespace/newline/machine-path checks; eight local Markdown targets
resolved. No active workflow exists.

**29 authored XCTest cases remain unrun.** They cover heap/limit/cancellation
behavior, metadata and unknown values, root/path/package/credential/known-cloud
rules, stale file/root/ancestor identity, traversal and hard-link selection IDs.
All filesystem fixtures live beneath unique runner-owned temporary directories;
the core tests contain no real Trash operation. Static counts are not passing
test outcomes or performance measurements.

Independent read-only review identified and closed package-descendant root
bypass, mixed-case protected/broad path aliases and documented legacy/team
Dropbox names. It also corrected failed-operation wording so an externally
changed file is not described as definitely still in place. Apple documentation
and installed SDK interfaces support the reviewed metadata/panel/Trash API
names, but no native compiler/runtime result is claimed.

Known cloud paths/name forms and iCloud/dataless metadata are excluded; arbitrary
renamed third-party sync locations cannot be detected universally. Fingerprint
checks are not an atomic transaction against a malicious filesystem writer.
Outcome and scan state are in memory; exported reports contain paths/metadata
and need explicit user-selected destinations. Native picker/sandbox access,
Trash semantics, cancellation under real interaction, UI, actual reclaimed
space, packaging, signing and distribution remain unverified.

## Publication

The authenticated personal CLI created the public
[alvarovillalbaa/roomlet](https://github.com/alvarovillalbaa/roomlet) repository.
Source [f86626312f6c632ff37b28cc98004662d8880b54](https://github.com/alvarovillalbaa/roomlet/commit/f86626312f6c632ff37b28cc98004662d8880b54)
was pushed to `main`; remote ref readback matched that exact SHA. Connected
GitHub metadata confirms the separate personal repository and default branch.

Immutable connected source reads matched local Git blobs:

| Source | Git blob |
| --- | --- |
| Core cleanup guard | `82b135f9827da875a8a45879348e592f969702f0` |
| App operation store | `0d7c1f61ff4c539a774c9eaccdca829e609919b4` |

A documentation-only follow-up preserves all checked source/test bytes. No
binary, notarized release, active CI, Vercel deployment or Supabase project was
created. No all-project completion claim is made.
