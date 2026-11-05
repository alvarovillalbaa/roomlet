# Second native run: all 29 core cases passed; packaging failed

5 November 2026. Preserved before changing the packager.

Source `02019e68141b295bd4366e2a66bb0e8bd353bd84`, tree
`2c4f14345c6d6c9268d8d79b43ce948b36675af9`, ran in
[41956513444](https://github.com/alvarovillalbaa/roomlet/actions/runs/41956513444),
job `127012593961`, at **02:38:27–02:39:05 UTC**. Xcode 16.4/Swift 6.1.2,
macOS 15.8.2/arm64 and SDK 15.5 match the first run.

The app compiled and **all 29 exact XCTest identities passed** in one
invocation, CLI exit zero, XML failures/errors/skips zero. All original case
names and 64 original assertion lines remain, with four new assertion lines
inside existing path-policy cases. Lexical root normalization and physical
fixture setup therefore have actual core regression evidence. The first run's
exact rejected ancestor remains unobserved.

The unchanged packager then exited 1. Code signing reported an unsigned
subcomponent at `Contents/.roomlet-generated`. Apple's
[code-signing guidance](https://developer.apple.com/library/archive/technotes/tn2206/_index.html)
places data resources in `Contents/Resources`; the ownership marker is data,
not nested code. Full package/signature/entitlement verification was not
reached. Do not weaken strict verification or sign data as nested code.

The [JSON receipt](native-checks-attempt-2.json) preserves xUnit, actual exits,
full case identities and lossless command streams. Both full source checks
protected 50 files/291,108 bytes. All 19 original command groups disappeared,
with children reaped and both pipes at EOF. Owned generated/scratch cleanup
passed, including the failed package stage; final ignored output was empty.
The earlier failed run remains preserved. No app launch, native UI, real
Trash, personal scan, installation or trusted distribution is established.
