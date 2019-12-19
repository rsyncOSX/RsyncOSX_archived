//
//  ConfigurationsXCTEST.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 19/12/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

class ConfigurationsXCTEST: Configurations {
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
        dict.removeObject(forKey: "singleFile")
        array.append(dict)
        self.appendconfigurationstomemory(dict: array[array.count - 1])
    }
}
