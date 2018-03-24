//
//  RcloneFiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.03.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

class RcloneFiles {

    var root: Root?
    var rootpath: String?

    private func setrootpath() {
        switch self.root! {
        case .profileRoot:
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
            let docuDir = (paths.firstObject as? String)!
            let profilePath = docuDir + RcloneReference.shared.configpath + Tools().getMacSerialNumber()!
            self.rootpath = profilePath
        case .sshRoot:
            self.rootpath = NSHomeDirectory() + "/.ssh/"
        }
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
                    array!.append(fileURLs[i].path)
                }
                return array
            }
        }
        return nil
    }

    // Function for returning profiles as array of Strings
    func getDirectorysStrings() -> [String] {
        var array: [String] = [String]()
        array.append("Default")
        if let filePath = self.rootpath {
            if let fileURLs = self.getfileURLs(path: filePath) {
                for i in 0 ..< fileURLs.count where fileURLs[i].hasDirectoryPath {
                    let path = fileURLs[i].pathComponents
                    let i = path.count
                    array.append(path[i-1])
                }
                return array
            }
        }
        return array
    }

    // Function for getting fileURLs for a given path
    private func getfileURLs (path: String) -> [URL]? {
        let fileManager = FileManager.default
        if let filepath = URL.init(string: path) {
            do {
                let files = try fileManager.contentsOfDirectory(at: filepath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                return files
            } catch let e {
                _ = e as NSError
                return nil
            }
        } else {
            return nil
        }
    }

    init (root: Root) {
        self.root = root
        self.setrootpath()
    }
}
