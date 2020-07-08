//
//  Logging.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 20.11.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

class Logging: FileErrors {
    var outputprocess: OutputProcess?
    var log: String?
    var contentoflogfile: [String]?
    var filename: String?
    var fileURL: URL?
    var filesize: NSNumber?

    private func setfilenamelogging() {
        self.filename = ViewControllerReference.shared.logname
        let DocumentDirURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        self.fileURL = DocumentDirURL?.appendingPathComponent(self.filename!).appendingPathExtension("txt")
        self.filesize = try? FileManager.default.attributesOfItem(atPath: self.fileURL!.path)[FileAttributeKey.size] as? NSNumber ?? 0
        ViewControllerReference.shared.fileURL = self.fileURL
    }

    private func writeloggfile() {
        globalMainQueue.async { () -> Void in
            do {
                try self.log?.write(to: self.fileURL!, atomically: true, encoding: String.Encoding.utf8)
                if let filesize = self.filesize {
                    guard Int(truncating: filesize) < ViewControllerReference.shared.logfilesize else {
                        let size = Int(truncating: filesize)
                        self.error(error: String(size), errortype: .filesize)
                        return
                    }
                }
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .writelogfile)
            }
        }
    }

    private func readloggfile() {
        do {
            self.log = try String(contentsOf: self.fileURL!, encoding: String.Encoding.utf8)
        } catch _ {
            self.log = "No logfile..." + "\n" + "creating logfile: " + (self.fileURL?.absoluteString ?? "")
            self.writeloggfile()
        }
    }

    private func minimumlogging() {
        let date = Date().localized_string_from_date()
        self.readloggfile()
        var tmplogg = [String]()
        var startindex = (self.outputprocess?.getOutput()?.count ?? 0) - 8
        if startindex < 0 { startindex = 0 }
        tmplogg.append("\n")
        tmplogg.append("-------------------------------------------")
        tmplogg.append(date + "\n")
        for i in startindex ..< (self.outputprocess?.getOutput()?.count ?? 0) {
            tmplogg.append(self.outputprocess?.getOutput()?[i] ?? "")
        }
        if self.log == nil {
            self.log = tmplogg.joined(separator: "\n")
        } else {
            self.log = self.log! + tmplogg.joined(separator: "\n")
        }
        self.writeloggfile()
    }

    private func fulllogging() {
        let date = Date().localized_string_from_date()
        self.readloggfile()
        let tmplogg: String = "\n" + "-------------------------------------------\n" + date + "\n"
            + "-------------------------------------------\n"
        if self.log == nil {
            self.log = tmplogg + (self.outputprocess?.getOutput() ?? [""]).joined(separator: "\n")
        } else {
            self.log = self.log! + tmplogg + (self.outputprocess?.getOutput() ?? [""]).joined(separator: "\n")
        }
        self.writeloggfile()
    }

    init(outputprocess: OutputProcess?) {
        guard ViewControllerReference.shared.fulllogging == true ||
            ViewControllerReference.shared.minimumlogging == true else {
            return
        }
        self.outputprocess = outputprocess
        self.setfilenamelogging()
        if ViewControllerReference.shared.fulllogging {
            self.fulllogging()
        } else {
            self.minimumlogging()
        }
    }

    init(_ outputprocess: OutputProcess?, _ logging: Bool) {
        self.setfilenamelogging()
        if logging == false, outputprocess == nil {
            self.log = "Creating a new logfile: " + (self.fileURL?.absoluteString ?? "")
            self.writeloggfile()
        } else {
            self.outputprocess = outputprocess
            self.fulllogging()
        }
    }

    init() {
        self.setfilenamelogging()
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
