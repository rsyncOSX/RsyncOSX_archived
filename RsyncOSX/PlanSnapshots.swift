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
    private var numberoflogs: Int?
    private var firstlog: Double?

    private func datefromstring(datestring: String) -> Date {
        let dateformatter = Dateandtime().setDateformat()
        return dateformatter.date(from: datestring)!
    }

    init() {
        self.SnapshotsLoggDataDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        self.snapshotsloggdata = self.SnapshotsLoggDataDelegate?.getsnapshotsloggaata()
        guard self.snapshotsloggdata?.snapshotslogs != nil else { return }
        self.numberoflogs = self.snapshotsloggdata?.snapshotslogs?.count ?? 0
        self.firstlog = Double(self.snapshotsloggdata?.snapshotslogs![0].value(forKey: "days") as? String ?? "0")
    }
}
