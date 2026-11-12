# Publish a current-app universal preview

The public0.1.0 preview predates the Files navigation repair. Standing all-project
approval covers one public macos-15 packaging job,20minutes, then publication of
unchanged accepted assets at v0.1.1-preview.1. Keep v0.1.0-preview.1 and every
previous failure/receipt immutable. Publish this preparation before activation.

Version0.1.1/build2 changes Info.plist metadata only. All application/core Swift,
Package.swift, icon, production entitlements and existing tests retain the bytes
from accepted main caaaf20f. The bundled guide now describes the actual bounded
native workflow and repaired navigation. Both packaging helpers derive the ZIP
name from validated source version metadata, retaining no-overwrite behavior.

The new small profile reuses the accepted packaging engine. Its only shared
refactor extracts source admission and names version/build expectations. Old
profile defaults retain0.1.0/build1; old scopes are not rerun. The refresh admits
exactly six changed baseline files and three additions, preserving all other140
baseline paths/blobs/modes and prior native application input hashes. Source
bound16MiB accommodates already-retained native evidence; only selected runtime
files are exported, without Git history, old evidence or environments.

One immutable-source job compiles actual Release arm64/x86_64 app slices, joins
them with lipo, signs locally ad-hoc, validates both slices' minimum OS/system
links/effective two-key entitlements, source-exact guide/license/icon/plist,
strict signatures, archive/checksum and fresh ditto extraction with byte/mode/
xattr parity. Reuse the existing4GiB storage/RSS,64 process,900s work/150s cleanup,
bounded complete-stream/originals and source/index/owned-root controls. Require
8GiB initially free on the runner. Local guard0.2GiB/34GiB failed: no local build,
test, app, scan, Trash, environment, dependency or SDK/runtime installation.

The branch is qa/roomlet-preview-refresh-20261112-1; the inactive workflow pins
the reviewed source, Xcode16.4, contents-read and no checkout credentials.
No core/native-UI replay, app launch/quit, folder/panel/Trash action, model call,
account, paid enrollment or signing-posture change is included. Preserve compiler
warnings and resource-sampling limitations; no Swift6-language or OS-quota claim.

After a packaging pass, independently verify retained originals, then publish
the exact ZIP, checksum and manifest through a separately prepared bounded
contents-write job; verify server asset sizes/hashes and unchanged old release.
Retire only exact owned QA/work controls after terminal evidence. No workflow
belongs on main. Publication does not establish downloaded fresh installation,
Gatekeeper/trusted distribution, Intel runtime, all security boundaries or the
full product. The prior native UI case is carried at its actual source/profile.
