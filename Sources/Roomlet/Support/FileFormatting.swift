import Foundation
import RoomletCore

enum FileFormatting {
    static func bytes(_ value: Int64?) -> String {
        guard let value, value >= 0 else { return "Unavailable" }
        return ByteCountFormatter.string(fromByteCount: value, countStyle: .file)
    }

    static func logicalTotal(_ files: [ScannedFile]) -> String {
        var total: Int64 = 0
        for file in files {
            let (next, overflow) = total.addingReportingOverflow(max(0, file.logicalBytes))
            if overflow { return "At least \(bytes(Int64.max))" }
            total = next
        }
        return bytes(total)
    }

    static func ordered(_ files: [ScannedFile], by order: FileOrder) -> [ScannedFile] {
        files.sorted { left, right in
            switch order {
            case .allocated:
                switch (left.allocatedBytes, right.allocatedBytes) {
                case let (leftBytes?, rightBytes?) where leftBytes != rightBytes:
                    return leftBytes > rightBytes
                case (.some, .none): return true
                case (.none, .some): return false
                default: break
                }
            case .logical:
                if left.logicalBytes != right.logicalBytes { return left.logicalBytes > right.logicalBytes }
            case .modified:
                if left.modifiedAt != right.modifiedAt { return left.modifiedAt > right.modifiedAt }
            }
            if left.logicalBytes != right.logicalBytes { return left.logicalBytes > right.logicalBytes }
            return left.relativePath.localizedStandardCompare(right.relativePath) == .orderedAscending
        }
    }
}
