import AppKit
import Foundation
import Observation
import RoomletCore

@MainActor
@Observable
final class RoomletStore {
    var rootURL: URL?
    var snapshot: ScanSnapshot?
    var capacity: CapacityReading?
    var selectedIDs: Set<String> = []
    var searchText = ""
    var sizeFilter = SizeFilter.all
    var fileOrder = FileOrder.allocated
    var phase = WorkPhase.idle
    var visitedEntries = 0
    var foundFiles = 0
    var moveProcessed = 0
    var moveTotal = 0
    var stopRequested = false
    var scanWasStopped = false
    var isRefreshingSpace = false
    var notice: AppNotice?
    var review: CleanupReview?
    var lastOutcome: CleanupOutcome?

    @ObservationIgnored private var folder: ScopedFolder?
    @ObservationIgnored private var operation: Task<Void, Never>?
    @ObservationIgnored private var spaceOperation: Task<Void, Never>?
    @ObservationIgnored private var generation = UUID()
    @ObservationIgnored private var spaceRequest = UUID()

    deinit {
        operation?.cancel()
        spaceOperation?.cancel()
    }

    var isWorking: Bool { phase != .idle }
    var canChooseFolder: Bool { !isWorking && review == nil }
    var canScan: Bool { folder != nil && !isWorking && review == nil }
    var isPartialScan: Bool { scanWasStopped || snapshot?.isComplete == false }
    var selectedFiles: [ScannedFile] {
        (snapshot?.files ?? []).filter { selectedIDs.contains($0.id) }.sorted {
            $0.relativePath.localizedStandardCompare($1.relativePath) == .orderedAscending
        }
    }
    var canReview: Bool {
        snapshot != nil && !isWorking && review == nil && !selectedIDs.isEmpty
            && selectedFiles.count == selectedIDs.count && selectedIDs.count <= CleanupGuard.maximumSelection
    }
    var visibleFiles: [ScannedFile] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let matches = (snapshot?.files ?? []).filter {
            $0.logicalBytes >= sizeFilter.minimumBytes
                && (query.isEmpty || $0.relativePath.localizedStandardContains(query))
        }
        return FileFormatting.ordered(matches, by: fileOrder)
    }

    func chooseFolder() {
        guard canChooseFolder, let chosen = FolderPicker.choose() else { return }
        generation = UUID()
        spaceRequest = UUID()
        spaceOperation?.cancel()
        isRefreshingSpace = false
        folder = ScopedFolder(url: chosen)
        rootURL = chosen
        snapshot = nil
        selectedIDs.removeAll()
        lastOutcome = nil
        notice = nil
        capacity = nil
        visitedEntries = 0
        foundFiles = 0
        searchText = ""
        scanWasStopped = false
        refreshSpace()
    }

    func startScan() {
        guard canScan, let folder else { return }
        let token = UUID()
        generation = token
        spaceRequest = UUID()
        spaceOperation?.cancel()
        isRefreshingSpace = false
        phase = .scanning
        snapshot = nil
        selectedIDs.removeAll()
        notice = nil
        stopRequested = false
        scanWasStopped = false
        visitedEntries = 0
        foundFiles = 0
        operation = Task.detached(priority: .userInitiated) { [weak self, folder] in
            do {
                let result = try withExtendedLifetime(folder) {
                    try DiskScanner.scan(root: folder.url, shouldCancel: { Task.isCancelled }, progress: { update in
                        Task { @MainActor [weak self] in
                            guard let self, self.generation == token, self.phase == .scanning else { return }
                            self.visitedEntries = update.visitedEntries
                            self.foundFiles = update.foundFiles
                        }
                    })
                }
                let reading = withExtendedLifetime(folder) { DiskScanner.capacity(at: folder.url) }
                await self?.finishScan(result, capacity: reading, token: token, cancelled: Task.isCancelled)
            } catch {
                await self?.failOperation(error.localizedDescription, token: token)
            }
        }
    }

    private func finishScan(_ result: ScanSnapshot, capacity: CapacityReading, token: UUID, cancelled: Bool) {
        guard generation == token, phase == .scanning else { return }
        snapshot = result
        self.capacity = capacity
        visitedEntries = result.visitedEntries
        foundFiles = result.files.count
        scanWasStopped = cancelled || stopRequested
        phase = .idle
        operation = nil
        if isPartialScan {
            notice = AppNotice(message: "This scan is incomplete. Review its limits and skipped items before selecting files.", isError: false)
        }
    }

    private func failOperation(_ message: String, token: UUID) {
        guard generation == token else { return }
        phase = .idle
        operation = nil
        notice = AppNotice(message: message, isError: true)
    }

    func stop() {
        guard isWorking else { return }
        stopRequested = true
        operation?.cancel()
    }

    func refreshSpace() {
        guard let folder, !isWorking, review == nil, !isRefreshingSpace else { return }
        let token = UUID()
        let workspace = generation
        spaceRequest = token
        spaceOperation?.cancel()
        isRefreshingSpace = true
        spaceOperation = Task.detached(priority: .utility) { [weak self, folder] in
            let reading = withExtendedLifetime(folder) { DiskScanner.capacity(at: folder.url) }
            guard !Task.isCancelled else { return }
            await self?.finishSpaceRefresh(reading, token: token, workspace: workspace)
        }
    }

    private func finishSpaceRefresh(_ reading: CapacityReading, token: UUID, workspace: UUID) {
        guard spaceRequest == token, generation == workspace else { return }
        capacity = reading
        isRefreshingSpace = false
        spaceOperation = nil
    }

    func reviewSelection() {
        guard canReview, let snapshot else { return }
        review = CleanupReview(snapshot: snapshot, files: selectedFiles)
    }

    func moveReviewedFiles(_ candidate: CleanupReview) {
        guard review?.id == candidate.id, snapshot?.id == candidate.snapshot.id,
              !isWorking, let folder, !candidate.files.isEmpty,
              candidate.files.count <= CleanupGuard.maximumSelection else { return }
        review = nil
        snapshot = nil
        selectedIDs.removeAll()
        notice = nil
        phase = .moving
        stopRequested = false
        moveProcessed = 0
        moveTotal = candidate.files.count
        let token = UUID()
        generation = token
        spaceRequest = UUID()
        spaceOperation?.cancel()
        isRefreshingSpace = false
        operation = Task.detached(priority: .userInitiated) { [weak self, folder] in
            let outcome = withExtendedLifetime(folder) {
                TrashService.move(snapshot: candidate.snapshot, files: candidate.files,
                    shouldCancel: { Task.isCancelled }, progress: { done, total in
                        Task { @MainActor [weak self] in
                            guard let self, self.generation == token, self.phase == .moving else { return }
                            self.moveProcessed = done
                            self.moveTotal = total
                        }
                    })
            }
            await self?.finishMove(outcome, token: token)
        }
    }

    private func finishMove(_ outcome: CleanupOutcome, token: UUID) {
        guard generation == token, phase == .moving else { return }
        lastOutcome = outcome
        capacity = CapacityReading(availableBytes: outcome.after.availableBytes, totalBytes: outcome.after.totalBytes,
                                   recordedAt: outcome.after.recordedAt)
        moveProcessed = outcome.items.count - outcome.unattemptedCount
        phase = .idle
        operation = nil
        notice = AppNotice(message: "\(outcome.movedCount) files moved to Trash. Scan again before another cleanup.", isError: outcome.failedCount > 0)
    }

    func reveal(_ file: ScannedFile) {
        guard let snapshot, !isWorking else { return }
        do { NSWorkspace.shared.activateFileViewerSelecting([try CleanupGuard.validate(snapshot: snapshot, file: file)]) }
        catch { notice = AppNotice(message: error.localizedDescription, isError: true) }
    }

    func openTrash() {
        let trash = lastOutcome?.trashURL ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".Trash", isDirectory: true)
        if !NSWorkspace.shared.open(trash) {
            notice = AppNotice(message: "Finder could not open Trash. Open it from the Dock instead.", isError: true)
        }
    }

    func saveReport() {
        guard !isWorking, let lastOutcome else { return }
        do {
            if try ReportExporter.save(lastOutcome) {
                notice = AppNotice(message: "Cleanup report saved. It contains file paths and metadata, not file contents.", isError: false)
            }
        } catch { notice = AppNotice(message: "Could not save the report: \(error.localizedDescription)", isError: true) }
    }
}
