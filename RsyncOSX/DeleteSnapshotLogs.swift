//
//  DeleteSnapshotLogs.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 04/04/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

final class DeleteSnapshotLogs: SetSchedules {
    var snapshotlogsandcatalogs: Snapshotlogsandcatalogs?

    private func selectednumber() -> String {
        if let number = self.snapshotlogsandcatalogs?.scheduleloggdata?.loggdata?.filter({ ($0.value(forKey: "deleteCellID") as? Int) == 1 }).count {
            return String(number)
        } else {
            return "0"
        }
    }

    init(config: Configuration?) {
        if let config = config {
            self.snapshotlogsandcatalogs = Snapshotlogsandcatalogs(config: config, getsnapshots: true, updateprogress: self)
        }
    }
}

extension DeleteSnapshotLogs: UpdateProgress {
    func processTermination() {
        self.snapshotlogsandcatalogs?.processTermination()
        self.snapshotlogsandcatalogs?.scheduleloggdata?.align(snapshotlogsandcatalogs: self.snapshotlogsandcatalogs)
        guard self.selectednumber() != "0" else { return }
        let question: String = NSLocalizedString("Delete", comment: "Logg")
        let text: String = NSLocalizedString("Cancel or Delete", comment: "Logg")
        let dialog: String = NSLocalizedString("Delete", comment: "Logg")
        let answer = Alerts.dialogOrCancel(question: question + " " + self.selectednumber() + " logrecords?", text: text, dialog: dialog)
        if answer {
            self.schedules?.deleteselectedrows(scheduleloggdata: self.snapshotlogsandcatalogs?.scheduleloggdata)
        }
    }

    func fileHandler() {
        //
    }
}
