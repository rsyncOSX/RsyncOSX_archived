//
//  ConfigurationsAsDictionarys.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 11/12/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

final class ConfigurationsAsDictionarys: SetConfigurations {
    func uniqueserversandlogins() -> [NSDictionary]? {
        guard self.configurations != nil else { return nil }
        var configurations = self.configurations?.configurations?.filter {
            ViewControllerReference.shared.synctasks.contains($0.task)
        }
        var data = [NSDictionary]()
        for i in 0 ..< (configurations?.count ?? 0) {
            if configurations?[i].offsiteServer.isEmpty == true {
                configurations?[i].offsiteServer = DictionaryStrings.localhost.rawValue
            }
            if let config = self.configurations?.configurations?[i] {
                let row: NSDictionary = ConvertOneConfig(config: config).dict
                let server = config.offsiteServer
                let user = config.offsiteUsername
                if server != DictionaryStrings.localhost.rawValue {
                    if data.filter({ $0.value(forKey: DictionaryStrings.offsiteServerCellID.rawValue) as? String ?? "" ==
                            server && $0.value(forKey: DictionaryStrings.offsiteUsernameID.rawValue) as? String ?? "" == user }).count == 0
                    {
                        data.append(row)
                    }
                }
            }
        }
        return data
    }

    deinit {
        print("deinit ConfigurationsAsDictionarys")
    }
}
