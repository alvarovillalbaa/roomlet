import SwiftUI

@MainActor
struct RoomletCommands: Commands {
    let store: RoomletStore

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("Choose Folder…") { store.chooseFolder() }
                .keyboardShortcut("o")
                .disabled(!store.canChooseFolder)
        }
        CommandMenu("Workspace") {
            Button("Scan Selected Folder") { store.startScan() }
                .keyboardShortcut("r")
                .disabled(!store.canScan)
            Button("Stop After Current File") { store.stop() }
                .keyboardShortcut(".")
                .disabled(!store.isWorking || store.stopRequested)
            Button("Refresh Available Space") { store.refreshSpace() }
                .keyboardShortcut("r", modifiers: [.command, .shift])
                .disabled(store.rootURL == nil || store.isWorking || store.review != nil)
            Divider()
            Button("Review Selected Files…") { store.reviewSelection() }
                .keyboardShortcut(.delete, modifiers: .command)
                .disabled(!store.canReview)
            Button("Open Trash in Finder") { store.openTrash() }
                .disabled(store.isWorking)
            Button("Save Cleanup Report…") { store.saveReport() }
                .keyboardShortcut("s", modifiers: [.command, .shift])
                .disabled(store.lastOutcome == nil || store.isWorking)
        }
    }
}
