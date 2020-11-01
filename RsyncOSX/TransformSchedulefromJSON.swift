//
//  TransformSchedulefromJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 31/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable trailing_comma

import Foundation

struct TransformSchedulefromJSON {
    func transform(object: DecodeScheduleJSON) -> ConfigurationSchedule {
        var log: [Any]?
        let dict: NSMutableDictionary = [
            "hiddenID": object.hiddenID ?? -1,
            "offsiteserver": object.offsiteserver ?? "",
            "dateStart": object.dateStart ?? "",
            "schedule": object.schedule ?? "",
            "profilename": object.profilename ?? "",
        ]
        if object.dateStop?.isEmpty == false {
            dict.setObject(object.dateStop ?? "", forKey: "dateStop" as NSCopying)
        }
        for i in 0 ..< (object.logrecords?.count ?? 0) {
            if i == 0 { log = Array() }
            let logdict: NSMutableDictionary = [
                "dateExecuted": object.logrecords![i].dateExecuted ?? "",
                "resultExecuted": object.logrecords![i].resultExecuted ?? "",
            ]
            log?.append(logdict)
        }
        return ConfigurationSchedule(dictionary: dict as NSDictionary, log: log as NSArray?, nolog: false)
    }
}
