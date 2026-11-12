"""Retire only the completed native packet's exact temporary controls."""
import hashlib
import json
import os
import re
import subprocess
import time
import traceback

REPO = "alvarovillalbaa/roomlet"
WORKFLOW = 415362445
assert os.environ["GITHUB_REPOSITORY"] == REPO
assert os.environ["GITHUB_REF"] == "refs/heads/qa/roomlet-ui-20261112-ci4"
assert os.environ["ROOMLET_PUBLIC_REPOSITORY"] == "true"
expected = os.environ["ROOMLET_RETIREMENT_SOURCE"]
assert re.fullmatch(r"[0-9a-f]{40}", expected)
assert subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip() == expected
assert subprocess.check_output(["git", "status", "--porcelain=v1", "--untracked-files=all", "--ignored"]) == b""
own_run = int(os.environ["GITHUB_RUN_ID"])
own_head = os.environ["GITHUB_SHA"]
assert re.fullmatch(r"[0-9a-f]{40}", own_head)
targets = {
    "qa/roomlet-ui-20261112-ci5": "e20c82b4e9be4f8a3ad1954e493a0366cd65aaa0",
    "qa/roomlet-ui-20261112-ci7": "152145769e9661a36cf269a0197178a172d38f98",
    "qa/roomlet-ui-20261112-ci8": "b724dfc88747b6218441b95ea0d7e9f4173ddd8b",
    "qa/roomlet-ui-20261112-ci9": "d70d9be49db243ad10e0344a1e92ae2c275cd8b3",
    "qa/roomlet-ui-20261112-ci10": "2526e6ff007d9acdacc57ebaa1a83489fa9c26ea",
    "qa/roomlet-ui-20261112-ci11": "1f088f9bdf1183a92c9b7c03c90b173ec8ec5c9a",
    "work/roomlet-native-ui-20261112": expected,
    "qa/roomlet-ui-20261112-ci4": own_head,
}
report = {"schemaVersion": "roomlet-native-ui-retirement-v1", "source": expected,
          "qaHead": own_head, "run": own_run, "status": "failed", "requests": [],
          "deleted": [], "appOrTestsReplayed": False, "mainMutated": False}
deadline = time.monotonic() + 150


def call(method, path, statuses=(200,)):
    remaining = deadline - time.monotonic()
    assert remaining > 0 and len(report["requests"]) < 40
    assert path.startswith("repos/" + REPO + "/")
    p = subprocess.run(["gh", "api", "--include", "--method", method, path],
                       capture_output=True, timeout=min(20, remaining))
    assert len(p.stdout) <= 2097152 and len(p.stderr) <= 65536
    headers, separator, body = p.stdout.replace(b"\r\n", b"\n").partition(b"\n\n")
    match = re.match(rb"HTTP/\S+ (\d{3})", headers)
    status = int(match[1]) if match else None
    report["requests"].append({"method": method, "path": path, "status": status,
        "exitCode": p.returncode, "stdoutBytes": len(p.stdout),
        "stdoutSha256": hashlib.sha256(p.stdout).hexdigest(),
        "stderrBytes": len(p.stderr), "stderrSha256": hashlib.sha256(p.stderr).hexdigest()})
    assert status in statuses and p.returncode == 0 and separator, method + " " + path + " rejected; no retry"
    return json.loads(body) if body.strip() else None


def head(branch):
    value = call("GET", "repos/" + REPO + "/git/ref/heads/" + branch)
    assert value["ref"] == "refs/heads/" + branch and value["object"]["type"] == "commit"
    return value["object"]["sha"]


try:
    runs = call("GET", "repos/" + REPO + "/actions/runs?per_page=100")
    assert all(row["status"] == "completed" or row["id"] == own_run
               for row in runs["workflow_runs"] if row["workflow_id"] == WORKFLOW)
    assert head("main") == expected
    assert all(head(branch) == sha for branch, sha in targets.items())
    report["allOwnedHeadsAndTerminalRunsVerified"] = True
    call("PUT", "repos/" + REPO + "/actions/workflows/" + str(WORKFLOW) + "/disable", (204,))
    assert call("GET", "repos/" + REPO + "/actions/workflows/" + str(WORKFLOW))["state"] == "disabled_manually"
    report["workflowDisabled"] = True
    for branch, sha in targets.items():
        assert head(branch) == sha, "owned ref moved; leave it untouched"
        call("DELETE", "repos/" + REPO + "/git/refs/heads/" + branch, (204,))
        report["deleted"].append({"branch": branch, "expectedHead": sha})
    remaining = []
    for prefix in ("qa/roomlet-ui-20261112", "work/roomlet-native-ui-20261112"):
        rows = call("GET", "repos/" + REPO + "/git/matching-refs/heads/" + prefix)
        remaining.extend(row["ref"] for row in rows)
    assert not any("refs/heads/" + branch in remaining for branch in targets)
    report["allOwnedRefsAbsent"] = True
    assert head("main") == expected
    report["mainStillExact"] = True
    report["status"] = "passed"
except BaseException as error:
    report["error"] = type(error).__name__ + ": " + str(error)
    report["traceback"] = traceback.format_exc()
print("ROOMLET_NATIVE_UI_RETIREMENT=" + json.dumps(report, separators=(",", ":")), flush=True)
raise SystemExit(0 if report["status"] == "passed" else 1)
