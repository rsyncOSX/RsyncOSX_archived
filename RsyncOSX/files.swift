//
//  files.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

enum Root {
    case profileRoot
    case userRoot
}

protocol ReportError: class {
    func reportError(errorstr:String)
}


class files {
    
    // Report error
    weak var reportError_delegate: ReportError?
    // Set the string to absolute string path
    var filePath:String?
    // Which root
    var root:Root?
    // Root of files
    var fileRoot: String? {
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
        if let filePath = self.fileRoot {
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
        if let filePath = self.fileRoot {
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
        if let filePath = self.fileRoot {
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
                        // File path
                        // .path is /Volume..
                        // .absoluteString is file:///Volume
                        array!.append(fileURLs[i].path)
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
        if let filePath = self.fileRoot {
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
    
    
    // Func that creates directory if not created
    func createDirectory() {
        let fileManager = FileManager.default
        if let path = self.filePath {
            if (fileManager.fileExists(atPath: path) == false) {
                do {
                    try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                } catch let e {
                    let error = e as NSError
                    self.reportError_delegate?.reportError(errorstr: error.description)
                }
            }
        }
    }
    
    
    // Function for setting fileURLs for a given path
    func getfileURLs (path:String) -> Array<URL>? {
        let fileManager = FileManager.default
        if let filepath = URL.init(string: path) {
            do {
                let files = try fileManager.contentsOfDirectory(at: filepath, includingPropertiesForKeys: nil , options: .skipsHiddenFiles)
                return files
            } catch let e {
                let error = e as NSError
                self.reportError_delegate?.reportError(errorstr: error.description)
                return nil
            }
        }
        return nil
    }
        
    init (path:String?, root:Root) {
        self.root = root
        self.filePath = path
    }
    
}

