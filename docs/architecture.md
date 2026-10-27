# Architecture

`RoomletCore` is a Foundation/Darwin library for bounded metadata scans,
fingerprints, path protection, capacity readings and cleanup validation.
`Roomlet` is a SwiftUI executable with narrow AppKit folder-picker/Finder/Trash
boundaries. `RoomletCoreTests` contains authored fixtures; tests must never touch
the user's Trash or unrelated folders.

The main window and menu entry expose the same current operation. Scan and
cleanup workers run off the main actor; progress/results carry a generation so
older workers cannot replace a newer folder/session. A selected folder's
security scope outlives every worker using it. Selection starts empty, cleanup
review is explicit, and an attempted batch invalidates its scan.

Root device/inode and regular-file device/inode/size/nanosecond modification
fingerprints catch ordinary stale snapshots. Ancestor/path/package/known-cloud rules
are reapplied immediately before Trash. This is not an atomic filesystem
transaction against a malicious concurrent writer. The app only moves selected
regular files to Trash and reports each result; it never permanently deletes.
Known sync paths/name forms and iCloud/dataless metadata are checked. This cannot
identify arbitrary renamed third-party sync folders or certify files as unsynced.

Logical bytes, optional allocated bytes and optional observed volume capacity
remain separate in the model and interface. Unknown values are not zero.
Volume changes are observations, not attributed savings. Apple's
[allocated-size contract](https://developer.apple.com/documentation/foundation/urlresourcevalues/totalfileallocatedsize)
includes metadata and can differ from logical size; the
[Trash API](https://developer.apple.com/documentation/foundation/filemanager/trashitem(at:resultingitemurl:))
returns the resulting location, whose name may differ from the original.

The SwiftPM executable is packaged as a real `.app` with explicit bundle metadata
and sandbox entitlements by the single local run helper. Source syntax parsing
does not validate linking, concurrency isolation, sandbox access, GUI behavior,
Trash integration, signing or distribution. Keep proof in the owning receipt.
