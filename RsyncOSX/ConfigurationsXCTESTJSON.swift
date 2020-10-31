//
//  ConfigurationsXCTESTJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

class ConfigurationsXCTESTJSON: Configurations {
    override func addNewConfigurations(dict: NSMutableDictionary) {
        var config = Configuration(dictionary: dict)
        config.hiddenID = self.maxhiddenID + 1
        self.configurations?.append(config)
    }

    override func readconfigurationsjson() {
        self.argumentAllConfigurations = [ArgumentsOneConfiguration]()
        let store = PersistentStorageConfigurationJSON(profile: self.profile).decodedjson
        let transform = TransformConfigfromJSON()
        for i in 0 ..< (store?.count ?? 0) {
            let transformed = transform.transform(object: (store?[i] as? DecodeConfigJSON)!)
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
