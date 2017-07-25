//
//  ConfigurationSchedule.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 02/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable syntactic_sugar

import Foundation

struct ConfigurationSchedule {
    var hiddenID: Int
    var dateStart: String
    var dateStop: String?
    var schedule: String
    var logrecords = Array<NSMutableDictionary>()
    var delete: Bool?

    init(dictionary: NSDictionary, log: NSArray?) {
        self.hiddenID = (dictionary.object(forKey: "hiddenID") as? Int)!
        self.dateStart = (dictionary.object(forKey: "dateStart") as? String)!
        self.schedule = (dictionary.object(forKey: "schedule") as? String)!
        if let date = dictionary.object(forKey: "dateStop") as? String {
            self.dateStop = date
        }
        if log != nil {
            for i in 0 ..< log!.count {
                self.logrecords.append((log![i] as? NSMutableDictionary)!)
            }
        }
    }
}
