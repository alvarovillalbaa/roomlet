# Files navigation repair: native compilation passed

The store now emits a transient Files presentation identity after a successful
folder selection or admitted scan. Open windows observe it while retaining
their own sidebar selection. Toolbar, keyboard, Workspace and menu-bar scans
therefore use the same navigation path, including choosing the same folder
again. Cleanup completion retains its existing Last Cleanup presentation.

Checked source `3be4c1c5531320544004c93f94c5b73863e85c38`, tree
`f6ccc7b3cc1d743dec3cff39fa86db4962e2bdb8`, passed one app-only native build in
[run43129747967](https://github.com/alvarovillalbaa/roomlet/actions/runs/43129747967),
job130890633630, at QA activation
`92e6f0609cc70bab2943d709ef97f0e3ad7bcab5`. The macOS15/arm64 runner used
Xcode16.4's Swift6.1.2 toolchain, keeping the package's existing language mode.
The current app compiled/linked successfully in15.75seconds. No package was
installed and no test, app, panel, scan, Trash or packaging/release was run.

All nine child commands exited zero, with complete stdout/stderr, reaped children
and absent original process groups. Every one of70tracked files/2,148,787bytes
retained its exact mode/blob/content before and after compilation. The fresh
executable was1,440,624bytes, SHA256
`b8f1af3e06ad525dd179bcee1235bc666354e62b6c8369a46a56b02d862bc113`.
Owned build/cache/config/security/tmp directories were removed only after
process-group and root identity checks. This does not independently inventory
system caches, separately detached processes or runner disposal.

The [original JSON receipt](files-navigation-build.json) includes all18complete
streams as gzip/base64 plus observed lengths/SHA256 and full source vectors.
It is byte-identical to the single tagged receipt in the [full original job log](files-navigation-build.log).
Receipt SHA256:763bd46e5ed2d270f440a878cedba755a789c61841500f51aaabf7f6391ca59a.
Every stream was independently decompressed and rehashed after retrieval.
Existing concurrency warnings at two captured-self locations remain in those
originals. No Swift6 language-mode or worker-concurrency repair is claimed.

Local Swift source parsing, Python controller parsing and whitespace checks
passed. Storage Guard measured0.2GiB free/34GiB required, so no local native
build or runtime occurred. The old29-case and universal-preview scopes were
not replayed. This source repair is not a rebuilt public preview or native
multiwindow/keyboard/picker/security-scope/Trash acceptance.

Temporary workflow415324943 is disabled. Its exact QA activation was deleted
after the run became terminal; the workflow never belonged to main. Later
result/README edits retain all compiled app/core/Package/resource inputs.
