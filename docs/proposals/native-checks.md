# Proposed native source checks

Status: inactive, pending explicit approval. No workflow is installed.

The local Storage Guard preflight on 2026-10-27 reported 29.9 GiB free against
34.0 GiB required for the estimated operation. Native build/test/package actions
were not run locally. Source parsing and static checks do not substitute for
them.

After approval, install the [prepared workflow](native-checks-ci.yml.example) as
`.github/workflows/roomlet-native-checks.yml`, publish that exact source and
dispatch it once on `main`. Remove the active temporary workflow after the job
is terminal and publish its receipt. Keep all tests and checks enabled.

## Bounded scope

- One standard `macos-15` GitHub-hosted runner, 15-minute timeout, public repository,
  read-only repository token and shallow checkout without persisted credentials.
- Print the exact commit/toolchain, syntax-check helper scripts and plist files,
  build `Roomlet`, then run the authored `RoomletCoreTests` filesystem fixtures.
- Fixtures create only uniquely named temporary directories in the runner's temp
  space and remove only those owned fixtures. No real Trash API, user folders,
  cloud files, account, network provider, model or app launch is part of the tests.
- Package the built binary as a sandbox-entitled local ad-hoc `.app`, verify its
  signature and metadata, and log its executable hash. This uses no signing
  certificate, Apple account, notarization, store enrollment or external release.
- Do not install dependencies, enable caches, upload artifacts, publish a release,
  launch the app, grant permissions, drive the UI or scan real directories.

The public standard runner is listed by [GitHub's runner documentation](https://docs.github.com/en/actions/how-tos/write-workflows/choose-where-workflows-run/choose-the-runner-for-a-job).
No paid/larger runner or artifact-storage allocation is proposed. Account policy
or provider availability can still reject a job; that is not authority to change
plans or use another account.

Passing this job would establish compilation, authored core behavior and local
package/signature checks on that runner. It would not prove NSOpenPanel security
scope, rendered UI, real Trash behavior, free-space reclamation, cancellation
under native interaction, installability or notarized distribution. Those remain
separate acceptance work.
