//
//  ReadWriteScheduleJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 18/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Files
import Foundation

class ReadWriteSchedulesJSON: NamesandPaths {
    var jsonstring: String?
    var schedules: [ConfigurationSchedule]?
    var decodejson: [Any]?

    private func createJSON() {
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
        } catch {
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
                let jsonfile = atpath + "/" + "schedules.json"
                let file = try File(path: jsonfile)
                let jsonfromstore = try file.readAsString()
                if let jsonstring = jsonfromstore.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        self.decodejson = try decoder.decode([ScheduleJSON].self, from: jsonstring)
                        let logg = OutputProcess()
                        logg.addlinefromoutput(str: "JSON (schedules): readJSONFromPersistentStore success")
                        _ = Logging(logg, true)
                    } catch {}
                }
            } catch {}
        }
    }

    func writeJSONToPersistentStore() {
        if var atpath = self.fullroot {
            do {
                if self.profile != nil {
                    atpath += "/" + (self.profile ?? "")
                }
                let folder = try Folder(path: atpath)
                let file = try folder.createFile(named: "schedules.json")
                if let data = self.jsonstring {
                    try file.write(data)
                    let logg = OutputProcess()
                    logg.addlinefromoutput(str: "JSON (schedules): writeJSONToPersistentStore success")
                    _ = Logging(logg, true)
                }
            } catch {}
        }
    }

    init(schedules: [ConfigurationSchedule]?, profile: String?) {
        super.init(profileorsshrootpath: .profileroot)
        self.schedules = schedules
        self.profile = profile
        self.createJSON()
    }

    init(profile: String?) {
        super.init(profileorsshrootpath: .profileroot)
        self.profile = profile
        self.readJSONFromPersistentStore()
    }
}
