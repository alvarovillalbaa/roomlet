# Roomlet preview guide

Last updated: 2026-11-12 · app0.1.1, build2

Roomlet is a native macOS 15+ utility for reviewing large local files. It needs
no external runtime, package installation, account, model or hosted service.
The preview app includes this guide and `LICENSE.txt` in its Resources folder.

## Before opening

Use the ZIP, checksum and manifest from the same release. Check the ZIP's
SHA-256 against both records before extracting with Finder's Archive Utility.
The executable contains arm64 and x86_64 slices; this is a build property,
not evidence of interactive acceptance on both kinds of Mac.

The app is ad-hoc signed, without a Developer ID identity or notarization.
It has not established Gatekeeper or fresh-Mac installation acceptance. If
macOS refuses it, stop; inspect the source or wait for a trusted distribution.
Do not remove quarantine or disable security controls to follow this guide.

## Expected workflow

Begin with a small disposable local folder whose files you own and understand.
One generated-folder workflow passed on a virtual arm64 Mac under production
app entitlements: selection/scan, review/cancel, authored Trash/restoration,
native report export and keyboard rescan. This does not establish fresh-Mac,
Intel runtime, denied-access or other filesystem-provider behavior.

1. Choose **Choose Folder** and select one local folder. The sandbox declares
   user-selected read/write access; the selection lasts only for this session.
   Roomlet does not request Full Disk Access or retain a folder bookmark.
2. Choose **Scan**. Roomlet collects metadata, not file contents. It does not
   follow symlinks or cross volumes; packages, protected/known cloud paths and
   OS-marked cloud items are excluded. Renamed sync folders cannot reliably be
   recognized, so Roomlet cannot certify files as unsynced or disposable.
3. Review names, paths and sizes. Nothing starts selected. A partial scan is
   incomplete: default limits are 200,000 visited entries, 10,000 results and
   64 levels. **Stop** preserves the collected partial outcome.
4. If you intend to remove files, select at most 200 regular files and choose
   **Review**. Read the complete list before the explicit **Move … Files to
   Trash** action; choose **Keep Files** to cancel the review.
5. Read each recorded outcome. Changed/protected candidates are refused; a
   stopped batch may already have moved some files. Scan again before another
   batch. Revalidation reduces stale-file risk; it is not an atomic transaction
   against concurrent filesystem changes.
6. **Save Report…** exports paths and metadata through the native Save panel.
   Choosing another folder, reselecting the same folder, or starting a scan with
   **Command-R** opens Files. A new folder clears the previous cleanup outcome;
   every new scan starts with no files selected.

Moving files to Trash does **not** reclaim their space. Roomlet does not empty
Trash or permanently delete files. Finder's Trash is a separate macOS action;
use **Refresh Available Space** to obtain a new observed volume reading.
Logical size, allocation estimates and available space differ: APFS sharing,
compression, hard links, snapshots and other activity can affect the values.

Roomlet's source and evidence are available at
https://github.com/alvarovillalbaa/roomlet. The native workflow and its limits are
recorded in docs/results/2026/11-12/native-ui-acceptance.md. Authored core/native
and package checks do not establish private-folder safety, all filesystem
providers, permission prompts or reclaimed-space claims.
