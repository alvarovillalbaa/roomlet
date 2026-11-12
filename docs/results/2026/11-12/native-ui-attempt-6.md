# Sixth activation: native target resolution failed before RUI01

[Run43139552552](https://github.com/alvarovillalbaa/roomlet/actions/runs/43139552552),
job130922939234, QA`e20c82b4e9be4f8a3ad1954e493a0366cd65aaa0`, correctly
checked out unchanged source`5bc1ab39941ba912484bddfc640771a7d6e805f4`.

The real app/core/UI runner built. Production signing and strict validation
passed, and the exact two-key app entitlements matched before and after the
attempt. Xcode failed during test setup: it tried to resolve the app at
`derived/Build/Products/Debug/Roomlet`, without `.app`. RUI01 did not execute;
the native summary's one failed entry is a runner setup error, not a completed
application case. No scan, Trash, report, screenshot or UI assertion ran.

The [original receipt](native-ui-attempt-6.json) and [full job log](native-ui-attempt-6.log)
retain34complete streams, independently decompressed and SHA256 verified.
All source/export, process-group, exact app/runner, fixture and owned-root
cleanup guards passed. Both evidence uploads were correctly admitted within
their new bounds: compact299,317bytes before final receipt; raw88,180,070bytes
before manifest. Original temporary artifacts:

- Compact13908807551:71,761bytes, server SHA256
  `d6a1b08e5fdce1ce50d075fea2cc7f09dbcd0ed9d99594cdcecaf0766c657972`.
- Raw13908527913:88,413,008bytes, server SHA256
  `4561c23a2865dd193a54b575aaf0fcba7f46aec0369a7097c9d2379d2ca5e6d0`.

These ZIPs were not independently downloaded; their two-day expiry is not
permanent retention. Receipt/log originals remain in Git.

The Xcode app target and local Swift package executable both used the name
Roomlet. A naming collision during target resolution is a source-supported
hypothesis; the exact internal cause was not captured. The changed setup names
the Xcode-only target RoomletApp while retaining Roomlet.app, bundle ID, app
source and production entitlements. It also retains and validates the generated
xctestrun's exact app path/bundle before execution, then consumes that unchanged
file with test-without-building rather than resolving the scheme graph again.
No generated metadata is edited and no native assertion is weakened.
