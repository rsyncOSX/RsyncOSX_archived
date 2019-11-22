//
//  Reorgschedule.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21/11/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

class Reorgschedule {

    var schedule: [ConfigurationSchedule]?
    var uniquehiddenIDs: [Int]?
    var schedulemanuel: [ConfigurationSchedule]?
    var schedulenotmanuel: [ConfigurationSchedule]?

    func finduniquehiddenIDs() {
        var hiddenids: [Int]?
        hiddenids = [Int]()
        for i in 0 ..< schedule!.count {
            hiddenids!.append(schedule![i].hiddenID)
        }
        self.uniquehiddenIDs = hiddenids!.unique()
    }

    func mergeloggsmaunal() {
        var manuel = [ConfigurationSchedule]()
        for i in 0 ..< uniquehiddenIDs!.count {
            let hiddenID = uniquehiddenIDs![i]
            let filter = schedule!.filter({$0.hiddenID == hiddenID && $0.schedule == "manuel"})
            if filter.count > 0 {
                manuel.append(filter[0])
                let index = manuel.count - 1
                for j in 1 ..< filter.count {
                    for k in 0 ..< filter[j].logrecords.count {
                         manuel[index].logrecords.append(filter[j].logrecords[k])
                    }
                }
            }
        }
        self.schedulemanuel = manuel
    }

    func findnotmanual() {
        var notmanuel = [ConfigurationSchedule]()
        for i in 0 ..< uniquehiddenIDs!.count {
            let hiddenID = uniquehiddenIDs![i]
            let filter = schedule!.filter({$0.hiddenID == hiddenID && $0.schedule != "manuel"})
            if filter.count > 0 {
                notmanuel.append(filter[0])
                let index = notmanuel.count - 1
                for j in 1 ..< filter.count {
                    for k in 0 ..< filter[j].logrecords.count {
                         notmanuel[index].logrecords.append(filter[j].logrecords[k])
                    }
                }
            }
        }
        self.schedulenotmanuel = notmanuel
    }

    init(schedule: [ConfigurationSchedule]?) {
        self.schedule = schedule
        /*
        Do not use...
        self.finduniquehiddenIDs()
        self.mergeloggsmaunal()
        self.findnotmanual()
        self.schedule = (self.schedulemanuel ?? []) + (self.schedulenotmanuel ?? [])
        */
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var alreadyAdded = Set<Iterator.Element>()
        return self.filter { alreadyAdded.insert($0).inserted }
    }
}
