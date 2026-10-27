# Roomlet product scope

Source intent: the inline “(Mac-ext) disk space freer” entry in [Alvaro's project page](https://app.notion.com/p/311a1ee8bd06805caa21c5306dd315ac), fetched 2026-10-27. This is a one-line brief, not a detailed interaction specification. “Roomlet” and the workflow below are implementation choices. The parent reports truncation and three unknown blocks elsewhere; this is not a complete all-project inventory.

Build a native Mac utility with a normal main window and a compact menu-bar entry. It runs locally without an account, cloud database or hosted service.

1. Choose one local folder using the native folder picker. Show its path and available volume space.
2. Scan metadata in a cancellable background operation, with entry/depth/result bounds and an honest partial-result status. Never read file contents or follow links. Exclude protected/system/credential/known cloud locations, OS-marked cloud items, packages and other volumes. Arbitrary renamed sync folders cannot be certified as unsynced.
3. Sort files by on-disk estimate or logical size; search names/relative paths, filter size and select exact files. No automatic selection or “safe to delete” recommendations.
4. Review the complete selected file list, paths and sizes before an explicit Move to Trash action. Revalidate every candidate, skip changed files and record failures without claiming an externally changed file is still present. Cancel between operations; retain the exact partial outcome.
5. Show how many files moved, failures and observed volume availability. Explain that files in Trash still occupy space. Offer Finder's Trash and an explicit space refresh; emptying Trash remains a separate OS action.

Logical file bytes, allocated-byte estimates and observed available-volume bytes are different quantities. Hard links, APFS clones/compression, snapshots, purgeable data and other processes prevent a reliable “bytes freed by this action” claim. Do not invent it.

The app does not permanently delete files, empty Trash, purge snapshots/caches automatically, manage cloud downloads or certify files as disposable. These are deliberate product boundaries, not completed features. Native compilation, filesystem behavior, picker/sandbox/UI, packaging and distribution need their own evidence before calling the app complete.
