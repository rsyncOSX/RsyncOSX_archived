//
//  singleTaskWorkQueu.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 13/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

enum SingleTaskWork {
    case estimatesinglerun
    case executesinglerun
    case abort
    case empty
    case done
    case error
}

final class SingleTaskWorkQueu {

    // Work Queue
    private var work: Array<SingleTaskWork>?

    // Returns the top most element.
    // Top element is read only
    func peek() -> SingleTaskWork {
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
    func pop() -> SingleTaskWork {
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
        self.work = Array<SingleTaskWork>()
        self.work!.append(.estimatesinglerun)
        self.work!.append(.executesinglerun)
        self.work!.append(.done)
    }

    // Either Abort or Batchrun
    init (task: SingleTaskWork) {
        self.work = nil
        self.work = Array<SingleTaskWork>()
        self.work!.append(task)
    }
}
