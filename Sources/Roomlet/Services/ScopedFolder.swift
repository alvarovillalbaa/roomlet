import AppKit
import Foundation

final class ScopedFolder: @unchecked Sendable {
    let url: URL
    private let accessStarted: Bool

    init(url: URL) {
        self.url = url
        accessStarted = url.startAccessingSecurityScopedResource()
    }

    deinit {
        if accessStarted { url.stopAccessingSecurityScopedResource() }
    }
}

@MainActor
enum FolderPicker {
    static func choose() -> URL? {
        let panel = NSOpenPanel()
        panel.title = "Choose a folder to inspect"
        panel.message = "Roomlet reads file metadata only in the folder you choose."
        panel.prompt = "Choose Folder"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.resolvesAliases = false
        panel.canDownloadUbiquitousContents = false
        panel.canResolveUbiquitousConflicts = false
        panel.showsHiddenFiles = false
        return panel.runModal() == .OK ? panel.url : nil
    }
}
