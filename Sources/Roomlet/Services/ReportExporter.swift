import AppKit
import Foundation
import UniformTypeIdentifiers

@MainActor
enum ReportExporter {
    static func save(_ outcome: CleanupOutcome) throws -> Bool {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(outcome)
        let panel = NSSavePanel()
        panel.title = "Save cleanup report"
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        let date = DateFormatter()
        date.dateFormat = "yyyy-MM-dd-HHmmss"
        panel.nameFieldStringValue = "Roomlet-cleanup-\(date.string(from: outcome.finishedAt)).json"
        guard panel.runModal() == .OK, let url = panel.url else { return false }
        // A report never silently replaces a file already at the selected destination.
        try data.write(to: url, options: .withoutOverwriting)
        return true
    }
}
