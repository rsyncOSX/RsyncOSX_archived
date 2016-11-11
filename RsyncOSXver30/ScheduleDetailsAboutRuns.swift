//
//  ScheduleDetailsAboutRuns.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

enum searchLogs {
    case localCatalog
    case remoteServer
    case executeDate
}

class ScheduleDetailsAboutRuns {
    
    private var data:[NSDictionary]?
    
    func filter(search:String?, what:searchLogs?) -> [NSDictionary]? {
        if (search != nil) {
            if (search!.isEmpty == false) {
                // Filter data
                self.readfilteredData(filter: search)
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
    
    private func readfilteredData (filter : String?) {
        var data = Array<NSDictionary>()
        self.data = nil
        let input = SharingManagerSchedule.sharedInstance.getSchedule()
        
        guard (filter != nil) else {
            return
        }
        
        for i in 0 ..< input.count {
            let hiddenID = SharingManagerSchedule.sharedInstance.getSchedule()[i].hiddenID
            if (SharingManagerConfiguration.sharedInstance.getoffSiteserver(hiddenID).contains(filter!)) {
                if (input[i].executed.count > 0) {
                    for j in 0 ..< input[i].executed.count {
                        let dict = input[i].executed[j]
                        let logdetail: NSDictionary = [
                            "localCatalog":SharingManagerConfiguration.sharedInstance.getlocalCatalog(hiddenID),
                            "offsiteServer":SharingManagerConfiguration.sharedInstance.getoffSiteserver(hiddenID),
                            "dateExecuted":(dict.value(forKey: "dateExecuted") as? String)!,
                            "resultExecuted":(dict.value(forKey: "resultExecuted") as? String)!]
                        data.append(logdetail)
                    }
                }
            }
        
        let dateformatter = Utils.sharedInstance.setDateformat()
        let logsorted: [NSDictionary] = data.sorted { (dict1, dict2) -> Bool in
            guard (dateformatter.date(from: dict1.value(forKey: "dateExecuted") as! String) != nil && (dateformatter.date(from: dict2.value(forKey: "dateExecuted") as! String) != nil)) else {
                return true
            }
            if ((dateformatter.date(from: dict1.value(forKey: "dateExecuted") as! String))!.timeIntervalSince(dateformatter.date(from: dict2.value(forKey: "dateExecuted") as! String)!) > 0 ) {
                return false
            } else {
                return true
            }
        }
        self.data = logsorted
        }
    }
    
    init () {
        self.readfilteredData(filter: nil)
    }
}

