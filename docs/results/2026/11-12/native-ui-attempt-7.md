# Seventh activation: actual folder scan, wrong accessibility row kind

[Run43140302042](https://github.com/alvarovillalbaa/roomlet/actions/runs/43140302042),
job130925403397, tested source`e4c0f8fbd1dbe308fd2dccc06f3bfe7e2f3d4310`
through QA`152145769e9661a36cf269a0197178a172d38f98`.

The app/core/UI runner built, and the retained generated xctestrun bound the
exact Roomlet.app path and bundle ID. Production signing/strict validation and
both exact two-key entitlement guards passed. RUI01 launched the actual app,
chose only the generated folder through the native NSOpenPanel and clicked
Scan Folder. It failed waiting for a TableRow; no review, Trash or report ran.

The [actual failure hierarchy](native-ui-attempt-7-scan.accessibility.txt)
shows the two collected fixture rows inside an Outline with OutlineRow
children. The test queried tables/tableRows. This is a concrete observer-type
error; scan collection is observed, but row selection and the remaining workflow
are still unproved. The continuation uses outlines/outlineRows with the same
exact generated filenames and assertions, plus a final diagnostic attachment.

The [original receipt](native-ui-attempt-7.json) and [full native job log](native-ui-attempt-7.log)
retain34complete independently decompressed/hash-verified streams. All exact
process/group, source/export, fixture and owned-root cleanup guards passed;
no fixture was moved to Trash. Exported and raw evidence remained below their
64MiB/128MiB bounds, and upload admission passed.

The separate [read-only inspector run43140827639](https://github.com/alvarovillalbaa/roomlet/actions/runs/43140827639),
job130927097644/head`3a5c5226bb8f9d4640f7e509a3a0b5f1cfd93b6e`, verified the
complete3,646,898byte compact ZIP (artifact13909013952), SHA256
`ad9fa2428b330990d49b72c2707c208a0e30212ef45c705a88cc4667b1e20260`,
then exported existing text/PNG without replay. The [full inspector log](native-ui-attempt-7-inspection.log)
retains originals and their exact hashes. The [empty hierarchy](native-ui-attempt-7-empty.accessibility.txt)
and [actual empty-state PNG](native-ui-attempt-7-empty.png) were recovered and
independently SHA256 verified. Visual inspection confirms a readable native
Roomlet window, Files/Last Cleanup sidebar, empty folder state and Choose Folder
button. That image does not show a completed scan or cleanup.

The actual attachment manifest appends a counter/UUID before each extension.
The controller now maps that observed format to exact required phase identities,
keeps original names/hashes and rejects missing/ambiguous captures. It also
requires both actual native JSON attachments to match the saved native report.
No additional app rights, app source, generated fixture or action is introduced.
Raw artifact13909785696 is91,992,677bytes with server SHA256
`9485b1d2b712633378638dfb198fde0c09e5527f42dc43ecc8357cea117a4635`;
its ZIP was not independently downloaded. Both artifacts expire14November.
