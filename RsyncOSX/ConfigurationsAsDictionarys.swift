//
//  ConfigurationsAsDictionarys.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

struct ConfigurationsAsDictionarys: SetConfigurations {
    var quickbackuplist: [Int]?
    var estimatedlist: [NSMutableDictionary]?

    // Function for getting all Configurations
    func getConfigurationsDataSourceSynchronize() -> [NSMutableDictionary]? {
        guard self.configurations != nil else { return nil }
        var configurations = self.configurations?.configurations?.filter {
            ViewControllerReference.shared.synctasks.contains($0.task)
        }
        var data = [NSMutableDictionary]()
        for i in 0 ..< (configurations?.count ?? 0) {
            if configurations?[i].offsiteServer.isEmpty == true {
                configurations?[i].offsiteServer = DictionaryStrings.localhost.rawValue
            }
            if let config = self.configurations?.configurations?[i] {
                let row: NSMutableDictionary = ConvertOneConfig(config: config).dict

                if self.quickbackuplist != nil {
                    let quickbackup = self.quickbackuplist?.filter { $0 == config.hiddenID }
                    if (quickbackup?.count ?? 0) > 0 {
                        row.setValue(1, forKey: DictionaryStrings.selectCellID.rawValue)
                    }
                }
                data.append(row)
            }
        }
        return data
    }

    init() {
        self.estimatedlist = [NSMutableDictionary]()
    }

    init(quickbackuplist: [Int]?, estimatedlist: [NSMutableDictionary]?) {
        self.estimatedlist = estimatedlist
        self.quickbackuplist = quickbackuplist
    }
}
