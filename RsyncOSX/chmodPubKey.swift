//
//  ChmodPubKey.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 17.06.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

enum chmodTask {
    case chmodRsa
    case chmodDsa
    case empty
}

final class chmodPubKey {
    
    // Work Queue
    private var work:Array<chmodTask>?
    
    // Returns the top most element.
    // Top element is read only
    func peek() -> chmodTask {
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
    func pop() -> chmodTask {
        guard self.work != nil else {
            return .empty
        }
        guard self.work!.count > 0 else {
            return .empty
        }
        return self.work!.removeFirst()
    }
    
    // Single run
    init(key:String) {
        self.work = nil
        self.work = Array<chmodTask>()
        switch key {
        case "rsa":
            self.work!.append(.chmodRsa)
        case "dsa":
            self.work!.append(.chmodDsa)
        default:
            self.work = nil
            break
        }
    }
}
