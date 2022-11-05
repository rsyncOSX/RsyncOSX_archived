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
            DictionaryStrings.transferredNumber.rawValue: transferredNumber ?? "",
            DictionaryStrings.transferredNumberSizebytes.rawValue: transferredNumberSizebytes ?? "",
            DictionaryStrings.totalNumber.rawValue: totalNumber ?? "",
            DictionaryStrings.totalNumberSizebytes.rawValue: totalNumberSizebytes ?? "",
            DictionaryStrings.totalDirs.rawValue: totalDirs ?? "",
            DictionaryStrings.newfiles.rawValue: newfiles ?? "",
        ]
        dict.setValue(deletefiles ?? "", forKey: DictionaryStrings.deletefiles.rawValue)
        dict.setValue(0, forKey: DictionaryStrings.select.rawValue)
        return dict
    }

    func recordremotenumbers(index: Int) -> NSMutableDictionary {
        let dict: NSMutableDictionary = [
            DictionaryStrings.transferredNumber.rawValue: transferredNumber ?? "",
            DictionaryStrings.transferredNumberSizebytes.rawValue: transferredNumberSizebytes ?? "",
            DictionaryStrings.totalNumber.rawValue: totalNumber ?? "",
            DictionaryStrings.totalNumberSizebytes.rawValue: totalNumberSizebytes ?? "",
            DictionaryStrings.totalDirs.rawValue: totalDirs ?? "",
            DictionaryStrings.newfiles.rawValue: newfiles ?? "",
            DictionaryStrings.deletefiles.rawValue: deletefiles ?? "",
            DictionaryStrings.index.rawValue: index,
        ]
        return dict
    }

    init(outputprocess: OutputfromProcess?) {
        let number = Numbers(outputprocess: outputprocess)
        transferredNumber = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .transferredNumber)), number: NumberFormatter.Style.none)
        transferredNumberSizebytes = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .transferredNumberSizebytes)), number: NumberFormatter.Style.decimal)
        totalNumber = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalNumber)), number: NumberFormatter.Style.decimal)
        totalNumberSizebytes = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalNumberSizebytes)), number: NumberFormatter.Style.decimal)
        totalDirs = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalDirs)), number: NumberFormatter.Style.decimal)
        newfiles = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .new)), number: NumberFormatter.Style.none)
        deletefiles = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .delete)), number: NumberFormatter.Style.none)
    }

    init(outputfromrsync: [String]?) {
        let number = Numbers(outputfromrsync ?? [])
        transferredNumber = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .transferredNumber)), number: NumberFormatter.Style.none)
        transferredNumberSizebytes = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .transferredNumberSizebytes)), number: NumberFormatter.Style.decimal)
        totalNumber = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalNumber)), number: NumberFormatter.Style.decimal)
        totalNumberSizebytes = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalNumberSizebytes)), number: NumberFormatter.Style.decimal)
        totalDirs = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .totalDirs)), number: NumberFormatter.Style.decimal)
        newfiles = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .new)), number: NumberFormatter.Style.none)
        deletefiles = NumberFormatter.localizedString(from: NSNumber(value: number.getTransferredNumbers(numbers: .delete)), number: NumberFormatter.Style.none)
    }
}
