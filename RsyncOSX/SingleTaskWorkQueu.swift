//
//  singleTaskWorkQueu.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 13/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

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
    private var work: [SingleTaskWork]?

    // Returns the top most element.
    // Top element is read only
    func peek() -> SingleTaskWork {
        return self.work?[0] ?? .empty
    }

    // Returns the top most element.
    // Top element is removed
    func pop() -> SingleTaskWork {
        return self.work?.removeFirst() ?? .empty
    }

    // rsync error
    // Pushing error token ontop of stack
    func error() {
        self.work?.insert(.error, at: 0)
    }

    // Single run
    init() {
        self.work = [SingleTaskWork]()
        self.work?.append(.estimatesinglerun)
        self.work?.append(.executesinglerun)
        self.work?.append(.done)
    }
}
