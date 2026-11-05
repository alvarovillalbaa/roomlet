# Roomlet native build, 29 core cases and local package verified

5 November 2026. **Passed within the authored-fixture and ad-hoc package scope.**
Roomlet is not yet a released or fully accepted Mac application.

Checked source [`d6248b29`](https://github.com/alvarovillalbaa/roomlet/tree/d6248b293748bfc1c43f3dd5dc61b37b29f6dc6c),
tree `95840829c40d183d3df947a02f7b59dc8618063b`, passed in
[run 41956986352](https://github.com/alvarovillalbaa/roomlet/actions/runs/41956986352),
job `127014147099`. The controller ran **02:43:01–02:43:34 UTC**; the job ran
**02:42:57–02:43:37 UTC**. The actual public `macos-15`
runner reported macOS 15.8.2/arm64, Xcode 16.4 (16F6), Swift 6.1.2, macOS SDK
15.5 and Python 3.15.2. No toolchain or package dependency was installed.
The [JSON receipt](native-checks.json) preserves every case identity, emitted
xUnit, complete source vectors and lossless command streams.

## Changes and observed results

Filesystem-aware URL standardization could rewrite physical `/private` paths
into paths containing a symlink. Root validation and cleanup comparisons now
use lexical normalization, rejecting decoded dot/traversal components first.
The fixture alone uses POSIX `realpath` to obtain its physical temporary parent.
The strict root/ancestor symlink, exclusion, volume and fingerprint checks
remain. The original failed run did not log the exact rejected ancestor;
Foundation's documented/source behavior supports the mechanism, followed by
actual passing regression evidence.

All **29 exact XCTest identities passed once** in the accepted invocation:
CLI exit zero, XML failures/errors/skips zero, one worker and no retry.
All 29 original method names and 64 original assertion lines remain. Four new
assertion lines inside existing cases cover hidden-link traversal and protected
`/private` paths. Counts across these runs overlap:

| Attempt | Source | Core result | Package result |
| --- | --- | --- | --- |
| [1](native-checks-attempt-1.md) | `62f1a163` | 10 pass, 19 fail | Not reached |
| [2](native-checks-attempt-2.md) | `02019e68` | 29 pass | Unsigned marker rejected |
| Accepted | `d6248b29` | 29 pass | Verified |

The ownership marker now resides in `Contents/Resources` before signing,
following [Apple's code-signing layout](https://developer.apple.com/library/archive/technotes/tn2206/_index.html).
Fresh packaging passed actual strict signature verification and an ad-hoc
identity check. Effective entitlements contain exactly sandbox and
user-selected read/write access, with no network entitlement. Built/signed
Mach-O UUID and arm64 architecture match. Their executable hashes are recorded
separately because signing rewrites signature bytes. Packaged Info.plist and
icon bytes equal source; all ten ICNS representations were checked.

All **28 command exits were zero**, children reaped, pipes at EOF and original
process groups absent. Three complete checks protected **52 tracked
files/373,893 bytes**, including binary artwork and both failed receipts.
Owned fixtures, the generated `dist` root and external scratch were removed;
final ignored output was empty. The temporary QA workflow is retired after
its terminal run. Publication and source-to-final differences are recorded in
[the publication receipt](native-checks-publication.json).

## Remaining acceptance

No app launch, picker/security-scope behavior, rendered desktop UI, real Trash,
personal-folder scan, filesystem-provider behavior or reclaimed space was
exercised. Ad-hoc signing is not Developer ID, notarization, Gatekeeper/install
acceptance or a downloadable/store release. Legacy-output replacement and
rollback were source-reviewed; the runner packaged fresh output only. The
current Swift language mode emits a captured-`self` concurrency warning; Swift
6 language-mode migration was not attempted. Detached sessions and system/tool
caches are outside the controller's independent inventory.

Local Storage Guard failed at 21.0 GiB free against 34.0 GiB required, so no
local native execution occurred. No model, account, paid enrollment, Vercel or
Supabase resource was used. This closes one verification packet; native
interaction and distribution remain separate work under the active portfolio
goal.
