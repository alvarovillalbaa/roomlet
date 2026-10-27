import RoomletCore
import SwiftUI

@MainActor
struct CleanupReviewView: View {
    let review: CleanupReview
    let cancel: () -> Void
    let move: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label("Review before moving", systemImage: "trash")
                .font(.title2.bold())
            Text("Move \(review.files.count) selected files to Trash?").font(.headline)
            Text(review.snapshot.rootURL.path).font(.caption).foregroundStyle(.secondary).textSelection(.enabled)
                .help(review.snapshot.rootURL.path)
            Table(review.files) {
                TableColumn("Relative Path") { file in
                    Text(file.relativePath).lineLimit(2).textSelection(.enabled).help(file.relativePath)
                }.width(min: 300)
                TableColumn("Logical Size") { file in Text(FileFormatting.bytes(file.logicalBytes)).monospacedDigit() }
                    .width(110)
                TableColumn("On Disk") { file in Text(FileFormatting.bytes(file.allocatedBytes)).monospacedDigit() }
                    .width(110)
            }
            .frame(minHeight: 220)
            Text("Logical size: \(FileFormatting.logicalTotal(review.files)). Roomlet rechecks every file before moving it. Changed or inaccessible candidates are skipped, and each result is recorded.")
                .font(.callout).foregroundStyle(.secondary)
            Text("Files in Trash still occupy space. Emptying Trash is a separate action in Finder; Roomlet never empties it.")
                .font(.callout)
            HStack {
                Button("Keep Files", action: cancel).keyboardShortcut(.cancelAction)
                Spacer()
                Button("Move \(review.files.count) Files to Trash", role: .destructive, action: move)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 780, height: 530)
    }
}
