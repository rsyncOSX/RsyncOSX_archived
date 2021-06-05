//
//  OutputfromPipe.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 14/07/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation
struct LoggOutputfromPipe {
    var messages: [String]?
    init(pipe: Pipe?) {
        messages = [String]()
        if let outHandle = pipe?.fileHandleForReading {
            let data = outHandle.availableData
            if data.count > 0 {
                if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    messages?.append(str as String)
                }
            }
        }
    }
}
