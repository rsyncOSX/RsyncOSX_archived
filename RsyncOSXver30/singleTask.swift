//
//  singleTask.swift
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
    case batchrun
    case error
}

final class singleTask {

    // Work Queue
    private var work:[singleWorkTask]?
    
    // Returns the top most element.
    // Top element is read only
    func peek() -> singleWorkTask {
        if (self.work != nil) {
            if self.work!.count > 0 {
                return self.work![0]
            } else {
                return .empty
            }
        } else {
            return .empty
        }
    }
    
    // Returns the top most element.
    // Top element is removed
    func pop() -> singleWorkTask {
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
    
    // rsync error
    // Pushing error token ontop of stack
    func error() {
        if (self.work != nil) {
            self.work!.insert(.error, at: 0)
        }
    }
    
    // Single run
    init() {
        self.work = nil
        self.work = Array<singleWorkTask>()
        self.work!.append(.estimate_singlerun)
        self.work!.append(.execute_singlerun)
        self.work!.append(.done)
    }
    
    // Either Abort or Batchrun
    init (task:singleWorkTask) {
        self.work = nil
        self.work = Array<singleWorkTask>()
        self.work!.append(task)
    }
}
