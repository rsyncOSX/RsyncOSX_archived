//
//  Estimatedlistforsynchronization.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

final class Estimatedlistforsynchronization: SetConfigurations {
    var quickbackuplist: [Int]?
    var estimatedlist: [NSMutableDictionary]?

    // Function for getting all Configurations
    func getConfigurationsDataSourceSynchronize() -> [NSMutableDictionary]? {
        guard self.configurations != nil else { return nil }
        var configurations = self.configurations?.configurations?.filter {
            SharedReference.shared.synctasks.contains($0.task)
        }
        var data = [NSMutableDictionary]()
        for i in 0 ..< (configurations?.count ?? 0) {
            if configurations?[i].offsiteServer.isEmpty == true {
                configurations?[i].offsiteServer = DictionaryStrings.localhost.rawValue
            }
            if let config = self.configurations?.configurations?[i] {
                let row: NSMutableDictionary = ConvertOneConfig(config: config).dict

                if quickbackuplist != nil {
                    let quickbackup = quickbackuplist?.filter { $0 == config.hiddenID }
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
        estimatedlist = [NSMutableDictionary]()
    }

    init(quickbackuplist: [Int]?, estimatedlist: [NSMutableDictionary]?) {
        self.estimatedlist = estimatedlist
        self.quickbackuplist = quickbackuplist
    }

    deinit {
        // print("deinit Estimatedlistforsynchronization")
    }
}
