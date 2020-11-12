//
//  RemoteInfoTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 31.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length trailing_comma

import Foundation

class RemoteinfonumbersOnetask {
    var transferredNumber: String?
    var transferredNumberSizebytes: String?
    var totalNumber: String?
    var totalNumberSizebytes: String?
    var totalDirs: String?
    var newfiles: String?
    var deletefiles: String?

    func record() -> NSMutableDictionary {
        let dict: NSMutableDictionary = [
            DictionaryStrings.transferredNumber.rawValue: self.transferredNumber ?? "",
            DictionaryStrings.transferredNumberSizebytes.rawValue: self.transferredNumberSizebytes ?? "",
            DictionaryStrings.totalNumber.rawValue: self.totalNumber ?? "",
            DictionaryStrings.totalNumberSizebytes.rawValue: self.totalNumberSizebytes ?? "",
            DictionaryStrings.totalDirs.rawValue: self.totalDirs ?? "",
            DictionaryStrings.newfiles.rawValue: self.newfiles ?? "",
        ]
        dict.setValue(self.deletefiles ?? "", forKey: DictionaryStrings.deletefiles.rawValue)
        dict.setValue(0, forKey: DictionaryStrings.select.rawValue)
        return dict
    }

    func recordremotenumbers(index: Int) -> NSMutableDictionary {
        let dict: NSMutableDictionary = [
            DictionaryStrings.transferredNumber.rawValue: self.transferredNumber ?? "",
            DictionaryStrings.transferredNumberSizebytes.rawValue: self.transferredNumberSizebytes ?? "",
            DictionaryStrings.totalNumber.rawValue: self.totalNumber ?? "",
            DictionaryStrings.totalNumberSizebytes.rawValue: self.totalNumberSizebytes ?? "",
            DictionaryStrings.totalDirs.rawValue: self.totalDirs ?? "",
            DictionaryStrings.newfiles.rawValue: self.newfiles ?? "",
            DictionaryStrings.deletefiles.rawValue: self.deletefiles ?? "",
            "index": index,
        ]
        return dict
    }

    init(outputprocess: OutputProcess?) {
        let number = Numbers(outputprocess: outputprocess)
        self.transferredNumber = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .transferredNumber)), number: NumberFormatter.Style.none)
        self.transferredNumberSizebytes = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .transferredNumberSizebytes)), number: NumberFormatter.Style.decimal)
        self.totalNumber = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalNumber)), number: NumberFormatter.Style.decimal)
        self.totalNumberSizebytes = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalNumberSizebytes)), number: NumberFormatter.Style.decimal)
        self.totalDirs = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalDirs)), number: NumberFormatter.Style.decimal)
        self.newfiles = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .new)), number: NumberFormatter.Style.none)
        self.deletefiles = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .delete)), number: NumberFormatter.Style.none)
    }
}
