//
//  files.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

enum WhichRoot {
    case profileRoot
    case sshRoot
}

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

class Files: FileErrors {
    var whichroot: WhichRoot?
    var rootpath: String?
    // If global keypath and identityfile is set must split keypath and identifile
    // create a new key require full path
    var identityfile: String?
    // config path either
    // ViewControllerReference.shared.configpath or RcloneReference.shared.configpath
    var configpath: String?

    private func setrootpath() {
        switch self.whichroot {
        case .profileRoot:
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
            let docuDir = (paths.firstObject as? String) ?? ""
            if ViewControllerReference.shared.macserialnumber == nil {
                ViewControllerReference.shared.macserialnumber = Macserialnumber().getMacSerialNumber() ?? ""
            }
            let profilePath = docuDir + self.configpath! + (ViewControllerReference.shared.macserialnumber ?? "")
            self.rootpath = profilePath
        case .sshRoot:
            // Check if a global ssh keypath and identityfile is set
            // Set full path if not ssh-keygen will fail
            // The sshkeypath + identityfile must be prefixed with "~" used in rsync parameters
            // only full path when ssh-keygen is used
            if ViewControllerReference.shared.sshkeypathandidentityfile == nil {
                self.rootpath = NSHomeDirectory() + "/.ssh"
                self.identityfile = "id_rsa"
            } else {
                // global sshkeypath and identityfile is set
                if let sshkeypathandidentityfile = ViewControllerReference.shared.sshkeypathandidentityfile {
                    if sshkeypathandidentityfile.first == "~" {
                        // must drop identityfile and then set rootpath
                        // also drop the "~" character
                        var sshkeypathandidentityfilesplit = sshkeypathandidentityfile.split(separator: "/")
                        self.identityfile = String(sshkeypathandidentityfilesplit[sshkeypathandidentityfilesplit.count - 1])
                        sshkeypathandidentityfilesplit.remove(at: sshkeypathandidentityfilesplit.count - 1)
                        self.rootpath = NSHomeDirectory() + sshkeypathandidentityfilesplit.joined(separator: "/").dropFirst()
                    } else {
                        // If anything goes wrong set to default global values
                        self.rootpath = NSHomeDirectory() + "/.ssh"
                        ViewControllerReference.shared.sshkeypathandidentityfile = "~./ssh/id_rsa"
                        self.identityfile = "id_rsa"
                    }
                }
            }
        default:
            return
        }
    }

    // Function for returning files in path as array of URLs
    func getFilesURLs() -> [URL]? {
        var array: [URL]?
        if let filePath = self.rootpath {
            let fileManager = FileManager.default
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: filePath, isDirectory: &isDir) {
                guard isDir.boolValue else { return nil }
            } else { return nil }
            if let fileURLs = self.getfileURLs(path: filePath) {
                array = [URL]()
                for i in 0 ..< fileURLs.count where fileURLs[i].isFileURL {
                    array?.append(fileURLs[i])
                }
                return array
            }
        }
        return nil
    }

    // Function for returning files in path as array of Strings
    func getFileStrings() -> [String]? {
        var array: [String]?
        if let filePath = self.rootpath {
            let fileManager = FileManager.default
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: filePath, isDirectory: &isDir) {
                guard isDir.boolValue else { return nil }
            } else { return nil }
            if let fileURLs = self.getfileURLs(path: filePath) {
                array = [String]()
                for i in 0 ..< fileURLs.count where fileURLs[i].isFileURL {
                    array?.append(fileURLs[i].path)
                }
                return array
            }
        }
        return nil
    }

    // Function for returning profiles as array of Strings
    func getDirectorysStrings() -> [String] {
        var array = [String]()
        if let filePath = self.rootpath {
            if let fileURLs = self.getfileURLs(path: filePath) {
                for i in 0 ..< fileURLs.count where fileURLs[i].hasDirectoryPath {
                    let path = fileURLs[i].pathComponents
                    let i = path.count
                    array.append(path[i - 1])
                }
                return array
            }
        }
        return array
    }

    // Func that creates directory if not created
    func createDirectory() {
        let fileManager = FileManager.default
        if let path = self.rootpath {
            // Profile root
            if fileManager.fileExists(atPath: path) == false {
                do {
                    try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                } catch let e {
                    let error = e as NSError
                    self.error(error: error.description, errortype: .profilecreatedirectory)
                }
            }
        }
    }

    // Function for getting fileURLs for a given path
    func getfileURLs(path: String) -> [URL]? {
        let fileManager = FileManager.default
        if let filepath = URL(string: path) {
            do {
                let files = try fileManager.contentsOfDirectory(at: filepath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                return files
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .profilecreatedirectory)
                return nil
            }
        } else {
            return nil
        }
    }

    init(whichroot: WhichRoot, configpath: String) {
        self.configpath = configpath
        self.whichroot = whichroot
        self.setrootpath()
    }
}
