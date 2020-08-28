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

    private func moveplistfilestonewhome() {
        if let oldpath = self.oldpath {
            if let newpath = self.newpath {
                var originFolder: Folder?
                var targetFolder: Folder?

                // Root
                print("root")
                do {
                    originFolder = try Folder(path: oldpath)
                } catch let e {
                    let error = e as NSError
                    self.error(error: error.description, errortype: .profilecreatedirectory)
                    return
                }
                do {
                    targetFolder = try Folder(path: newpath)
                } catch let e {
                    let error = e as NSError
                    self.error(error: error.description, errortype: .profilecreatedirectory)
                    return
                }
                do {
                    if let targetFolder = targetFolder {
                        print(originFolder?.description ?? "")
                        print(targetFolder.description)
                        // try originFolder?.files.move(to: targetFolder)
                    }
                } catch let e {
                    let error = e as NSError
                    self.error(error: error.description, errortype: .profilecreatedirectory)
                    return
                }
                // Catalogs
                print("catalogs")
                for i in 0 ..< (self.profilecatalogs?.count ?? 0) {
                    do {
                        originFolder = try Folder(path: oldpath + "/" + (self.profilecatalogs?[i] ?? ""))
                    } catch let e {
                        let error = e as NSError
                        self.error(error: error.description, errortype: .profilecreatedirectory)
                        return
                    }
                    do {
                        targetFolder = try Folder(path: newpath + "/" + (self.profilecatalogs?[i] ?? ""))
                    } catch let e {
                        let error = e as NSError
                        self.error(error: error.description, errortype: .profilecreatedirectory)
                        return
                    }
                    do {
                        if let targetFolder = targetFolder {
                            print(originFolder?.description ?? "")
                            print(targetFolder.description)
                            // try originFolder?.files.move(to: targetFolder)
                        }
                    } catch let e {
                        let error = e as NSError
                        self.error(error: error.description, errortype: .profilecreatedirectory)
                        return
                    }
                }
            }
        }
    }

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

    private func createnewpaths() {
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
        self.createnewpaths()
        // move files
        self.moveplistfilestonewhome()
        ViewControllerReference.shared.usenewconfigpath = false
    }
}
