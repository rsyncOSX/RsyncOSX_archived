//
//  Backupconfigfiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Files
import Foundation

struct Backupconfigfiles: FileErrors {
    var usedpath: String?
    var backuppath: String?

    func backup() {
        if let documentscatalog = self.backuppath,
            let usedpath = self.usedpath
        {
            var originFolder: Folder?
            do {
                originFolder = try Folder(path: usedpath)
                let targetpath = "RsyncOSXcopy-" + Date().shortlocalized_string_from_date()
                let targetFolder = try Folder(path: documentscatalog).createSubfolder(at: targetpath)
                try originFolder?.copy(to: targetFolder)
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .profilecreatedirectory)
            }
        }
    }

    init() {
        let path = NamesandPaths(profileorsshrootpath: .profileroot)
        self.usedpath = path.fullrootnomacserial
        self.backuppath = path.documentscatalog
        self.backup()
    }
}
