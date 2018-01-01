//
//  RemoteInfoTaskWorkQueue.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 31.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

protocol SetRemoteInfo: class {
    func setremoteinfo(remoteinfotask: RemoteInfoTaskWorkQueue?)
}

class RemoteInfoTaskWorkQueue: SetConfigurations {
    // (hiddenID, index)
    typealias Row = (Int, Int)
    var stackoftasktobeestimated: [Row]?
    var outputprocess: OutputProcess?
    var records: [NSMutableDictionary]?
    weak var reloadtableDelegate: UpdateProgress?
    var index: Int?

    private func prepareandstartexecutetasks() {
        self.stackoftasktobeestimated = nil
        self.stackoftasktobeestimated = [Row]()
        for i in 0 ..< self.configurations!.getConfigurations().count {
            if self.configurations!.getConfigurations()[i].task == "backup" {
                self.stackoftasktobeestimated?.append((self.configurations!.getConfigurations()[i].hiddenID, i))
            }
        }
    }

    private func start() {
        self.outputprocess = OutputProcess()
        self.index = self.stackoftasktobeestimated?.remove(at: 0).1
        if self.stackoftasktobeestimated?.count == 0 {
            self.stackoftasktobeestimated = nil
        }
        _ = EstimateRemoteInformationTask(index: self.index!, outputprocess: self.outputprocess)
    }

    func processTermination() {
        let record = RemoteInfoTask(outputprocess: self.outputprocess).record()
        record.setValue(self.configurations?.getConfigurations()[self.index!].localCatalog, forKey: "localCatalog")
        record.setValue(self.configurations?.getConfigurations()[self.index!].offsiteCatalog, forKey: "offsiteCatalog")
        record.setValue(self.configurations?.getConfigurations()[self.index!].offsiteServer, forKey: "offsiteServer")
        self.records?.append(record)
        self.reloadtableDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcremoteinfo) as? ViewControllerRemoteInfo
        self.reloadtableDelegate?.processTermination()
        guard self.stackoftasktobeestimated != nil else { return }
        self.outputprocess = nil
        self.outputprocess = OutputProcess()
        self.index = self.stackoftasktobeestimated?.remove(at: 0).1
        if self.stackoftasktobeestimated?.count == 0 {
            self.stackoftasktobeestimated = nil
        }
        _ = EstimateRemoteInformationTask(index: self.index!, outputprocess: self.outputprocess)
    }

    init() {
        self.prepareandstartexecutetasks()
        self.records = [NSMutableDictionary]()
        self.start()
    }
}
