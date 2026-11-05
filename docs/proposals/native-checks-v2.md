# First Roomlet native compilation and 29 core cases

5 November 2026. **Prepared, not executed.** Baseline personal main is
`1531c9d8c7806d042b5a9d4c36ec5f03e6044f7f`. The owner's standing
“I approve everything / Keep going / Do all the work” instructions authorize
this focused native verification and its necessary temporary public CI. The
[older proposal](native-checks.md) remains historical; its pending-approval and
manual-dispatch instructions do not override that authorization.

The [product brief](../specs/product.md) owns a native local Mac disk-space
utility. This packet preserves the existing app, 29 authored cases, icon and
packager. It supplies compilation and fixture/package evidence, not a new
feature or full product acceptance. Local Storage Guard most recently failed
at 21.0 GiB free against 34.0 GiB required; no local build, test or installation
is proposed.

## Exact execution

Publish the reviewed preparation source without an active workflow. Root then
copies the [inactive example](native-checks-v2.workflow.yml.example) into
`.github/workflows/roomlet-native-checks.yml`, replacing only the source pin
with that preparation's immutable 40-character commit. Create the task-owned
`qa/roomlet-native-20261105` branch at the activation commit. The public-repo,
create-event and exact-branch predicates admit one standard `macos-15` job,
capped at 15 minutes. Checkout is shallow, read-only and does not retain
credentials. No dependency installation, cache restore, artifact upload, paid
runner, signing identity or account is used. Root retires only this temporary
workflow after a terminal run and publishes the exact result separately.

The [stdlib controller](../../script/run_native_checks.py) selects the existing
`/Applications/Xcode_16.4.app/Contents/Developer`, requiring actual Xcode
16.4/build 16F6, Swift 6.1.2 and macOS SDK 15.5. No fallback or toolchain
download is allowed. The official
[runner image inventory](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-arm64-Readme.md)
supports the selected installed profile; the controller records actual values.

1. Verify immutable HEAD, complete index and every tracked working file's
   type/mode/Git blob/byte length/SHA-256, including binary artwork and symlink
   target text without following it. Reject tracked active workflows, source
   changes and nonignored untracked files. Repeat after checks and after owned
   generated-output cleanup. No tracked source or generated exception exists.
2. Syntax-check the existing two shell helpers and source plists. Build the
   real `Roomlet` product using SwiftPM scratch/cache/config/security paths
   inside a private task-owned directory. Keep runner HOME unchanged; direct
   manifest/compiler module caches into the owned tree.
3. Run exactly the 29 literal methods in
   `Tests/RoomletCoreTests/RoomletCoreTests.swift`. Use the existing package's
   XCTest runner with `--parallel --num-workers 1 --enable-xctest
   --disable-swift-testing --filter RoomletCoreTests --xunit-output ...`.
   [SwiftPM 6.1.2 source](https://github.com/swiftlang/swift-package-manager/blob/swift-6.1.2-RELEASE/Sources/Commands/SwiftTestCommand.swift#L260)
   emits XCTest XML through its parallel path. One worker runs the cases one
   at a time; there is no retry or repetition. Require actual CLI exit zero,
   29 unique exact class/method identities, suite tests=29 and zero
   failures/errors/skips. A Swift Testing zero-case line cannot establish a pass.
4. Run the unchanged packager without launching. Verify its actual strict
   local ad-hoc signature, exact effective sandbox/user-selected-read-write
   entitlements and no network entitlement. Compare built/signed Mach-O UUIDs
   and architectures. Record their separate executable SHA-256 values: signing
   may rewrite signature bytes. Require packaged Info.plist/icon bytes to
   equal protected source resources, including all ten ICNS representations.

## Bounds and cleanup

The controller has a 12-minute work budget, a 90-second cleanup reserve and a
two-second bounded report write, beneath the 15-minute job. Every child starts
an owned process group. It records real exit/reaping, both pipe EOF states and
original-group absence; bounded TERM then KILL/drain preserves failures.
Catchable interruption remains handled through cleanup/reporting. Userspace
timers cannot interrupt blocked kernel filesystem operations.

Each stdout/stderr stream is capped at 512 KiB, lossless gzip at 128 KiB per
stream and 512 KiB combined, with a 1 MiB final JSON ceiling. Exceeding a bound
fails acceptance. Preserve emitted xUnit and command streams even on failure;
do not replace failed native evidence with a source parse. The report records
expected and actual case identities, toolchain, full source vectors, package
fingerprints and all cleanup outcomes.

Only uniquely owned runner scratch and preverified-absent generated roots
(`dist`, `.build`, `.swiftpm`, `artifacts`) may be removed, after original
command groups are verified gone and inode identities match. Existing output
is preserved and rejected. XCTest teardown and an owned temporary-prefix check
qualify authored fixture cleanup. Source guards and ignored-output checks
remain strict on failure. Separately detached sessions, toolchain/system caches
and GitHub's final runner teardown are not independently inventoried.

No app launch, picker/permission prompt, real user scan, Trash operation,
native UI, filesystem-provider behavior, reclaimed space, installation,
notarization or store distribution is proved. No model, network provider,
cloud resource, Vercel or Supabase is involved.
