//
//  ScheduleDetailsAboutRuns.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

class ScheduleDetailsAboutRuns {
    
    private var data:[NSMutableDictionary]?
    
    func filter(search:String?) -> [NSMutableDictionary]? {
        if (search != nil) {
            if (search!.isEmpty == false) {
                // Filter data
                self.readScheduledataDetailsAll(filter: search)
                return self.data!
            } else {
                return self.data
            }
        } else {
            if (self.data != nil) {
                return self.data
            }
        }
        return self.data
    }

    private func readScheduledataDetailsAll (filter : String?) {
        var row: NSMutableDictionary?
        var data = [NSMutableDictionary]()
        self.data = nil
        let input = SharingManagerSchedule.sharedInstance.getSchedule()
        for i in 0 ..< input.count {
            let hiddenID = SharingManagerSchedule.sharedInstance.getSchedule()[i].hiddenID
            let server = SharingManagerConfiguration.sharedInstance.getoffSiteserver(hiddenID)
            let localCatalog = SharingManagerConfiguration.sharedInstance.getlocalCatalog(hiddenID)
            
            if (filter == server || filter == nil) {
                row = [
                    "offsiteServer":server,
                    "localCatalog":localCatalog,
                    "schedule":input[i].schedule,
                    "dateExecuted":"",
                    "resultExecuted":"" ]
                data.append(row!)
                if (input[i].executed.count > 0) {
                    let contstr:String = String(input[i].executed.count) + " task(s)"
                    row!.setValue(contstr, forKey: "dateExecuted")
                    for j in 0 ..< input[i].executed.count {
                        let dict = input[i].executed[j]
                        let dateExecuted:String = (dict.value(forKey: "dateExecuted") as? String)!
                        let resultExecuted:String = (dict.value(forKey: "resultExecuted") as? String)!
                        let rowdetail: NSMutableDictionary = [
                            "dateExecuted":dateExecuted,
                            "resultExecuted":resultExecuted]
                        if let parent = (dict.value(forKey: "parent") as? String) {
                            rowdetail.setValue(parent, forKey: "parent")
                        }
                        data.append(rowdetail)
                    }
                }
            }
        }
        self.data = data
    }
    
    init () {
        self.readScheduledataDetailsAll(filter: nil)
    }

    
}
