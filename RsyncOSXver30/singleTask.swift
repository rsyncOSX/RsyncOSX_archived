//
//  workLoadMain.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 13/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

enum singleWorkTask {
    case estimate_singlerun
    case execute_singlerun
    case abort
    case empty
    case done
}

final class singleTask {

    // Work Queue
    private var work:[singleWorkTask]?
    
    func working() -> singleWorkTask {
        return self.getWork()
    }
    
    
    // Returns the top most element.
    // Top element is removed
    private func getWork() -> singleWorkTask {
        if (self.work != nil) {
            if self.work!.count > 0 {
                return self.work!.removeFirst()
            } else {
                return .empty
            }
        } else {
            return .empty
        }
    }
      
    init() {
        self.work = [singleWorkTask]()
        self.work!.append(.estimate_singlerun)
        self.work!.append(.estimate_singlerun)
        self.work!.append(.execute_singlerun)
        self.work!.append(.execute_singlerun)
        self.work!.append(.done)
    }
    
    init (abort:Bool) {
        self.work = [singleWorkTask]()
        
        if (abort) {
            self.work!.append(.abort)
        }
        
    }
}
