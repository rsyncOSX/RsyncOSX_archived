//
//  ReadWriteJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 16/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation
import SwiftyJSON

class ReadWriteJSON: NamesandPaths {
    func readJSONFromPersistentStore() -> Any? {
        return nil
    }

    func writeJSONToPersistentStore() {}

    override init(whattoreadwrite: WhatToReadWrite, profile: String?) {
        super.init(whattoreadwrite: whattoreadwrite, profile: profile)
    }
}
