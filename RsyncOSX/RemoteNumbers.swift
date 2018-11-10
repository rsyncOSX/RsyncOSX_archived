//
//  RemoteNumbers.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 10/11/2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

final class RemoteNumbers {
    // Second last String in Array rsync output of how much in what time
    private var resultRsync: String?
    // calculated number of files
    // output Array to keep output from rsync in
    private var output: [String]?
    private var splitnumbers: [String]?

    // Split an Rsync argument into argument and value
    private func split (_ str: String) -> [String] {
        return  str.components(separatedBy: " ")
    }

    private func setnumbers() {
        guard self.output != nil  else { return }
        guard self.output!.count == 2 else { return }
        let splitnumberstring = self.split(self.output![1])
        self.splitnumbers = [String]()
        for i in 0 ..< splitnumberstring.count where splitnumberstring[i].isEmpty == false {
            self.splitnumbers?.append(splitnumberstring[i])
        }
    }

    init (outputprocess: OutputProcess?) {
        self.output = outputprocess?.trimoutput(trim: .two)
        self.setnumbers()
    }
}
