import Foundation

public struct FileFingerprint: Hashable, Sendable {
    public let device: UInt64
    public let inode: UInt64
    public let logicalBytes: Int64
    public let modifiedSeconds: Int64
    public let modifiedNanoseconds: Int64

    public init(device: UInt64, inode: UInt64, logicalBytes: Int64, modifiedSeconds: Int64, modifiedNanoseconds: Int64) {
        self.device = device
        self.inode = inode
        self.logicalBytes = logicalBytes
        self.modifiedSeconds = modifiedSeconds
        self.modifiedNanoseconds = modifiedNanoseconds
    }
}

public struct RootIdentity: Hashable, Sendable {
    public let device: UInt64
    public let inode: UInt64

    public init(device: UInt64, inode: UInt64) {
        self.device = device
        self.inode = inode
    }
}

public struct ScannedFile: Identifiable, Hashable, Sendable {
    public let id: String
    public let relativePath: String
    public let logicalBytes: Int64
    public let allocatedBytes: Int64?
    public let modifiedAt: Date
    public let fingerprint: FileFingerprint

    public init(id: String, relativePath: String, logicalBytes: Int64, allocatedBytes: Int64?, modifiedAt: Date, fingerprint: FileFingerprint) {
        self.id = id
        self.relativePath = relativePath
        self.logicalBytes = logicalBytes
        self.allocatedBytes = allocatedBytes
        self.modifiedAt = modifiedAt
        self.fingerprint = fingerprint
    }
}

public struct ScanOptions: Sendable {
    public let maxEntries: Int
    public let maxResults: Int
    public let maxDepth: Int

    public init(maxEntries: Int = 200_000, maxResults: Int = 10_000, maxDepth: Int = 64) {
        self.maxEntries = min(200_000, max(1, maxEntries))
        self.maxResults = min(10_000, max(1, maxResults))
        self.maxDepth = min(64, max(1, maxDepth))
    }
}

public struct ScanProgress: Sendable {
    public let visitedEntries: Int
    public let foundFiles: Int

    public init(visitedEntries: Int, foundFiles: Int) {
        self.visitedEntries = visitedEntries
        self.foundFiles = foundFiles
    }
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

    public init(id: UUID = UUID(), rootURL: URL, rootIdentity: RootIdentity, files: [ScannedFile], visitedEntries: Int, skippedEntries: Int, issues: [String], isComplete: Bool, finishedAt: Date = Date()) {
        self.id = id
        self.rootURL = rootURL
        self.rootIdentity = rootIdentity
        self.files = files
        self.visitedEntries = visitedEntries
        self.skippedEntries = skippedEntries
        self.issues = issues
        self.isComplete = isComplete
        self.finishedAt = finishedAt
    }
}

public struct CapacityReading: Sendable {
    public let availableBytes: Int64?
    public let totalBytes: Int64?
    public let recordedAt: Date

    public init(availableBytes: Int64?, totalBytes: Int64?, recordedAt: Date = Date()) {
        self.availableBytes = availableBytes
        self.totalBytes = totalBytes
        self.recordedAt = recordedAt
    }
}

public enum RoomletError: Error, LocalizedError, Equatable {
    case invalidRoot(String)
    case excluded(String)
    case unreadable(String)
    case invalidCandidate(String)
    case changed(String)

    public var errorDescription: String? {
        switch self {
        case .invalidRoot(let message), .excluded(let message), .unreadable(let message),
             .invalidCandidate(let message), .changed(let message): return message
        }
    }
}
