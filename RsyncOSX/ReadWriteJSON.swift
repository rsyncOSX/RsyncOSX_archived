//
//  ReadWriteJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 29/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Files
import Foundation

class ReadWriteJSON: NamesandPaths, FileErrors {
    var jsonstring: String?
    var decodedjson: [Any]?
/*
    private func createJSONfromstructs<T: Codable>(records: [Any]?, decode: (Any) -> T) {
        var structscodable: [T]?
        if let records = records {
            structscodable = [T]()
            for i in 0 ..< records.count {
                structscodable?.append(decode(records[i]))
            }
        }
        self.jsonstring = self.encodedata(data: structscodable)
    }

    private func encodedata<T: Codable>(data: [T]?) -> String? {
        do {
            let jsonData = try JSONEncoder().encode(data)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            return nil
        }
        return nil
    }
*/
    func writeJSONToPersistentStore() {
        if var atpath = self.fullroot {
            do {
                if self.profile != nil {
                    atpath += "/" + (self.profile ?? "")
                }
                let folder = try Folder(path: atpath)
                let file = try folder.createFile(named: self.filename ?? "")
                if let data = self.jsonstring {
                    try file.write(data)
                }
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .json)
            }
        }
    }

    func writeconvertedtostore() {
        if var atpath = self.fullroot {
            if self.profile != nil {
                atpath += "/" + (self.profile ?? "")
            }
            do {
                if try Folder(path: atpath).containsFile(named: self.filename ?? "") {
                    let question: String = NSLocalizedString("JSON file exists: ", comment: "Logg")
                    let text: String = NSLocalizedString("Cancel or Save", comment: "Logg")
                    let dialog: String = NSLocalizedString("Save", comment: "Logg")
                    let answer = Alerts.dialogOrCancel(question: question + " " + (self.filename ?? ""), text: text, dialog: dialog)
                    if answer {
                        self.writeJSONToPersistentStore()
                    }
                } else {
                    self.writeJSONToPersistentStore()
                }
            } catch {}
        }
    }

    init(profile: String?, filename: String?) {
        super.init(profileorsshrootpath: .profileroot)
        self.filename = filename
        self.profile = profile
    }
}
