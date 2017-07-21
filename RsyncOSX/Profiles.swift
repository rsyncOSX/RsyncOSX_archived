//
//  profiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 17/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//swiftlint:disable line_length

import Foundation

class Profiles: Files {

    // Delegate for reporting file error if any to main view
    weak var errorDelegate: ReportErrorInMain?

    // Function for creating new profile directory
    func createProfile(profileName: String) {
        let fileManager = FileManager.default
        if let path = self.rootfiles {
            let profileDirectory = path + "/" + profileName
            if fileManager.fileExists(atPath: profileDirectory) == false {
                do {
                    try fileManager.createDirectory(atPath: profileDirectory, withIntermediateDirectories: true, attributes: nil)} catch let e {
                    let error = e as NSError
                    self.reportError(errorstr: error.description)
                }
            }
        }
    }

    // Function for deleting profile
    // if let path = URL.init(string: profileDirectory) {
    func deleteProfile(profileName: String) {
        let fileManager = FileManager.default
        if let path = self.rootfiles {
            let profileDirectory = path + "/" + profileName
            if fileManager.fileExists(atPath: profileDirectory) == true {
                let answer = Alerts.dialogOKCancel("Delete profile: " + profileName + "?", text: "Cancel or OK")
                if answer {
                    do {
                        try fileManager.removeItem(atPath: profileDirectory)} catch let e {
                        let error = e as NSError
                        self.reportError(errorstr: error.description)
                    }
                }
            }
        }
    }

    init () {
        super.init(root: .profileRoot)
    }
}

extension Profiles: ReportError {
    // Private func for propagating any file error to main view
    func reportError(errorstr: String) {
        if let pvc = Configurations.shared.viewControllertabMain {
            self.errorDelegate = pvc as? ViewControllertabMain
            self.errorDelegate?.fileerror(errorstr: errorstr)
        }
    }

}
