//
//  files.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Files
import Foundation

enum Result<Value, Error: Swift.Error> {
    case success(Value)
    case failure(Error)
}

// typealias HandlerRsyncOSX = (Result<Data, RsyncOSXTypeErrors>) -> Void
// typealias Handler = (Result<Data, Error>) -> Void
typealias HandlerNSNumber = (Result<NSNumber, Error>) -> Void

extension Result {
    func get() throws -> Value {
        switch self {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        }
    }
}

enum RsyncOSXTypeErrors: LocalizedError {
    case writelogfile
    case profilecreatedirectory
    case profiledeletedirectory
    case logfilesize
    case createsshdirectory
    case combine
    case emptylogfile
    case readerror
    case rsyncerror

    var errorDescription: String? {
        switch self {
        case .writelogfile:
            return "Error writing to logfile"
        case .profilecreatedirectory:
            return "Error in creating profile directory"
        case .profiledeletedirectory:
            return "Error in delete profile directory"
        case .logfilesize:
            return "Error filesize logfile, is getting bigger"
        case .createsshdirectory:
            return "Error in creating ssh directory"
        case .combine:
            return "Error in Combine"
        case .emptylogfile:
            return "Error empty logfile"
        case .readerror:
            return "Some error trying to read a file"
        case .rsyncerror:
            return NSLocalizedString("There are errors in output", comment: "rsync error")
        }
    }
}

// Protocol for reporting file errors
protocol ErrorMessage: AnyObject {
    func errormessage(errorstr: String, error: RsyncOSXTypeErrors)
}

protocol Errors {
    var errorDelegate: ErrorMessage? { get }
}

extension Errors {
    var errorDelegate: ErrorMessage? {
        return SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    func error(errordescription: String, errortype: RsyncOSXTypeErrors) {
        errorDelegate?.errormessage(errorstr: errordescription, error: errortype)
    }
}

class Catalogsandfiles: NamesandPaths {
    func getfilesasstringnames() -> [String]? {
        if let atpath = fullpathmacserial {
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
        if let atpath = fullpathmacserial {
            var array = [String]()
            // Append default profile
            array.append(NSLocalizedString("Default profile", comment: "default profile"))
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
           let fullrootnomacserial = fullpathnomacserial
        {
            do {
                let pathexists = try Folder(path: fullrootnomacserial).containsSubfolder(named: macserialnumber)
                guard pathexists == false else { return }
            } catch {
                // if fails then create profile catalogs
                // Creating profile catalalog is a two step task
                // 1: create profilecatalog
                // 2: create profilecatalog/macserialnumber
                // config path (/.rsyncosx)
                catalog = SharedReference.shared.configpath
                root = Folder.home
                do {
                    try root?.createSubfolder(at: catalog ?? "")
                } catch let e {
                    let error = e
                    self.error(errordescription: error.localizedDescription, errortype: .profilecreatedirectory)
                    return
                }
                if let macserialnumber = self.macserialnumber,
                   let fullrootnomacserial = fullpathnomacserial
                {
                    do {
                        try Folder(path: fullrootnomacserial).createSubfolder(at: macserialnumber)
                    } catch let e {
                        let error = e
                        self.error(errordescription: error.localizedDescription, errortype: .profilecreatedirectory)
                        return
                    }
                }
            }
        }
    }

    // Create SSH catalog
    // If ssh catalog exists - bail out, no need to create
    func createsshkeyrootpath() {
        if let path = onlysshkeypath {
            let root = Folder.home
            guard root.containsSubfolder(named: path) == false else { return }
            do {
                try root.createSubfolder(at: path)
            } catch let e {
                let error = e as NSError
                self.error(errordescription: error.description, errortype: .createsshdirectory)
                return
            }
        }
    }

    override init(_ whichroot: Rootpath) {
        super.init(whichroot)
    }
}
