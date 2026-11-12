# Fifth activation: workflow variable substitution failed before work

[Run43139355575](https://github.com/alvarovillalbaa/roomlet/actions/runs/43139355575),
job130922294558, failed at QA`e3e970f53b76efe2f7d394b449da6ba26bb15816`,
intended source`5bc1ab39941ba912484bddfc640771a7d6e805f4`.

A global template substitution changed the environment-variable key as well as
its value. The controller raised KeyError for ROOMLET_SOURCE_COMMIT before
creating any private root/evidence path, child process, build, app or fixture.
No native case ran and no controller receipt exists. Upload admission found
zero files and correctly skipped both upload steps. The
[complete original job log](native-ui-attempt-5.log) retains the failure.

The continuation changes only the active workflow's environment binding.
The exact published source tree remains11c831a54921e8c6c2cb20355962a5ce07af5c8e;
native local commit8ff3ecc1c1bea0dd017f6270bcc68dcdf29e9bf7 has identical bytes,
published through connected GitHub commit5bc1ab3 after local Git DNS failure.
No app source, test action/assertion, entitlement, data bound or timeout changes.
