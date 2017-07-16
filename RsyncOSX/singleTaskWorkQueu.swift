//
//  singleTaskWorkQueu.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 13/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

enum singleTaskWork {
    case estimate_singlerun
    case execute_singlerun
    case abort
    case empty
    case done
    case error
}

final class singleTaskWorkQueu {

    // Work Queue
    private var work: Array<singleTaskWork>?

    // Returns the top most element.
    // Top element is read only
    func peek() -> singleTaskWork {
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
    func pop() -> singleTaskWork {
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
        self.work = Array<singleTaskWork>()
        self.work!.append(.estimate_singlerun)
        self.work!.append(.execute_singlerun)
        self.work!.append(.done)
    }

    // Either Abort or Batchrun
    init (task: singleTaskWork) {
        self.work = nil
        self.work = Array<singleTaskWork>()
        self.work!.append(task)
    }
}
