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
    
    
    // Function for returning directorys in path as array of URLs
    func getDirectorysURLs () -> [URL] {
        var array:[URL] = [URL]()
        if let filePath = self.filePath {
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
    
    func getDirectorysStrings()-> [String] {
        var array:[String] = [String]()
        if let filePath = self.filePath {
            if let fileURLs = self.getfileURLs(path: filePath) {
                for i in 0 ..< fileURLs.count {
                    if fileURLs[i].hasDirectoryPath {
                        array.append(fileURLs[i].relativePath)
                    }
                }
                return array
            }
        }
        return array
    }
    
    
    // Func that creates directory if not created
    func createDirectory () {
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
    
    init (path:String) {
        self.filePath = path
    }
    
}
