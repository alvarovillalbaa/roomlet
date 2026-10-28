# Roomlet icon source

28 October 2026. Original artwork and bundle-resource wiring are published on
GitHub. Native build, packaging and distribution remain unverified.

The [editable SVG](../../../../artwork/app-icon.svg) uses differently sized file
blocks and an open area on a mint tile, with transparent padding. The generated
[PNG reference](../../../../artwork/app-icon.png) is source artwork, not a macOS
screenshot. The [exporter](../../../../script/render_app_icon.py) uses only Python
standard-library rectangle rasterization and a big-endian PNG-backed ICNS
container. It adds no app runtime dependency or model call.

Apple's archived [high-resolution guide](https://developer.apple.com/library/archive/documentation/GraphicsAnimation/Conceptual/HighResolutionOSX/Optimizing/Optimizing.html)
specifies ten standard/retina icon slots. The current
[CFBundleIconFile reference](https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleiconfile)
identifies the bundle icon resource. The installed Apple SDK's IconStorage.h
defines the big-endian family/record layout; the pinned maintained
[Pillow decoder](https://github.com/python-pillow/Pillow/blob/75d6d6db2fa61940552fe2df0a54943a5596702b/src/PIL/IcnsImagePlugin.py)
provides the PNG-backed slot mapping. Pillow was inspected as a format reference,
not installed or used by the exporter.

`CFBundleIconFile` names `AppIcon.icns`, and the source packager copies it into
Contents/Resources before the unchanged signing commands. Entitlements, runtime,
core tests, package dependencies, build/launch guard and CI source are unchanged.

## Observed checks

- Export and `--check` passed with Python 3.14.7 on macOS 26.5.2 (25F84).
- Apple's iconutil decoded the final ICNS into all ten canonical PNG names,
  with their expected 16–1024 pixel dimensions and 8-bit RGBA format. Decoder
  re-encoding bytes are not used as a source-byte equivalence claim.
- The artwork PNG was inspected directly; independent parsing confirms alpha
  ranges from transparent to opaque, with antialiasing and expected block colors.
  sips reports a 1024-square RGB image with alpha.
- Shell syntax, property-list lint and `git diff --check` passed. The source
  resource copy precedes the original ad-hoc signature step; the packager itself
  was not executed.

Direct SVG rasterization failed in sips despite its advertised SVG capability.
Native iconutil encoding rejected the complete authored ten-slot set, including
after a bounded native PNG-to-PNG normalization attempt. Native ICNS decoding
works. The final exporter therefore uses a small explicit container writer;
these failures are not recorded as successful native encoding. Temporary
authored diagnostics and the read-only Apple-art decode output were removed.

| Asset | SHA256 |
| --- | --- |
| SVG | `7c989b2107100eff55c66a24f5618a39fb354577edc6fb64314398a651e4eccc` |
| PNG | `7372807013ab5c3ed8a683e376f27f9a7193679e591e8aa613f0546745cce2f5` |
| ICNS | `290d8227f6c1f73845ca11a13a889711f6f44942246a72c43929ffe8842b312c` |
| Exporter | `d74c7ab9195a9896d9cf2b6483d9cc5877a661f3f4e7308046f68447edac24b6` |

## Source publication

Published [source commit 6f7b437](https://github.com/alvarovillalbaa/roomlet/commit/6f7b4377c8ca5edf33540d059fafdfbca73138ea).
Immutable GitHub readback matched the local Git blobs below; `main` was identical
to that source commit at readback. Independent final checks confirmed all ten
ICNS mappings, embedded PNG checksums and reference bytes, unchanged original
plist values/packaging commands after removing the icon additions, twelve local
documentation links and the nine-file change scope. `git diff --check` passed.

| Published file | Git blob |
| --- | --- |
| SVG | `427379e146a781c7270d852cca74f3a0598826b9` |
| PNG | `e31bcf28a4b47a9c7beadd19f3617a3a4f4739a8` |
| ICNS | `a4e724fd519e232cc6487437879b4d0680dc1c01` |
| Info.plist | `ae70328d027d6bf979d13c0cd8c77152816ce817` |
| Packaging helper | `effdde40df9806da2788e5caab6ae17025b6f342` |
| Python exporter | `e92e08658aa37f57d206665ea14d2d335658393b` |
| Shell exporter | `d10c23f87148dcc238dca2957e8e897c2819be02` |

There is no built app artifact from this work. No app build, core test, signature,
launch, scan, file Trash action, permission prompt, CI, signing account or store
submission ran. Actual packaged resource presence, Finder/Dock rendering,
sandbox behavior and trusted distribution still need their applicable native
approval and verification steps. This source step does not finish the app or
the broader all-project delivery goal.
