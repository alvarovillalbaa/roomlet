import SwiftUI

@MainActor
struct SidebarView: View {
    let store: RoomletStore
    @Binding var section: WorkspaceSection?

    var body: some View {
        List(selection: $section) {
            Section("Workspace") {
                Label("Files", systemImage: "doc.on.doc").tag(WorkspaceSection.files)
                Label("Last Cleanup", systemImage: "clock.arrow.circlepath").tag(WorkspaceSection.cleanup)
            }
            Section("Selected Folder") {
                if let root = store.rootURL {
                    VStack(alignment: .leading, spacing: 3) {
                        Label(root.lastPathComponent, systemImage: "folder")
                            .lineLimit(1)
                        Text(root.path).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                    }
                    .help(root.path)
                } else {
                    Text("No folder selected").foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) {
            Text("Local files. Your decisions.")
                .font(.caption).foregroundStyle(.secondary)
                .padding()
        }
    }
}
