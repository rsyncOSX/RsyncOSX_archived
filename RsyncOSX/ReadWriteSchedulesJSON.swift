//
//  ReadWriteScheduleJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 18/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Files
import Foundation

class ReadWriteSchedulesJSON: NamesandPaths, FileErrors {
    var jsonstring: String?
    var schedules: [ConfigurationSchedule]?
    var decodedjson: [Any]?

    private func createJSONfromstructs() {
        var structscodable: [ConvertOneScheduleCodable]?
        if let schedules = self.schedules {
            structscodable = [ConvertOneScheduleCodable]()
            for i in 0 ..< schedules.count {
                structscodable?.append(ConvertOneScheduleCodable(schedule: schedules[i]))
            }
        }
        self.jsonstring = self.encodedata(data: structscodable)
    }

    private func encodedata(data: [ConvertOneScheduleCodable]?) -> String? {
        do {
            let jsonData = try JSONEncoder().encode(data)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch let e {
            let error = e as NSError
            self.error(error: error.description, errortype: .json)
            return nil
        }
        return nil
    }

    func readJSONFromPersistentStore() {
        if var atpath = self.fullroot {
            do {
                if self.profile != nil {
                    atpath += "/" + (self.profile ?? "")
                }
                // check if file exists befor reading, if not bail out
                guard try Folder(path: atpath).containsFile(named: ViewControllerReference.shared.fileschedulesjson) else { return }
                let jsonfile = atpath + "/" + ViewControllerReference.shared.fileschedulesjson
                let file = try File(path: jsonfile)
                let jsonfromstore = try file.readAsString()
                if let jsonstring = jsonfromstore.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        self.decodedjson = try decoder.decode([DecodeScheduleJSON].self, from: jsonstring)
                    } catch let e {
                        let error = e as NSError
                        self.error(error: error.description, errortype: .json)
                    }
                }
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .json)
            }
        }
    }

    func writeJSONToPersistentStore() {
        if var atpath = self.fullroot {
            do {
                if self.profile != nil {
                    atpath += "/" + (self.profile ?? "")
                }
                let folder = try Folder(path: atpath)
                let file = try folder.createFile(named: ViewControllerReference.shared.fileschedulesjson)
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
                if try Folder(path: atpath).containsFile(named: ViewControllerReference.shared.fileschedulesjson) {
                    let question: String = NSLocalizedString("JSON file exists: ", comment: "Logg")
                    let text: String = NSLocalizedString("Cancel or Save", comment: "Logg")
                    let dialog: String = NSLocalizedString("Save", comment: "Logg")
                    let answer = Alerts.dialogOrCancel(question: question + " " + ViewControllerReference.shared.fileschedulesjson, text: text, dialog: dialog)
                    if answer {
                        self.writeJSONToPersistentStore()
                    }
                }
            } catch {
                self.writeJSONToPersistentStore()
            }
        }
    }

    init(schedules: [ConfigurationSchedule]?, profile: String?) {
        super.init(profileorsshrootpath: .profileroot)
        self.schedules = schedules
        self.profile = profile
        self.createJSONfromstructs()
    }

    init(profile: String?) {
        super.init(profileorsshrootpath: .profileroot)
        self.profile = profile
        self.readJSONFromPersistentStore()
    }
}
