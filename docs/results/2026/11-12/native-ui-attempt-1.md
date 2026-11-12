# First native workflow attempt: test-project architecture mismatch

[Run43135453836](https://github.com/alvarovillalbaa/roomlet/actions/runs/43135453836),
job130909593466, failed at source
`f92eaa629c0b9fd55856b7be833d7ec382f78bb3`, QA activation
`412da8ec20a5717183f304a1086e3b962e1a3a9a`.

The new Xcode Debug app target requested an x86_64 slice while the existing local
RoomletCore package built for the current arm64 destination. The compiler could
not find RoomletCore for x86_64; build-for-testing exited65. No UI case, app,
native panel, scan, Trash or report action ran. No application regression is
inferred from this test-project configuration failure.

The [original receipt](native-ui-attempt-1.json) and
[complete job log](native-ui-attempt-1.log) retain all18complete lossless streams,
native source vectors, exit codes and verified cleanup. Every stream was
independently decompressed/rehashed. Both generated files retained their bytes,
no owned Trash fixture remained, no app/runner was present, child groups were
absent and the exact owned root was removed. Checkout/export hashes matched.
No screenshot or native UI acceptance exists for this attempt.

Artifact13907357009 was reported as46554bytes with ZIP SHA256
d5fb0066fcc0eed06fdf5fa5ba89a8240c8f40ab1c90f38a9c7534ece2867844;
this is server metadata, not recovered original ZIP bytes. Existing core29 and
preview scopes remain closed and unrun. Application source/resources/Package
and entitlement bytes remain unchanged from main49b44445.

The changed continuation enables the normal Debug active-architecture setting
and selects native macOS arm64 explicitly. This matches the already-approved
runner profile; it is not a universal release claim. App behavior and the exact
RUI01 assertions remain unchanged, and no pass is carried from this failure.
