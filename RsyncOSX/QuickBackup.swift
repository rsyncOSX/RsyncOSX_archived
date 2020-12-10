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
    // var estimatedlist: [NSMutableDictionary]?
    typealias Row = (Int, Int)
    var stackoftasktobeexecuted: [Row]?
    var index: Int?
    var hiddenID: Int?
    var maxcount: Int?
    weak var reloadtableDelegate: Reloadandrefresh?
    var outputprocess: OutputProcess?
    var command: QuickbackupDispatch?

    func sortbydays() {
        guard self.sortedlist != nil else { return }
        self.sortedlist = self.sortedlist?.sorted { (di1, di2) -> Bool in
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
        self.reloadtableDelegate?.reloadtabledata()
    }

    private func executequickbackuptask(hiddenID: Int) {
        let now = Date()
        ViewControllerReference.shared.quickbackuptask = [
            DictionaryStrings.start.rawValue: now,
            DictionaryStrings.hiddenID.rawValue: hiddenID,
            DictionaryStrings.dateStart.rawValue: "01 Jan 1900 00:00".en_us_date_from_string(),
            DictionaryStrings.schedule.rawValue: Scheduletype.manuel.rawValue,
        ]
        self.outputprocess = nil
        self.outputprocess = OutputProcessRsync()
        self.command = QuickbackupDispatch(processtermination: self.processtermination,
                                           filehandler: self.filehandler,
                                           outputprocess: self.outputprocess)
    }

    private func prepareandstartexecutetasks() {
        if let list = self.sortedlist {
            self.stackoftasktobeexecuted = [Row]()
            for i in 0 ..< list.count {
                self.sortedlist?[i].setObject(false, forKey: DictionaryStrings.completeCellID.rawValue as NSCopying)
                self.sortedlist?[i].setObject(false, forKey: DictionaryStrings.inprogressCellID.rawValue as NSCopying)
                if list[i].value(forKey: DictionaryStrings.select.rawValue) as? Int == 1 {
                    self.stackoftasktobeexecuted?.append(((list[i].value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int) ?? -1, i))
                }
            }
            guard self.stackoftasktobeexecuted!.count > 0 else { return }
            // Kick off first task
            if let hiddenID = self.stackoftasktobeexecuted?[0].0,
               let index = self.stackoftasktobeexecuted?[0].1
            {
                self.stackoftasktobeexecuted?.remove(at: 0)
                self.hiddenID = hiddenID
                self.index = index
                self.sortedlist?[index].setValue(true, forKey: DictionaryStrings.inprogressCellID.rawValue)
                self.maxcount = Int(self.sortedlist?[index].value(forKey: DictionaryStrings.transferredNumber.rawValue) as? String ?? "0")
                self.executequickbackuptask(hiddenID: hiddenID)
            }
        }
    }

    func setcompleted() {
        let dict = self.sortedlist!.filter { ($0.value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int) == self.hiddenID! }
        guard dict.count == 1 else { return }
        self.index = self.sortedlist!.firstIndex(of: dict[0])
        self.sortedlist![self.index!].setValue(true, forKey: DictionaryStrings.completeCellID.rawValue)
        self.sortedlist![self.index!].setValue(false, forKey: DictionaryStrings.inprogressCellID.rawValue)
    }

    init() {
        self.sortedlist = ViewControllerReference.shared.configurationsasdictionarys?.estimatedlist
        guard self.sortedlist?.count ?? 0 > 0 else { return }
        self.sortbydays()
        self.hiddenID = nil
        self.reloadtableDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcquickbackup) as? ViewControllerQuickBackup
        self.prepareandstartexecutetasks()
    }

    deinit {
        self.stackoftasktobeexecuted = nil
        ViewControllerReference.shared.configurationsasdictionarys = nil
        print("deinit QuickBackup")
    }

    func abort() {
        self.stackoftasktobeexecuted = nil
        ViewControllerReference.shared.configurationsasdictionarys = nil
    }
}

extension QuickBackup {
    func processtermination() {
        self.setcompleted()
        ViewControllerReference.shared.completeoperation?.finalizeScheduledJob(outputprocess: self.outputprocess)
        ViewControllerReference.shared.completeoperation = nil
        guard (self.stackoftasktobeexecuted?.count ?? 0) > 0 else {
            self.stackoftasktobeexecuted = nil
            self.hiddenID = nil
            self.reloadtableDelegate?.reloadtabledata()
            weak var quickbackupcompletedDelegate: QuickBackupCompleted?
            quickbackupcompletedDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcquickbackup) as? ViewControllerQuickBackup
            quickbackupcompletedDelegate?.quickbackupcompleted()
            return
        }
        if let hiddenID = self.stackoftasktobeexecuted?[0].0,
           let index = self.stackoftasktobeexecuted?[0].1
        {
            self.stackoftasktobeexecuted?.remove(at: 0)
            self.hiddenID = hiddenID
            self.index = index
            self.sortedlist?[index].setValue(true, forKey: DictionaryStrings.inprogressCellID.rawValue)
            self.maxcount = Int(self.sortedlist?[index].value(forKey: DictionaryStrings.transferredNumber.rawValue) as? String ?? "0")
            self.executequickbackuptask(hiddenID: hiddenID)
            self.reloadtableDelegate?.reloadtabledata()
            self.command = nil
        }
    }

    func filehandler() {
        weak var localprocessupdateDelegate: Reloadandrefresh?
        weak var outputeverythingDelegate: ViewOutputDetails?
        localprocessupdateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcquickbackup) as? ViewControllerQuickBackup
        localprocessupdateDelegate?.reloadtabledata()
        outputeverythingDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if outputeverythingDelegate?.appendnow() ?? false {
            outputeverythingDelegate?.reloadtable()
        }
    }
}
