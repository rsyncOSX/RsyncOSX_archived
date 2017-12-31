//
//  RemoteInfoTaskWorkQueue.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 31.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

class RemoteInfoTaskWorkQueue: SetConfigurations {
    // (hiddenID, index)
    typealias Row = (Int, Int)
    var stackoftasktobeestimated: [Row]?
    var outputprocess: OutputProcess?

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
        let index = self.stackoftasktobeestimated?.remove(at: 0).1
        if self.stackoftasktobeestimated?.count == 0 {
            self.stackoftasktobeestimated = nil
        }
        _ = EstimateRemoteInformationTask(index: index!, outputprocess: self.outputprocess)
    }

    func processTermination() {
        let info = RemoteInfoTask(outputprocess: self.outputprocess)
        print(info.info())
        guard self.stackoftasktobeestimated != nil else { return }
        self.outputprocess = nil
        self.outputprocess = OutputProcess()
        let index = self.stackoftasktobeestimated?.remove(at: 0).1
        if self.stackoftasktobeestimated?.count == 0 {
            self.stackoftasktobeestimated = nil
        }
        _ = EstimateRemoteInformationTask(index: index!, outputprocess: self.outputprocess)

    }

    init() {
        self.prepareandstartexecutetasks()
        self.start()
    }
}
