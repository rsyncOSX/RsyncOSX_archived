//
//  SingleTaskWorkQueu.swift
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
        return work?[0] ?? .empty
    }

    // Returns the top most element.
    // Top element is removed
    func pop() -> SingleTaskWork {
        return work?.removeFirst() ?? .empty
    }

    // rsync error
    // Pushing error token ontop of stack
    func error() {
        work?.insert(.error, at: 0)
    }

    // Single run
    init() {
        work = [SingleTaskWork]()
        work?.append(.estimatesinglerun)
        work?.append(.executesinglerun)
        work?.append(.done)
    }
}
