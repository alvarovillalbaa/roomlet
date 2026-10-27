import Foundation

enum PathPolicy {
    private static let excludedRoots = [
        "/system", "/library", "/usr", "/bin", "/sbin", "/dev", "/etc", "/network",
        "/private/etc", "/private/var/db", "/private/var/vm", "/private/var/root", "/private/var/log",
    ]
    private static let broadRoots: Set<String> = ["/", "/users", "/volumes", "/private", "/private/var", "/var", "/tmp", "/private/tmp"]
    private static let excludedNames: Set<String> = [
        ".git", ".hg", ".svn", ".ssh", ".aws", ".gnupg", ".codex", ".trash", ".trashes",
        "cloudstorage", "mobile documents", "dropbox", "google drive",
    ]
    private static let privateLibraryNames: Set<String> = [
        "keychains", "mail", "messages", "accounts", "safari", "cookies", "identityservices",
        "containers", "group containers", "cloudstorage", "mobile documents",
    ]
    private static let packageExtensions: Set<String> = [
        "app", "bundle", "framework", "plugin", "kext", "photoslibrary", "photolibrary",
        "musiclibrary", "sparsebundle", "backupbundle", "xcodeproj", "xcworkspace",
    ]

    static func isExcluded(_ url: URL) -> Bool {
        let path = url.standardizedFileURL.path.lowercased()
        if excludedRoots.contains(where: { path == $0 || path.hasPrefix($0 + "/") }) { return true }
        let components = url.standardizedFileURL.pathComponents.map { $0.lowercased() }
        if components.contains(where: {
            excludedNames.contains($0) || $0.hasPrefix("onedrive")
                || $0.hasPrefix("dropbox (") || $0.hasSuffix(" dropbox")
        }) { return true }
        if components.contains(where: { packageExtensions.contains(($0 as NSString).pathExtension) }) { return true }
        for pair in zip(components, components.dropFirst()) {
            if pair.0 == "library" && privateLibraryNames.contains(pair.1) { return true }
        }
        let name = url.lastPathComponent.lowercased()
        return name == ".env" || name.hasPrefix(".env.") || name.hasPrefix("id_rsa")
            || name.hasPrefix("id_ecdsa") || name.hasPrefix("id_ed25519")
            || ["pem", "key", "p12", "pfx"].contains(url.pathExtension.lowercased())
            || packageExtensions.contains(url.pathExtension.lowercased())
    }

    static func isBroadRoot(_ url: URL) -> Bool {
        broadRoots.contains(url.standardizedFileURL.path.lowercased())
    }

    static func validatedRoot(_ input: URL) throws -> (URL, RootIdentity) {
        guard input.isFileURL, input.query == nil, input.fragment == nil,
              !input.path.contains("\0"), input.host == nil || input.host == "" || input.host == "localhost" else {
            throw RoomletError.invalidRoot("Choose a local folder on this Mac.")
        }
        let original = URL(fileURLWithPath: input.path, isDirectory: true).standardizedFileURL
        let root = original
        guard !isBroadRoot(root), !isExcluded(root) else {
            throw RoomletError.excluded("Choose a specific folder outside protected system, credential and cloud-managed locations.")
        }
        var ancestor = URL(fileURLWithPath: "/", isDirectory: true)
        var rootMetadata: FileMetadata?
        for part in root.pathComponents.dropFirst() {
            ancestor.appendPathComponent(part, isDirectory: true)
            let metadata = try FileMetadata.read(ancestor)
            guard metadata.isDirectory, !metadata.isSymbolicLink else {
                throw RoomletError.invalidRoot("Choose the actual folder path, rather than a symbolic link or a path through one.")
            }
            guard !isExcluded(ancestor), !MetadataPolicy.isExcluded(try MetadataPolicy.values(ancestor), metadata: metadata) else {
                throw RoomletError.excluded("This folder is inside a protected, package, alias, placeholder or cloud-managed location.")
            }
            rootMetadata = metadata
        }
        guard let metadata = rootMetadata else { throw RoomletError.invalidRoot("Choose a specific folder.") }
        let volume = try root.resourceValues(forKeys: [.volumeIsLocalKey])
        guard volume.volumeIsLocal == true else {
            throw RoomletError.excluded("Roomlet scans local volumes only; this volume could not be verified as local.")
        }
        return (root, metadata.rootIdentity)
    }

    static func components(of relativePath: String) throws -> [String] {
        let parts = relativePath.split(separator: "/", omittingEmptySubsequences: false).map(String.init)
        guard !relativePath.isEmpty, !relativePath.hasPrefix("/"), !relativePath.contains("\0"),
              parts.allSatisfy({ !$0.isEmpty && $0 != "." && $0 != ".." }) else {
            throw RoomletError.invalidCandidate("This file has an invalid relative path.")
        }
        return parts
    }

    static func relativePath(of url: URL, under root: URL) throws -> String {
        let prefix = root.path + "/"
        guard url.path.hasPrefix(prefix) else { throw RoomletError.invalidCandidate("The file is outside the selected folder.") }
        let relative = String(url.path.dropFirst(prefix.count))
        _ = try components(of: relative)
        return relative
    }

    static func fileID(path: String, fingerprint: FileFingerprint) -> String {
        "\(fingerprint.device):\(fingerprint.inode):\(path)"
    }
}
