//
//  RemoteInfoTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 31.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

class RemoteInfoTask {

    var transferredNumber: String?
    var transferredNumberSizebytes: String?
    var totalNumber: String?
    var totalNumberSizebytes: String?
    var totalDirs: String?
    var newfiles: String?
    var deletefiles: String?

    func record() -> NSMutableDictionary {
        let dict: NSMutableDictionary = [
            "transferredNumber": self.transferredNumber ?? "",
            "transferredNumberSizebytes": self.transferredNumberSizebytes ?? "",
            "totalNumber": self.totalNumber ?? "",
            "totalNumberSizebytes": self.totalNumberSizebytes ?? "",
            "totalDirs": self.totalDirs ?? "",
            "newfiles": self.newfiles ?? ""]
        dict.setValue(self.deletefiles ?? "", forKey: "deletefiles")
        dict.setValue(0, forKey: "backup")
        return dict
    }

    init(outputprocess: OutputProcess?) {
        let number = Numbers(outputprocess: outputprocess)
        self.transferredNumber = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .transferredNumber)), number: NumberFormatter.Style.decimal)
        self.transferredNumberSizebytes = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .transferredNumberSizebytes)), number: NumberFormatter.Style.decimal)
        self.totalNumber = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalNumber)), number: NumberFormatter.Style.decimal)
        self.totalNumberSizebytes = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalNumberSizebytes)), number: NumberFormatter.Style.decimal)
        self.totalDirs = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalDirs)), number: NumberFormatter.Style.decimal)
        self.newfiles = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .new)), number: NumberFormatter.Style.decimal)
        self.deletefiles = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .delete)), number: NumberFormatter.Style.decimal)
    }
}
