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
        for i in 0 ..< (assistassets?.count ?? 0) {
            switch i {
            case 0:
                for j in 0 ..< (assistassets?.count ?? 0) {
                    let dict: NSDictionary = [
                        "remotecomputers": assistassets?[j] ?? "",
                    ]
                    self.assist?.append(dict)
                }
            case 1:
                for j in 0 ..< (assistassets?.count ?? 0) {
                    let dict: NSDictionary = [
                        "remoteusers": assistassets?[j] ?? "",
                    ]
                    self.assist?.append(dict)
                }
            case 2:
                for j in 0 ..< (assistassets?.count ?? 0) {
                    let dict: NSDictionary = [
                        "remotecatalogs": assistassets?[j] ?? "",
                    ]
                    self.assist?.append(dict)
                }
            default:
                return
            }
        }
    }
}
