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
    case done
    case empty
}

class workLoadMain {

    // Work Queue
    private var work:[workMain]?
    
    func abort() {
        self.work = nil
    }
    
    
    func working() -> workMain {
        let work = self.getWork()
        print("Next work is :" + "\(work)")
        print("Rest of work queue is :" + "\(self.work)")
        return work
    }
    
    // Returns the top most element.
    // Top element is removed
    private func getWork() -> workMain {
        if (self.work != nil) {
            if self.work!.count > 1 {
                return self.work!.removeFirst()
            } else {
                return .empty
            }
        } else {
            return .empty
        }
    }
    
    init(singlerun:Bool, number:Int?) {
        
        self.work = [workMain]()
        
        switch singlerun {
        case true:
            self.work!.append(.estimate_singlerun)
            self.work!.append(.execute_singlerun)
            self.work!.append(.logRunDate)
            self.work!.append(.done)
            
        case false:
            if number != nil {
                for _ in 0 ..< number! {
                    self.work!.append(.estimate_batch)
                    self.work!.append(.execute_batch)
                    self.work!.append(.logRunDate)
                }
                self.work!.append(.done)
            }
            
        }
        
    }
}
