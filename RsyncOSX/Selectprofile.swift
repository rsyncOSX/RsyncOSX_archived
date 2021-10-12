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
    weak var newProfileDelegate: NewProfile?

    init(profile: String?, selectedindex: Int?) {
        newProfileDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if profile == NSLocalizedString("Default profile", comment: "default profile") {
            newProfileDelegate?.newprofile(profile: nil, selectedindex: selectedindex)
        } else {
            newProfileDelegate?.newprofile(profile: profile, selectedindex: selectedindex)
        }
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
