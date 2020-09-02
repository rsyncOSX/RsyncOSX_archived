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
        if let atpath = self.fullroot {
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
        if let atpath = self.fullroot {
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
        if let atpath = self.fullroot {
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

    // Create profile catalog at first start of RsyncOSX.
    // If profile catalog exists - bail out, no need to create
    func createrootprofilecatalog() {
        var root: Folder?
        var catalog: String?
        // First check if profilecatalog exists, if yes bail out
        if let macserialnumber = self.macserialnumber,
            let fullrootnomacserial = self.fullrootnomacserial
        {
            do {
                let pathexists = try Folder(path: fullrootnomacserial).containsSubfolder(named: macserialnumber)
                guard pathexists == false else { return }
            } catch {
                // if fails then create profile catalogs
                // Creating profile catalalog is a two step task
                // 1: create profilecatalog
                // 2: create profilecatalog/macserialnumber
                // New config path (/.rsyncosx)
                if ViewControllerReference.shared.usenewconfigpath {
                    catalog = ViewControllerReference.shared.newconfigpath
                    root = Folder.home
                    do {
                        try root?.createSubfolder(at: catalog ?? "")
                    } catch {
                        return
                    }
                } else {
                    // Old configpath (Rsync)
                    catalog = ViewControllerReference.shared.configpath
                    root = Folder.documents
                    do {
                        try root?.createSubfolder(at: catalog ?? "")
                    } catch {
                        return
                    }
                }
                if let macserialnumber = self.macserialnumber,
                    let fullrootnomacserial = self.fullrootnomacserial
                {
                    do {
                        try Folder(path: fullrootnomacserial).createSubfolder(at: macserialnumber)
                    } catch {
                        return
                    }
                }
            }
        }
    }

    // Create SSH catalog
    // If ssh catalog exists - bail out, no need
    // to create
    func createsshkeyrootpath() {
        if let path = self.onlysshkeypath {
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
