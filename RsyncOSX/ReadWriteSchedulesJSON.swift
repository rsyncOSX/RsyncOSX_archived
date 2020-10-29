//
//  ReadWriteScheduleJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 18/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Files
import Foundation

class ReadWriteSchedulesJSON: ReadWriteJSON {
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

    private func decode(jsonfileasstring: String) {
        if let jsonstring = jsonfileasstring.data(using: .utf8) {
            do {
                let decoder = JSONDecoder()
                self.decodedjson = try decoder.decode([DecodeScheduleJSON].self, from: jsonstring)
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .json)
            }
        }
    }

    func JSONFromPersistentStore() {
        do {
            let test = try self.readJSONFromPersistentStore()
            self.decode(jsonfileasstring: test ?? "")
        } catch {}
    }

    init(schedules: [ConfigurationSchedule]?, profile: String?) {
        super.init(profile: profile, filename: ViewControllerReference.shared.fileschedulesjson)
        self.schedules = schedules
        self.profile = profile
        self.createJSONfromstructs()
    }

    init(profile: String?) {
        super.init(profile: profile, filename: ViewControllerReference.shared.fileschedulesjson)
        self.profile = profile
        self.JSONFromPersistentStore()
    }
}
