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
    private var work:Array<singleWorkTask>?
    
    // Returns the top most element.
    // Top element is read only
    func peek() -> singleWorkTask {
        guard self.work != nil else {
            return .empty
        }
        guard self.work!.count > 0 else {
            return .empty
        }
        return self.work![0]
    }
    
    // Returns the top most element.
    // Top element is removed
    func pop() -> singleWorkTask {
        guard self.work != nil else {
            return .empty
        }
        guard self.work!.count > 0 else {
            return .empty
        }
        return self.work!.removeFirst()
    }
    
    // rsync error
    // Pushing error token ontop of stack
    func error() {
        guard self.work != nil else {
            return
        }
        self.work!.insert(.error, at: 0)
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
