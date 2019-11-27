//
//  Reorgschedule.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21/11/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

class Reorgschedule {

    func uniquelements<T: Hashable>(data: [T]) -> [T] {
        var elements: [T]?
        elements = [T]()
        for i in 0 ..< data.count {
            elements!.append(data[i])
        }
        return elements!.unique()
    }

    func mergeelements<T: Hashable>(data: [T]?) -> [T]? {
        guard data != nil else { return  nil }
        var mergedelements = [T]()
        let uniqueelements = self.uniquelements(data: data!)
        for i in 0 ..< uniqueelements.count {
            let element = uniqueelements[i]
            let filter = data!.filter({$0 == element})
            switch filter.count {
            case 0:
                return nil
            case 1:
                mergedelements.append(element)
            default:
                mergedelements.append(element)
                for j in 1 ..< filter.count {
                    let record = filter[j] as? ConfigurationSchedule
                    let index = mergedelements.count - 1
                    for k in 0 ..< (record?.logrecords.count ?? 0) {
                        var mergedrecord = mergedelements[index] as? ConfigurationSchedule
                        mergedrecord!.logrecords.append(record!.logrecords[k])
                    }
                }
            }
        }
        return mergedelements
    }
}

/*
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

*/
