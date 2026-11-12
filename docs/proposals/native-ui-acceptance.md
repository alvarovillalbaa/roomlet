# Actual macOS workflow acceptance

Standing “I approve everything / Keep going / Do all the work” authorization
covers one dedicated T2 UI case in one standard public macos-15 arm64 job,
capped at20minutes. Publish the controller, Xcode target, case and this scope
before activating the exact owned QA branch. Pin immutable source checkout,
use contents-read permission and retain no checkout credentials.

`Tests/RoomletAcceptance.xcodeproj` compiles the actual current AppKit/SwiftUI
app and links the existing local RoomletCore product. App source, Package.swift,
resources and the production entitlement file are unchanged. The target disables
base entitlement injection for the app; require exactly App Sandbox and
user-selected read/write entitlements before launching. The XCTest runner uses
normal ad-hoc debug signing, no Apple account or paid certificate. No TCC reset,
privacy-database edit, permission bypass, dependency or simulator is allowed.

`RUI01` drives the actual native folder panel, metadata scan, empty selection,
one selected row, review/Keep Files, explicit Move to Trash, cleanup result and
native Save Report panel. It checks the actual JSON paths/size/disposition and
file bytes, then re-selects the same folder from Last Cleanup and verifies
Command-R opens Files and rescans with empty selection. Four native PNGs and
accessibility snapshots document the real windows; emitted images remain
unreviewed until inspected. This is one workflow, not many inflated case IDs.

Only two generated files participate:4096authored bytes and64authored bytes,
both named with a fresh32hex nonce inside a new owned physical directory.
An independent owner marker and generated test-only FixtureConfig.json bind
the exact scan/report/evidence paths. That generated resource exists only in
the owned source export. No model, account, private folder, cloud file or
production data is used. The old29core and universal-preview cases stay closed.

The dedicated Trash action moves only that nonce-bound4096byte fixture through
the unchanged native app. Teardown may restore only its exact expected filename
from the runner's own Trash after verifying regular-file identity, nonce,
preabsence and all4096bytes. The other fixture must retain all64bytes. Never
empty Trash or list/delete unrelated Trash contents. A missing or ambiguous
fixture location fails cleanup and retains scratch. Removal after verified
restoration applies only to this newly generated disposable root.

The controller exports selected source blobs/modes without Git history or old
evidence; creates private build/cache/tmp/fixture paths; performs one native
build-for-testing and one exact test-without-building; captures native result
summary, child exits and bounded lossless streams; verifies checkout/export
hashes; reaps its own exact app/runner paths and child groups; restores the
fixture; and removes only its owned root. New Xcode result bundles/screenshots
are retained through XCTest attachments in a bounded64MiB exported evidence
packet for two days. Raw xcresult diagnostics have a separate128MiB/two-day
artifact, with a lossless file hash manifest. Upload admission checks both
bounds; an oversized packet is not uploaded or accepted. Runtime work
budget900seconds, cleanup within the20minute job; hard termination retains
unproved teardown. Local Storage Guard remains failed, so no local build, app,
native test, file scan or Trash operation is permitted.

After terminal evidence, preserve failures, repair only concrete product or
observer problems, rerun only unfinished/changed scope, then disable the
workflow and delete only exact owned refs. No workflow belongs on main. A native
pass does not prove all volumes/providers, hostile concurrent writers, physical
Mac installation/Gatekeeper, Intel runtime, accessibility completeness or
reclaimed space. The public preview is not replaced by this test app build.

Primary framework references: [Apple UI testing](https://developer.apple.com/documentation/xcode/adding-tests-to-your-xcode-project)
and [XCUIApplication bundle resolution](https://developer.apple.com/documentation/xcuiautomation/xcuiapplication/init(bundleidentifier:)).

## Changed continuation after native build setup failure

[Attempt1](../results/2026/11-12/native-ui-attempt-1.md) failed before UI when the
new Xcode target requested x86_64 but its local core library built for arm64.
One changed continuation enables Debug `ONLY_ACTIVE_ARCH` and explicitly
selects macOS arm64, matching this original scope. Preserve all failure originals;
carry no UI pass. Application code/resources/Package/entitlements, generated
data bounds and the RUI01 assertions remain unchanged. Repeat only this
unfinished native workflow, with all original teardown and evidence controls.

[Attempt2](../results/2026/11-12/native-ui-attempt-2.md) compiled the actual app,
then failed three test-query spellings. The changed continuation uses Apple's
documented `tableRows` property. Preserve that failure and rerun only RUI01;
the native actions, assertions, data/Trash bounds and teardown are unchanged.

[Attempt3](../results/2026/11-12/native-ui-attempt-3.md) built both app and tests,
then correctly rejected Xcode's additional test-only app entitlements before
launch. The continuation applies the existing local ad-hoc signing method to
only the disposable app using the unchanged production entitlement file.
Keep the exact two-key guard and add an identical post-UI check. Do not accept
broader test-build rights as production sandbox proof. App source, native
actions/assertions and all fixture/Trash/teardown bounds remain unchanged.

[Attempt4](../results/2026/11-12/native-ui-attempt-4.md) launched the actual app
under production entitlements, then failed at an unauthorized recorder write;
its raw diagnostic bundle also exceeded the old combined evidence limit.
The continuation uses Apple's standard XCTest string/PNG/JSON attachments,
without granting additional filesystem rights. The controller consumes the
actual exported attachment manifest and reads/copies the actual app-saved
report before teardown. Separate raw and exported bounds are as stated above.
Only unfinished RUI01 runs again. No app/resource/entitlement or assertion
relaxation, additional fixture, old core case or preview build is introduced.

Recorder API: [XCTAttachment screenshot initializer](https://developer.apple.com/documentation/xctest/xctattachment/init(screenshot:))
and [typed data initializer](https://developer.apple.com/documentation/xctest/xctattachment/init(data:uniformtypeidentifier:)).

[Activation5](../results/2026/11-12/native-ui-attempt-5.md) failed before any work
because workflow template substitution changed the source environment key;
activation6 corrected only that binding, preserving its negative original.
[Activation6](../results/2026/11-12/native-ui-attempt-6.md) then compiled but
resolved an app path without `.app` before RUI01. The changed Xcode-only target
name RoomletApp avoids its duplicate Swift package target name. Require one
unchanged generated xctestrun with the exact Roomlet.app path and bundle ID,
retain its original, and execute it directly. App bytes, case/actions, two-key
entitlement guards and all fixture/Trash/cleanup/budget limits remain unchanged.

[Activation7](../results/2026/11-12/native-ui-attempt-7.md) reached the actual
folder panel and scan; its retained hierarchy identifies Outline/OutlineRow,
not the queried Table/TableRow. The changed case uses that observed row kind
with the same exact fixture names and adds a final diagnostic snapshot. Require
the original four phase PNGs/hierarchies plus both native JSON attachments;
map the observed counter/UUID export suffix strictly, retaining original names.
Independently cross-check both JSON attachments against the actual saved report.
No product change, privilege expansion, additional file or weakened assertion.
