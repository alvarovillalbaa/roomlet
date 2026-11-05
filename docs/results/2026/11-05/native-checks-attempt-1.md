# First native run: compilation passed, core checks failed

5 November 2026. This failed result is retained before any repair.

Source `62f1a163394f9c12f37b363da2201104c506b438`, tree
`6c4389bdcae4871f848cfc896cd466a77af8f791`, was checked by
[run 41955453507](https://github.com/alvarovillalbaa/roomlet/actions/runs/41955453507),
job `127009168322`, at **02:28:49–02:29:40 UTC**. The public `macos-15`
runner reported macOS 15.8.2/arm64, Xcode 16.4 (16F6), Swift 6.1.2 and SDK 15.5.

The real app compiled. The XCTest invocation exited 1: all **29 exact case
identities** ran once, with **10 passing and 19 failing**, zero XML errors.
All nineteen failures report `PathPolicy.validatedRoot`'s symbolic-link or
path-through-one rejection before their normal scans. The exact rejected
ancestor was not logged, so this report does not assign a fixture or product
root cause. Package/signature verification was not reached. The compiler also
reported a captured-`self` concurrency warning under the package's current
Swift language mode; a Swift 6 language-mode migration was not attempted.

The [JSON receipt](native-checks-attempt-1.json) preserves all actual case
verdicts, lossless command streams and emitted xUnit. Both complete source
checks protected 48 files/207,053 bytes. All 18 owned command groups were
reaped and absent with both pipes at EOF. Generated/scratch cleanup passed;
final ignored output was empty. No app launch, personal scan, real Trash,
dependency installation, account, model call or distribution was involved.

The original create-event activation produced no registered run by 02:26:49
UTC. Actions was enabled; its cause remains unknown. The subsequent push
activation `9109b4c44be4e95a44ee8119ae2d20b21aef6b35` started this sole native
run, attempt 1. The terminal workflow is retired separately. This failure is
not acceptance of the core behavior or a released application.
