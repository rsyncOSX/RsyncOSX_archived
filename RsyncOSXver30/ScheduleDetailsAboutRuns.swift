//
//  ScheduleDetailsAboutRuns.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

enum filterLogs {
    case localCatalog
    case remoteServer
    case executeDate
}

class ScheduleDetailsAboutRuns {
    
    // Reference to filtered data
    private var data:[NSDictionary]?
    // Reference to all sorted loggdata
    // Loggdata is only sorted and read once
    private var loggdata:[NSDictionary]?
    
    // Function for filter loggdata
    func filter(search:String?, what:filterLogs?) -> [NSDictionary]? {
        if (search != nil) {
            if (search!.isEmpty == false) {
                // Filter data
                self.readfilteredData(filter: search!, filterwhat: what!)
                return self.data!
            } else {
                return self.data
            }
        } else {
            return self.loggdata
        }
    }
    
    
    // Function for sorting and filetering loggdata
    private func readfilteredData (filter:String, filterwhat:filterLogs) {
        
        var data = Array<NSDictionary>()
        self.data = nil
        // Check if loggdata exist
        guard self.loggdata != nil else {
            return
        }
        for i in 0 ..< self.loggdata!.count {
            
            switch filterwhat {
            case .executeDate:
                if (self.loggdata![i].value(forKey: "dateExecuted") as! String).contains(filter) {
                    data.append(self.loggdata![i])
                }
            case .localCatalog:
                if (self.loggdata![i].value(forKey: "localCatalog") as! String).contains(filter) {
                    data.append(self.loggdata![i])
                }
            case .remoteServer:
                if (self.loggdata![i].value(forKey: "offsiteServer") as! String).contains(filter) {
                    data.append(self.loggdata![i])
                }
            }
        }
        self.data = data
    }
    
    // Function for sorting loggdata before any filtering.
    // Loggdata is only read and sorted once
    private func readAndSortAllLoggdata() {
        var data = Array<NSDictionary>()
        let input:[configurationSchedule] = SharingManagerSchedule.sharedInstance.getSchedule()
        for i in 0 ..< input.count {
            let hiddenID = SharingManagerSchedule.sharedInstance.getSchedule()[i].hiddenID
            if (input[i].executed.count > 0) {
                for j in 0 ..< input[i].executed.count {
                    let dict = input[i].executed[j]
                    let logdetail: NSDictionary = [
                        "localCatalog":SharingManagerConfiguration.sharedInstance.getlocalCatalog(hiddenID),
                        "offsiteServer":SharingManagerConfiguration.sharedInstance.getoffSiteserver(hiddenID),
                        "dateExecuted":(dict.value(forKey: "dateExecuted") as? String)!,
                        "resultExecuted":(dict.value(forKey: "resultExecuted") as? String)!,
                        "parent":(dict.value(forKey: "parent") as? String)!,
                        "hiddenID":hiddenID]
                    data.append(logdetail)
                }
            }
        }
        let dateformatter = Utils.sharedInstance.setDateformat()
        self.loggdata = data.sorted { (dict1, dict2) -> Bool in
            guard (dateformatter.date(from: dict1.value(forKey: "dateExecuted") as! String) != nil && (dateformatter.date(from: dict2.value(forKey: "dateExecuted") as! String) != nil)) else {
                return true
            }
            if ((dateformatter.date(from: dict1.value(forKey: "dateExecuted") as! String))!.timeIntervalSince(dateformatter.date(from: dict2.value(forKey: "dateExecuted") as! String)!) > 0 ) {
                return false
            } else {
                return true
            }
        }
    }
    
    init () {
        // Read and sort loggdata only once
        if self.loggdata == nil {
            self.readAndSortAllLoggdata()
        }
    }
}
