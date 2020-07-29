//
//  files.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

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

class Files: NamesandPaths, FileErrors {
    /*
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
      */
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

    /*
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
     */

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

    /*
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
     */

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

    // Func that creates directory if not created
    func createprofilecatalog() {
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

    /*
     func createprofilecatalog() {
         if let docupath = self.docupath {
             do {
                 let path = docupath + (self.configpath ?? "")
                 try Folder(path: path).createSubfolder(named: path)
             } catch {}
             if let macserial = self.macserial {
                 do {
                     let path = docupath + (self.configpath ?? "") + macserial
                     try Folder(path: path).createSubfolder(named: path)
                 } catch {}
             }
         }
     }
     */

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

    override init(whichroot: WhichRoot, configpath: String?) {
        super.init(whichroot: whichroot, configpath: configpath)
    }
}
