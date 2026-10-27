import Foundation

public enum CleanupGuard {
    public static let maximumSelection = 200

    public static func validate(snapshot: ScanSnapshot, file: ScannedFile) throws -> URL {
        guard snapshot.files.contains(file), snapshot.files.filter({ $0.id == file.id }).count == 1,
              file.id == PathPolicy.fileID(path: file.relativePath, fingerprint: file.fingerprint),
              file.logicalBytes == file.fingerprint.logicalBytes else {
            throw RoomletError.invalidCandidate("The selected file is not an unchanged member of this scan.")
        }
        let parts = try PathPolicy.components(of: file.relativePath)
        let (root, identity) = try PathPolicy.validatedRoot(snapshot.rootURL)
        guard root.path == snapshot.rootURL.standardizedFileURL.path, identity == snapshot.rootIdentity else {
            throw RoomletError.changed("The selected folder changed after the scan. Scan it again before cleanup.")
        }
        var candidate = root
        for (index, part) in parts.enumerated() {
            candidate.appendPathComponent(part, isDirectory: index < parts.count - 1)
            guard !PathPolicy.isExcluded(candidate) else {
                throw RoomletError.excluded("This path is protected or cloud-managed and will not be moved.")
            }
            let metadata = try FileMetadata.read(candidate)
            guard !metadata.isSymbolicLink, metadata.fingerprint.device == identity.device else {
                throw RoomletError.changed("A path became a link or changed volume. The file was not moved.")
            }
            guard !MetadataPolicy.isExcluded(try MetadataPolicy.values(candidate), metadata: metadata) else {
                throw RoomletError.excluded("A path is now a package, alias, placeholder or cloud-managed item.")
            }
            if index < parts.count - 1 {
                guard metadata.isDirectory else { throw RoomletError.changed("A parent folder changed after the scan.") }
            } else {
                let checked = try FileMetadata.read(candidate)
                guard checked.isRegularFile, checked.fingerprint == file.fingerprint, metadata.fingerprint == checked.fingerprint else {
                    throw RoomletError.changed("This file changed after the scan. It was not moved; scan again to review it.")
                }
            }
        }
        return candidate
    }
}
