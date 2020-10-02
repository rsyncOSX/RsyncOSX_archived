//
//  ConvertAssist.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 02/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

struct ConvertAssist {
    var assist: [NSDictionary]?

    init(assistassets: [Set<String>]?) {
        guard assistassets != nil else { return }
        self.assist = [NSDictionary]()
        for i in 0 ..< (assistassets?.count ?? 0) {}
    }
}
