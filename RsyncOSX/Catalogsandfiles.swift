//
//  files.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Files
import Foundation

enum Fileerrortype {
    case writelogfile
    case profilecreatedirectory
    case profiledeletedirectory
    case filesize
}

// Protocol for reporting file errors
protocol Fileerror: AnyObject {
    func errormessage(errorstr: String, errortype: Fileerrortype)
}

protocol FileErrors {
    var errorDelegate: Fileerror? { get }
}

extension FileErrors {
    var errorDelegate: Fileerror? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    func error(error: String, errortype: Fileerrortype) {
        self.errorDelegate?.errormessage(errorstr: error, errortype: errortype)
    }
}

protocol ErrorMessage {
    func errordescription(errortype: Fileerrortype) -> String
}

extension ErrorMessage {
    func errordescription(errortype: Fileerrortype) -> String {
        switch errortype {
        case .writelogfile:
            return "Could not write to logfile"
        case .profilecreatedirectory:
            return "Could not create profile directory"
        case .profiledeletedirectory:
            return "Could not delete profile directory"
        case .filesize:
            return "Filesize of logfile is getting bigger"
        }
    }
}

class Catalogsandfiles: NamesandPaths, FileErrors {
    func getcatalogsasURLnames() -> [URL]? {
        if let atpath = self.rootpath {
            do {
                var array = [URL]()
                for file in try Folder(path: atpath).files {
                    array.append(file.url)
                }
                return array
            } catch {
                return nil
            }
        }
        return nil
    }

    func getfilesasstringnames() -> [String]? {
        if let atpath = self.rootpath {
            do {
                var array = [String]()
                for file in try Folder(path: atpath).files {
                    array.append(file.name)
                }
                return array
            } catch {
                return nil
            }
        }
        return nil
    }

    func getcatalogsasstringnames() -> [String]? {
        if let atpath = self.rootpath {
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

    // Create profile catalog
    func createprofilecatalog() {
        var root: Folder?
        var catalog: String?
        // First check if profilecatalog exists, if yes bail out
        if let serial = self.macserialnumber,
            let barerootpath = self.barerootpath
        {
            do {
                let pathexists = try Folder(path: barerootpath).containsSubfolder(named: serial)
                guard pathexists == false else { return }
            } catch {
                // if fails then create profile catalogs
                // Creating profile catalalog is a two step task
                // 1: create profilecatalog
                // 2: create profilecatalog/macserialnumber
                if ViewControllerReference.shared.usenewconfigpath {
                    catalog = ViewControllerReference.shared.newconfigpath
                    root = Folder.home
                    do {
                        try root?.createSubfolder(at: catalog ?? "")
                    } catch {
                        return
                    }
                } else {
                    catalog = ViewControllerReference.shared.configpath
                    root = Folder.documents
                    do {
                        try root?.createSubfolder(at: catalog ?? "")
                    } catch {
                        return
                    }
                }
                if let serial = self.macserialnumber,
                    let barerootpath = self.barerootpath
                {
                    do {
                        try Folder(path: barerootpath).createSubfolder(at: serial)
                    } catch {
                        return
                    }
                }
            }
        }
    }

    // Create SSH catalog
    func createsshcatalog() {
        if let path = self.sshkeyrootpath {
            let root = Folder.home
            guard root.containsSubfolder(named: path) == false else { return }
            do {
                try root.createSubfolder(at: path)
            } catch {}
        }
    }

    override init(profileorsshrootpath whichroot: Profileorsshrootpath) {
        super.init(profileorsshrootpath: whichroot)
    }
}
