import Foundation
import RoomletCore

enum CleanupDisposition: String, Codable, Sendable {
    case moved
    case failed
    case notAttempted
}

struct CleanupItemOutcome: Identifiable, Codable, Sendable {
    let id: String
    let relativePath: String
    let logicalBytes: Int64
    let disposition: CleanupDisposition
    let destinationPath: String?
    let error: String?
}

struct CapacityObservation: Codable, Sendable {
    let availableBytes: Int64?
    let totalBytes: Int64?
    let recordedAt: Date

    init(_ reading: CapacityReading) {
        availableBytes = reading.availableBytes
        totalBytes = reading.totalBytes
        recordedAt = reading.recordedAt
    }
}

struct CleanupOutcome: Identifiable, Codable, Sendable {
    let id: UUID
    let rootPath: String
    let startedAt: Date
    let finishedAt: Date
    let items: [CleanupItemOutcome]
    let before: CapacityObservation
    let after: CapacityObservation
    let wasCancelled: Bool

    var movedCount: Int { items.filter { $0.disposition == .moved }.count }
    var failedCount: Int { items.filter { $0.disposition == .failed }.count }
    var unattemptedCount: Int { items.filter { $0.disposition == .notAttempted }.count }

    var trashURL: URL? {
        guard let path = items.first(where: { $0.disposition == .moved })?.destinationPath else { return nil }
        return URL(fileURLWithPath: path).deletingLastPathComponent()
    }
}
