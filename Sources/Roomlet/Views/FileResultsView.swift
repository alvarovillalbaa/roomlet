import RoomletCore
import SwiftUI

@MainActor
struct FileResultsView: View {
    @Bindable var store: RoomletStore

    var body: some View {
        if let root = store.rootURL {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(root.lastPathComponent).font(.largeTitle.bold())
                    Text(root.path).foregroundStyle(.secondary).textSelection(.enabled).lineLimit(2)
                }
                CapacitySummaryView(store: store)
                NoticeView(store: store)
                if let snapshot = store.snapshot {
                    filterBar
                    FileTableView(store: store)
                    HStack {
                        Text("\(store.visibleFiles.count) of \(snapshot.files.count) collected files · \(store.selectedIDs.count) selected")
                        Spacer()
                        if store.selectedIDs.count > CleanupGuard.maximumSelection {
                            Text("Review up to \(CleanupGuard.maximumSelection) at a time").foregroundStyle(.orange)
                        }
                    }
                    .font(.caption).foregroundStyle(.secondary)
                    DisclosureGroup(store.isPartialScan ? "Incomplete scan and exclusions" : "Scan notes and exclusions") {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(snapshot.visitedEntries) entries inspected; \(snapshot.skippedEntries) entries skipped. Collected results prioritize the largest on-disk estimates, using logical size when allocation is unavailable.")
                            Text("Sorting by logical size reorders these collected files. Protected locations, packages, links, known cloud-managed items and other volumes are excluded.")
                            ForEach(Array(snapshot.issues.enumerated()), id: \.offset) { _, issue in Text(issue) }
                        }
                        .font(.caption).foregroundStyle(.secondary).textSelection(.enabled).padding(.top, 6)
                    }
                } else if !store.isWorking {
                    ContentUnavailableView {
                        Label("Ready when you are", systemImage: "internaldrive")
                    } description: {
                        Text("Scan this folder to review collected file sizes. Nothing is selected or moved automatically.")
                    } actions: {
                        Button("Scan Folder") { store.startScan() }.buttonStyle(.borderedProminent)
                    }
                } else {
                    Spacer()
                }
            }
        } else {
            ContentUnavailableView {
                Label("Make room for what matters", systemImage: "internaldrive")
            } description: {
                Text("Choose a local folder to inspect file sizes, review your selection, and move unwanted files to Trash.")
            } actions: {
                Button("Choose Folder…") { store.chooseFolder() }
                    .buttonStyle(.borderedProminent).keyboardShortcut("o")
            }
        }
    }

    private var filterBar: some View {
        HStack {
            TextField("Search file names and paths", text: $store.searchText)
                .textFieldStyle(.roundedBorder).accessibilityLabel("Search file names and relative paths")
            Picker("Size", selection: $store.sizeFilter) {
                ForEach(SizeFilter.allCases) { Text($0.rawValue).tag($0) }
            }.frame(width: 185)
            Picker("Order", selection: $store.fileOrder) {
                ForEach(FileOrder.allCases) { Text($0.rawValue).tag($0) }
            }.frame(width: 245)
        }
    }
}

@MainActor
private struct CapacitySummaryView: View {
    let store: RoomletStore

    var body: some View {
        HStack(spacing: 16) {
            metric("Available space", value: FileFormatting.bytes(store.capacity?.availableBytes), note: store.isRefreshingSpace ? "Measuring…" : "Observed on this volume")
            metric("Files collected", value: store.snapshot.map { String($0.files.count) } ?? "Not scanned", note: store.isPartialScan ? "Incomplete scan" : "Metadata only")
            metric("Selected logical size", value: FileFormatting.logicalTotal(store.selectedFiles), note: "Not a reclaimed-space estimate")
        }
    }

    private func metric(_ title: String, value: String, note: String) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.caption).foregroundStyle(.secondary)
                Text(value).font(.title2.weight(.semibold)).monospacedDigit()
                Text(note).font(.caption2).foregroundStyle(.secondary)
            }.frame(maxWidth: .infinity, alignment: .leading).padding(5)
        }
    }
}
