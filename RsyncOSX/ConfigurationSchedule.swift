//
//  ConfigurationSchedule.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 02/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

struct ConfigurationSchedule {
    var hiddenID: Int
    var offsiteserver: String?
    var dateStart: String
    var dateStop: String?
    var schedule: String
    var logrecords = [NSMutableDictionary]()
    var delete: Bool?
    var profilename: String?

    init(dictionary: NSDictionary, log: NSArray?, nolog: Bool) {
        self.hiddenID = dictionary.object(forKey: "hiddenID") as? Int ?? -1
        self.dateStart = dictionary.object(forKey: "dateStart") as? String ?? ""
        self.schedule = dictionary.object(forKey: "schedule") as? String ?? ""
        self.offsiteserver = dictionary.object(forKey: "offsiteserver") as? String ?? ""
        if let date = dictionary.object(forKey: "dateStop") as? String { self.dateStop = date }
        if log != nil, nolog == false {
            for i in 0 ..< (log?.count ?? 0) {
                if let dict = log?[i] as? NSMutableDictionary {
                    self.logrecords.append(dict)
                }
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
