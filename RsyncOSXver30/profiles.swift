//
//  profiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 17/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

class profiles {
    
    // Set the string path 
    private var filePath:String?
    // profiles root
    // Set which file to read
    private var profileRoot : String? {
        get {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
            let docuDir = paths.firstObject as! String
            let profilePath = docuDir + "/Rsync/" + SharingManagerConfiguration.sharedInstance.getMacSerialNumber()
            return profilePath
        }
    }
    
    // Function for returning directorys in path as array of URLs
    private func getDirectorysURLs () -> [URL] {
        var array:[URL] = [URL]()
        if let filePath = self.profileRoot {
            if let fileURLs = self.getfileURLs(path: filePath) {
                for i in 0 ..< fileURLs.count {
                    if fileURLs[i].hasDirectoryPath {
                        array.append(fileURLs[i])
                    }
                }
                return array
            }
        }
        return array
    }
    
    // Function for returning profiles as array of Strings
    func getDirectorysStrings()-> [String] {
        var array:[String] = [String]()
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
                catch _ as NSError { }
            }
        }
    }
    
    // Function for deleting profile
    func deleteProfile(profileName:String) {
        let fileManager = FileManager.default
        if let path = self.profileRoot {
            let profileDirectory = path + "/" + profileName
            if (fileManager.fileExists(atPath: profileDirectory) == true) {
                do {
                    if let path = URL.init(string: profileDirectory) {
                        try fileManager.trashItem(at: path, resultingItemURL:nil)}
                    }
                catch _ as NSError { }
            }
        }
    }
    
    
    // Func that creates directory if not created
    func createDirectory() {
        let fileManager = FileManager.default
        if let path = self.filePath {
            if (fileManager.fileExists(atPath: path) == false) {
                do {
                    try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)}
                catch _ as NSError { }
            }
        }
    }

    
    // Function for setting fileURLs for a given path
    private func getfileURLs (path:String) -> [URL]? {
        let fileManager = FileManager.default
        if let filepath = URL.init(string: path) {
            do {
                let files = try fileManager.contentsOfDirectory(at: filepath, includingPropertiesForKeys: nil , options: .skipsHiddenFiles)
                return files
            } catch _ as NSError { }
        }
        return nil
    }
    
    init (path:String?) {
        self.filePath = path
    }
    
}
