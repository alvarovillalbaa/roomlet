# Actual macOS workflow acceptance

Standing “I approve everything / Keep going / Do all the work” authorization
covers one dedicated T2 UI case in one standard public macos-15 arm64 job,
capped at20minutes. Publish the controller, Xcode target, case and this scope
before activating the exact owned QA branch. Pin immutable source checkout,
use contents-read permission and retain no checkout credentials.

`Tests/RoomletAcceptance.xcodeproj` compiles the actual current AppKit/SwiftUI
app and links the existing local RoomletCore product. Source, Package.swift,
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
may be retained in a bounded64MiB evidence packet for two days. Runtime work
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
