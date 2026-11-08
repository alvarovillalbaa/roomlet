# Roomlet preview attempt 1 — failed live storage observer

8 November 2026. **Failed; no preview artifact accepted.** The live resource
observer encountered a disappearing compiler temporary path and terminated the
owned build. This is not an application-behavior result or a compiler verdict.

[Run 42473965692](https://github.com/alvarovillalbaa/roomlet/actions/runs/42473965692),
job `128711016433`, executed immutable source
[`6a30df478d0401f8722ce606830cba3d538723bf`](https://github.com/alvarovillalbaa/roomlet/tree/6a30df478d0401f8722ce606830cba3d538723bf)
through QA activation `be185add807c990238cd26ef65d9579c8ca4fd14`.
The [original JSON](preview-package-attempt-1.json) and
[original job log](preview-package-attempt-1.log) remain unchanged:

| Original | Bytes | SHA-256 |
| --- | ---: | --- |
| JSON | 18,602 | `41eba161a8abf6c1aed1fc14bd431a6611a05ee2d44e4196ff385d308994abd7` |
| Log | 35,643 | `19fd9fc5a1cdce10d34101cb5ef630e2b6f7c07e19520fdf4cb7a4bf92758532` |

## Observed failure and limits

The five toolchain commands exited zero: arm64 host, macOS 15.8.2, Xcode 16.4
(16F6), Swift 6.1.2 and macOS SDK 15.5. The sixth command was the actual
`./script/build_and_run.sh --build-preview`. Its output reached “Building for
production” and `Compiling RoomletCore CleanupGuard.swift`; it did not report
completion. No later packaging, signature, entitlement or extraction command
ran, and no ZIP, checksum or manifest was retained.

During the five-second live storage sample, the controller's separate
`is_file()`/`stat()` probes raised `FileNotFoundError` for:

```text
export/.build/preview-arm64/arm64-apple-macosx/release/ModuleCache/1EVONXTT4HBCU/simd-2MZ9PHDPX5X65-f73e4d71.pcm.tmp
```

The observed fact is that the sampled path was unavailable. Temporary-file
churn is consistent with the source and path, but this run did not observe the
deletion/rename event, identify its actor or establish its exact mechanism.
There was no observed storage-limit excess or application diagnostic. The
controller sent four SIGTERM signals; the build's retained exit is **-15**.
The original failed state must not be converted into a package pass.

All six commands' **12 streams** retain exact gzip/raw/observed byte lengths
and SHA-256 values, EOF and closed descriptors; 317 captured bytes in total.
The timestamped result in the job log equals the JSON. Complete captures
establish retention, not successful packaging.

The controller finished in **28.173 seconds**, recording peak owned storage
65,627,039 bytes, RSS 387,416,064 bytes and five concurrent owned processes.
Teardown was verified: **274 entries removed**, root absent, zero remaining
owned processes, 32 attributed process identities and 23 groups. These are
scoped controller observations, excluding unrelated Apple/Xcode services.

## Changed next scope

The [attempt-2 amendment](../../../proposals/preview-package-checks.md#changed-attempt-2--live-storage-sampling)
allows a narrow live-sampler repair and one fresh immutable QA run. Source,
stopped snapshots, frozen artifacts and cleanup guards remain strict. The
bundled guide stays byte-identical at SHA-256
`29125065669aec2ad3425b71558258a4916d039357c2b852a7f1536d2e66f15a`.
The closed 29 core cases remain unrun; app launch, picker, scans, Trash,
private folders and trusted installation remain outside both preview attempts.
