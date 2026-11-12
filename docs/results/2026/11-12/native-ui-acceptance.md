# Actual macOS workflow accepted

**RUI01 passed as one native workflow** at source
`cdb66c7a0a9ca5b51facc9bbcff6d60982fc4894`, tree
`152c418e24d442f3ed1d8c390ff07b5f5d52a260`.
[Run43143776311](https://github.com/alvarovillalbaa/roomlet/actions/runs/43143776311),
job130936709464, QA`1f088f9bdf1183a92c9b7c03c90b173ec8ec5c9a`, completed
successfully: one passed, zero failed/skipped. The ten earlier activations remain
failed; their original records are preserved beside this file.

The actual app/core/UI runner compiled with Xcode16.4 on macOS15.8.2 arm64.
The generated xctestrun bound Roomlet.app and its bundle ID. Strict ad-hoc
signature and exact production App Sandbox/selected-folder read-write guards
passed before **and after** UI; no broader Xcode test-only app rights were accepted.

One workflow verified native folder selection, both exact collected files and
zero initial selection, exact4096byte single selection, Review/Keep Files,
reopened Review and explicit native Trash. The64byte file remained unchanged.
The actual NSSavePanel report agrees with both native JSON attachments on the
root, exact filename,4096bytes, moved outcome and Trash destination. Command-O
reselected the same folder and opened Files; Command-R from cleared Last Cleanup
opened Files and rescanned only the64byte file with zero selected.

## Inspected originals

The [original receipt](native-ui-attempt-11.json) retains its emitted
passed_pending_visual_review status; this separate record closes that review.
All34complete command streams and14 lossless native originals were independently
decompressed/byte/SHA256 verified, with zero omissions. The [full original log](native-ui-attempt-11.log)
is retained. The expected pgrep exit1 proves no preexisting Roomlet; other exits
were0, with no timeout/truncation and all original groups absent.

All four required1024×768 PNGs were hash-verified and inspected: readable native
controls, exact review file/size, one-moved/zero-failed cleanup with space warning,
and the remaining64byte file after keyboard rescan.

| Native phase | Original screenshot and hierarchy |
| --- | --- |
| Empty folder state | [PNG](native-ui-attempt-11-01-empty.png) · [tree](native-ui-attempt-11-01-empty.accessibility) |
| Exact one-file review | [PNG](native-ui-attempt-11-02-review.png) · [tree](native-ui-attempt-11-02-review.accessibility) |
| Actual cleanup outcome | [PNG](native-ui-attempt-11-03-cleanup.png) · [tree](native-ui-attempt-11-03-cleanup.accessibility) |
| Keyboard rescan in Files | [PNG](native-ui-attempt-11-04-keyboard-rescan.png) · [tree](native-ui-attempt-11-04-keyboard-rescan.accessibility) |

The [859byte actual saved report](native-ui-attempt-11-cleanup-report.json) was
recovered by removing outer indentation from the nested native attachment,
then matched byte count and the controller's independent saved-file SHA256:
`d1ba2486c09226e427617c29d7f2954d185c8c588f0a95e76318c435ecc8448f`.
The [native observations](native-ui-attempt-11-ui-observations.json) and
[owned Trash binding](native-ui-attempt-11-owned-trash.json) remain originals.
Diagnostic captures survive losslessly in the receipt; the identical final/
rescan PNG is not copied twice.

Teardown restored only the nonce/preabsence/4096byte-verified regular fixture
from /Users/runner/.Trash, verified both originals/no owned Trash residue, checked
exact app/runner and command-group absence, verified all119 checkout files
(6,743,653bytes)/modes/blobs and selected exports, and removed only the owned root.
Fourteen native originals total1,115,904bytes. Compact1,467,001bytes before final
receipt and raw1,236,965bytes before manifest stayed within64MiB/128MiB; both
upload admissions passed.

Temporary Actions ZIPs expire14November; neither was independently downloaded
or promised permanent retention. Original receipt/log and named native payloads
remain in Git:

- Compact13911156502:1,939,566bytes, server SHA256
  `a0a85729e68741e64f4f97bb98f5285dc8bdcdb80b07595d6abf36752e38f7fe`.
- Raw13910378722:982,375bytes, server SHA256
  `5d3abee90753a7ca7128bc85b134d5c6778eafe1703fea84b12bdda8f4321773`.

Temporary-control retirement follows the [published scope](../../../proposals/native-ui-retirement.md).

## Limits

App/core/Package/resources/production entitlements/old core-test bytes remain
identical to49b44445; only test setup/controllers and evidence/docs changed.
No old29-core/preview replay, local native execution, personal/private file,
network/model, account, paid enrollment or simulator. Existing captured
concurrency warnings remain; no Swift6-language/race claim.

This qualifies one generated-folder T2 workflow on one arm64 virtual Mac.
Multiwindow/menu-bar paths, other volumes/providers, hostile concurrent writers,
denied/protected access, physical Mac/Intel runtime, downloaded installation/
Gatekeeper, trusted signing/distribution and full product scope remain open.
Observed volume availability is not attributed reclaimed space. Public
v0.1.0-preview.1 retains its older tested bytes and is not replaced here.
