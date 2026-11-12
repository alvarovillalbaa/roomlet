# Publish the accepted0.1.1 originals and retire controls

Packaging passed at d7ba615aae33cb8a2d06a9c878278c6df59137a1 in
run43147144720/job130947503103. All44 complete original streams and all three
retained payloads were independently byte/hash verified. A separate data-only
ZIP audit verifies all seven payload/mode records, source-exact guide/license/
plist,0.1.1/build2 and both native CPU headers. No app or test ran locally.

Standing approval covers one five-minute public Ubuntu24.04 job at the same
owned QA branch. Publish reviewed helper/source/results before activation.
The helper checks its pinned accepted receipt, all exact payload sizes/SHA256s,
main/work/QA heads, other runs terminal, absent target release/tag, and the
existing0.1.0 release/tag/three server asset pins. It creates one new draft at
v0.1.1-preview.1 targeting the actual packaged source, uploads exactly the
unchanged ZIP/checksum/manifest via GitHub's REST upload endpoint, verifies
server sizes/digests before publishing as a prerelease, then verifies tag and
three unauthenticated public downloads. Keep0.1.0 and its assets unchanged.

The temporary workflow grants contents-write/actions-write only for that release
and retirement of workflow415450805 plus the exact task QA/work refs. No copied
user credential, account, paid signing/enrollment, app/build/test rerun, scan,
Trash, deployment, database or model call. API authentication uses only this
job's automatically scoped token; anonymous downloads carry no token.

Only after successful publication/download verification does the helper disable
its workflow and delete its two exact heads, then read absence/main back. Head
checks are serialized, not atomic delete leases. A rejection/uncertain mutation
stops without retry or token changes; preserve any partial draft/public state,
receipt and log before deciding a changed continuation. Do not overwrite assets,
create a second release blindly, or turn metadata into fresh-Mac proof.

References: [GitHub releases API](https://docs.github.com/en/rest/releases/releases)
and [release asset upload/download API](https://docs.github.com/en/rest/releases/assets).

This scope [completed successfully](../results/2026/11-12/preview-refresh-publication.md).
Preserve its accepted source/assets and retired controls; no unchanged rerun.
