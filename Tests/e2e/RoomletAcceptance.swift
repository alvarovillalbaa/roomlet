// T2: generated files only, actual native panels, scan, Trash and report.
import CryptoKit
import Foundation
import XCTest

final class RoomletAcceptance: XCTestCase {
    @MainActor
    func testRUI01FolderScanReviewTrashReport() throws {
        continueAfterFailure = false
        let configURL = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "FixtureConfig", withExtension: "json"))
        let config = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: configURL)) as? [String: String])
        let root = URL(fileURLWithPath: try XCTUnwrap(config["root"]), isDirectory: true)
        let nonce = try XCTUnwrap(config["nonce"])
        XCTAssertTrue(nonce.range(of: "^[a-f0-9]{32}$", options: .regularExpression) != nil)
        XCTAssertEqual(try String(contentsOf: root.appendingPathComponent("owner"), encoding: .utf8), nonce)
        let folder = root.appendingPathComponent("fixtures", isDirectory: true)
        let movedName = "roomlet-ui-\(nonce)-move.bin"
        let keptName = "roomlet-ui-\(nonce)-keep.bin"
        let moved = folder.appendingPathComponent(movedName)
        let kept = folder.appendingPathComponent(keptName)
        XCTAssertEqual(try Data(contentsOf: moved), Data(repeating: 65, count: 4096))
        XCTAssertEqual(try Data(contentsOf: kept), Data(repeating: 66, count: 64))
        let app = XCUIApplication(bundleIdentifier: "com.alvarovillalbaa.Roomlet")

        func record(_ phase: String) {
            let hierarchy = XCTAttachment(string: app.debugDescription)
            hierarchy.name = phase + ".accessibility"
            hierarchy.lifetime = .keepAlways
            add(hierarchy)
            let screenshot = XCTAttachment(screenshot: app.screenshot())
            screenshot.name = phase
            screenshot.lifetime = .keepAlways
            add(screenshot)
        }
        func attachJSON(_ value: Any, named name: String) throws {
            let attachment = XCTAttachment(data: try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys, .prettyPrinted]), uniformTypeIdentifier: "public.json")
            attachment.name = name
            attachment.lifetime = .keepAlways
            add(attachment)
        }
        func chooseFolder() {
            app.typeKey("g", modifierFlags: [.command, .shift])
            app.typeText(folder.path)
            app.typeKey(.return, modifierFlags: [])
            let choose = app.dialogs.buttons["Choose Folder"].firstMatch
            XCTAssertTrue(choose.waitForExistence(timeout: 15))
            choose.click()
        }
        func waitForFile(_ url: URL) {
            let check = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
                FileManager.default.fileExists(atPath: url.path)
            }, object: nil)
            XCTAssertEqual(XCTWaiter.wait(for: [check], timeout: 15), .completed)
        }
        defer {
            if app.state == .runningForeground { record("diagnostic-final") }
            app.terminate()
        }

        app.launch()
        XCTAssertTrue(app.windows["Roomlet"].waitForExistence(timeout: 20))
        record("01-empty")
        app.buttons["Choose Folder…"].firstMatch.click()
        chooseFolder()
        let scan = app.buttons["Scan Folder"]
        XCTAssertTrue(scan.waitForExistence(timeout: 15))
        scan.click()
        let row = app.outlines.outlineRows.containing(.staticText, identifier: movedName).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 20))
        XCTAssertTrue(app.outlines.outlineRows.containing(.staticText, identifier: keptName).firstMatch.exists)
        XCTAssertTrue(app.staticTexts["2 of 2 collected files · 0 selected"].exists)
        row.staticTexts[movedName].firstMatch.click()
        record("diagnostic-selection")
        XCTAssertTrue(app.staticTexts["2 of 2 collected files · 1 selected"].waitForExistence(timeout: 10))
        app.buttons["Review 1"].click()
        XCTAssertTrue(app.staticTexts["Review before moving"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts[movedName].firstMatch.exists)
        record("02-review")
        app.buttons["Keep Files"].click()
        XCTAssertTrue(FileManager.default.fileExists(atPath: moved.path))
        app.buttons["Review 1"].click()
        app.buttons["Move 1 Files to Trash"].click()
        XCTAssertTrue(app.staticTexts["1 files moved to Trash. Scan again before another cleanup."].waitForExistence(timeout: 20))
        XCTAssertFalse(FileManager.default.fileExists(atPath: moved.path))
        XCTAssertEqual(try Data(contentsOf: kept), Data(repeating: 66, count: 64))
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Moving files to Trash does not reclaim their space.")).firstMatch.exists)
        record("03-cleanup")

        app.buttons["Save Report…"].click()
        app.typeKey("g", modifierFlags: [.command, .shift])
        app.typeText(root.path)
        app.typeKey(.return, modifierFlags: [])
        let filename = app.dialogs.textFields.firstMatch
        XCTAssertTrue(filename.waitForExistence(timeout: 15))
        filename.click()
        app.typeKey("a", modifierFlags: .command)
        app.typeText("cleanup-report.json")
        app.dialogs.buttons["Save"].click()
        let reportURL = root.appendingPathComponent("cleanup-report.json")
        waitForFile(reportURL)
        let report = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: reportURL)) as? [String: Any])
        XCTAssertEqual(report["rootPath"] as? String, folder.path)
        XCTAssertEqual(report["wasCancelled"] as? Bool, false)
        let items = try XCTUnwrap(report["items"] as? [[String: Any]])
        XCTAssertEqual(items.count, 1)
        let item = try XCTUnwrap(items.first)
        XCTAssertEqual(item["relativePath"] as? String, movedName)
        XCTAssertEqual(item["logicalBytes"] as? Int, 4096)
        XCTAssertEqual(item["disposition"] as? String, "moved")
        let destination = URL(fileURLWithPath: try XCTUnwrap(item["destinationPath"] as? String))
        XCTAssertEqual(destination.lastPathComponent, movedName)
        XCTAssertTrue(destination.pathComponents.contains(".Trash") || destination.pathComponents.contains(".Trashes"))
        let trashBinding: [String: String] = ["source": moved.path, "destination": destination.path, "nonce": nonce]
        try attachJSON(trashBinding, named: "owned-trash")
        XCTAssertEqual(try Data(contentsOf: destination), Data(repeating: 65, count: 4096))

        app.typeKey("o", modifierFlags: .command)
        chooseFolder()
        XCTAssertTrue(app.staticTexts["Ready when you are"].waitForExistence(timeout: 15))
        app.staticTexts["Last Cleanup"].click()
        XCTAssertTrue(app.staticTexts["No cleanup yet"].waitForExistence(timeout: 10))
        app.typeKey("r", modifierFlags: .command)
        XCTAssertTrue(app.outlines.outlineRows.containing(.staticText, identifier: keptName).firstMatch.waitForExistence(timeout: 20))
        XCTAssertFalse(app.staticTexts["No cleanup yet"].exists)
        XCTAssertTrue(app.staticTexts["1 of 1 collected files · 0 selected"].exists)
        record("04-keyboard-rescan")
        try attachJSON(["caseId": "RUI01", "status": "passed", "nativeReport": report], named: "ui-observations")
    }
}
