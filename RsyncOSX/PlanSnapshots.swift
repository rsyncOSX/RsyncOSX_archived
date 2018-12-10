//
//  PlanSnapshots.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

protocol GetSnapshotsLoggData: class {
    func getsnapshotsloggaata() -> SnapshotsLoggData?
}

class PlanSnapshots {

    weak var SnapshotsLoggDataDelegate: GetSnapshotsLoggData?
    var snapshotsloggdata: SnapshotsLoggData?

    // 1 - 7 days
    private func currentweek(offsetcurrentweek: Int) {
        
    }
    
    // 8 - 28/29/30/31 days
    private func currentmonth(offsetcurrentmonth: Int) {
        
    }

    // 31 - 365 days
    private func currentyear(offsetlastyear: Int) {
        
    }

    // 365 days
    private func previousyears(offsett: Int) {
        
    }

    init() {
        self.SnapshotsLoggDataDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        self.snapshotsloggdata = self.SnapshotsLoggDataDelegate?.getsnapshotsloggaata()
    }
}
