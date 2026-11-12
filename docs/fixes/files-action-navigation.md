# Show Files for folder and scan actions

Selecting Last Cleanup and then starting a scan from Command-R, Workspace or
the menu bar previously kept the cleanup detail visible. Only the toolbar Scan
explicitly switched sections. Selecting another folder could also leave the
empty cleanup page visible after the previous outcome was cleared.

The shared store now emits a transient Files presentation identity after a
successful folder choice or an admitted scan. Each window observes it while
retaining its own manual sidebar selection. All action entry points therefore
use the same behavior. Re-selecting the same folder emits a new identity;
cancelling its panel or rejecting an action does not. The existing cleanup
completion observation continues to show Last Cleanup.

This changes navigation only. Scan workers, cancellation, security scopes,
metadata/selection validation and the native Trash boundary retain their code.
The published preview is the previous tested edition and is not rebuilt here.

Source parsing and `git diff --check` passed. Storage Guard reported0.2GiB free
against34GiB required, blocking a local build, app launch and native checks.
No new mirror test or replay of the closed29-case/preview scopes was added.
Compilation and actual native multiwindow/picker/keyboard acceptance of this
small change remain unverified; source review does not establish those claims.
