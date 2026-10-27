import AppKit
import SwiftUI

@main
@MainActor
struct RoomletApp: App {
    @NSApplicationDelegateAdaptor(RoomletAppDelegate.self) private var delegate
    @State private var store: RoomletStore

    init() {
        let workspace = RoomletStore()
        _store = State(initialValue: workspace)
        RoomletAppDelegate.workspace = workspace
    }

    var body: some Scene {
        WindowGroup("Roomlet", id: "main") {
            ContentView(store: store)
        }
        .defaultSize(width: 1120, height: 740)
        .commands { RoomletCommands(store: store) }

        MenuBarExtra("Roomlet", systemImage: "internaldrive") {
            RoomletMenu(store: store)
        }
    }
}

@MainActor
private struct RoomletMenu: View {
    @Environment(\.openWindow) private var openWindow
    let store: RoomletStore

    var body: some View {
        Button("Open Roomlet") {
            if let window = NSApp.windows.first(where: { $0.canBecomeMain && !$0.isSheet }) {
                window.makeKeyAndOrderFront(nil)
            } else {
                openWindow(id: "main")
            }
            NSApp.activate(ignoringOtherApps: true)
        }
        Divider()
        if store.isWorking {
            Text(store.phase == .scanning ? "Scanning selected folder…" : "Moving reviewed files…")
            Button("Stop After Current File") { store.stop() }.disabled(store.stopRequested)
        } else {
            Button("Choose Folder…") { store.chooseFolder() }.disabled(!store.canChooseFolder)
            Button("Scan Selected Folder") { store.startScan() }.disabled(!store.canScan)
            Button("Refresh Available Space") { store.refreshSpace() }.disabled(store.rootURL == nil || store.review != nil)
        }
        Divider()
        Button("Quit Roomlet") { NSApp.terminate(nil) }.keyboardShortcut("q")
    }
}
