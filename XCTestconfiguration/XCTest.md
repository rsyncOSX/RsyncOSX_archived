This is the RsyncOSX configurations for executing XCTest runs for RsyncOSX. To execute the tests [create two profile directories (catalogs)](https://rsyncosx.github.io/configfiles) and name them:

- `XCTest`
- `Datacheck`

From version 6.4.5 release candidate the default path for config files is changed. If the the old config catalog (`~/Documents/Rsync/mac_serial_number`) does exist, RsyncOSX will continue utilizing the old catalog until the user changes the catalog.

New catalog: `~/.rsyncosx/mac_serial_number`
Old catalog: `~/Documents/Rsync/mac_serial_number`

Copy the configurations `configRsync.plist` and `scheduleRsync`to the catalog `~/.rsyncosx/mac_serial_number/XCTest` and likewise for the above files in the `Datacheck` catalog, to `~/.rsyncosx/mac_serial_number/Datacheck`.

There are tests for loading configurations and verifying that parameters for `rsync`.
