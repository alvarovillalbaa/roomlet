import AppKit

@MainActor
final class RoomletAppDelegate: NSObject, NSApplicationDelegate {
    static weak var workspace: RoomletStore?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard let workspace = Self.workspace, workspace.isWorking else { return .terminateNow }
        let alert = NSAlert()
        alert.messageText = "Roomlet is still working"
        alert.informativeText = "Keep Roomlet open until the current scan or Trash operation finishes. You can stop after the current file and review the partial result before quitting."
        alert.addButton(withTitle: "Keep Roomlet Open")
        alert.addButton(withTitle: "Stop After Current File")
        if alert.runModal() == .alertSecondButtonReturn { workspace.stop() }
        return .terminateCancel
    }
}
