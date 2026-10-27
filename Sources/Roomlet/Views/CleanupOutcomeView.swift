import SwiftUI

@MainActor
struct CleanupOutcomeView: View {
    let store: RoomletStore

    var body: some View {
        if let outcome = store.lastOutcome {
            VStack(alignment: .leading, spacing: 18) {
                Text("Last cleanup").font(.largeTitle.bold())
                Text(outcome.rootPath).foregroundStyle(.secondary).textSelection(.enabled).lineLimit(2)
                NoticeView(store: store)
                HStack(spacing: 18) {
                    outcomeMetric("Moved to Trash", value: String(outcome.movedCount))
                    outcomeMetric("Failed", value: String(outcome.failedCount))
                    outcomeMetric("Not attempted", value: String(outcome.unattemptedCount))
                }
                if outcome.wasCancelled {
                    Label("Stopped after the current file. Completed moves remain in Trash.", systemImage: "stop.circle")
                        .font(.callout)
                }
                GroupBox("Observed available space") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Before").font(.caption).foregroundStyle(.secondary)
                            Text(FileFormatting.bytes(outcome.before.availableBytes)).font(.title3).monospacedDigit()
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("After").font(.caption).foregroundStyle(.secondary)
                            Text(FileFormatting.bytes(outcome.after.availableBytes)).font(.title3).monospacedDigit()
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Latest reading").font(.caption).foregroundStyle(.secondary)
                            Text(FileFormatting.bytes(store.capacity?.availableBytes)).font(.title3).monospacedDigit()
                        }
                    }.padding(8)
                }
                Text("Moving files to Trash does not reclaim their space. Empty Trash in Finder when you are ready, then refresh the reading. Other apps, snapshots and volume activity can also change available space.")
                    .font(.callout).foregroundStyle(.secondary)
                Table(outcome.items) {
                    TableColumn("Relative Path") { item in
                        Text(item.relativePath).lineLimit(2).textSelection(.enabled).help(item.relativePath)
                    }.width(min: 220, ideal: 360)
                    TableColumn("Result") { item in
                        Text(disposition(item.disposition))
                            .foregroundStyle(item.disposition == .failed ? Color.orange : Color.primary)
                    }.width(min: 100, ideal: 130)
                    TableColumn("Details") { item in
                        Text(item.error ?? (item.disposition == .moved ? "Moved to Trash" : ""))
                            .font(.caption).foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }.width(min: 140, ideal: 220)
                }.frame(minHeight: 180)
                HStack {
                    Button("Open Trash in Finder") { store.openTrash() }.disabled(store.isWorking)
                    Button("Refresh Available Space") { store.refreshSpace() }
                        .disabled(store.isWorking || store.isRefreshingSpace || store.review != nil)
                    Spacer()
                    Button("Save Report…") { store.saveReport() }.disabled(store.isWorking)
                }
                Text("Finished \(outcome.finishedAt.formatted(date: .abbreviated, time: .shortened)). The previous scan is invalidated; scan again before another cleanup.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        } else {
            ContentUnavailableView("No cleanup yet", systemImage: "clock.arrow.circlepath",
                                   description: Text("Choose a folder, scan, and review selected files. Every completed or stopped batch will show its individual outcomes here."))
        }
    }

    private func outcomeMetric(_ title: String, value: String) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.caption).foregroundStyle(.secondary)
                Text(value).font(.title2.weight(.semibold)).monospacedDigit()
            }.frame(maxWidth: .infinity, alignment: .leading).padding(5)
        }
    }

    private func disposition(_ value: CleanupDisposition) -> String {
        switch value {
        case .moved: return "Moved"
        case .failed: return "Move not confirmed"
        case .notAttempted: return "Not attempted"
        }
    }
}
