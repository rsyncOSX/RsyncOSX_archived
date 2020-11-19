//
//  ConfigurationSchedule.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 02/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

struct Log {
    var dateExecuted: String?
    var resultExecuted: String?
    var delete: Bool?
}

struct ConfigurationSchedule {
    var hiddenID: Int
    var offsiteserver: String?
    var dateStart: String
    var dateStop: String?
    var schedule: String
    var logrecords: [Log]?
    var delete: Bool?
    var profilename: String?

    init(dictionary: NSDictionary, log: NSArray?, includelog: Bool) {
        self.hiddenID = dictionary.object(forKey: DictionaryStrings.hiddenID.rawValue) as? Int ?? -1
        self.dateStart = dictionary.object(forKey: DictionaryStrings.dateStart.rawValue) as? String ?? ""
        self.schedule = dictionary.object(forKey: DictionaryStrings.schedule.rawValue) as? String ?? ""
        self.offsiteserver = dictionary.object(forKey: DictionaryStrings.offsiteserver.rawValue) as? String ?? ""
        if let date = dictionary.object(forKey: DictionaryStrings.dateStop.rawValue) as? String { self.dateStop = date }
        if log != nil, includelog == true {
            for i in 0 ..< (log?.count ?? 0) {
                if i == 0 { self.logrecords = [Log]() }
                var logrecord = Log()
                if let dict = log?[i] as? NSDictionary {
                    logrecord.dateExecuted = dict.object(forKey: DictionaryStrings.dateExecuted.rawValue) as? String
                    logrecord.resultExecuted = dict.object(forKey: DictionaryStrings.resultExecuted.rawValue) as? String
                }
                self.logrecords?.append(logrecord)
            }
        }
    }
}

extension ConfigurationSchedule: Hashable, Equatable {
    static func == (lhs: ConfigurationSchedule, rhs: ConfigurationSchedule) -> Bool {
        return lhs.hiddenID == rhs.hiddenID &&
            lhs.dateStart == rhs.dateStart &&
            lhs.schedule == rhs.schedule &&
            lhs.dateStop == rhs.dateStop &&
            lhs.offsiteserver == rhs.offsiteserver &&
            lhs.profilename == rhs.profilename
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(self.hiddenID))
        hasher.combine(self.dateStart)
        hasher.combine(self.schedule)
        hasher.combine(self.dateStop)
        hasher.combine(self.offsiteserver)
        hasher.combine(self.profilename)
    }
}

extension Log: Hashable, Equatable {
    static func == (lhs: Log, rhs: Log) -> Bool {
        return lhs.dateExecuted == rhs.dateExecuted &&
            lhs.resultExecuted == rhs.resultExecuted
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.dateExecuted)
        hasher.combine(self.resultExecuted)
    }
}
