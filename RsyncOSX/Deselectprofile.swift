//
//  Deselectprofile.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 17/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

final class Deselectprofile {

    weak var deselectprofileDelegate: DisableselectProfile?

    init(deselect: Bool) {
        self.deselectprofileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcallprofiles) as? ViewControllerAllProfiles
        guard self.deselectprofileDelegate != nil else { return }
        if deselect {
            self.deselectprofileDelegate?.disableselectprofile()
        } else {
            self.deselectprofileDelegate?.enableselectprofile()
        }
    }
}
