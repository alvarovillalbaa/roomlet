import Foundation
import XCTest
@testable import RoomletCore

// Authored filesystem fixtures only. No real Trash, user-folder scan or network.
// These cases require the approved native execution scope before running.
final class RoomletCoreTests: XCTestCase {
    private func fixture() throws -> Fixture {
        let fixture = try Fixture()
        addTeardownBlock {
            do { try FileManager.default.removeItem(at: fixture.base) }
            catch { XCTFail("Could not remove owned fixture \(fixture.base.path): \(error.localizedDescription)") }
        }
        return fixture
    }

    func testOptionsKeepHardUpperBoundsAndPositiveLowerBounds() {
        let large = ScanOptions(maxEntries: .max, maxResults: .max, maxDepth: .max)
        XCTAssertEqual(large.maxEntries, 200_000)
        XCTAssertEqual(large.maxResults, 10_000)
        XCTAssertEqual(large.maxDepth, 64)
        let small = ScanOptions(maxEntries: 0, maxResults: -1, maxDepth: 0)
        XCTAssertEqual(small.maxEntries, 1)
        XCTAssertEqual(small.maxResults, 1)
        XCTAssertEqual(small.maxDepth, 1)
    }

    func testHeapKeepsLateLargerFilesRatherThanFirstResults() {
        var heap = LargestFiles(limit: 2)
        heap.insert(authoredFile("first", logical: 10, allocated: 10))
        heap.insert(authoredFile("second", logical: 20, allocated: 20))
        heap.insert(authoredFile("last-large", logical: 100, allocated: 100))
        XCTAssertEqual(heap.sorted().map(\.relativePath), ["last-large", "second"])
    }

    func testHeapUsesLogicalFallbackAndDeterministicTiesWithoutInventingAllocation() {
        var heap = LargestFiles(limit: 2)
        heap.insert(authoredFile("z", logical: 40, allocated: nil))
        heap.insert(authoredFile("a", logical: 40, allocated: nil))
        heap.insert(authoredFile("middle", logical: 100, allocated: 20))
        XCTAssertEqual(heap.sorted().map(\.relativePath), ["a", "z"])
        XCTAssertTrue(heap.sorted().allSatisfy { $0.allocatedBytes == nil })
    }

    func testScannerCollectsOnlyMetadataAndRelativeRegularFilePaths() throws {
        let fixture = try self.fixture()
        _ = try fixture.file("top.bin", bytes: 15)
        _ = try fixture.file("sub/nested.bin", bytes: 33)
        let snapshot = try DiskScanner.scan(root: fixture.root)
        XCTAssertTrue(snapshot.isComplete)
        XCTAssertEqual(Set(snapshot.files.map(\.relativePath)), ["top.bin", "sub/nested.bin"])
        XCTAssertEqual(Set(snapshot.files.map(\.logicalBytes)), [15, 33])
        XCTAssertTrue(snapshot.files.allSatisfy { $0.fingerprint.logicalBytes == $0.logicalBytes })
        XCTAssertEqual(snapshot.rootURL.path, fixture.root.path)
    }

    func testEmptyFolderAndZeroByteFileRemainValid() throws {
        let fixture = try self.fixture()
        let empty = try DiskScanner.scan(root: fixture.root)
        XCTAssertTrue(empty.isComplete)
        XCTAssertEqual(empty.files.count, 0)
        _ = try fixture.file("empty.txt", bytes: 0)
        let scanned = try DiskScanner.scan(root: fixture.root)
        XCTAssertEqual(scanned.files.first?.logicalBytes, 0)
        XCTAssertEqual(scanned.files.count, 1)
    }

    func testScannerDoesNotFollowFileOrDirectorySymlinks() throws {
        let fixture = try self.fixture()
        let outside = fixture.base.appendingPathComponent("outside", isDirectory: true)
        try FileManager.default.createDirectory(at: outside, withIntermediateDirectories: true)
        let secret = outside.appendingPathComponent("outside.txt")
        try Data([1, 2, 3]).write(to: secret)
        try FileManager.default.createSymbolicLink(at: fixture.root.appendingPathComponent("linked-file"), withDestinationURL: secret)
        try FileManager.default.createSymbolicLink(at: fixture.root.appendingPathComponent("linked-folder", isDirectory: true), withDestinationURL: outside)
        _ = try fixture.file("kept.txt", bytes: 5)
        let snapshot = try DiskScanner.scan(root: fixture.root)
        XCTAssertEqual(snapshot.files.map(\.relativePath), ["kept.txt"])
        XCTAssertGreaterThanOrEqual(snapshot.skippedEntries, 2)
    }

    func testSelectedSymbolicLinkRootIsRejectedEvenWithDirectoryURLHint() throws {
        let fixture = try self.fixture()
        let link = fixture.base.appendingPathComponent("link", isDirectory: true)
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: fixture.root)
        XCTAssertThrowsError(try DiskScanner.scan(root: link))
    }

    func testSelectedFolderThroughSymlinkAncestorIsRejected() throws {
        let fixture = try self.fixture()
        _ = try fixture.file("child/file.txt", bytes: 8)
        let link = fixture.base.appendingPathComponent("alias", isDirectory: true)
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: fixture.root)
        XCTAssertThrowsError(try DiskScanner.scan(root: link.appendingPathComponent("child", isDirectory: true)))
    }

    func testPackagesAndCredentialFilesAreNotCandidates() throws {
        let fixture = try self.fixture()
        for name in ["Example.app/Contents/data", ".git/objects/value", ".ssh/private", ".aws/config", ".env.production", "private.pem"] {
            _ = try fixture.file(name, bytes: 20)
        }
        _ = try fixture.file("plain.txt", bytes: 4)
        let snapshot = try DiskScanner.scan(root: fixture.root)
        XCTAssertEqual(snapshot.files.map(\.relativePath), ["plain.txt"])
        XCTAssertGreaterThan(snapshot.skippedEntries, 0)
    }

    func testKnownCloudManagedPathsAreExcluded() throws {
        let fixture = try self.fixture()
        for name in ["Library/CloudStorage/provider/file", "Library/Mobile Documents/cloud/file", "Dropbox/file",
                     "Dropbox (Personal)/file", "Dropbox (Organization)/file", "Organization Dropbox/file", "OneDrive-personal/file"] {
            _ = try fixture.file(name, bytes: 20)
        }
        _ = try fixture.file("local.txt", bytes: 7)
        XCTAssertEqual(try DiskScanner.scan(root: fixture.root).files.map(\.relativePath), ["local.txt"])
        XCTAssertThrowsError(try DiskScanner.scan(root: fixture.root.appendingPathComponent("Library/CloudStorage", isDirectory: true)))
    }

    func testSelectedRootInsidePackageIsRejected() throws {
        let fixture = try self.fixture()
        _ = try fixture.file("Example.app/Contents/Resources/authored.bin", bytes: 20)
        let inside = fixture.root.appendingPathComponent("Example.app/Contents/Resources", isDirectory: true)
        XCTAssertThrowsError(try DiskScanner.scan(root: inside))
    }

    func testGuardRejectsForgedSnapshotWhoseSelectedRootIsInsidePackage() throws {
        let fixture = try self.fixture()
        let url = try fixture.file("Example.app/Contents/Resources/authored.bin", bytes: 20)
        let root = url.deletingLastPathComponent()
        let metadata = try FileMetadata.read(url)
        let file = authoredFile("authored.bin", metadata: metadata)
        let forged = ScanSnapshot(rootURL: root, rootIdentity: try FileMetadata.read(root).rootIdentity,
            files: [file], visitedEntries: 1, skippedEntries: 0, issues: [], isComplete: true)
        XCTAssertThrowsError(try CleanupGuard.validate(snapshot: forged, file: file))
    }

    func testResultCapRetainsLargestEstimatesAndMarksSnapshotIncomplete() throws {
        let fixture = try self.fixture()
        for index in 1...4 { _ = try fixture.file("\(index).bin", bytes: index * 4097) }
        let complete = try DiskScanner.scan(root: fixture.root)
        let limited = try DiskScanner.scan(root: fixture.root, options: ScanOptions(maxResults: 1))
        XCTAssertEqual(limited.files.map(\.id), Array(complete.files.prefix(1)).map(\.id))
        XCTAssertEqual(limited.files.count, 1)
        XCTAssertFalse(limited.isComplete)
        XCTAssertTrue(limited.issues.contains { $0.contains("Result limit") })
    }

    func testEntryCapIsHonestAndNeverExceedsRequestedBound() throws {
        let fixture = try self.fixture()
        for index in 0..<5 { _ = try fixture.file("\(index).txt", bytes: 3) }
        let snapshot = try DiskScanner.scan(root: fixture.root, options: ScanOptions(maxEntries: 2))
        XCTAssertEqual(snapshot.visitedEntries, 2)
        XCTAssertFalse(snapshot.isComplete)
        XCTAssertLessThanOrEqual(snapshot.files.count, 2)
        XCTAssertTrue(snapshot.issues.contains { $0.contains("Entry limit") })
    }

    func testDepthCapDoesNotHideThatNestedFilesWereOmitted() throws {
        let fixture = try self.fixture()
        _ = try fixture.file("top.txt", bytes: 2)
        _ = try fixture.file("deep/deeper/file.txt", bytes: 8)
        let snapshot = try DiskScanner.scan(root: fixture.root, options: ScanOptions(maxDepth: 1))
        XCTAssertFalse(snapshot.isComplete)
        XCTAssertEqual(snapshot.files.map(\.relativePath), ["top.txt"])
        XCTAssertTrue(snapshot.issues.contains { $0.contains("Depth limit") })
    }

    func testCancellationReturnsAnExplicitPartialSnapshot() throws {
        let fixture = try self.fixture()
        _ = try fixture.file("file.txt", bytes: 5)
        let snapshot = try DiskScanner.scan(root: fixture.root, shouldCancel: { true })
        XCTAssertFalse(snapshot.isComplete)
        XCTAssertEqual(snapshot.visitedEntries, 0)
        XCTAssertTrue(snapshot.files.isEmpty)
        XCTAssertTrue(snapshot.issues.contains { $0.contains("stopped") })
    }

    func testUnknownCapacityRemainsNilInsteadOfZero() {
        let reading = DiskScanner.capacity(at: URL(string: "https://authored.invalid/folder")!)
        XCTAssertNil(reading.availableBytes)
        XCTAssertNil(reading.totalBytes)
    }

    func testUnchangedFileValidatesWithoutPerformingAnyCleanup() throws {
        let fixture = try self.fixture()
        let url = try fixture.file("regular.txt", bytes: 11)
        let snapshot = try DiskScanner.scan(root: fixture.root)
        let file = try XCTUnwrap(snapshot.files.first)
        XCTAssertEqual(try CleanupGuard.validate(snapshot: snapshot, file: file).path, url.path)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    func testSizeChangeIsRejected() throws {
        let fixture = try self.fixture()
        let url = try fixture.file("changing.txt", bytes: 10)
        let snapshot = try DiskScanner.scan(root: fixture.root)
        let file = try XCTUnwrap(snapshot.files.first)
        try Data(repeating: 9, count: 11).write(to: url)
        XCTAssertThrowsError(try CleanupGuard.validate(snapshot: snapshot, file: file))
    }

    func testModificationTimeChangeIsRejectedEvenWithSameSize() throws {
        let fixture = try self.fixture()
        let url = try fixture.file("changing.txt", bytes: 10)
        let snapshot = try DiskScanner.scan(root: fixture.root)
        let file = try XCTUnwrap(snapshot.files.first)
        try FileManager.default.setAttributes([.modificationDate: Date(timeIntervalSince1970: 1_234_567_890)], ofItemAtPath: url.path)
        XCTAssertThrowsError(try CleanupGuard.validate(snapshot: snapshot, file: file))
    }

    func testReplacementIdentityIsRejected() throws {
        let fixture = try self.fixture()
        let url = try fixture.file("replace.txt", bytes: 10)
        let snapshot = try DiskScanner.scan(root: fixture.root)
        let file = try XCTUnwrap(snapshot.files.first)
        try FileManager.default.moveItem(at: url, to: fixture.base.appendingPathComponent("previous.txt"))
        try Data(repeating: 1, count: 10).write(to: url)
        XCTAssertThrowsError(try CleanupGuard.validate(snapshot: snapshot, file: file))
    }

    func testRootReplacementIsRejected() throws {
        let fixture = try self.fixture()
        _ = try fixture.file("file.txt", bytes: 10)
        let snapshot = try DiskScanner.scan(root: fixture.root)
        let file = try XCTUnwrap(snapshot.files.first)
        try FileManager.default.moveItem(at: fixture.root, to: fixture.base.appendingPathComponent("previous-root"))
        try FileManager.default.createDirectory(at: fixture.root, withIntermediateDirectories: true)
        _ = try fixture.file("file.txt", bytes: 10)
        XCTAssertThrowsError(try CleanupGuard.validate(snapshot: snapshot, file: file))
    }

    func testAncestorChangedToLinkIsRejected() throws {
        let fixture = try self.fixture()
        _ = try fixture.file("folder/file.txt", bytes: 10)
        let snapshot = try DiskScanner.scan(root: fixture.root)
        let file = try XCTUnwrap(snapshot.files.first)
        let folder = fixture.root.appendingPathComponent("folder", isDirectory: true)
        let moved = fixture.base.appendingPathComponent("moved-folder", isDirectory: true)
        try FileManager.default.moveItem(at: folder, to: moved)
        try FileManager.default.createSymbolicLink(at: folder, withDestinationURL: moved)
        XCTAssertThrowsError(try CleanupGuard.validate(snapshot: snapshot, file: file))
    }

    func testChangedFileBecomingDirectoryIsRejected() throws {
        let fixture = try self.fixture()
        let url = try fixture.file("file.txt", bytes: 10)
        let snapshot = try DiskScanner.scan(root: fixture.root)
        let file = try XCTUnwrap(snapshot.files.first)
        try FileManager.default.moveItem(at: url, to: fixture.base.appendingPathComponent("original-file"))
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        XCTAssertThrowsError(try CleanupGuard.validate(snapshot: snapshot, file: file))
    }

    func testNonmemberAndAlteredMetadataAreRejected() throws {
        let fixture = try self.fixture()
        _ = try fixture.file("file.txt", bytes: 10)
        let snapshot = try DiskScanner.scan(root: fixture.root)
        let file = try XCTUnwrap(snapshot.files.first)
        let altered = ScannedFile(id: file.id, relativePath: file.relativePath, logicalBytes: file.logicalBytes,
            allocatedBytes: -1, modifiedAt: file.modifiedAt, fingerprint: file.fingerprint)
        XCTAssertThrowsError(try CleanupGuard.validate(snapshot: snapshot, file: altered))
        XCTAssertThrowsError(try CleanupGuard.validate(snapshot: snapshot, file: authoredFile("other", logical: 1, allocated: nil)))
    }

    func testTraversalAndAbsoluteForgedMembersCannotEscapeRoot() throws {
        let fixture = try self.fixture()
        _ = try fixture.file("file.txt", bytes: 10)
        let snapshot = try DiskScanner.scan(root: fixture.root)
        let original = try XCTUnwrap(snapshot.files.first)
        for path in ["../outside", "/outside", "folder/../outside", "folder//outside", "./file.txt"] {
            let forged = ScannedFile(id: PathPolicy.fileID(path: path, fingerprint: original.fingerprint),
                relativePath: path, logicalBytes: original.logicalBytes, allocatedBytes: original.allocatedBytes,
                modifiedAt: original.modifiedAt, fingerprint: original.fingerprint)
            let alteredSnapshot = ScanSnapshot(rootURL: snapshot.rootURL, rootIdentity: snapshot.rootIdentity,
                files: [forged], visitedEntries: 1, skippedEntries: 0, issues: [], isComplete: true)
            XCTAssertThrowsError(try CleanupGuard.validate(snapshot: alteredSnapshot, file: forged))
        }
    }

    func testHardLinkPathsKeepDistinctSelectionIdentities() throws {
        let fixture = try self.fixture()
        let first = try fixture.file("one.txt", bytes: 10)
        try FileManager.default.linkItem(at: first, to: fixture.root.appendingPathComponent("two.txt"))
        let snapshot = try DiskScanner.scan(root: fixture.root)
        XCTAssertEqual(snapshot.files.count, 2)
        XCTAssertEqual(Set(snapshot.files.map(\.id)).count, 2)
        XCTAssertEqual(Set(snapshot.files.map(\.fingerprint)).count, 1)
        for file in snapshot.files { XCTAssertNoThrow(try CleanupGuard.validate(snapshot: snapshot, file: file)) }
    }

    func testBroadAndProtectedRootsAreRefusedWithoutEnumeration() {
        for path in ["/", "/Users", "/System", "/Library", "/private/var/db", "/Volumes"] {
            XCTAssertThrowsError(try DiskScanner.scan(root: URL(fileURLWithPath: path, isDirectory: true)))
        }
    }

    func testRootPoliciesRejectMixedCaseAliasesWithoutChangingFilesystemPaths() {
        for path in ["/sYsTeM", "/LIBRARY/Caches", "/USr/bin", "/Private/VAR/DB"] {
            XCTAssertTrue(PathPolicy.isExcluded(URL(fileURLWithPath: path)))
        }
        for path in ["/uSeRs", "/VOLUMES", "/PRIvate", "/TmP"] {
            XCTAssertTrue(PathPolicy.isBroadRoot(URL(fileURLWithPath: path)))
        }
        XCTAssertFalse(PathPolicy.isBroadRoot(URL(fileURLWithPath: "/Users/authored-local-folder")))
    }
}

private final class Fixture {
    let base: URL
    let root: URL

    init() throws {
        base = FileManager.default.temporaryDirectory.resolvingSymlinksInPath()
            .appendingPathComponent("roomlet-fixture-" + UUID().uuidString, isDirectory: true)
        root = base.appendingPathComponent("selected", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    }

    func file(_ relativePath: String, bytes: Int) throws -> URL {
        let url = root.appendingPathComponent(relativePath)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(repeating: 0x53, count: bytes).write(to: url)
        return url
    }
}

private func authoredFile(_ path: String, logical: Int64, allocated: Int64?) -> ScannedFile {
    let fingerprint = FileFingerprint(device: 1, inode: 2, logicalBytes: logical, modifiedSeconds: 3, modifiedNanoseconds: 4)
    return ScannedFile(id: PathPolicy.fileID(path: path, fingerprint: fingerprint), relativePath: path,
        logicalBytes: logical, allocatedBytes: allocated, modifiedAt: Date(timeIntervalSince1970: 3), fingerprint: fingerprint)
}

private func authoredFile(_ path: String, metadata: FileMetadata) -> ScannedFile {
    let fingerprint = metadata.fingerprint
    return ScannedFile(id: PathPolicy.fileID(path: path, fingerprint: fingerprint), relativePath: path,
        logicalBytes: fingerprint.logicalBytes, allocatedBytes: nil,
        modifiedAt: Date(timeIntervalSince1970: Double(fingerprint.modifiedSeconds)), fingerprint: fingerprint)
}
