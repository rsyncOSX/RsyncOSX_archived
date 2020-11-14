//
//  extensionsSchedules.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 25.08.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

protocol SetSchedules {
    var schedulesDelegate: GetSchedulesObject? { get }
}

extension SetSchedules {
    var schedulesDelegate: GetSchedulesObject? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    var schedules: Schedules? {
        return self.schedulesDelegate?.getschedulesobject()
    }
}

// Protocol for returning object configurations data
protocol GetSchedulesObject: AnyObject {
    func getschedulesobject() -> Schedules?
    func reloadschedulesobject()
}

enum Scheduletype: String {
    case once
    case daily
    case weekly
    case manuel
    case stopped
}
