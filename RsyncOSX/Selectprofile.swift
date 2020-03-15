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
    weak var loggdataProfileDelegate: NewProfile?
    weak var restoreProfileDelegate: NewProfile?

    init(profile: String?, selectedindex: Int?) {
        weak var getprocess: GetProcessreference?
        getprocess = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        guard getprocess?.getprocessreference() == nil else { return }
        self.profile = profile
        self.newProfileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.snapshotnewProfileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        self.loggdataProfileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
        self.restoreProfileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
        if self.profile == NSLocalizedString("Default profile", comment: "default profile") {
            newProfileDelegate?.newProfile(profile: nil, selectedindex: selectedindex)
        } else {
            newProfileDelegate?.newProfile(profile: self.profile, selectedindex: selectedindex)
        }
        self.snapshotnewProfileDelegate?.newProfile(profile: nil, selectedindex: selectedindex)
        self.loggdataProfileDelegate?.newProfile(profile: nil, selectedindex: selectedindex)
        self.restoreProfileDelegate?.newProfile(profile: nil, selectedindex: selectedindex)
    }
}
