# Documentation of RsyncOSX source

This is documentation of the design and code of RsyncOSX. I have just commenced the documentation (June 2017) and it will take time to complete. Why am I doing it? Well, primary for fun but i might learn something from it as well. The design is based upon ideas of the [MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) pattern. The objective is to separate the view and the model.

# High Level design

The views has no knowledge about the models or data stored about configurations, schedules and logdata. All data presented in RsyncOSX are most table data. To present table data I am using the `NSTableViewDelegate`. All data stored to permanent store are saved in xml-files ([plist](https://en.wikipedia.org/wiki/Property_list) files). I am **not** using the Core Data mostly because the data about `configurations`, `schedules` and `logs` are simple and there are no need for a complex datamodel.

## Configurations (tasks)

The configurations are read from permanent store and kept in memory during lifetime. Each record (one task) are read from permanent store as `NSDictionary` and loaded in an array of configurations. A [configuration](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/configuration.swift) is a struct holding all data about one task.

The object [SharingManagerConfigurations.swift](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/SharingManagerConfiguration.swift) holds all data and methods operating on configurations. The method `readAllConfigurationsAndArguments` read all data about configurations to memory. Every time a configuration is read the rsync arguments are computed and loaded into memory by the object [argumentsConfigurations.swift](https://github.com/rsyncOSX/RsyncOSX/blob/master/RsyncOSX/argumentsConfigurations.swift).

To be continued.
