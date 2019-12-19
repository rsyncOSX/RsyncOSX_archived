This is the RsyncOSX configurations for executing XCTest runs for RsyncOSX. To execute the tests [create two profile directories (catalogs)](https://rsyncosx.github.io/configfiles) and name them:

- `XCTest`
- `Datacheck`

Copy the configurations `configRsync.plist` and `scheduleRsync`to the catalog `~/Documents/Rsync/mac_serial_number/XCTest` and likewise for the above files in the `Datacheck` catalog, to `~/Documents/Rsync/mac_serial_number/Datacheck`.

There are tests for loading configurations and checking that parameters for `rsync` are correct.
