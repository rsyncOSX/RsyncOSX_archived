//
//  PersistentStorageAssist.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 02/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

final class PersistentStorageAssist: ReadWriteDictionary {
    var assist: [Set<String>]?

    // Save assist configuration
    func saveassist() {
        if let array: [NSDictionary] = ConvertAssist(assistassets: self.assist).assist {
            self.writeToStore(array: array)
        }
    }

    // Read assist
    func readassist() -> [NSDictionary]? {
        return self.readNSDictionaryFromPersistentStore()
    }

    // Writing assist to persistent store
    // Configuration is [NSDictionary]
    private func writeToStore(array: [NSDictionary]) {
        // Getting the object just for the write method, no read from persistent store
        _ = self.writeNSDictionaryToPersistentStorage(array: array)
    }

    init(assistassets: [Set<String>]?) {
        super.init(whattoreadwrite: .assist, profile: nil)
        self.assist = assistassets
    }
}
