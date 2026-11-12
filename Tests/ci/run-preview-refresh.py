"""Current-app preview profile; reuse the accepted packaging engine, no tests/UI."""
import importlib.util
import json
from pathlib import Path
import shutil
import sys

spec = importlib.util.spec_from_file_location("roomlet_preview_engine", Path(__file__).with_name("run-preview-package.py"))
engine = importlib.util.module_from_spec(spec)
spec.loader.exec_module(engine)
engine.BRANCH = "refs/heads/qa/roomlet-preview-refresh-20261112-1"
engine.WORKFLOW = ".github/workflows/preview-refresh.yml"
engine.ARCHIVE = "Roomlet-0.1.1-macos-universal.zip"
engine.APP_VERSION, engine.APP_BUILD = "0.1.1", "2"
BASE = "caaaf20f0de283f17fbba1af15420a8e9c055520"
CHANGED = {"AGENTS.md", "Resources/Info.plist", "docs/preview-setup.md", "script/build_and_run.sh",
           "script/package_app.sh", "Tests/ci/run-preview-package.py"}
ADDED = {"Tests/ci/run-preview-refresh.py", "docs/proposals/preview-refresh.md",
         "docs/proposals/preview-refresh.workflow.yml.example"}


class Refresh(engine.Check):
    def admit_source(self, vector, index_sha):
        engine.need(self.git("rev-list", "--parents", "-n", "1", self.commit).decode().split() == [self.commit, BASE], "refresh_source_parent")
        engine.need(engine.WORKFLOW not in vector and sum(row["bytes"] for row in vector.values()) < 16 * engine.MIB, "refresh_inert_source_scope")
        baseline = {}
        for entry in filter(None, self.git("ls-tree", "-rz", "--full-tree", BASE).split(b"\0")):
            metadata, name = entry.split(b"\t", 1)
            mode, kind, oid = metadata.decode().split()
            engine.need(kind == "blob" and mode in ("100644", "100755"), "refresh_baseline_entry")
            baseline[engine.safe(name.decode())] = {"mode": mode, "blob": oid}
        engine.need(set(vector) == set(baseline) | ADDED, "refresh_file_set")
        changed = {name for name, row in baseline.items() if any(vector[name][key] != row[key] for key in row)}
        engine.need(changed == CHANGED, "refresh_exact_change_set")
        prior = json.loads((self.checkout / "docs/results/2026/11-12/native-ui-attempt-11.json").read_bytes())
        engine.need(prior["source"] == "cdb66c7a0a9ca5b51facc9bbcff6d60982fc4894"
                    and prior["nativeTestCommandPassed"] and not prior["errors"]
                    and prior["nativeJSONAttachmentsMatchSavedReport"] and prior["testSummary"]["passedTests"] == 1, "carried_native_acceptance")
        protected = 0
        for row in prior["sourceFiles"]:
            name = row["path"]
            if name == "Package.swift" or name.startswith(("Sources/", "Resources/", "Tests/RoomletCoreTests/")):
                if name == "Resources/Info.plist": continue
                engine.need(vector[name]["sha256"] == row["sha256"] and vector[name]["mode"] == row["mode"], "native_application_bytes_changed")
                protected += 1
        self.source, self.index_sha = vector, index_sha
        self.report.update(sourceCommit=self.commit, canonicalBaseCommit=BASE, sourceVector=vector, indexSha256=index_sha,
                           releaseTag="v0.1.1-preview.1", appVersion="0.1.1", buildNumber="2",
                           nativeApplicationInputsUnchanged=protected,
                           carriedNativeUI={"source": prior["source"], "run": 43143776311, "cases": 1, "executedHere": False},
                           priorFailuresPreserved=True)

    def admit(self):
        super().admit()
        engine.need(shutil.disk_usage(self.root.parent).free >= 8 * 1024 ** 3, "remote_free_storage")


if __name__ == "__main__":
    sys.exit(Refresh().execute())
