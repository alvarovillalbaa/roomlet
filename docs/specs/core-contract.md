# Core and app boundary

`RoomletCore` owns the scanner, metadata/fingerprint rules, path protections and cleanup validation. `Roomlet` owns SwiftUI state, the AppKit folder/Save panels, security-scope lifetime, Finder actions and the actual `FileManager.trashItem` boundary. No file content reads, shell commands or network calls belong in either target.

The public API below is the shared implementation contract. Any necessary adjustment must be coordinated between core and app owners before editing callers.

```swift
public struct FileFingerprint: Hashable, Sendable {
    public let device: UInt64
    public let inode: UInt64
    public let logicalBytes: Int64
    public let modifiedSeconds: Int64
    public let modifiedNanoseconds: Int64
}
public struct RootIdentity: Hashable, Sendable {
    public let device: UInt64
    public let inode: UInt64
}
public struct ScannedFile: Identifiable, Hashable, Sendable {
    public let id: String
    public let relativePath: String
    public let logicalBytes: Int64
    public let allocatedBytes: Int64?
    public let modifiedAt: Date
    public let fingerprint: FileFingerprint
}
public struct ScanOptions: Sendable {
    public init(maxEntries: Int = 200_000, maxResults: Int = 10_000, maxDepth: Int = 64)
}
public struct ScanProgress: Sendable {
    public let visitedEntries: Int
    public let foundFiles: Int
}
public struct ScanSnapshot: Sendable {
    public let id: UUID
    public let rootURL: URL
    public let rootIdentity: RootIdentity
    public let files: [ScannedFile]
    public let visitedEntries: Int
    public let skippedEntries: Int
    public let issues: [String]
    public let isComplete: Bool
    public let finishedAt: Date
}
public struct CapacityReading: Sendable {
    public let availableBytes: Int64?
    public let totalBytes: Int64?
    public let recordedAt: Date
}
public enum DiskScanner {
    public static func scan(root: URL, options: ScanOptions = ScanOptions(),
        shouldCancel: @Sendable () -> Bool = { false },
        progress: @Sendable (ScanProgress) -> Void = { _ in }) throws -> ScanSnapshot
    public static func capacity(at root: URL) -> CapacityReading
}
public enum CleanupGuard {
    public static let maximumSelection: Int // 200
    public static func validate(snapshot: ScanSnapshot, file: ScannedFile) throws -> URL
}
```

All listed value types need public initializers for authored fixtures and app use. File IDs identify paths within one scan; inode/device alone do not distinguish hard-link paths. Unknown allocation/capacity stays nil, never zero. Cancellation returns an incomplete snapshot with bounded issues and whatever entries were already collected. Size/result limits must not be presented as a full disk analysis.

The app calls `CleanupGuard.validate` immediately before each selected file's Trash boundary. Validation must reject forged/nonmember candidates, traversal/absolute paths, root replacement, ancestor links, protected/package/cloud paths, changed identity/size/time, nonregular files and volume changes. Validation reduces ordinary stale-scan risk; it is not an atomic filesystem transaction or protection against a malicious concurrent filesystem writer. Trash is recoverable and errors remain explicit.

After an attempted batch, invalidate the scan so it cannot be reused as a current cleanup plan; keep a separate outcome containing each success/failure. The user can refresh/rescan intentionally. Do not lose the selected folder's security scope during a scan or cleanup, or accept a stale worker result after folder changes/cancellation.
