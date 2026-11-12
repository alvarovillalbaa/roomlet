# Fourth attempt: actual launch, recorder denied and oversized raw diagnostics

[Run43137270226](https://github.com/alvarovillalbaa/roomlet/actions/runs/43137270226),
job130915492457, ran source `40a00b1649ef34140be886abfe0e6c1c2d2b4369`
through QA `0f6f348a45dd720f8bbaf9a1af9d731a103d2365`.

The full app and UI runner built. The disposable app was signed with the
unchanged production entitlements, and the exact two-key guard passed before
and after the UI attempt. The real Roomlet process launched and its main-window
assertion passed. RUI01 then failed when the standard sandboxed XCTest runner
tried to write its accessibility snapshot outside its writable container
(NSCocoaError513/EPERM). No folder selection, scan, Trash or saved-report action
ran. No PNG was captured, so there is no visual acceptance claim.

The [original receipt](native-ui-attempt-4.json) and [full job log](native-ui-attempt-4.log)
retain all34complete command streams, independently decompressed and SHA256
verified. App/runner and child groups were absent, both fixtures were intact,
no owned Trash fixture remained, source/export hashes matched and the exact
owned root was removed.

The evidence guard also correctly failed: the packet was89,874,475bytes before
the final receipt, above its64MiB limit. The always-upload step nevertheless
uploaded the oversized packet. Preserve this bound violation. Original artifact
13908565179 is89,727,376bytes with server and independently inspected ZIP SHA256
`576ea1bfe4a29c17fcdd2bef87a33b98f306170cc3688a800f8c669d90372dd3`.
Its two-day retention is temporary, not permanent evidence availability.

A separate [read-only inspector](https://github.com/alvarovillalbaa/roomlet/actions/runs/43138304300)
(job130918875006, head`6a4946b7c9548323ad1b285c6235d53480497ad0`) verified the
exact ZIP size/hash remotely, without replaying any app/test. Its
[retained index and attachment manifest](native-ui-attempt-4-artifact-inspection.json)
show1678files/89,874,819expanded bytes. The raw xcresult contains opaque
38,451,978byte and36,215,458byte blobs; their contents were not classified.
Exported attachments contain one317,949byte screen recording and a failure
description, with no PNG. Do not infer a screenshot verdict from this index.

The concrete continuation records through standard XCTest attachments, with no
runner permission expansion. It keeps the raw xcresult separately, capped at
128MiB, and the exported/receipt packet at64MiB; upload admission enforces both
bounds. Native actions/assertions, the production-rights guards and all fixture,
Trash and teardown controls remain intact.
