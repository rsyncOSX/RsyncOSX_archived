//
//  SynchronizeAlltasksNow.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 06/11/2022.
//  Copyright © 2022 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

final class SynchronizeAlltasksNow: SetConfigurations {
    var sortedlist: [NSMutableDictionary]?
    typealias Row = (Int, Int)
    var stackoftasktobeexecuted: [Row]?
    var hiddenID: Int?
    var index: Int?
    var maxcount: Int?
    weak var reloadtableDelegate: Reloadandrefresh?
    var outputprocess: OutputfromProcess?

    func sortbydays() {
        guard sortedlist != nil else { return }
        sortedlist = sortedlist?.sorted { di1, di2 -> Bool in
            if let di1 = (di1.value(forKey: DictionaryStrings.daysID.rawValue) as? NSString)?.doubleValue,
               let di2 = (di2.value(forKey: DictionaryStrings.daysID.rawValue) as? NSString)?.doubleValue
            {
                if di1 > di2 {
                    return false
                } else {
                    return true
                }
            }
            return false
        }
        reloadtableDelegate?.reloadtabledata()
    }

    private func executequickbackuptask(hiddenID: Int) {
        outputprocess = nil
        outputprocess = OutputfromProcessRsync()
        if let index = configurations?.getIndex(hiddenID) {
            if let config = configurations?.getConfigurations()?[index] {
                self.index = index
                let arguments = ArgumentsSynchronize(config: config).argumentssynchronize(dryRun: false, forDisplay: false)
                let command = RsyncProcess(arguments: arguments,
                                           config: config,
                                           processtermination: processtermination,
                                           filehandler: filehandler)
                command.executeProcess(outputprocess: outputprocess)
            }
        }
    }

    private func prepareandstartexecutetasks() {
        if let list = sortedlist?.filter({ $0.value(forKey: DictionaryStrings.select.rawValue) as? Int == 1 }) {
            // adjust selected tasks if any adjustmenst
            if list.count != sortedlist?.count {
                sortedlist = list
            }
            stackoftasktobeexecuted = [Row]()
            for i in 0 ..< list.count {
                sortedlist?[i].setObject(false, forKey: DictionaryStrings.completeCellID.rawValue as NSCopying)
                sortedlist?[i].setObject(false, forKey: DictionaryStrings.inprogressCellID.rawValue as NSCopying)
                if list[i].value(forKey: DictionaryStrings.select.rawValue) as? Int == 1 {
                    stackoftasktobeexecuted?.append(((list[i].value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int) ?? -1, i))
                }
            }
            guard stackoftasktobeexecuted!.count > 0 else { return }
            // Kick off first task
            if let hiddenID = stackoftasktobeexecuted?[0].0,
               let index = stackoftasktobeexecuted?[0].1
            {
                stackoftasktobeexecuted?.remove(at: 0)
                self.hiddenID = hiddenID
                sortedlist?[index].setValue(true, forKey: DictionaryStrings.inprogressCellID.rawValue)
                maxcount = Int(sortedlist?[index].value(forKey: DictionaryStrings.transferredNumber.rawValue) as? String ?? "0")
                executequickbackuptask(hiddenID: hiddenID)
            }
        }
    }

    func setcompleted() {
        if let hiddenID = hiddenID {
            if let dict = sortedlist?.filter({ ($0.value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int) == hiddenID }) {
                guard dict.count == 1 else { return }
                if let index = sortedlist?.firstIndex(of: dict[0]) {
                    sortedlist?[index].setValue(true, forKey: DictionaryStrings.completeCellID.rawValue)
                    sortedlist?[index].setValue(false, forKey: DictionaryStrings.inprogressCellID.rawValue)
                }
            }
        }
    }

    init() {
        sortedlist = SharedReference.shared.estimatedlistforsynchronization?.estimatedlist
        guard sortedlist?.count ?? 0 > 0 else { return }
        sortbydays()
        hiddenID = nil
        reloadtableDelegate = SharedReference.shared.getvcref(viewcontroller: .vcquickbackup) as? ViewControllerQuickBackup
        prepareandstartexecutetasks()
    }

    deinit {
        self.stackoftasktobeexecuted = nil
        SharedReference.shared.estimatedlistforsynchronization = nil
        // print("deinit QuickBackup")
    }

    func abort() {
        stackoftasktobeexecuted = nil
        SharedReference.shared.estimatedlistforsynchronization = nil
    }
}

extension SynchronizeAlltasksNow {
    func processtermination() {
        setcompleted()
        configurations?.setCurrentDateonConfiguration(index: index ?? 0, outputprocess: outputprocess)
        guard (stackoftasktobeexecuted?.count ?? 0) > 0 else {
            stackoftasktobeexecuted = nil
            hiddenID = nil
            reloadtableDelegate?.reloadtabledata()
            weak var completed: SynchronizeallCompleted?
            completed = SharedReference.shared.getvcref(viewcontroller: .vcquickbackup) as? ViewControllerQuickBackup
            completed?.synchronizeallcompleted()
            return
        }
        if let hiddenID = stackoftasktobeexecuted?[0].0,
           let index = stackoftasktobeexecuted?[0].1
        {
            stackoftasktobeexecuted?.remove(at: 0)
            self.hiddenID = hiddenID
            sortedlist?[index].setValue(true, forKey: DictionaryStrings.inprogressCellID.rawValue)
            maxcount = Int(sortedlist?[index].value(forKey: DictionaryStrings.transferredNumber.rawValue) as? String ?? "0")
            executequickbackuptask(hiddenID: hiddenID)
            reloadtableDelegate?.reloadtabledata()
        }
    }

    func filehandler() {
        weak var localprocessupdateDelegate: Reloadandrefresh?
        weak var outputeverythingDelegate: ViewOutputDetails?
        localprocessupdateDelegate = SharedReference.shared.getvcref(viewcontroller: .vcquickbackup) as? ViewControllerQuickBackup
        localprocessupdateDelegate?.reloadtabledata()
        outputeverythingDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if outputeverythingDelegate?.appendnow() ?? false {
            outputeverythingDelegate?.reloadtable()
        }
    }
}
