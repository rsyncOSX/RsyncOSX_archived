//
//  Copyconfigfilestonewhome.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 28/08/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable function_body_length

import Files
import Foundation

struct Copyconfigfilestonewhome: FileErrors {
    var oldpath: String?
    var newpath: String?
    var profilecatalogs: [String]?

    // Move all plistfiles from old profile catalog
    // to new profile catalog.
    func moveplistfilestonewhome() -> Bool {
        if let oldpath = self.oldpath,
            let newpath = self.newpath
        {
            var originFolder: Folder?
            var targetFolder: Folder?

            // root of profile catalog
            do {
                originFolder = try Folder(path: oldpath)
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .profilecreatedirectory)
                return false
            }
            do {
                targetFolder = try Folder(path: newpath)
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .profilecreatedirectory)
                return false
            }
            do {
                if let targetFolder = targetFolder {
                    try originFolder?.files.move(to: targetFolder)
                }
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .profilecreatedirectory)
                return false
            }
            // profile catalogs
            for i in 0 ..< (self.profilecatalogs?.count ?? 0) {
                do {
                    originFolder = try Folder(path: oldpath + "/" + (self.profilecatalogs?[i] ?? ""))
                } catch let e {
                    let error = e as NSError
                    self.error(error: error.description, errortype: .profilecreatedirectory)
                    return false
                }
                do {
                    targetFolder = try Folder(path: newpath + "/" + (self.profilecatalogs?[i] ?? ""))
                } catch let e {
                    let error = e as NSError
                    self.error(error: error.description, errortype: .profilecreatedirectory)
                    return false
                }
                do {
                    if let targetFolder = targetFolder {
                        try originFolder?.files.move(to: targetFolder)
                    }
                } catch let e {
                    let error = e as NSError
                    self.error(error: error.description, errortype: .profilecreatedirectory)
                    return false
                }
            }
            return true
        }
        return false
    }

    // Collect all catalognames from old profile catalog.
    // Profilenames are used to create new profile catalogs
    private func getoldcatalogsasstringnames() -> [String]? {
        if let atpath = self.oldpath {
            var array = [String]()
            do {
                for folders in try Folder(path: atpath).subfolders {
                    array.append(folders.name)
                }
                return array
            } catch {
                return nil
            }
        }
        return nil
    }

    // Create new profile catalogs at new profile root
    // ahead of moving profile files.
    private func createnewprofilecatalogs() {
        var newpath: Folder?
        do {
            newpath = try Folder(path: self.newpath ?? "")
        } catch {
            return
        }
        for i in 0 ..< (self.profilecatalogs?.count ?? 0) {
            do {
                try newpath?.createSubfolder(at: self.profilecatalogs?[i] ?? "")
            } catch {
                return
            }
        }
    }

    init() {
        // Temporary set old path
        ViewControllerReference.shared.usenewconfigpath = false
        self.oldpath = NamesandPaths(profileorsshrootpath: .profileroot).rootpath
        ViewControllerReference.shared.usenewconfigpath = true
        self.newpath = NamesandPaths(profileorsshrootpath: .profileroot).rootpath
        // Catalogs in oldpath
        self.profilecatalogs = self.getoldcatalogsasstringnames()
        // create new subcatalogs
        // self.createnewprofilecatalogs()
        // move files
        // self.moveplistfilestonewhome()
        // ViewControllerReference.shared.usenewconfigpath = false
    }
}
