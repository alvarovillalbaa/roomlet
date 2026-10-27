import Foundation
import RoomletCore
import SwiftUI

@MainActor
struct FileTableView: View {
    @Bindable var store: RoomletStore

    var body: some View {
        Table(store.visibleFiles, selection: $store.selectedIDs) {
            TableColumn("File") { file in
                VStack(alignment: .leading, spacing: 3) {
                    Text(URL(fileURLWithPath: file.relativePath).lastPathComponent).lineLimit(1)
                    Text(file.relativePath).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
                .help(file.relativePath)
                .contextMenu { Button("Show in Finder") { store.reveal(file) }.disabled(store.isWorking) }
            }.width(min: 220, ideal: 350)
            TableColumn("Logical Size") { file in
                Text(FileFormatting.bytes(file.logicalBytes)).monospacedDigit()
            }.width(min: 90, ideal: 110)
            TableColumn("On Disk") { file in
                Text(FileFormatting.bytes(file.allocatedBytes)).monospacedDigit()
                    .help("An allocation estimate; links, clones and snapshots can affect actual reclaimed space.")
            }.width(min: 90, ideal: 110)
            TableColumn("Modified") { file in
                Text(file.modifiedAt, style: .date).foregroundStyle(.secondary)
            }.width(min: 100, ideal: 120)
        }
        .frame(minHeight: 190)
        .overlay {
            if store.visibleFiles.isEmpty {
                ContentUnavailableView("No matching files", systemImage: "doc.text.magnifyingglass",
                                       description: Text("Try another search or size filter. Excluded and inaccessible files are not shown."))
            }
        }
    }
}
