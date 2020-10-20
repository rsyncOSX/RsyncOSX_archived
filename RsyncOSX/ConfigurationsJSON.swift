//
//  ConfigurationsJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

class ConfigurationsJSON: Configurations {
    override func readconfigurations() {
        self.argumentAllConfigurations = [ArgumentsOneConfiguration]()
        // let store: [Configuration]? = PersistentStorageConfiguration(profile: self.profile).readconfigurations()
        let store = ReadWriteConfigurationsJSON(profile: self.profile).decodejson
        for i in 0 ..< (store?.count ?? 0) {
            let transformed = transform(object: (store?[i] as? ConfigJSON)!)
            if ViewControllerReference.shared.synctasks.contains(transformed.task) {
                self.configurations?.append(transformed)
                let rsyncArgumentsOneConfig = ArgumentsOneConfiguration(config: transformed)
                self.argumentAllConfigurations?.append(rsyncArgumentsOneConfig)
            }
        }
        // Then prepare the datasource for use in tableviews as Dictionarys
        var data = [NSMutableDictionary]()
        for i in 0 ..< (self.configurations?.count ?? 0) {
            let task = self.configurations?[i].task
            if ViewControllerReference.shared.synctasks.contains(task ?? "") {
                if let config = self.configurations?[i] {
                    data.append(ConvertOneConfig(config: config).dict)
                }
            }
        }
        self.configurationsDataSource = data
    }
}

extension Configurations {
    func transform(object: ConfigJSON) -> Configuration {
        var dayssincelastbackup: String?
        var markdays: Bool = false
        var lastruninseconds: Double? {
            if let date = object.dateRun {
                let lastbackup = date.en_us_date_from_string()
                let seconds: TimeInterval = lastbackup.timeIntervalSinceNow
                return seconds * (-1)
            } else {
                return nil
            }
        }
        // Last run of task
        if object.dateRun != nil {
            if let secondssince = lastruninseconds {
                dayssincelastbackup = String(format: "%.2f", secondssince / (60 * 60 * 24))
                if secondssince / (60 * 60 * 24) > ViewControllerReference.shared.marknumberofdayssince {
                    markdays = true
                }
            }
        }
        let dict: NSDictionary = [
            "backupID": object.backupID ?? "",
            "dateRun": object.dateRun ?? "",
            "haltshelltasksonerror": object.haltshelltasksonerror ?? 0,
            "localCatalog": object.localCatalog ?? "",
            "offsiteCatalog": object.offsiteCatalog ?? "",
            "offsiteServer": object.offsiteServer ?? "",
            "offsiteUsername": object.offsiteUsername ?? "",
            "parameter1": object.parameter1 ?? "",
            "parameter2": object.parameter2 ?? "",
            "parameter3": object.parameter3 ?? "",
            "parameter4": object.parameter4 ?? "",
            "parameter5": object.parameter5 ?? "",
            "parameter6": object.parameter6 ?? "",
            "parameter8": object.parameter8 ?? "",
            "parameter9": object.parameter9 ?? "",
            "parameter10": object.parameter10 ?? "",
            "parameter11": object.parameter11 ?? "",
            "parameter12": object.parameter12 ?? "",
            "parameter13": object.parameter13 ?? "",
            "parameter14": object.parameter14 ?? "",
            "rsyncdaemon": object.rsyncdaemon ?? 0,
            "sshkeypathandidentityfile": object.sshkeypathandidentityfile ?? "",
            "sshport": object.sshport ?? 22,
            "task": object.task ?? "",
            "hiddenID": object.hiddenID ?? 0,
            "snapdayoffweek": object.snapdayoffweek ?? "",
            "snaplast": object.snaplast ?? 0,
            "snapshotnum": object.snapshotnum ?? 0,
            "pretask": object.pretask ?? "",
            "executepretask": object.executepretask ?? 0,
            "posttask": object.posttask ?? "",
            "executeposttask": object.executeposttask ?? 0,
            "lastruninseconds": lastruninseconds ?? 0,
            "dayssincelastbackup": dayssincelastbackup ?? "",
            "markdays": markdays,
        ]
        return Configuration(dictionary: dict)
    }
}
