//
//  workLoadMain.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 13/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

enum workMain {
    case estimate_singlerun
    case execute_singlerun
    case logRunDate
    case abort
    case estimate_batch
    case execute_batch
    case empty
    case done
}

class workLoadMain {

    // Work Queue
    private var work:[workMain]?
    
    func abort() {
        self.work = nil
    }
    
    
    func working() -> workMain {
        let work = self.getWork()
        print("WORK       :" + "\(work)")
        print("WORK QUEUE :" + "\(self.work!)")
        return work
    }
    
    
    // Returns the top most element.
    // Top element is removed
    private func getWork() -> workMain {
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
        self.work = [workMain]()
        self.work!.append(.estimate_singlerun)
        self.work!.append(.estimate_singlerun)
        self.work!.append(.execute_singlerun)
        self.work!.append(.execute_singlerun)
        self.work!.append(.done)
    }
    
    init (abort:Bool) {
        self.work = [workMain]()
        
        if (abort) {
            self.work!.append(.abort)
        }
        
    }
}
