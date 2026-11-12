"""T2 macOS UI acceptance, only generated fixtures and an owned app build."""
import base64
import gzip
import hashlib
import json
import os
from pathlib import Path
import platform
import plistlib
import re
import selectors
import shutil
import signal
import stat
import subprocess
import tempfile
import time
import traceback
import uuid

SOURCE = os.environ["ROOMLET_SOURCE_COMMIT"]
assert re.fullmatch(r"[0-9a-f]{40}", SOURCE)
assert platform.system() == "Darwin" and platform.machine() == "arm64"
assert os.environ["GITHUB_REPOSITORY"] == "alvarovillalbaa/roomlet"
assert os.environ["GITHUB_REF"] == "refs/heads/qa/roomlet-ui-20261112-ci9"
assert os.environ["ROOMLET_PUBLIC_REPOSITORY"] == "true"
repo = Path.cwd().resolve()
parent = Path(os.environ["RUNNER_TEMP"]).resolve()
root = Path(tempfile.mkdtemp(prefix="roomlet-ui-", dir=parent)).resolve()
identity = root.stat()
nonce = uuid.uuid4().hex
(root / "owner").write_text(nonce)
evidence = parent / ("roomlet-ui-evidence-" + os.environ["GITHUB_RUN_ID"])
assert not evidence.exists()
evidence.mkdir(mode=0o700)
native_evidence = parent / ("roomlet-ui-native-result-" + os.environ["GITHUB_RUN_ID"])
assert not native_evidence.exists()
native_evidence.mkdir(mode=0o700)
for name in ("source", "fixtures", "derived", "cache", "tmp"):
    (root / name).mkdir(mode=0o700)
export = root / "source"
env = {key: os.environ[key] for key in ("PATH", "HOME", "LANG") if key in os.environ}
env.update(DEVELOPER_DIR="/Applications/Xcode_16.4.app/Contents/Developer", CI="true",
           TMPDIR=str(root / "tmp") + "/", CLANG_MODULE_CACHE_PATH=str(root / "cache/modules"),
           SWIFTPM_MODULECACHE_OVERRIDE=str(root / "cache/swiftpm"))
moved_name = "roomlet-ui-" + nonce + "-move.bin"
kept_name = "roomlet-ui-" + nonce + "-keep.bin"
moved = root / "fixtures" / moved_name
kept = root / "fixtures" / kept_name
moved_data = b"A" * 4096
home = Path(env["HOME"]).resolve()
trash_candidates = [home / ".Trash" / moved_name,
                    home / "Library/Containers/com.alvarovillalbaa.Roomlet/Data/.Trash" / moved_name]
app = root / "derived/Build/Products/Debug/Roomlet.app"
runner = root / "derived/Build/Products/Debug/RoomletAcceptance-Runner.app"
result_path = native_evidence / "ui.xcresult"
report = {"schemaVersion": "roomlet-native-ui-v1", "source": SOURCE, "status": "failed",
          "tier": "T2", "caseId": "RUI01", "nonce": nonce, "commands": [], "errors": [],
          "cleanup": {}, "coreTestsReplayed": False, "simulatorUsed": False,
          "personalFiles": False, "appLaunched": "unproved", "nativeTrash": "unproved"}
children = []
exports = []
started = time.monotonic()
cleanup_phase = False


def sha(value):
    return hashlib.sha256(value).hexdigest()


def persist():
    (evidence / "receipt.json").write_text(json.dumps(report, indent=2) + "\n")


def run(name, args, seconds=30, cwd=None, allowed=(0,)):
    assert re.fullmatch(r"[a-z0-9-]+", name)
    remaining = 900 - (time.monotonic() - started)
    assert cleanup_phase or remaining > 0
    deadline = time.monotonic() + (seconds if cleanup_phase else min(seconds, remaining))
    child = subprocess.Popen(args, cwd=cwd or repo, env=env, stdin=subprocess.DEVNULL,
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE, start_new_session=True)
    children.append(child)
    streams = {"stdout": bytearray(), "stderr": bytearray()}
    selector = selectors.DefaultSelector()
    for key in streams:
        pipe = getattr(child, key)
        os.set_blocking(pipe.fileno(), False)
        selector.register(pipe, selectors.EVENT_READ, key)
    stopped = None
    try:
        while selector.get_map():
            if time.monotonic() > deadline or any(len(value) > 1048576 for value in streams.values()):
                stopped = "timeout_or_stream_bound"
                try: os.killpg(child.pid, signal.SIGKILL)
                except ProcessLookupError: pass
                break
            for event, _ in selector.select(0.1):
                value = os.read(event.fd, 65536)
                if value: streams[event.data].extend(value)
                else: selector.unregister(event.fileobj)
        child.wait(timeout=5)
    finally:
        if child.poll() is None:
            try: os.killpg(child.pid, signal.SIGKILL)
            except ProcessLookupError: pass
            child.wait(timeout=5)
        selector.close()
        child.stdout.close(); child.stderr.close()
    try: os.killpg(child.pid, 0)
    except ProcessLookupError: group_absent = True
    else: group_absent = False
    row = {"name": name, "args": args, "exitCode": child.returncode,
           "stopReason": stopped, "groupAbsent": group_absent, "streams": {}}
    for key, value in streams.items():
        kept = bytes(value[:1048576])
        filename = name + "." + key + ".txt"
        (evidence / filename).write_bytes(kept)
        row["streams"][key] = {"file": filename, "bytes": len(kept), "sha256": sha(kept),
                               "complete": stopped is None and len(value) <= 1048576,
                               "gzipBase64": base64.b64encode(gzip.compress(kept, mtime=0)).decode()}
    report["commands"].append(row)
    persist()
    assert child.returncode in allowed and stopped is None and group_absent, name + " failed"
    return bytes(streams["stdout"])


def guard(label):
    assert run(label + "-head", ["git", "rev-parse", "HEAD"]).decode().strip() == SOURCE
    assert run(label + "-status", ["git", "status", "--porcelain=v1", "--untracked-files=all", "--ignored"]) == b""
    vector = []
    for value in run(label + "-tree", ["git", "ls-tree", "-rz", "--long", "HEAD"]).split(b"\0"):
        if not value: continue
        metadata, raw_name = value.split(b"\t", 1)
        mode, kind, blob, length = metadata.decode().split()
        path = Path(raw_name.decode())
        assert not path.is_absolute() and ".." not in path.parts and kind == "blob" and mode in ("100644", "100755")
        item = repo / path
        assert item.is_file() and not item.is_symlink() and int(length) <= 4 * 1024 * 1024
        data = item.read_bytes()
        assert len(data) == int(length) and hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest() == blob
        assert ("100755" if item.stat().st_mode & 0o111 else "100644") == mode
        vector.append({"path": str(path), "mode": mode, "bytes": len(data), "blob": blob, "sha256": sha(data)})
    return vector


def owned_processes(name):
    raw = run(name, ["/bin/ps", "-axo", "pid=,command="]).decode()
    binaries = [str(app / "Contents/MacOS/Roomlet"), str(runner / "Contents/MacOS/RoomletAcceptance-Runner")]
    result = []
    for line in raw.splitlines():
        parts = line.strip().split(None, 1)
        if len(parts) == 2 and any(parts[1] == b or parts[1].startswith(b + " ") for b in binaries):
            result.append({"pid": int(parts[0]), "command": parts[1]})
    return result


try:
    report["sourceFiles"] = baseline = guard("before")
    assert shutil.disk_usage(parent).free >= 8 * 1024 ** 3
    assert root.stat().st_dev == home.stat().st_dev
    assert not run("preexisting-roomlet", ["/usr/bin/pgrep", "-x", "Roomlet"], allowed=(0, 1)), "preexisting Roomlet left untouched"
    assert all(not os.path.lexists(path) for path in trash_candidates)
    for row in baseline:
        name = row["path"]
        if name != "Package.swift" and not name.startswith(("Sources/", "Resources/", "Tests/RoomletCoreTests/", "Tests/e2e/", "Tests/RoomletAcceptance.xcodeproj/")):
            continue
        target = export / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes((repo / name).read_bytes())
        target.chmod(0o755 if row["mode"] == "100755" else 0o644)
        exports.append(row)
    moved.write_bytes(moved_data)
    kept.write_bytes(b"B" * 64)
    fixture_config = export / "Tests/e2e/FixtureConfig.json"
    fixture_config.write_text(json.dumps({"root": str(root), "nonce": nonce}))
    report["generatedTestResource"] = {"path": "Tests/e2e/FixtureConfig.json", "sha256": sha(fixture_config.read_bytes())}
    report["fixture"] = {"source": str(moved), "sha256": sha(moved_data), "bytes": 4096,
                         "kept": str(kept), "keptSha256": sha(b"B" * 64)}
    common = ["/usr/bin/xcodebuild", "-project", "Tests/RoomletAcceptance.xcodeproj", "-scheme", "RoomletAcceptance",
              "-configuration", "Debug", "-destination", "platform=macOS,arch=arm64", "-derivedDataPath", str(root / "derived")]
    run("build-for-testing", common + ["build-for-testing"], seconds=300, cwd=export)
    run_files = list((root / "derived/Build/Products").glob("*.xctestrun"))
    assert len(run_files) == 1
    run_file = run_files[0]
    run_data = run_file.read_bytes()
    assert not run_file.is_symlink() and len(run_data) <= 1048576
    (evidence / "build-for-testing.xctestrun.plist").write_bytes(run_data)
    pending = [plistlib.loads(run_data)]
    target_paths = []
    while pending:
        value = pending.pop()
        if isinstance(value, dict):
            if "UITargetAppPath" in value: target_paths.append(value["UITargetAppPath"])
            pending.extend(value.values())
        elif isinstance(value, list): pending.extend(value)
    assert len(target_paths) == 1
    target_path = target_paths[0].replace("__TESTROOT__", str(run_file.parent))
    assert Path(target_path).is_absolute() and Path(target_path).resolve() == app.resolve()
    assert plistlib.loads((app / "Contents/Info.plist").read_bytes())["CFBundleIdentifier"] == "com.alvarovillalbaa.Roomlet"
    report["nativeTargetBinding"] = {"runFile": run_file.name, "sha256": sha(run_data), "appPath": target_path,
                                     "bundleIdentifier": "com.alvarovillalbaa.Roomlet"}
    # Xcode adds testing exceptions even when base entitlement injection is off.
    # Exercise the actual app rights, using the same local signing input as packaging.
    run("production-signature", ["/usr/bin/codesign", "--force", "--sign", "-", "--entitlements", str(export / "Resources/Roomlet.entitlements"), str(app)])
    entitlements = run("app-entitlements", ["/usr/bin/codesign", "-d", "--entitlements", ":-", str(app)])
    assert plistlib.loads(entitlements) == {"com.apple.security.app-sandbox": True, "com.apple.security.files.user-selected.read-write": True}
    run("signature", ["/usr/bin/codesign", "--verify", "--strict", str(app)])
    report["appEntitlementsMatchProduction"] = True
    run("native-ui", ["/usr/bin/xcodebuild", "test-without-building", "-xctestrun", str(run_file),
        "-destination", "platform=macOS,arch=arm64", "-resultBundlePath", str(result_path),
        "-only-testing:RoomletAcceptance/RoomletAcceptance/testRUI01FolderScanReviewTrashReport",
        "-parallel-testing-enabled", "NO", "-test-timeouts-enabled", "YES",
        "-default-test-execution-time-allowance", "240", "-maximum-test-execution-time-allowance", "300"], seconds=480, cwd=export)
    report["nativeTestCommandPassed"] = True
except BaseException as error:
    report["errors"].append(type(error).__name__ + ": " + str(error))
    report["traceback"] = traceback.format_exc()
finally:
    cleanup_phase = True
    if report.get("appEntitlementsMatchProduction"):
        try:
            final_entitlements = run("post-ui-entitlements", ["/usr/bin/codesign", "-d", "--entitlements", ":-", str(app)])
            assert plistlib.loads(final_entitlements) == {"com.apple.security.app-sandbox": True, "com.apple.security.files.user-selected.read-write": True}
            report["appEntitlementsStillMatchProduction"] = True
        except BaseException as error:
            report["errors"].append("post-UI entitlement guard: " + str(error))
    if result_path.exists():
        try:
            value = run("test-summary", ["/usr/bin/xcrun", "xcresulttool", "get", "test-results", "summary", "--path", str(result_path)])
            (evidence / "native-summary.json").write_bytes(value)
            summary = json.loads(value)
            report["testSummary"] = summary
            tests_value = run("test-identities", ["/usr/bin/xcrun", "xcresulttool", "get", "test-results", "tests", "--path", str(result_path)])
            (evidence / "native-tests.json").write_bytes(tests_value)
            pending = list(json.loads(tests_value).get("testNodes", []))
            cases = []
            while pending:
                node = pending.pop()
                if node.get("nodeType") == "Test Case": cases.append(node)
                pending.extend(node.get("children", []))
            report["nativeCases"] = cases
            if report.get("nativeTestCommandPassed"):
                assert summary["totalTestCount"] == summary["passedTests"] == 1
                assert summary["failedTests"] == summary["skippedTests"] == 0
                assert summary["result"] == "Passed" and not summary.get("testFailures")
                assert len(cases) == 1 and cases[0]["name"] == "testRUI01FolderScanReviewTrashReport()" and cases[0]["result"] == "Passed"
                report["appLaunched"] = "observed_by_native_ui"
        except BaseException as error:
            report["errors"].append("test result: " + str(error))
        try:
            run("failure-attachments", ["/usr/bin/xcrun", "xcresulttool", "export", "attachments", "--path", str(result_path),
                                        "--output-path", str(evidence / "attachments")], seconds=60)
            manifest = json.loads((evidence / "attachments/manifest.json").read_text())
            attachments = []
            for case in manifest:
                assert case["testIdentifier"] == "RoomletAcceptance/testRUI01FolderScanReviewTrashReport()"
                for item in case["attachments"]:
                    filename = item["exportedFileName"]
                    assert Path(filename).name == filename and filename not in (".", "..")
                    path = evidence / "attachments" / filename
                    assert path.is_file() and not path.is_symlink()
                    data = path.read_bytes()
                    assert len(data) <= 4 * 1024 * 1024
                    name = item["suggestedHumanReadableName"]
                    match = re.fullmatch(r"(01-empty|02-review|03-cleanup|04-keyboard-rescan|diagnostic-final|diagnostic-selection|owned-trash|ui-observations)_[0-9]+_([A-F0-9-]{36})\.(png|json|accessibility)", name)
                    canonical = None
                    if match:
                        assert str(uuid.UUID(match[2])).upper() == match[2]
                        canonical = match[1] + "." + match[3]
                    attachments.append({"file": "attachments/" + filename, "name": name, "canonicalName": canonical,
                                        "bytes": len(data), "sha256": sha(data)})
            report["attachments"] = attachments
        except BaseException as error:
            report["attachmentExportLimit"] = str(error)
            if report.get("nativeTestCommandPassed"):
                report["errors"].append("native attachment evidence: " + str(error))
    try:
        processes = owned_processes("owned-app-processes")
        report["cleanup"]["processesBeforeCleanup"] = processes
        for row in processes:
            os.kill(row["pid"], signal.SIGTERM)
        deadline = time.monotonic() + 10
        while processes and time.monotonic() < deadline:
            time.sleep(0.5)
            processes = owned_processes("owned-app-wait-" + str(len(report["commands"])))
        assert not processes, "owned app/runner remains; root retained"
        report["cleanup"]["ownedAppAndRunnerAbsent"] = True
        for child in children:
            assert child.poll() is not None
            try: os.killpg(child.pid, 0)
            except ProcessLookupError: pass
            else: raise RuntimeError("owned child group remains")
        report["cleanup"]["ownedChildGroupsAbsent"] = True
    except BaseException as error:
        report["errors"].append("process cleanup: " + str(error))
    try:
        assert (root / "owner").read_text() == nonce
        candidates = [path for path in trash_candidates if os.path.lexists(path)]
        native_report = root / "cleanup-report.json"
        if native_report.exists():
            assert native_report.is_file() and not native_report.is_symlink() and native_report.stat().st_size <= 65536
            data = native_report.read_bytes()
            value = json.loads(data)
            assert value["rootPath"] == str(root / "fixtures") and value["wasCancelled"] is False
            assert len(value["items"]) == 1
            item = value["items"][0]
            assert item["relativePath"] == moved_name and item["logicalBytes"] == 4096 and item["disposition"] == "moved"
            assert Path(item["destinationPath"]) in trash_candidates
            (evidence / "cleanup-report.json").write_bytes(data)
            report["nativeReport"] = {"bytes": len(data), "sha256": sha(data)}
        elif report.get("nativeTestCommandPassed"):
            raise RuntimeError("native saved report missing")
        assert len(candidates) <= 1
        if candidates:
            path = candidates[0]
            assert path.is_file() and not path.is_symlink() and path.read_bytes() == moved_data
            assert not os.path.lexists(moved)
            path.rename(moved)
            report["cleanup"]["authoredTrashFixtureRestored"] = True
            report["nativeTrash"] = "observed_owned_fixture"
        else:
            report["cleanup"]["authoredTrashFixtureNotMoved"] = True
        if "fixture" in report:
            assert moved.read_bytes() == moved_data and kept.read_bytes() == b"B" * 64
        assert all(not os.path.lexists(path) for path in trash_candidates)
        report["cleanup"]["noOwnedTrashFixtureRemains"] = True
    except BaseException as error:
        report["errors"].append("fixture cleanup: " + str(error))
    try:
        assert guard("after") == baseline
        assert all(sha((export / row["path"]).read_bytes()) == row["sha256"] for row in exports)
        report["cleanup"]["sourceAndExportUnchanged"] = True
        current = root.lstat()
        assert root.parent == parent and not root.is_symlink() and stat.S_ISDIR(current.st_mode)
        assert (current.st_dev, current.st_ino, current.st_uid) == (identity.st_dev, identity.st_ino, os.getuid())
        assert report["cleanup"].get("ownedAppAndRunnerAbsent") and report["cleanup"].get("noOwnedTrashFixtureRemains")
        shutil.rmtree(root)
        report["cleanup"]["ownedRootAbsent"] = not root.exists()
    except BaseException as error:
        report["errors"].append("source/root cleanup: " + str(error))
    try:
        captures = [{**row, "visualReview": "pending"} for row in report.get("attachments", []) if row["file"].endswith(".png")]
        report["screenshots"] = captures
        capsule = []
        capsule_bytes = 0
        omitted = 0
        for row in report.get("attachments", []):
            if row.get("canonicalName") is None: continue
            data = (evidence / row["file"]).read_bytes()
            if capsule_bytes + len(data) > 2 * 1024 * 1024:
                omitted += 1
                continue
            capsule.append({**row, "gzipBase64": base64.b64encode(gzip.compress(data, mtime=0)).decode()})
            capsule_bytes += len(data)
        report["nativeEvidenceCapsule"] = {"entries": capsule, "originalBytes": capsule_bytes, "omitted": omitted, "maximumOriginalBytes": 2 * 1024 * 1024}
        if report.get("nativeTestCommandPassed"):
            for phase in ("01-empty", "02-review", "03-cleanup", "04-keyboard-rescan"):
                assert len([row for row in captures if row["canonicalName"] == phase + ".png"]) == 1, "missing or ambiguous native phase: " + phase
                assert len([row for row in report["attachments"] if row["canonicalName"] == phase + ".accessibility"]) == 1
            native_json = {}
            for name in ("owned-trash.json", "ui-observations.json"):
                matches = [row for row in report["attachments"] if row["canonicalName"] == name]
                assert len(matches) == 1
                native_json[name] = json.loads((evidence / matches[0]["file"]).read_text())
            actual_report = json.loads((evidence / "cleanup-report.json").read_text())
            observation = native_json["ui-observations.json"]
            assert observation["caseId"] == "RUI01" and observation["status"] == "passed" and observation["nativeReport"] == actual_report
            binding = native_json["owned-trash.json"]
            assert binding["nonce"] == nonce and binding["source"] == str(moved) and binding["destination"] == actual_report["items"][0]["destinationPath"]
            report["nativeJSONAttachmentsMatchSavedReport"] = True
        packet_files = [path for path in evidence.rglob("*") if path.is_file()]
        packet_bytes = sum(path.stat().st_size for path in packet_files)
        report["evidenceBudget"] = {"files": len(packet_files), "bytesBeforeFinalReceipt": packet_bytes, "maximumBytes": 64 * 1024 * 1024}
        assert packet_bytes <= 60 * 1024 * 1024, "evidence packet exceeds bound; preserve original runner evidence, no acceptance"
        assert len(json.dumps(report, indent=2).encode()) <= 4 * 1024 * 1024, "final receipt reserve exceeded"
    except BaseException as error:
        report["errors"].append("capture/packet evidence: " + str(error))
    try:
        vector = []
        raw_bytes = 0
        for path in sorted(native_evidence.rglob("*")):
            assert not path.is_symlink()
            if not path.is_file(): continue
            length = path.stat().st_size
            raw_bytes += length
            assert raw_bytes <= 127 * 1024 * 1024 and len(vector) < 4096, "raw native result exceeds separate bound"
            digest = hashlib.sha256()
            with path.open("rb") as stream:
                for block in iter(lambda: stream.read(1048576), b""): digest.update(block)
            vector.append({"file": str(path.relative_to(native_evidence)), "bytes": length, "sha256": digest.hexdigest()})
        data = (json.dumps(vector, indent=2) + "\n").encode()
        assert len(data) <= 1048576
        (native_evidence / "result-manifest.json").write_bytes(data)
        report["nativeResultBudget"] = {"files": len(vector), "bytesBeforeManifest": raw_bytes, "maximumBytes": 128 * 1024 * 1024,
                                        "manifestSha256": sha(data), "retentionDays": 2}
    except BaseException as error:
        report["errors"].append("raw result evidence: " + str(error))
report["status"] = "passed_pending_visual_review" if not report["errors"] and report.get("nativeTestCommandPassed") and report.get("testSummary") else "failed"
report["seconds"] = time.monotonic() - started
persist()
print("ROOMLET_NATIVE_UI_RESULT=" + json.dumps(report, separators=(",", ":")), flush=True)
raise SystemExit(0 if report["status"] == "passed_pending_visual_review" else 1)
