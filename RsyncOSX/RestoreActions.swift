//
//  RestoreActions.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 04/12/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

struct RestoreActions {
    // Restore to tmp restorepath selected and verified
    var tmprestorepathverified: Bool = false
    var tmprestorepathselected: Bool = true
    // Index for restore selected
    var index: Bool = false
    // Estimated
    var estimated: Bool = false
    // Type of restore
    var fullrestore: Bool = false
    var restorefiles: Bool = false
    // Remote file if restore files
    var remotefileverified: Bool = false
    // Do the real thing
    var executerealrestore: Bool = false

    init(closure: () -> Bool) {
        self.tmprestorepathverified = closure()
    }

    func goforfullrestoretotemporarypath() -> Bool {
        guard self.tmprestorepathverified, self.tmprestorepathselected, self.index, self.estimated, self.fullrestore else { return false }
        return true
    }

    func goforrestorefilestotemporarypath() -> Bool {
        guard self.tmprestorepathverified, self.tmprestorepathselected, self.index, self.estimated, self.restorefiles, self.remotefileverified else { return false }
        return true
    }

    func goforfullrestoreestimatetemporarypath() -> Bool {
        guard self.tmprestorepathverified, self.tmprestorepathselected, self.index, self.estimated == false, self.fullrestore else { return false }
        return true
    }

    func getfilelistrestorefiles() -> Bool {
        guard self.index, self.estimated == false, self.restorefiles else { return false }
        return true
    }

    func reset() -> Bool {
        var reset = false
        if self.goforfullrestoretotemporarypath() == true {
            reset = true
        }
        if self.goforrestorefilestotemporarypath() == true {
            reset = true
        }
        return reset
    }
}
