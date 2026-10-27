import Foundation

private final class ScanState {
    var visited = 0
    var skipped = 0
    var found = 0
    var complete = true
    var issues: [String] = []

    func issue(_ message: String) {
        complete = false
        guard issues.count < 20, !issues.contains(message) else { return }
        issues.append(String(message.prefix(500)))
    }
}

public enum DiskScanner {
    public static func scan(root: URL, options: ScanOptions = ScanOptions(),
                            shouldCancel: @Sendable () -> Bool = { false },
                            progress: @Sendable (ScanProgress) -> Void = { _ in }) throws -> ScanSnapshot {
        let (rootURL, rootIdentity) = try PathPolicy.validatedRoot(root)
        let state = ScanState()
        var largest = LargestFiles(limit: options.maxResults)
        let enumerator = FileManager.default.enumerator(at: rootURL, includingPropertiesForKeys: [], options: []) { url, _ in
            state.visited = min(options.maxEntries, state.visited + 1)
            state.skipped += 1
            state.issue("Could not inspect \(url.lastPathComponent); the results omit unreadable entries.")
            return state.visited < options.maxEntries
        }
        guard let enumerator else { throw RoomletError.unreadable("The selected folder could not be enumerated.") }

        while true {
            if shouldCancel() { state.issue("Scan stopped. These are partial results."); break }
            if state.visited >= options.maxEntries { state.issue("Entry limit reached. These are partial results."); break }
            guard let url = enumerator.nextObject() as? URL else { break }
            if state.visited >= options.maxEntries { state.issue("Entry limit reached. These are partial results."); break }
            state.visited += 1
            if state.visited % 200 == 0 {
                progress(ScanProgress(visitedEntries: state.visited, foundFiles: state.found))
            }
            do {
                let relative = try PathPolicy.relativePath(of: url, under: rootURL)
                let metadata = try FileMetadata.read(url)
                if metadata.isSymbolicLink || metadata.fingerprint.device != rootIdentity.device || PathPolicy.isExcluded(url) {
                    enumerator.skipDescendants(); state.skipped += 1; continue
                }
                let values = try MetadataPolicy.values(url)
                if MetadataPolicy.isExcluded(values, metadata: metadata) {
                    enumerator.skipDescendants(); state.skipped += 1; continue
                }
                if metadata.isDirectory {
                    if enumerator.level >= options.maxDepth {
                        enumerator.skipDescendants(); state.skipped += 1
                        state.issue("Depth limit reached. Some subfolders were not inspected.")
                    }
                    continue
                }
                guard metadata.isRegularFile else { state.skipped += 1; continue }
                let checked = try FileMetadata.read(url)
                guard checked.isRegularFile, checked.fingerprint == metadata.fingerprint else {
                    state.skipped += 1; state.issue("A file changed during the scan and was omitted."); continue
                }
                let fingerprint = checked.fingerprint
                let file = ScannedFile(id: PathPolicy.fileID(path: relative, fingerprint: fingerprint),
                    relativePath: relative, logicalBytes: fingerprint.logicalBytes,
                    allocatedBytes: MetadataPolicy.allocatedBytes(values),
                    modifiedAt: Date(timeIntervalSince1970: Double(fingerprint.modifiedSeconds) + Double(fingerprint.modifiedNanoseconds) / 1_000_000_000),
                    fingerprint: fingerprint)
                state.found += 1
                if state.found > options.maxResults {
                    state.skipped += 1
                    state.issue("Result limit reached. Only the largest on-disk estimates among inspected files are retained.")
                }
                largest.insert(file)
            } catch {
                enumerator.skipDescendants(); state.skipped += 1
                state.issue("An entry could not be inspected and was omitted.")
            }
        }
        if (try? FileMetadata.read(rootURL).rootIdentity) != rootIdentity {
            state.issue("The selected folder changed during the scan. Scan it again before cleanup.")
        }
        progress(ScanProgress(visitedEntries: state.visited, foundFiles: state.found))
        return ScanSnapshot(rootURL: rootURL, rootIdentity: rootIdentity, files: largest.sorted(),
            visitedEntries: state.visited, skippedEntries: state.skipped, issues: state.issues, isComplete: state.complete)
    }

    public static func capacity(at root: URL) -> CapacityReading {
        guard root.isFileURL, let values = try? URL(fileURLWithPath: root.path).resourceValues(forKeys: [.volumeAvailableCapacityKey, .volumeTotalCapacityKey]) else {
            return CapacityReading(availableBytes: nil, totalBytes: nil)
        }
        let available = values.volumeAvailableCapacity.flatMap { $0 >= 0 ? Int64($0) : nil }
        let total = values.volumeTotalCapacity.flatMap { $0 >= 0 ? Int64($0) : nil }
        return CapacityReading(availableBytes: available, totalBytes: total)
    }
}
