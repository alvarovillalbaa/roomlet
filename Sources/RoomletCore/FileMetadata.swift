import Darwin
import Foundation

struct FileMetadata {
    let fingerprint: FileFingerprint
    let mode: mode_t
    let flags: UInt32

    var isDirectory: Bool { mode & mode_t(S_IFMT) == mode_t(S_IFDIR) }
    var isRegularFile: Bool { mode & mode_t(S_IFMT) == mode_t(S_IFREG) }
    var isSymbolicLink: Bool { mode & mode_t(S_IFMT) == mode_t(S_IFLNK) }
    var isDataless: Bool { flags & UInt32(SF_DATALESS) != 0 }
    var rootIdentity: RootIdentity { RootIdentity(device: fingerprint.device, inode: fingerprint.inode) }

    static func read(_ url: URL) throws -> FileMetadata {
        var value = stat()
        var path = url.path
        while path.count > 1 && path.hasSuffix("/") { path.removeLast() }
        guard !path.contains("\0") else { throw RoomletError.unreadable("The file path is invalid.") }
        // lstat with a trailing slash can follow a directory symlink.
        let result = path.withCString { path -> Int32 in
            return Darwin.lstat(path, &value)
        }
        guard result == 0 else {
            throw RoomletError.unreadable("Could not read metadata for \(url.lastPathComponent).")
        }
        let fingerprint = FileFingerprint(
            device: UInt64(UInt32(bitPattern: value.st_dev)), inode: UInt64(value.st_ino),
            logicalBytes: max(0, Int64(value.st_size)), modifiedSeconds: Int64(value.st_mtimespec.tv_sec),
            modifiedNanoseconds: Int64(value.st_mtimespec.tv_nsec)
        )
        return FileMetadata(fingerprint: fingerprint, mode: value.st_mode, flags: value.st_flags)
    }
}

enum MetadataPolicy {
    static let keys: Set<URLResourceKey> = [
        .isAliasFileKey, .isPackageKey, .isUbiquitousItemKey, .isMountTriggerKey,
        .fileAllocatedSizeKey, .totalFileAllocatedSizeKey,
    ]

    static func values(_ url: URL) throws -> URLResourceValues {
        // Do not reuse prefetched resource values when validating a cleanup candidate.
        try URL(fileURLWithPath: url.path).resourceValues(forKeys: keys)
    }

    static func isExcluded(_ values: URLResourceValues, metadata: FileMetadata) -> Bool {
        metadata.isDataless || values.isAliasFile == true || values.isPackage == true
            || values.isUbiquitousItem == true || values.isMountTrigger == true
    }

    static func allocatedBytes(_ values: URLResourceValues) -> Int64? {
        guard let value = values.totalFileAllocatedSize ?? values.fileAllocatedSize, value >= 0 else { return nil }
        return Int64(value)
    }
}
