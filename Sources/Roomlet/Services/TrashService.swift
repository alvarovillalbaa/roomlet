import Foundation
import RoomletCore

enum TrashService {
    static func move(
        snapshot: ScanSnapshot,
        files: [ScannedFile],
        shouldCancel: @Sendable () -> Bool,
        progress: @Sendable (Int, Int) -> Void
    ) -> CleanupOutcome {
        let startedAt = Date()
        let before = CapacityObservation(DiskScanner.capacity(at: snapshot.rootURL))
        var outcomes: [CleanupItemOutcome] = []
        let selectionIsAllowed = !files.isEmpty && files.count <= CleanupGuard.maximumSelection

        for (index, file) in files.enumerated() {
            if shouldCancel() {
                outcomes.append(contentsOf: files[index...].map {
                    item($0, disposition: .notAttempted, error: "Stopped before this file.")
                })
                break
            }
            do {
                guard selectionIsAllowed else {
                    throw CocoaError(.fileWriteNoPermission, userInfo: [NSLocalizedDescriptionKey: "Review up to \(CleanupGuard.maximumSelection) files at a time."])
                }
                // Validation happens again for each file, directly before the native move.
                let url = try CleanupGuard.validate(snapshot: snapshot, file: file)
                var destination: NSURL?
                try FileManager.default.trashItem(at: url, resultingItemURL: &destination)
                outcomes.append(item(file, disposition: .moved, destination: destination.map { $0 as URL }))
            } catch {
                outcomes.append(item(file, disposition: .failed, error: error.localizedDescription))
            }
            progress(index + 1, files.count)
        }

        return CleanupOutcome(
            id: UUID(), rootPath: snapshot.rootURL.path, startedAt: startedAt, finishedAt: Date(),
            items: outcomes, before: before,
            after: CapacityObservation(DiskScanner.capacity(at: snapshot.rootURL)),
            wasCancelled: shouldCancel()
        )
    }

    private static func item(
        _ file: ScannedFile, disposition: CleanupDisposition, destination: URL? = nil, error: String? = nil
    ) -> CleanupItemOutcome {
        CleanupItemOutcome(id: file.id, relativePath: file.relativePath, logicalBytes: file.logicalBytes,
                           disposition: disposition, destinationPath: destination?.path, error: error)
    }
}
