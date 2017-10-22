//
//  OperationFactory.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

enum OperationObject {
    case timer
    case dispatch
}
class OperationFactory {

    private var factory: OperationObject?
    var operationTimer: ScheduleOperationTimer?
    var operationDispatch: ScheduleOperationDispatch?

    func initiate() {
        switch self.factory! {
        case .timer:
            self.operationTimer = ScheduleOperationTimer()
            self.operationTimer?.initiate()
        case .dispatch:
            self.operationDispatch = ScheduleOperationDispatch()
            self.operationDispatch?.initiate()
        }
    }

    init(factory: OperationObject) {
        self.factory = factory
    }
}
