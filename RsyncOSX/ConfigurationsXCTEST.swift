//
//  ConfigurationsXCTEST.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 19/12/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

class ConfigurationsXCTEST: Configurations {
    override func addNewConfigurations(dict: NSMutableDictionary) {
        var config = Configuration(dictionary: dict)
        config.hiddenID = self.maxhiddenID + 1
        self.configurations?.append(config)
    }

    override func readconfigurationsplist() {
        self.argumentAllConfigurations = [ArgumentsOneConfiguration]()
        let store = PersistentStorageConfiguration(profile: self.profile).configurationsasdictionary
        for i in 0 ..< (store?.count ?? 0) {
            if let dict = store?[i] {
                let config = Configuration(dictionary: dict)
                if ViewControllerReference.shared.synctasks.contains(config.task) {
                    self.configurations?.append(config)
                    let rsyncArgumentsOneConfig = ArgumentsOneConfiguration(config: config)
                    self.argumentAllConfigurations?.append(rsyncArgumentsOneConfig)
                }
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
