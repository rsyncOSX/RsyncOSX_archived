//
//  ExecuteTaskTimerMocup.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 19/08/2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

class ExecuteTaskTimerMocup: Operation {
    override func main() {
        weak var reloadDelegate: Reloadsortedandrefresh?
        reloadDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        reloadDelegate?.reloadsortedandrefreshtabledata()
        _ = Alerts.showInfo("Timer - scheduled task is executed, reload configuration...")
    }
}
