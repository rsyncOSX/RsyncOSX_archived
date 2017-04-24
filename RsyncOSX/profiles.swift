//
//  profiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 17/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

// Protocol for reporting file errors
protocol FileError: class {
    func fileerror(errorstr:String)
}

enum Root {
    case profileRoot
    case userRoot
}


class profiles {
    
    // Delegate for reporting file error if any to main view
    weak var error_delegate: FileError?
    // Set the string to absolute string path
    private var filePath:String?
    // Which root
    private var root:Root?
    // profiles root - returns the root of profiles
    fileprivate var profileRoot: String? {
        get {
            switch self.root! {
            case .profileRoot:
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
                let docuDir = paths.firstObject as! String
                let profilePath = docuDir + "/Rsync/" + SharingManagerConfiguration.sharedInstance.getMacSerialNumber()
                return profilePath
            case .userRoot:
                return NSHomeDirectory() + "/.ssh/"
            }
        }
    }
    
    // Function for returning directorys in path as array of URLs
    func getDirectorysURLs() -> Array<URL>? {
        var array:Array<URL>?
        if let filePath = self.profileRoot {
            if let fileURLs = self.getfileURLs(path: filePath) {
                array = Array<URL>()
                for i in 0 ..< fileURLs.count {
                    if fileURLs[i].hasDirectoryPath {
                        array!.append(fileURLs[i])
                    }
                }
                return array
            }
        }
        return nil
    }
    
    // Function for returning files in path as array of URLs
    func getFilesURLs() -> Array<URL>? {
        var array:Array<URL>?
        if let filePath = self.profileRoot {
            let fileManager = FileManager.default
            var isDir:ObjCBool = false
            if fileManager.fileExists(atPath: filePath, isDirectory:&isDir) {
                guard isDir.boolValue else {
                    return nil
                }
            } else {
                return nil
            }
            if let fileURLs = self.getfileURLs(path: filePath) {
                array = Array<URL>()
                for i in 0 ..< fileURLs.count {
                    if fileURLs[i].isFileURL {
                        array!.append(fileURLs[i])
                    }
                }
                return array
            }
        }
        return nil
    }
    
    func getFileStrings() -> Array<String>? {
        var array:Array<String>?
        if let filePath = self.profileRoot {
            let fileManager = FileManager.default
            var isDir:ObjCBool = false
            if fileManager.fileExists(atPath: filePath, isDirectory:&isDir) {
                guard isDir.boolValue else {
                    return nil
                }
            } else {
                return nil
            }
            if let fileURLs = self.getfileURLs(path: filePath) {
                array = Array<String>()
                for i in 0 ..< fileURLs.count {
                    if fileURLs[i].isFileURL {
                        array!.append(fileURLs[i].absoluteString)
                    }
                }
                return array
            }
        }
        return nil
    }
    
    
    // Function for returning profiles as array of Strings
    func getDirectorysStrings()-> Array<String> {
        var array:Array<String> = Array<String>()
        if let filePath = self.profileRoot {
            if let fileURLs = self.getfileURLs(path: filePath) {
                for i in 0 ..< fileURLs.count {
                    if fileURLs[i].hasDirectoryPath {
                        let path = fileURLs[i].pathComponents
                        let i = path.count
                        array.append(path[i-1])
                    }
                }
                return array
            }
        }
        return array
    }
    
    // Function for creating new profile directory
    func createProfile(profileName:String) {
        let fileManager = FileManager.default
        if let path = self.profileRoot {
            let profileDirectory = path + "/" + profileName
            if (fileManager.fileExists(atPath: profileDirectory) == false) {
                do {
                    try fileManager.createDirectory(atPath: profileDirectory, withIntermediateDirectories: true, attributes: nil)}
                catch let e {
                    let error = e as NSError
                    self.error(errorstr: error.description)
                }
            }
        }
    }
    
    // Function for deleting profile
    // if let path = URL.init(string: profileDirectory) {
    func deleteProfile(profileName:String) {
        let fileManager = FileManager.default
        if let path = self.profileRoot {
            let profileDirectory = path + "/" + profileName
            if (fileManager.fileExists(atPath: profileDirectory) == true) {
                let answer = Alerts.dialogOKCancel("Delete profile: " + profileName + "?", text: "Cancel or OK")
                if (answer){
                    do {
                        try fileManager.removeItem(atPath: profileDirectory)}
                    catch let e {
                        let error = e as NSError
                        self.error(errorstr: error.description)
                    }
                }
            }
        }
    }
    
    
    // Func that creates directory if not created
    func createDirectory() {
        let fileManager = FileManager.default
        if let path = self.filePath {
            if (fileManager.fileExists(atPath: path) == false) {
                do {
                    try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                } catch let e {
                    let error = e as NSError
                    self.error(errorstr: error.description)
                }
            }
        }
    }

    
    // Function for setting fileURLs for a given path
    private func getfileURLs (path:String) -> Array<URL>? {
        let fileManager = FileManager.default
        if let filepath = URL.init(string: path) {
            do {
                let files = try fileManager.contentsOfDirectory(at: filepath, includingPropertiesForKeys: nil , options: .skipsHiddenFiles)
                return files
            } catch let e {
                let error = e as NSError
                self.error(errorstr: error.description)
                return nil
            }
        }
        return nil
    }
    
    // Private func for propagating any file error to main view
    private func error(errorstr:String) {
        if let pvc = SharingManagerConfiguration.sharedInstance.ViewControllertabMain {
            self.error_delegate = pvc as? ViewControllertabMain
            self.error_delegate?.fileerror(errorstr: errorstr)
        }
    }
    
    init (path:String?, root:Root) {
        self.root = root
        self.filePath = path
    }
    
}
