//
//  Fileerrors.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 21.11.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

enum Fileerrortype {
    case openlogfile
    case writelogfile
    case profilecreatedirectory
    case profiledeletedirectory
}

// Protocol for reporting file errors
protocol Fileerror: class {
    func fileerror(errorstr: String, errortype: Fileerrortype)
}

protocol Reportfileerror {
    weak var errorDelegate: Fileerror? { get }
}

extension Reportfileerror {
    weak var errorDelegate: Fileerror? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }

    func error(error: String, errortype: Fileerrortype) {
        self.errorDelegate?.fileerror(errorstr: error, errortype: errortype)
    }
}

class Filerrors {

    private var errortype: Fileerrortype

    func errordescription() -> String {
        switch self.errortype {
        case .openlogfile:
            guard ViewControllerReference.shared.fileURL != nil else {
                return "No existing logfile, creating a new one"
            }
            return "No existing logfile, creating a new one: " + String(describing: ViewControllerReference.shared.fileURL!)
        case .writelogfile:
            return "Could not write to logfile"
        case .profilecreatedirectory:
            return "Could not create profile directory"
        case .profiledeletedirectory:
            return "Could not delete profile directory"
        }
     }

    init(errortype: Fileerrortype) {
        self.errortype = errortype
    }
}
