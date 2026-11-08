# Roomlet universal preview packaging passed

8 November 2026. **Passed within the fresh preview packaging scope; release
publication is pending.** This does not establish native interaction, scans,
Trash behavior, installation, publisher trust or full-product acceptance.
The [first observer failure](preview-package-attempt-1.md) remains failed,
with build exit -15, four SIGTERM signals and verified owned cleanup.

[Run 42474856669](https://github.com/alvarovillalbaa/roomlet/actions/runs/42474856669),
job `128713787376`, executed source
[`ee3b98772e150b6c8e9c332954705ee3a49b9ecd`](https://github.com/alvarovillalbaa/roomlet/tree/ee3b98772e150b6c8e9c332954705ee3a49b9ecd)
through workflow activation `a417c17874e4302a397aed0be3a1d64a915c68b8`.
The source directly follows `6a30df478d0401f8722ce606830cba3d538723bf` and
keeps protected app inputs anchored to
`a76f38383c4cbd0c9f49a676394252a8d30b4149`.

| Original | Bytes | SHA-256 |
| --- | ---: | --- |
| [JSON](preview-package-attempt-2.json) | 742,140 | `5b5e2b8388d630aca0f3e4f4c6dacaa05066a0afb1135b728e6be06d74b22923` |
| [Full job log](preview-package-attempt-2.log) | 759,119 | `e5cb8174b2dc25ed98616449173c4b774cf7676169c55de3066ef352873a5694` |

## Actual package observations

The actual arm64 host ran macOS 15.8.2, Xcode 16.4/16F6, Swift 6.1.2 and
macOS SDK 15.5. Two native SwiftPM Release builds completed in **12.86 seconds
and 10.89 seconds**, then `lipo` produced the universal executable. No toolchain,
dependency or external runtime installation was performed.

All **22 commands exited zero**. The 44 stdout/stderr originals total 50,917
bytes, with matching raw/observed lengths and hashes, EOF and closed descriptors.
The log's unique result marker reproduces the JSON byte-for-byte, including its
final newline. Together with three retained asset payloads, all **47 gzip
records** verify: 579,868 decoded bytes / 531,949 compressed bytes. Independent
source/stream/lifecycle and artifact audits passed; parsed copies are not extra
executions or carried outcomes from the failed attempt.

The ZIP has **12 members: seven regular files and five directories**, totaling
**1,956,738 expanded bytes**. It contains only Info.plist, the executable, icon,
the 31-byte Resources/`.roomlet-generated` marker, `LICENSE.txt`, `PREVIEW.md`
and CodeResources, plus their directories. Info/icon/license/guide and the marker
match their checked source or exact generation constant. The guide remains
3,073 bytes / SHA-256
`29125065669aec2ad3425b71558258a4916d039357c2b852a7f1536d2e66f15a`.

The executable is **1,912,096 bytes**, SHA-256
`da49fe3e0973176de4d9e637a1972f0fe1067ffb4acbf953068c9957921a7644`.
Both actual slices are MACOS, minimum 15.0 / SDK 15.5. Each has 49 load commands,
32 absolute system-library dependencies and zero runtime search paths. Strict
all-slice signature checks passed before and after fresh `ditto` extraction;
identity remains ad-hoc with no TeamIdentifier.

Four per-slice entitlement reads, original/extracted × arm64/x86_64, contain
exactly two Boolean true keys: `com.apple.security.app-sandbox` and
`com.apple.security.files.user-selected.read-write`. Source entitlement SHA-256
is `0288117aedfa6e05d9af78792ee7fcd89087e94a238d3b57e48f151d4c57ae3a`.
Independent binary auditing rehashed **224 x86_64 + 225 arm64 = 449 code pages**.
Each CodeDirectory has seven special slots: five populated Info/requirements/
CodeResources/XML/DER slots and zero-filled slots 4/6. The 321-byte XML blob embeds
the exact 313-byte source entitlement XML. The 108-byte DER blob is bound at
slot 7, SHA-256 `0892fffb0a7ef5f628e33f3aedcf745d9bb72d4a093881e15b44bdcfe5f4ab50`.
All four sealed resources match their SHA-1 and SHA-256 seals.

Fresh extraction matched every bundle entry, byte hash, mode and observed
xattr, then repeated strict signature and per-slice entitlement checks. All
observed bundle xattrs were empty; this does not exercise nonempty resource-fork
transport. Fresh outputs also leave replacement/rollback branches unexecuted.

## Retained assets

The target is `v0.1.0-preview.1`; these exact original bytes await publication.
No downloadable release, fresh download or installation is claimed here.

| Payload | Bytes | SHA-256 |
| --- | ---: | --- |
| `Roomlet-0.1.0-macos-universal.zip` | 526,053 | `8f24b5f348d4f8955f9ff8b2ceea3a316ba8fff8d96529dcdf2f0546287aedea` |
| `Roomlet-0.1.0-macos-universal.zip.sha256` | 100 | `a5cd4ea60173ddd9babb444e1a37811c5c30fc47190e939451afdf8167687830` |
| `Roomlet-preview-manifest.json` | 2,798 | `d84c5a690d828d87a2611b03986a1fc2a5a1b51580a1fb60dbc44fe4f7a595c4` |

## Source, resources and closure

All **63 source paths / 619,939 bytes** matched native Git blobs, modes, working
bytes and the index. App/core, Package.swift, resources, existing tests, both
helpers and the bundled guide were unchanged from the first preview candidate;
only the reviewed observer, documentation and failed receipt changed.
The prior failed receipt is imported evidence only, with zero accepted artifacts.
The closed 29-case native packet was not rerun.

Controller elapsed time was **44.831 seconds**. Recorded maximum owned regular
bytes were **151,135,690**, sampled aggregate RSS **507,576,320 bytes**, and
five concurrent attributable processes. Five live samples at the five-second
interval observed **zero disappearing entries**. Nonzero ENOENT and rejection
branches remain unexercised. These samples and stopped snapshots are not an
instantaneous storage quota or continuous host-wide resource proof.

Owned cleanup verified **588 removed entries**, scratch absent and zero
remaining attributed processes, with 72 process identities / 57 groups and no
signals. The final owned-tree receipt retains a count and digest, not a full
filesystem image; unrelated Apple/Xcode services are outside attribution.

The complete preview-build stdout is 4,285 bytes, SHA-256
`ed97ed097866886e06817dee8fc27c775512173e0506b7a190654a899b9b13f4`;
stderr is 126 bytes, SHA-256
`93634313ff0498adf0b312980d8666a38a6dc3a4d20d1379716e7381cbc3b5cc`.
It retains eight warning-containing lines: four actual compiler warning headers
at `RoomletStore.swift:100:49` and `189:49`, repeated per architecture, plus
caret-line duplicates. Captured-`self` concurrency diagnostics warn about Swift
6 language mode; no warning fix, race diagnosis or Swift 6 readiness is claimed.

Workflow controls `407628251` and `411075575` are disabled. QA1 and QA2 were
retired at `17a7b8f4` and `7b9e6dbe`; main has no active preview workflow.
Publication remains pending. No app launch, picker/security-scope interaction,
scan, private-folder access, real Trash, reclaimed-space, Intel runtime,
Gatekeeper, trusted signing/notarization or full-product proof was performed.
All local work for this closure was bounded data/source inspection; no local
native API, compiler, application, test, installation or new download ran.
