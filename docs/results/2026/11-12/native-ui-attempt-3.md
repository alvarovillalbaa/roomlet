# Third attempt: build passed, strict app entitlement guard stopped launch

[Run43136486284](https://github.com/alvarovillalbaa/roomlet/actions/runs/43136486284),
job130912961799, failed at source
`568fe8e113f9f1f0250789436335ffba0aae4f91`, QA activation
`20a732f1a6a1c383bc3cf738319aca45f71f8ef5`.

The actual app, core and UI test runner compiled successfully. The corrected
XCTest query API compiled. Before any app launch, the strict app-entitlement
guard found Xcode test-build additions: a temporary read-only exception for
`/` and global Mach lookups for testmanagerd/runner/coresymbolicationd. These
were in the disposable Xcode-built app, not the source entitlement file or a
published production artifact. The guard rejected those extra rights. No UI
case, app, panel, scan, Trash or report action ran.

The [original receipt](native-ui-attempt-3.json) and
[full original log](native-ui-attempt-3.log) retain all20complete lossless streams,
including the full effective-entitlement XML. Independent decompression and
SHA256 verification passed for every stream. Both generated files retained
their bytes, no Trash fixture remained, app/runner and child groups were absent,
source/export hashes matched and the exact owned root was removed.

The continuation re-signs only the disposable app with the unchanged production
entitlement file, using the existing package helper's local ad-hoc method.
Require exactly sandbox and selected-folder read/write before **and after**
the native UI run. The test runner keeps its normal Xcode debug profile. No
production source/config/entitlement change or relaxed test guard is made;
whether XCTest can drive this production-rights app remains to be observed.
