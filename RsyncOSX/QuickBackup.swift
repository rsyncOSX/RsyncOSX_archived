//
//  QuickBackup.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length trailing_comma

import Foundation

final class QuickBackup: SetConfigurations {
    var sortedlist: [NSMutableDictionary]?
    typealias Row = (Int, Int)
    var stackoftasktobeexecuted: [Row]?
    var index: Int?
    var hiddenID: Int?
    var maxcount: Int?
    weak var reloadtableDelegate: Reloadandrefresh?
    var outputprocess: OutputfromProcess?
    var command: QuickbackupDispatch?

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
        let now = Date()
        SharedReference.shared.quickbackuptask = [
            DictionaryStrings.start.rawValue: now,
            DictionaryStrings.hiddenID.rawValue: hiddenID,
            DictionaryStrings.dateStart.rawValue: "01 Jan 1900 00:00".en_us_date_from_string(),
            DictionaryStrings.schedule.rawValue: Scheduletype.manuel.rawValue,
        ]
        outputprocess = nil
        outputprocess = OutputfromProcessRsync()
        command = QuickbackupDispatch(processtermination: processtermination,
                                      filehandler: filehandler,
                                      outputprocess: outputprocess)
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
                self.index = index
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
                    self.index = index
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

extension QuickBackup {
    func processtermination() {
        setcompleted()
        SharedReference.shared.completeoperation?.finalizeScheduledJob(outputprocess: outputprocess)
        SharedReference.shared.completeoperation = nil
        guard (stackoftasktobeexecuted?.count ?? 0) > 0 else {
            stackoftasktobeexecuted = nil
            hiddenID = nil
            reloadtableDelegate?.reloadtabledata()
            weak var quickbackupcompletedDelegate: QuickBackupCompleted?
            quickbackupcompletedDelegate = SharedReference.shared.getvcref(viewcontroller: .vcquickbackup) as? ViewControllerQuickBackup
            quickbackupcompletedDelegate?.quickbackupcompleted()
            command = nil
            return
        }
        if let hiddenID = stackoftasktobeexecuted?[0].0,
           let index = stackoftasktobeexecuted?[0].1
        {
            stackoftasktobeexecuted?.remove(at: 0)
            self.hiddenID = hiddenID
            self.index = index
            sortedlist?[index].setValue(true, forKey: DictionaryStrings.inprogressCellID.rawValue)
            maxcount = Int(sortedlist?[index].value(forKey: DictionaryStrings.transferredNumber.rawValue) as? String ?? "0")
            executequickbackuptask(hiddenID: hiddenID)
            reloadtableDelegate?.reloadtabledata()
            command = nil
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
