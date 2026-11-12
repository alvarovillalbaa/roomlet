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
assert os.environ["GITHUB_REF"] == "refs/heads/qa/roomlet-ui-20261112-ci3"
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
result_path = evidence / "ui.xcresult"
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
    fixture_config.write_text(json.dumps({"root": str(root), "nonce": nonce, "evidence": str(evidence)}))
    report["generatedTestResource"] = {"path": "Tests/e2e/FixtureConfig.json", "sha256": sha(fixture_config.read_bytes())}
    report["fixture"] = {"source": str(moved), "sha256": sha(moved_data), "bytes": 4096,
                         "kept": str(kept), "keptSha256": sha(b"B" * 64)}
    common = ["/usr/bin/xcodebuild", "-project", "Tests/RoomletAcceptance.xcodeproj", "-scheme", "RoomletAcceptance",
              "-configuration", "Debug", "-destination", "platform=macOS,arch=arm64", "-derivedDataPath", str(root / "derived")]
    run("build-for-testing", common + ["build-for-testing"], seconds=300, cwd=export)
    entitlements = run("app-entitlements", ["/usr/bin/codesign", "-d", "--entitlements", ":-", str(app)])
    assert plistlib.loads(entitlements) == {"com.apple.security.app-sandbox": True, "com.apple.security.files.user-selected.read-write": True}
    run("signature", ["/usr/bin/codesign", "--verify", "--strict", str(app)])
    report["appEntitlementsMatchProduction"] = True
    run("native-ui", common + ["test-without-building", "-resultBundlePath", str(result_path),
        "-only-testing:RoomletAcceptance/RoomletAcceptance/testRUI01FolderScanReviewTrashReport",
        "-parallel-testing-enabled", "NO", "-test-timeouts-enabled", "YES",
        "-default-test-execution-time-allowance", "240", "-maximum-test-execution-time-allowance", "300"], seconds=480, cwd=export)
    report["nativeTestCommandPassed"] = True
except BaseException as error:
    report["errors"].append(type(error).__name__ + ": " + str(error))
    report["traceback"] = traceback.format_exc()
finally:
    cleanup_phase = True
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
        except BaseException as error:
            report["attachmentExportLimit"] = str(error)
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
        binding = evidence / "owned-trash.json"
        if binding.exists():
            value = json.loads(binding.read_text())
            assert value["nonce"] == nonce and value["source"] == str(moved)
            assert Path(value["destination"]) in trash_candidates
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
        captures = []
        for path in evidence.glob("*.png"):
            assert not path.is_symlink()
            data = path.read_bytes()
            assert len(data) <= 4 * 1024 * 1024
            captures.append({"file": path.name, "bytes": len(data), "sha256": sha(data), "visualReview": "pending"})
        report["screenshots"] = captures
        if report.get("nativeTestCommandPassed"):
            assert {row["file"] for row in captures} == {"01-empty.png", "02-review.png", "03-cleanup.png", "04-keyboard-rescan.png"}
        packet_files = [path for path in evidence.rglob("*") if path.is_file()]
        packet_bytes = sum(path.stat().st_size for path in packet_files)
        report["evidenceBudget"] = {"files": len(packet_files), "bytesBeforeFinalReceipt": packet_bytes, "maximumBytes": 64 * 1024 * 1024}
        assert packet_bytes <= 63 * 1024 * 1024, "evidence packet exceeds bound; preserve original runner evidence, no acceptance"
    except BaseException as error:
        report["errors"].append("capture/packet evidence: " + str(error))
report["status"] = "passed_pending_visual_review" if not report["errors"] and report.get("nativeTestCommandPassed") and report.get("testSummary") else "failed"
report["seconds"] = time.monotonic() - started
persist()
print("ROOMLET_NATIVE_UI_RESULT=" + json.dumps(report, separators=(",", ":")), flush=True)
raise SystemExit(0 if report["status"] == "passed_pending_visual_review" else 1)
