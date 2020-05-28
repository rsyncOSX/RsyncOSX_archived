//
//  ChmodPubKey.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 17.06.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

enum ChmodTask {
    case chmodRsa
    case empty
}

final class ChmodPubKey {
    // Work Queue
    private var work: [ChmodTask]?

    // Returns the top most element.
    // Top element is read only
    func peek() -> ChmodTask {
        guard (self.work?.count ?? 0) > 0 else { return .empty }
        return self.work?[0] ?? .empty
    }

    // Returns the top most element.
    // Top element is removed
    func pop() -> ChmodTask {
        guard (self.work?.count ?? 0) > 0 else { return .empty }
        return self.work?.removeFirst() ?? .empty
    }

    // Single run
    init() {
        self.work = nil
        self.work = [ChmodTask]()
        self.work?.append(.chmodRsa)
    }
}
