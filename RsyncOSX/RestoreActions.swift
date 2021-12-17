//
//  RestoreActions.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 04/12/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

struct RestoreActions {
    // Restore to tmp restorepath selected and verified
    var tmprestorepathverified: Bool = false
    var tmprestorepathselected: Bool = true
    // Index for restore selected
    var index: Bool = false
    // Estimated
    var estimated: Bool = false
    var restorefiles: Bool = false
    // Remote file if restore files
    var remotefileverified: Bool = false

    init(closure: () -> Bool) {
        tmprestorepathverified = closure()
    }

    func goforrestorefilestotemporarypath() -> Bool {
        guard tmprestorepathverified, tmprestorepathselected, index, estimated, restorefiles, remotefileverified else { return false }
        return true
    }

    func getfilelistrestorefiles() -> Bool {
        guard index, estimated == false, restorefiles else { return false }
        return true
    }

    func reset() -> Bool {
        var reset = false
        if goforrestorefilestotemporarypath() == true {
            reset = true
        }
        return reset
    }
}
