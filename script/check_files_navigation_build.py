"""One app-only native compilation; no launch, tests, picker, scan or Trash."""
import base64
import gzip
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import selectors
import shutil
import signal
import stat
import subprocess
import tempfile
import time

source = os.environ["ROOMLET_SOURCE_COMMIT"]
assert re.fullmatch(r"[a-f0-9]{40}", source)
assert platform.system() == "Darwin" and platform.mac_ver()[0].startswith("15.")
assert os.environ["GITHUB_REPOSITORY"] == "alvarovillalbaa/roomlet"
assert os.environ["GITHUB_REF"] == "refs/heads/qa/roomlet-files-navigation-20261112"
assert os.environ["ROOMLET_PUBLIC_REPOSITORY"] == "true"
repo = Path.cwd().resolve()
parent = Path(os.environ["RUNNER_TEMP"]).resolve()
root = Path(tempfile.mkdtemp(prefix="roomlet-files-navigation-", dir=parent))
identity = root.stat()
for name in ("tmp", "cache", "config", "security", "build"):
    (root / name).mkdir(mode=0o700)
env = {key: os.environ[key] for key in ("PATH", "HOME", "LANG") if key in os.environ}
env.update(DEVELOPER_DIR="/Applications/Xcode_16.4.app/Contents/Developer", CI="true",
           TMPDIR=str(root / "tmp") + "/", SWIFTPM_MODULECACHE_OVERRIDE=str(root / "cache/manifest"))
report = {"schemaVersion": "roomlet-files-navigation-build-v1", "source": source,
          "status": "failed", "commands": [], "errors": [], "cleanup": {},
          "testsRun": False, "appLaunched": False, "scanPerformed": False, "trashPerformed": False}
children = []


def run(name, args, seconds=30):
    child = subprocess.Popen(args, cwd=repo, env=env, stdin=subprocess.DEVNULL,
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE, start_new_session=True)
    children.append(child)
    selector = selectors.DefaultSelector()
    streams = {"stdout": bytearray(), "stderr": bytearray()}
    for key in streams:
        pipe = getattr(child, key)
        os.set_blocking(pipe.fileno(), False)
        selector.register(pipe, selectors.EVENT_READ, key)
    deadline, stopped = time.monotonic() + seconds, None
    try:
        while selector.get_map():
            if time.monotonic() > deadline or any(len(value) > 524288 for value in streams.values()):
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
        kept = bytes(value[:524288])
        row["streams"][key] = {"bytes": len(kept), "sha256": hashlib.sha256(kept).hexdigest(),
                               "complete": stopped is None and len(value) <= 524288,
                               "gzipBase64": base64.b64encode(gzip.compress(kept, mtime=0)).decode()}
    report["commands"].append(row)
    assert child.returncode == 0 and stopped is None and group_absent, name + " failed"
    return bytes(streams["stdout"])


def guard(label):
    assert run(label + "-head", ["git", "rev-parse", "HEAD"]).decode().strip() == source
    assert run(label + "-status", ["git", "status", "--porcelain=v1", "--untracked-files=all", "--ignored"]) == b""
    vector = []
    for value in run(label + "-tree", ["git", "ls-tree", "-rz", "--long", "HEAD"]).split(b"\0"):
        if not value: continue
        metadata, name = value.split(b"\t", 1)
        mode, kind, blob, length = metadata.decode().split()
        path = Path(name.decode())
        assert not path.is_absolute() and ".." not in path.parts and kind == "blob" and mode in ("100644", "100755")
        item = repo / path
        assert not item.is_symlink() and item.is_file() and int(length) <= 4 * 1024 * 1024
        data = item.read_bytes()
        assert len(data) == int(length) and hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest() == blob
        assert ("100755" if item.stat().st_mode & 0o111 else "100644") == mode
        vector.append({"path": str(path), "mode": mode, "bytes": len(data), "blob": blob, "sha256": hashlib.sha256(data).hexdigest()})
    return vector


try:
    before = guard("before")
    report["sourceFiles"] = before
    report["swiftVersion"] = run("swift-version", ["/usr/bin/xcrun", "swift", "--version"]).decode()
    options = ["--scratch-path", str(root / "build"), "--cache-path", str(root / "cache/swiftpm"),
               "--config-path", str(root / "config"), "--security-path", str(root / "security"),
               "-Xswiftc", "-module-cache-path", "-Xswiftc", str(root / "cache/modules")]
    run("app-build", ["/usr/bin/xcrun", "swift", "build", *options, "--product", "Roomlet"], 300)
    binary_dir = run("binary-path", ["/usr/bin/xcrun", "swift", "build", *options, "--show-bin-path"]).decode().strip()
    binary = Path(binary_dir) / "Roomlet"
    assert binary.resolve().is_relative_to(root / "build") and binary.is_file() and not binary.is_symlink() and os.access(binary, os.X_OK)
    report["binary"] = {"bytes": binary.stat().st_size, "sha256": hashlib.sha256(binary.read_bytes()).hexdigest()}
    assert guard("after") == before
    report["sourceUnchanged"] = True
except BaseException as error:
    report["errors"].append(type(error).__name__ + ": " + str(error))
finally:
    try:
        for child in children:
            assert child.poll() is not None
            try: os.killpg(child.pid, 0)
            except ProcessLookupError: pass
            else: raise RuntimeError("owned child group remains")
        report["cleanup"]["ownedGroupsAbsent"] = True
        current = root.lstat()
        assert root.parent == parent and stat.S_ISDIR(current.st_mode) and not root.is_symlink()
        assert (current.st_dev, current.st_ino, current.st_uid) == (identity.st_dev, identity.st_ino, os.getuid())
        shutil.rmtree(root)
        report["cleanup"]["ownedRootAbsent"] = not root.exists()
    except BaseException as error:
        report["errors"].append("cleanup: " + str(error))
report["status"] = "passed" if not report["errors"] and report.get("sourceUnchanged") and all(report["cleanup"].values()) else "failed"
print("ROOMLET_FILES_NAVIGATION_RESULT=" + json.dumps(report, separators=(",", ":")), flush=True)
raise SystemExit(0 if report["status"] == "passed" else 1)
