//
//  RemoteNumbers.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 10/11/2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

final class RemoteNumbers {
    private var output: [String]?
    private var splitnumbers: [String]?
    private var used1kblocks: Int?
    private var avail1kblocks: Int?
    private var capacity1kblocks: Int?
    private var percentavaliable: Double?

    private func split(_ str: String) -> [String] {
        return str.components(separatedBy: " ")
    }

    private func setnumbers() {
        guard self.output != nil else { return }
        guard (self.output?.count ?? 0) == 2 else { return }
        let splitnumberstring = self.split(self.output![1])
        self.splitnumbers = [String]()
        for i in 0 ..< splitnumberstring.count where splitnumberstring[i].isEmpty == false {
            self.splitnumbers?.append(splitnumberstring[i])
        }
        if let used1kblocks = Int(self.splitnumbers![2]) {
            self.used1kblocks = used1kblocks
        }
        if let avail1kblocks = Int(self.splitnumbers![3]) {
            self.avail1kblocks = avail1kblocks
        }
        if let capacity1kblocks = Int(self.splitnumbers![1]) {
            self.capacity1kblocks = capacity1kblocks
        }
        guard self.capacity1kblocks != nil, self.used1kblocks != nil else { return }
        self.percentavaliable = (1 - Double(self.used1kblocks!) / Double(self.capacity1kblocks!)) * 100
    }

    func getused() -> String {
        let used = (self.used1kblocks ?? 0 / 1024) / 1024
        return NumberFormatter.localizedString(from: NSNumber(value: used), number: NumberFormatter.Style.decimal)
    }

    func getavail() -> String {
        let avail = (self.avail1kblocks ?? 0 / 1024) / 1024
        return NumberFormatter.localizedString(from: NSNumber(value: avail), number: NumberFormatter.Style.decimal)
    }

    func getpercentavaliable() -> String {
        return String(format: "%.2f", self.percentavaliable ?? 0)
    }

    init(outputprocess: OutputProcess?) {
        self.output = outputprocess?.trimoutput(trim: .two)
        self.setnumbers()
    }
}
