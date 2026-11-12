"""Publish exact accepted 0.1.1 bytes, then retire only this packet's controls."""
import base64
import gzip
import hashlib
import io
import json
import os
from pathlib import Path
import re
import subprocess
import time
import traceback
import urllib.error
import urllib.parse
import urllib.request

REPO = "alvarovillalbaa/roomlet"
TAG = "v0.1.1-preview.1"
PACKAGED = "d7ba615aae33cb8a2d06a9c878278c6df59137a1"
WORKFLOW = 415450805
BRANCH = "qa/roomlet-preview-refresh-20261112-1"
WORK = "work/roomlet-preview-refresh-20261112"
PIN = "301c1079e46b34e4e1898ace8d7db9df0f4d0e7ce74c0996a5a27ed65d64eea9"
ASSETS = {
    "Roomlet-0.1.1-macos-universal.zip": (528861, "80d6562af841510c095acd5541c55aa70fea21c988c5864689777272dbd71c20", "application/zip"),
    "Roomlet-0.1.1-macos-universal.zip.sha256": (100, "89ade14e3f6a0b568242e602e94c9164b5affb007cd576203611126b465ad8ff", "text/plain"),
    "Roomlet-preview-manifest.json": (2837, "bfc48019916e0c3b7bdeda1833c203e249ca432db1335a6aec72bfd8254c2ee4", "application/json"),
}
OLD_ASSETS = {
    "Roomlet-0.1.0-macos-universal.zip": (723725676, 526053, "sha256:8f24b5f348d4f8955f9ff8b2ceea3a316ba8fff8d96529dcdf2f0546287aedea"),
    "Roomlet-0.1.0-macos-universal.zip.sha256": (723726435, 100, "sha256:a5cd4ea60173ddd9babb444e1a37811c5c30fc47190e939451afdf8167687830"),
    "Roomlet-preview-manifest.json": (723726471, 2798, "sha256:d84c5a690d828d87a2611b03986a1fc2a5a1b51580a1fb60dbc44fe4f7a595c4"),
}
assert os.environ["GITHUB_REPOSITORY"] == REPO and os.environ["GITHUB_REF"] == "refs/heads/" + BRANCH
assert os.environ["ROOMLET_PUBLIC_REPOSITORY"] == "true"
SOURCE = os.environ["SOURCE_COMMIT"]
assert re.fullmatch(r"[0-9a-f]{40}", SOURCE)
assert subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip() == SOURCE
assert subprocess.check_output(["git", "status", "--porcelain=v1", "--untracked-files=all", "--ignored"]) == b""
OWN_HEAD = os.environ["GITHUB_SHA"]
OWN_RUN = int(os.environ["GITHUB_RUN_ID"])
assert re.fullmatch(r"[0-9a-f]{40}", OWN_HEAD)
report = {"schemaVersion": "roomlet.preview-publication-v1", "status": "failed", "source": SOURCE,
          "packagedSource": PACKAGED, "tag": TAG, "qaHead": OWN_HEAD, "run": OWN_RUN,
          "requests": [], "assets": [], "deletedRefs": [], "appOrTestsReplayed": False, "mainMutated": False}
deadline = time.monotonic() + 240


def sha(data):
    return hashlib.sha256(data).hexdigest()


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *_args, **_kwargs):
        raise RuntimeError("unexpected authenticated API redirect")


api = urllib.request.build_opener(NoRedirect())


def request(method, path, value=None, upload_type=None, statuses=(200,)):
    remaining = deadline - time.monotonic()
    assert remaining > 0 and len(report["requests"]) < 40 and path.startswith("repos/" + REPO + "/")
    body = value if upload_type else (json.dumps(value).encode() if value is not None else None)
    assert body is None or len(body) <= 8 * 1024 ** 2
    headers = {"Authorization": "Bearer " + os.environ["GH_TOKEN"], "Accept": "application/vnd.github+json",
               "X-GitHub-Api-Version": "2022-11-28", "User-Agent": "Roomlet-owned-preview-publication"}
    if body is not None: headers["Content-Type"] = upload_type or "application/json"
    url = ("https://uploads.github.com/" if upload_type else "https://api.github.com/") + path
    try:
        with api.open(urllib.request.Request(url, data=body, headers=headers, method=method), timeout=min(25, remaining)) as response:
            raw = response.read(2 * 1024 ** 2 + 1)
            status = response.status
    except urllib.error.HTTPError as error:
        raw = error.read(16384)
        report["requests"].append({"method": method, "path": path, "status": error.code, "bytes": len(raw), "sha256": sha(raw)})
        raise RuntimeError("HTTP " + str(error.code) + " " + method + " " + path + "; no retry: " + raw.decode(errors="replace")[:512]) from None
    assert len(raw) <= 2 * 1024 ** 2
    report["requests"].append({"method": method, "path": path, "status": status, "bytes": len(raw), "sha256": sha(raw)})
    assert status in statuses, "unexpected API status"
    return json.loads(raw) if raw else None


def head(branch):
    value = request("GET", "repos/" + REPO + "/git/ref/heads/" + branch)
    assert value["ref"] == "refs/heads/" + branch and value["object"]["type"] == "commit"
    return value["object"]["sha"]


def verify_old():
    value = request("GET", "repos/" + REPO + "/releases/438199648")
    assert value["tag_name"] == "v0.1.0-preview.1" and value["draft"] is False
    assert {a["name"]: (a["id"], a["size"], a["digest"]) for a in value["assets"]} == OLD_ASSETS
    tag = request("GET", "repos/" + REPO + "/git/ref/tags/v0.1.0-preview.1")
    assert tag["object"]["type"] == "commit" and tag["object"]["sha"] == "71aa2e79115ff9f38f2d9d61786ed075d6702f55"


def verify_new(value, draft):
    assert value["id"] == report["releaseId"] and value["tag_name"] == TAG and value["draft"] is draft and value["prerelease"] is True
    assert {a["name"] for a in value["assets"]} == set(ASSETS) and len(value["assets"]) == len(ASSETS)
    for asset in value["assets"]:
        size, digest, _ = ASSETS[asset["name"]]
        assert asset["size"] == size and asset["digest"] == "sha256:" + digest and asset["state"] == "uploaded"


try:
    raw = Path("docs/results/2026/11-12/preview-refresh-attempt-1.json").read_bytes()
    assert len(raw) <= 2 * 1024 ** 2 and sha(raw) == PIN
    accepted = json.loads(raw)
    assert accepted["sourceCommit"] == PACKAGED and accepted["status"] == "passed" and accepted["cleanup"]["verified"] and accepted["cleanup"]["rootAbsent"]
    assert accepted["cleanup"]["ownedProcessesRemaining"] == 0 and not accepted["ownedSignals"]
    assert all(accepted[key] is False for key in ("testsExecuted", "appLaunched", "scanPerformed", "trashPerformed"))
    assert set(accepted["retainedOriginals"]) == set(ASSETS)
    payloads = {}
    for name, (size, digest, _) in ASSETS.items():
        row = accepted["retainedOriginals"][name]
        packed = base64.b64decode(row["gzipBase64"], validate=True)
        with gzip.GzipFile(fileobj=io.BytesIO(packed)) as stream: data = stream.read(size + 1)
        assert len(data) == size == row["bytes"] and sha(data) == digest == row["sha256"]
        payloads[name] = data
    report["acceptedReceiptSha256"] = PIN
    runs = request("GET", "repos/" + REPO + "/actions/runs?per_page=100")
    assert all(r["status"] == "completed" or r["id"] == OWN_RUN for r in runs["workflow_runs"] if r["workflow_id"] == WORKFLOW)
    assert head("main") == head(WORK) == SOURCE and head(BRANCH) == OWN_HEAD
    releases = request("GET", "repos/" + REPO + "/releases?per_page=100")
    assert len(releases) < 100 and not any(r["tag_name"] == TAG for r in releases)
    tags = request("GET", "repos/" + REPO + "/git/matching-refs/tags/" + TAG)
    assert not any(r["ref"] == "refs/tags/" + TAG for r in tags)
    verify_old()
    body = ("Current-app universal developer preview, app 0.1.1 (build 2).\n\n"
            "Includes Files navigation for folder selection and every scan entry point, including same-folder selection and Command-R from Last Cleanup.\n\n"
            "The ZIP, checksum and manifest are unchanged accepted native Release arm64/x86_64 outputs from " + PACKAGED + ". Both slices passed strict ad-hoc signature/production-entitlement and extraction checks. The earlier generated-folder native UI case is carried at its actual source/profile.\n\n"
            "Ad-hoc preview: no Developer ID/notarization, fresh-Mac/Gatekeeper or Intel runtime acceptance. Do not bypass macOS security controls. See the bundled guide and repository evidence.")
    draft = request("POST", "repos/" + REPO + "/releases", {"tag_name": TAG, "target_commitish": PACKAGED,
                    "name": "Roomlet 0.1.1 developer preview", "body": body, "draft": True, "prerelease": True, "make_latest": "false"}, statuses=(201,))
    report["releaseId"] = draft["id"]
    assert draft["draft"] is True and draft["tag_name"] == TAG and draft["assets"] == []
    for name, (_, _, content_type) in ASSETS.items():
        asset = request("POST", "repos/" + REPO + "/releases/" + str(draft["id"]) + "/assets?name=" + urllib.parse.quote(name, safe=""),
                        payloads[name], content_type, (201,))
        report["assets"].append({key: asset[key] for key in ("id", "name", "size", "digest", "browser_download_url")})
    verify_new(request("GET", "repos/" + REPO + "/releases/" + str(draft["id"])), True)
    public = request("PATCH", "repos/" + REPO + "/releases/" + str(draft["id"]), {"draft": False, "prerelease": True, "make_latest": "false"})
    verify_new(public, False)
    report["releasePublished"] = True
    public = request("GET", "repos/" + REPO + "/releases/" + str(draft["id"]))
    verify_new(public, False)
    report["draftUploadedAssets"] = report["assets"]
    report["assets"] = [{key: asset[key] for key in ("id", "name", "size", "digest", "browser_download_url")} for asset in public["assets"]]
    report["releaseURL"] = public["html_url"]
    report["publishedAt"] = public["published_at"]
    tag = request("GET", "repos/" + REPO + "/git/ref/tags/" + TAG)
    assert tag["object"]["type"] == "commit" and tag["object"]["sha"] == PACKAGED
    report["tagHead"] = tag["object"]["sha"]
    verify_old()
    report["oldReleaseAndTagUnchanged"] = True
    for asset in public["assets"]:
        name = asset["name"]
        url = "https://github.com/" + REPO + "/releases/download/" + TAG + "/" + name
        assert asset["browser_download_url"] == url
        remaining = deadline - time.monotonic()
        assert remaining > 0
        # Public download follows GitHub/CDN redirects with no Authorization header.
        with urllib.request.urlopen(url, timeout=min(25, remaining)) as response:
            data = response.read(ASSETS[name][0] + 1)
        assert len(data) == ASSETS[name][0] and sha(data) == ASSETS[name][1]
        report["requests"].append({"method": "GET", "url": url, "authenticated": False, "bytes": len(data), "sha256": sha(data)})
    report["anonymousDownloadsVerified"] = True
    request("PUT", "repos/" + REPO + "/actions/workflows/" + str(WORKFLOW) + "/disable", statuses=(204,))
    assert request("GET", "repos/" + REPO + "/actions/workflows/" + str(WORKFLOW))["state"] == "disabled_manually"
    report["workflowDisabled"] = True
    for branch, expected_head in ((WORK, SOURCE), (BRANCH, OWN_HEAD)):
        assert head(branch) == expected_head
        request("DELETE", "repos/" + REPO + "/git/refs/heads/" + branch, statuses=(204,))
        report["deletedRefs"].append({"branch": branch, "expectedHead": expected_head})
    for prefix in ("qa/roomlet-preview-refresh-20261112", WORK):
        assert request("GET", "repos/" + REPO + "/git/matching-refs/heads/" + prefix) == []
    assert head("main") == SOURCE
    report["ownedRefsAbsent"] = report["mainStillExact"] = True
    report["status"] = "passed"
except BaseException as error:
    report["error"] = type(error).__name__ + ": " + str(error)
    report["traceback"] = traceback.format_exc()
print("ROOMLET_PREVIEW_PUBLICATION=" + json.dumps(report, separators=(",", ":")), flush=True)
raise SystemExit(0 if report["status"] == "passed" else 1)
