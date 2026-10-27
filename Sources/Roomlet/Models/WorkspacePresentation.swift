import Foundation
import RoomletCore

enum WorkspaceSection: String, Hashable {
    case files
    case cleanup
}

enum WorkPhase: Equatable {
    case idle
    case scanning
    case moving
}

enum SizeFilter: String, CaseIterable, Identifiable {
    case all = "Any size"
    case tenMegabytes = "10 MB or more"
    case hundredMegabytes = "100 MB or more"
    case gigabyte = "1 GB or more"

    var id: Self { self }

    var minimumBytes: Int64 {
        switch self {
        case .all: return 0
        case .tenMegabytes: return 10_000_000
        case .hundredMegabytes: return 100_000_000
        case .gigabyte: return 1_000_000_000
        }
    }
}

enum FileOrder: String, CaseIterable, Identifiable {
    case allocated = "On disk, largest first"
    case logical = "Logical size, largest first"
    case modified = "Recently modified first"

    var id: Self { self }
}

struct AppNotice {
    let message: String
    let isError: Bool
}

struct CleanupReview: Identifiable, Sendable {
    let id = UUID()
    let snapshot: ScanSnapshot
    let files: [ScannedFile]
}
