# Documentation of RsyncOSX source

This is documentation of the design and code of RsyncOSX. I have just commenced the documentation (June 2017) and it will take time to complete. Why am I doing it? Well, primary for fun but i might learn something from it as well. The design is based upon ideas of the [MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) pattern. One of the objectives is to separate the views and models.

First will the data (model) and some of the methods operating on the data be documented. After that details about how RsyncOSX is working after data about configurations and schedules are loaded to memory. RsyncOSX kicks off the `rsync` utility to do the real work. The `rsync` is executed in a `Process` object. Any time RsyncOSX [executes](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/processCmd.swift) a command RsyncOSX is listening for two notifications `didTerminateNotification` and `NSFileHandleDataAvailable`. Those two notifications kicks of other functions depended upon the state of RsyncOSX.

# High Level design

The views has no knowledge about the models or data stored about configurations, schedules and logdata. All data presented in RsyncOSX are mostly table data. To present table data I am using the `NSTableViewDelegate`. All data stored to permanent store are saved in xml-files ([plist](https://en.wikipedia.org/wiki/Property_list) files). I am **not** using the Core Data because the data about `configurations`, `schedules` and `logs` are simple and there is no need for a complex datamodel.

## Configurations (tasks)

The configurations are read from the permanent store and kept in memory during lifetime. Each record (one task) are read from permanent store as a `NSDictionary` item and loaded in an `Array<configuration>`. A [configuration](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/configuration.swift) is a struct holding all data about one task.

The object [SharingManagerConfigurations.swift](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/SharingManagerConfiguration.swift) holds all data and methods operating on configurations. The method `readAllConfigurationsAndArguments` read all data about configurations to memory. Every time a configuration is read the rsync arguments are computed and hold by the struct [argumentsOneConfiguration.swift](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/argumentsOneConfiguration.swift) in memory. There are four types of arguments which are computed during startup, arguments for `--dry-run` and real run and both arguments for presentation on screen. Each configuration is allocated a uniq computed nonsense key `hiddenID = Int`.

The object [SharingManagerConfigurations.swift](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/SharingManagerConfiguration.swift) creates an `Array<NSMutableDictionary>` which holds all data about `configuration` and computed values of arguments. Computed values are **not** saved to permanent store. They are computed when RsyncOSX is started or a new profile is loaded. The method `getConfigurationsDataSource()` returns the computed `Array<NSMutableDictionary>` and it is the data object which is loaded by the `NSTableViewDelegate` delegate methods into tables in view. As an example see [ViewControllertabMain.swift](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/ViewControllertabMain.swift) and `func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any?` how data is loaded into tables.

### Changes to configurations

Any changes to configurations (edit, delete, new, parameters to rsync) is a three step operation:

- any changes to configurations are updated in memory (to the `Array<configuration>`)
  - [configuration](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/configuration.swift) is a struct holding all attributes for one configuration
  - the `Array<NSMutableDictionary>` is computed and read-only after loaded in memory
- after an update the configuration in memory configurations are saved to permanent store
- the configurations in memory are wiped out and loaded into memory from the permanent store to compute any new values due to changes
  - a new and computed `Array<NSMutableDictionary>` is loaded

This is a kind of brute force. No code needed for partly update and it secures a 100% correct and updated configuration in memory at all time. Saving, wiping memory and reading configurations is done in matter of milliseconds.

## Schedules and log data

TBC.
