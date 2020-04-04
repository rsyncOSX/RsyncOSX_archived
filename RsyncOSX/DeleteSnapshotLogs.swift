//
//  DeleteSnapshotLogs.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 04/04/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

class DeleteSnapshotLogs {
    var snapshotlogsandcatalogs: Snapshotlogsandcatalogs?

    init(config: Configuration?) {
        if let config = config {
            self.snapshotlogsandcatalogs = Snapshotlogsandcatalogs(config: config, getsnapshots: true, updateprogress: self)
            // scheduleloggdata.align to mark
        }
    }
}

extension DeleteSnapshotLogs: UpdateProgress {
    func processTermination() {
        self.snapshotlogsandcatalogs?.scheduleloggdata?.align(snapshotlogsandcatalogs: self.snapshotlogsandcatalogs)
    }

    func fileHandler() {
        //
    }
}
