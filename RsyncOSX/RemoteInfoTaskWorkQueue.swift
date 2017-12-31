//
//  RemoteInfoTaskWorkQueue.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 31.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

class RemoteInfoTaskWorkQueue: SetConfigurations {
    // (index, hiddenID)
    typealias Row = (Int, Int)
    var stackoftasktobeestimated: [Row]?
    
    private func prepareandstartexecutetasks() {
        self.stackoftasktobeestimated = nil
        self.stackoftasktobeestimated = [Row]()
        for i in 0 ..< self.configurations!.getConfigurations().count {
            if self.configurations!.getConfigurations()[i].task == "backup" {
                self.stackoftasktobeestimated?.append((i, self.configurations!.getConfigurations()[i].hiddenID))
            }
        }
    }

    func processTermination() {
        
    }
    
    init() {
        self.prepareandstartexecutetasks()
    }
}
