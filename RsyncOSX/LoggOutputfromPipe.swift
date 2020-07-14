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
        self.messages = [String]()
        if let outHandle = pipe?.fileHandleForReading {
            let data = outHandle.availableData
            if data.count > 0 {
                if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    self.messages?.append(str as String)
                }
            }
        }
        guard self.messages?.count ?? 0 > 0 else { return }
        let outputprocess = OutputProcess()
        outputprocess.addlinefromoutput(str: "Output from ShellOut")
        for i in 0 ..< (self.messages?.count ?? 0) {
            outputprocess.addlinefromoutput(str: self.messages?[i] ?? "")
        }
        _ = Logging(outputprocess, true)
    }
}
