//
//  RemoteInfoTaskWorkQueue.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 31.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

protocol SetRemoteInfo: AnyObject {
    func setremoteinfo(remoteinfotask: RemoteinfoEstimation?)
    func getremoteinfo() -> RemoteinfoEstimation?
}

final class RemoteinfoEstimation: SetConfigurations {
    // (hiddenID, index)
    typealias Row = (Int, Int)
    var stackoftasktobeestimated: [Row]?
    var outputprocess: OutputfromProcess?
    var records: [NSMutableDictionary]?
    var updateviewprocesstermination: () -> Void
    weak var startstopProgressIndicatorDelegate: StartStopProgressIndicator?
    weak var getmultipleselectedindexesDelegate: GetMultipleSelectedIndexes?
    var index: Int?
    private var maxnumber: Int?
    // estimated list, configs as NSDictionary
    var estimatedlistandconfigs: Estimatedlistforsynchronization?

    private func prepareandstartexecutetasks() {
        stackoftasktobeestimated = [Row]()
        if getmultipleselectedindexesDelegate?.multipleselection() == false {
            for i in 0 ..< (configurations?.getConfigurations()?.count ?? 0) {
                let task = configurations?.getConfigurations()?[i].task
                if SharedReference.shared.synctasks.contains(task ?? "") {
                    stackoftasktobeestimated?.append((configurations?.getConfigurations()?[i].hiddenID ?? 0, i))
                }
            }
        } else {
            let indexes = getmultipleselectedindexesDelegate?.getindexes()
            for i in 0 ..< (indexes?.count ?? 0) {
                if let index = indexes?[i] {
                    let task = configurations?.getConfigurations()?[index].task
                    if SharedReference.shared.synctasks.contains(task ?? "") {
                        stackoftasktobeestimated?.append((configurations?.getConfigurations()?[index].hiddenID ?? 0, index))
                    }
                }
            }
        }
        maxnumber = stackoftasktobeestimated?.count
    }

    func selectalltaskswithnumbers(deselect: Bool) {
        guard records != nil else { return }
        for i in 0 ..< (records?.count ?? 0) {
            let number = (records?[i].value(forKey: DictionaryStrings.transferredNumber.rawValue) as? String) ?? "0"
            let delete = (records?[i].value(forKey: DictionaryStrings.deletefiles.rawValue) as? String) ?? "0"
            if Int(number) ?? 0 > 0 || Int(delete) ?? 0 > 0 {
                if deselect {
                    records?[i].setValue(0, forKey: DictionaryStrings.select.rawValue)
                } else {
                    records?[i].setValue(1, forKey: DictionaryStrings.select.rawValue)
                }
            }
        }
    }

    private func finalizeandpreparesynchronizelist() {
        guard self.records != nil else { return }
        var quickbackuplist = [Int]()
        var records = [NSMutableDictionary]()
        for i in 0 ..< (self.records?.count ?? 0) {
            if self.records?[i].value(forKey: DictionaryStrings.select.rawValue) as? Int == 1 {
                if let hiddenID = self.records?[i].value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int,
                   let record = self.records?[i]
                {
                    quickbackuplist.append(hiddenID)
                    records.append(record)
                }
            }
        }
        estimatedlistandconfigs = Estimatedlistforsynchronization(quickbackuplist: quickbackuplist, estimatedlist: records)
        SharedReference.shared.estimatedlistforsynchronization = estimatedlistandconfigs
    }

    private func startestimation() {
        guard (stackoftasktobeestimated?.count ?? 0) > 0 else { return }
        if let index = stackoftasktobeestimated?.remove(at: 0).1 {
            self.index = index
            outputprocess = OutputfromProcess()
            startstopProgressIndicatorDelegate?.start()
            let estimation = EstimateremoteInformationOnetask(index: index, outputprocess: outputprocess, local: false, processtermination: processtermination, filehandler: filehandler)
            estimation.startestimation()
        }
    }

    init(viewcontroller: NSViewController, processtermination: @escaping () -> Void) {
        updateviewprocesstermination = processtermination
        startstopProgressIndicatorDelegate = viewcontroller as? StartStopProgressIndicator
        getmultipleselectedindexesDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        prepareandstartexecutetasks()
        records = [NSMutableDictionary]()
        estimatedlistandconfigs = Estimatedlistforsynchronization()
        startestimation()
    }

    deinit {
        self.stackoftasktobeestimated = nil
        self.estimatedlistandconfigs = nil
        // print("deinit RemoteinfoEstimation")
    }

    func abort() {
        stackoftasktobeestimated = nil
        estimatedlistandconfigs = nil
    }
}

extension RemoteinfoEstimation: CountRemoteEstimatingNumberoftasks {
    func maxCount() -> Int {
        return maxnumber ?? 0
    }

    func inprogressCount() -> Int {
        return stackoftasktobeestimated?.count ?? 0
    }
}

extension RemoteinfoEstimation {
    func processtermination() {
        if let index = index {
            let record = RemoteinfonumbersOnetask(outputprocess: outputprocess).record()
            record.setValue(configurations?.getConfigurations()?[index].localCatalog, forKey: DictionaryStrings.localCatalog.rawValue)
            record.setValue(configurations?.getConfigurations()?[index].offsiteCatalog, forKey: DictionaryStrings.offsiteCatalog.rawValue)
            record.setValue(configurations?.getConfigurations()?[index].hiddenID, forKey: DictionaryStrings.hiddenID.rawValue)
            record.setValue(configurations?.getConfigurations()?[index].dayssincelastbackup, forKey: DictionaryStrings.daysID.rawValue)
            if configurations?.getConfigurations()?[index].offsiteServer.isEmpty == true {
                record.setValue(DictionaryStrings.localhost.rawValue, forKey: DictionaryStrings.offsiteServer.rawValue)
            } else {
                record.setValue(configurations?.getConfigurations()?[index].offsiteServer, forKey: DictionaryStrings.offsiteServer.rawValue)
            }
            record.setValue(configurations?.getConfigurations()?[index].task, forKey: DictionaryStrings.task.rawValue)
            records?.append(record)
            estimatedlistandconfigs?.estimatedlist?.append(record)
            guard stackoftasktobeestimated?.count ?? 0 > 0 else {
                selectalltaskswithnumbers(deselect: false)
                startstopProgressIndicatorDelegate?.stop()
                // Prepare tasks with changes for synchronization
                finalizeandpreparesynchronizelist()
                return
            }
            // Update View
            updateviewprocesstermination()
            outputprocess = OutputfromProcessRsync()
            if let nextindex = stackoftasktobeestimated?.remove(at: 0).1 {
                self.index = nextindex
                let estimation = EstimateremoteInformationOnetask(index: nextindex, outputprocess: outputprocess, local: false, processtermination: processtermination, filehandler: filehandler)
                estimation.startestimation()
            }
        }
    }

    func filehandler() {
        weak var outputeverythingDelegate: ViewOutputDetails?
        outputeverythingDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if outputeverythingDelegate?.appendnow() ?? false {
            outputeverythingDelegate?.reloadtable()
        }
    }
}
