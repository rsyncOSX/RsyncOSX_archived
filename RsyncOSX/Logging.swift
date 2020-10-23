//
//  Logging.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 20.11.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Files
import Foundation

class Logging: NamesandPaths, FileErrors {
    var outputprocess: OutputProcess?
    var log: String?
    var contentoflogfile: [String]?

    func writeloggfile() {
        if let atpath = self.fullroot {
            do {
                let folder = try Folder(path: atpath)
                let file = try folder.createFile(named: ViewControllerReference.shared.logname)
                if let data = self.log {
                    try file.write(data)
                    if let filesize = self.filesize() {
                        guard Int(truncating: filesize) < ViewControllerReference.shared.logfilesize else {
                            let size = Int(truncating: filesize)
                            self.error(error: String(size), errortype: .filesize)
                            return
                        }
                    }
                }
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .writelogfile)
            }
        }
    }

    func filesize() -> NSNumber? {
        if var atpath = self.fullroot {
            do {
                atpath += "/" + ViewControllerReference.shared.logname
                let file = try File(path: atpath).url
                return try FileManager.default.attributesOfItem(atPath: file.path)[FileAttributeKey.size] as? NSNumber ?? 0
            } catch {
                return 0
            }
        }
        return 0
    }

    func readloggfile() {
        if var atpath = self.fullroot {
            do {
                atpath += "/" + ViewControllerReference.shared.logname
                let file = try File(path: atpath)
                self.log = try file.readAsString()
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .readlogfile)
            }
        }
    }

    private func minimumlogging() {
        let date = Date().localized_string_from_date()
        self.readloggfile()
        var tmplogg = [String]()
        var startindex = (self.outputprocess?.getOutput()?.count ?? 0) - 8
        if startindex < 0 { startindex = 0 }
        tmplogg.append("\n" + date + " -------------------------------------------" + "\n")
        for i in startindex ..< (self.outputprocess?.getOutput()?.count ?? 0) {
            tmplogg.append(self.outputprocess?.getOutput()?[i] ?? "")
        }
        if self.log == nil {
            self.log = tmplogg.joined(separator: "\n")
        } else {
            self.log! += tmplogg.joined(separator: "\n")
        }
        self.writeloggfile()
    }

    private func fulllogging() {
        let date = Date().localized_string_from_date()
        self.readloggfile()
        let tmplogg: String = "\n" + date + " -------------------------------------------" + "\n"
        if self.log == nil {
            self.log = tmplogg + (self.outputprocess?.getOutput() ?? [""]).joined(separator: "\n")
        } else {
            self.log! += tmplogg + (self.outputprocess?.getOutput() ?? [""]).joined(separator: "\n")
        }
        self.writeloggfile()
    }

    init(outputprocess: OutputProcess?) {
        super.init(profileorsshrootpath: .profileroot)
        guard ViewControllerReference.shared.fulllogging == true ||
            ViewControllerReference.shared.minimumlogging == true
        else {
            return
        }
        self.outputprocess = outputprocess
        if ViewControllerReference.shared.fulllogging {
            self.fulllogging()
        } else {
            self.minimumlogging()
        }
    }

    init(_ outputprocess: OutputProcess?, _ logging: Bool) {
        super.init(profileorsshrootpath: .profileroot)
        if logging == false, outputprocess == nil {
            let date = Date().localized_string_from_date()
            self.log = date + ": " + "new logfile is created...\n"
            self.writeloggfile()
        } else {
            self.outputprocess = outputprocess
            self.fulllogging()
        }
    }

    init() {
        super.init(profileorsshrootpath: .profileroot)
        self.readloggfile()
        self.contentoflogfile = [String]()
        if let log = self.log {
            self.contentoflogfile = log.components(separatedBy: .newlines)
        }
    }
}

extension Logging: ViewOutputDetails {
    func reloadtable() {}

    func appendnow() -> Bool { return false }

    func getalloutput() -> [String] {
        return self.contentoflogfile ?? [""]
    }
}
