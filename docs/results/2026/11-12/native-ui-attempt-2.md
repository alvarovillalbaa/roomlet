# Second native workflow attempt: UI-query compile error

[Run43136003558](https://github.com/alvarovillalbaa/roomlet/actions/runs/43136003558),
job130911385329, failed at source
`e5393a6eb96437190391fa8958e613bce104b916`, QA activation
`78fed9cb68713ce5337097b68c751152e3b36063`.

The corrected Debug architecture compiled the actual app/core for native arm64.
The test bundle then failed to compile three uses of the nonexistent
`XCUIElementQuery.rows` property. The actual framework provides
[`tableRows`](https://developer.apple.com/documentation/xcuiautomation/xcuielementtypequeryprovider/tablerows).
No app launch, UI case, native panel, scan, Trash or report action ran.

The [original receipt](native-ui-attempt-2.json) and
[full original log](native-ui-attempt-2.log) retain all18complete lossless streams,
all source vectors, native compiler exits and cleanup. Independent decompression
and SHA256 verification matched every stream. App/runner absence, child-group
absence, fixture byte preservation/no Trash residue, source/export equality and
owned-root removal all passed. Two existing app concurrency-warning locations
and the AppIntents metadata advisory remain in their original output.

Artifact13906993172 was reported as53192bytes, ZIP SHA256
aad305442d9d7370091a38557734579216c3b7c615ebb8feb0d18ce0a72556af.
That is server metadata, not a recovered original ZIP claim. Earlier native
core/preview scopes stay closed; this failed build establishes no UI pass.

The continuation changes only those three query property spellings and the
owned branch binding, retaining the same actual app, fixture, assertions,
architecture, deadlines, entitlements and teardown. No test is skipped or
weakened and no successful workflow is carried from this attempt.
