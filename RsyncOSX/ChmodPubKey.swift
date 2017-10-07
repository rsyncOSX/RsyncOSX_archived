//
//  ChmodPubKey.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 17.06.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

enum ChmodTask {
    case chmodRsa
    case chmodDsa
    case empty
}

final class ChmodPubKey {

    // Work Queue
    private var work: Array<ChmodTask>?

    // Returns the top most element.
    // Top element is read only
    func peek() -> ChmodTask {
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
    func pop() -> ChmodTask {
        guard self.work != nil else {
            return .empty
        }
        guard self.work!.count > 0 else {
            return .empty
        }
        return self.work!.removeFirst()
    }

    // Single run
    init(key: String) {
        self.work = nil
        self.work = Array<ChmodTask>()
        switch key {
        case "rsa":
            self.work!.append(.chmodRsa)
        case "dsa":
            self.work!.append(.chmodDsa)
        default:
            self.work = nil
        }
    }
}
