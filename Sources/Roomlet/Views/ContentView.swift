import RoomletCore
import SwiftUI

@MainActor
struct ContentView: View {
    @Bindable var store: RoomletStore
    @State private var section: WorkspaceSection? = .files

    var body: some View {
        NavigationSplitView {
            SidebarView(store: store, section: $section)
                .navigationSplitViewColumnWidth(min: 180, ideal: 210, max: 260)
        } detail: {
            VStack(alignment: .leading, spacing: 18) {
                if store.isWorking {
                    HStack(spacing: 10) {
                        ProgressView().controlSize(.small)
                        Text(store.phase == .moving
                             ? "Moving \(store.moveProcessed) of \(store.moveTotal) reviewed files"
                             : "Inspected \(store.visitedEntries) entries · found \(store.foundFiles) files")
                            .font(.callout).monospacedDigit()
                        Spacer()
                        if store.stopRequested { Text("Stopping…").foregroundStyle(.secondary) }
                    }
                }
                Group {
                    if section == .cleanup {
                        CleanupOutcomeView(store: store)
                    } else {
                        FileResultsView(store: store)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 900, minHeight: 600)
        .navigationTitle("Roomlet")
        .toolbar {
            ToolbarItemGroup {
                Button { store.chooseFolder() } label: { Label("Choose Folder", systemImage: "folder.badge.plus") }
                    .help("Choose a local folder (⌘O)")
                    .disabled(!store.canChooseFolder)
                Button { section = .files; store.startScan() } label: { Label("Scan", systemImage: "arrow.clockwise") }
                    .help("Scan the selected folder (⌘R)")
                    .disabled(!store.canScan)
                Button { store.stop() } label: { Label("Stop", systemImage: "stop.fill") }
                    .help("Stop after the current file (⌘.)")
                    .disabled(!store.isWorking || store.stopRequested)
                Divider()
                Button { store.refreshSpace() } label: { Label("Refresh Space", systemImage: "arrow.triangle.2.circlepath") }
                    .help("Measure available volume space again")
                    .disabled(store.rootURL == nil || store.isWorking || store.review != nil || store.isRefreshingSpace)
                Button { store.reviewSelection() } label: { Label("Review \(store.selectedIDs.count)", systemImage: "trash") }
                    .help("Review every selected file before moving anything")
                    .disabled(!store.canReview)
            }
        }
        .sheet(item: $store.review) { review in
            CleanupReviewView(review: review, cancel: { store.review = nil }, move: { store.moveReviewedFiles(review) })
        }
        .onChange(of: store.lastOutcome?.id) { _, value in
            if value != nil { section = .cleanup }
        }
    }
}

@MainActor
struct NoticeView: View {
    @Bindable var store: RoomletStore

    var body: some View {
        if let notice = store.notice {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: notice.isError ? "exclamationmark.triangle" : "info.circle")
                    .foregroundStyle(notice.isError ? Color.orange : Color.secondary)
                Text(notice.message).font(.callout).textSelection(.enabled)
                Spacer(minLength: 8)
                Button { store.notice = nil } label: { Image(systemName: "xmark") }
                    .buttonStyle(.plain).accessibilityLabel("Dismiss notice")
            }
            .padding(12)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
        }
    }
}
