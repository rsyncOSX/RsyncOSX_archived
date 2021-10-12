//
//  Selectprofile.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 16/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

final class Selectprofile {
    var profile: String?
    weak var newProfileDelegate: NewProfile?
    weak var snapshotnewProfileDelegate: NewProfile?
    weak var scheduleProfileDelegate: NewProfile?
    weak var restoreProfileDelegate: NewProfile?

    init(profile: String?, selectedindex: Int?) {
        self.profile = profile
        newProfileDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        snapshotnewProfileDelegate = SharedReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        scheduleProfileDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllerSchedule
        restoreProfileDelegate = SharedReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
        if self.profile == NSLocalizedString("Default profile", comment: "default profile") {
            newProfileDelegate?.newprofile(profile: nil, selectedindex: selectedindex)
        } else {
            newProfileDelegate?.newprofile(profile: self.profile, selectedindex: selectedindex)
        }
        snapshotnewProfileDelegate?.newprofile(profile: nil, selectedindex: selectedindex)
        scheduleProfileDelegate?.newprofile(profile: nil, selectedindex: selectedindex)
        restoreProfileDelegate?.newprofile(profile: nil, selectedindex: selectedindex)
        // Close edit and parameters view if open
        if let view = SharedReference.shared.getvcref(viewcontroller: .vcrsyncparameters) as? ViewControllerRsyncParameters {
            weak var closeview: ViewControllerRsyncParameters?
            closeview = view
            closeview?.closeview()
        }
        if let view = SharedReference.shared.getvcref(viewcontroller: .vcedit) as? ViewControllerEdit {
            weak var closeview: ViewControllerEdit?
            closeview = view
            closeview?.closeview()
        }
    }
}
