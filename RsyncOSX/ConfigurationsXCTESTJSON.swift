//
//  ConfigurationsXCTESTJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

class ConfigurationsXCTESTJSON: Configurations {
    private var maxhiddenID: Int {
        // Reading Configurations from memory
        let store: [Configuration] = self.getConfigurations()
        if store.count > 0 {
            _ = store.sorted { (config1, config2) -> Bool in
                if config1.hiddenID > config2.hiddenID {
                    return true
                } else {
                    return false
                }
            }
            let index = store.count - 1
            return store[index].hiddenID
        } else {
            return 0
        }
    }

    override func addNewConfigurations(_ dict: NSMutableDictionary) {
        var array = [NSDictionary]()
        let configs: [Configuration] = self.getConfigurations()
        for i in 0 ..< configs.count {
            if let dict: NSMutableDictionary = ConvertConfigurations(index: i).configuration {
                array.append(dict)
            }
        }
        dict.setObject(self.maxhiddenID + 1, forKey: "hiddenID" as NSCopying)
        array.append(dict)
        guard Validatenewconfigs(dict: dict).validated == true else { return }
        self.appendconfigurationstomemory(dict: array[array.count - 1])
    }

    override func readconfigurationsjson() {
        self.argumentAllConfigurations = [ArgumentsOneConfiguration]()
        let store = PersistentStorageConfigurationJSON(profile: self.profile).decodedjson
        for i in 0 ..< (store?.count ?? 0) {
            let transformed = transform(object: (store?[i] as? DecodeConfigJSON)!)
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
