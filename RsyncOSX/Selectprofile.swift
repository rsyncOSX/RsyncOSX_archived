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
    weak var copyfilesnewProfileDelegate: NewProfile?

    init(profile: String?) {
        self.profile = profile
        self.newProfileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.snapshotnewProfileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        self.copyfilesnewProfileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vccopyfiles) as? ViewControllerCopyFiles
        if self.profile == NSLocalizedString("Default profile", comment: "default profile") {
            newProfileDelegate?.newProfile(profile: nil)
        } else {
            newProfileDelegate?.newProfile(profile: self.profile)
        }
        self.snapshotnewProfileDelegate?.newProfile(profile: nil)
        self.copyfilesnewProfileDelegate?.newProfile(profile: nil)
    }

}
