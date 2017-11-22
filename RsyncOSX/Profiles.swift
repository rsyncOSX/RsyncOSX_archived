//
//  profiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 17/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

class Profiles: Files {

    // Function for creating new profile directory
    func createProfile(profileName: String) -> Bool {
        let fileManager = FileManager.default
        if let path = self.rootpath {
            let profileDirectory = path + "/" + profileName
            if fileManager.fileExists(atPath: profileDirectory) == false {
                do {
                    try fileManager.createDirectory(atPath: profileDirectory,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                    return true
                } catch let e {
                    let error = e as NSError
                    self.error(error: error.description, errortype: .profilecreatedirectory)
                    return false
                }
            } else {
                return false
            }
        }
        return false
    }

    // Function for deleting profile
    // if let path = URL.init(string: profileDirectory) {
    func deleteProfile(profileName: String) {
        let fileManager = FileManager.default
        if let path = self.rootpath {
            let profileDirectory = path + "/" + profileName
            if fileManager.fileExists(atPath: profileDirectory) == true {
                let answer = Alerts.dialogOKCancel("Delete profile: " + profileName + "?", text: "Cancel or OK")
                if answer {
                    do {
                        try fileManager.removeItem(atPath: profileDirectory)
                    } catch let e {
                        let error = e as NSError
                        self.error(error: error.description, errortype: .profiledeletedirectory)
                    }
                }
            }
        }
    }

    init () {
        super.init(root: .profileRoot)
    }
}
