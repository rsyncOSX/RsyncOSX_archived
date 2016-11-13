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
    case all
}

class ScheduleDetailsAboutRuns {
    
    private var data:[NSDictionary]?
    weak var delegate_loadingLogdata:loadLoggata?
    
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
            self.readfilteredData(filter: "all", filterwhat: .all)
            if (self.data != nil) {
                return self.data
            }
        }
        return self.data
    }
    
    // Function for sorting and filetering loggdata
    private func readfilteredData (filter:String, filterwhat:filterLogs) {
        var data = Array<NSDictionary>()
        self.data = nil
        let input = SharingManagerSchedule.sharedInstance.getSchedule()
        for i in 0 ..< input.count {
            let hiddenID = SharingManagerSchedule.sharedInstance.getSchedule()[i].hiddenID
            if (input[i].executed.count > 0) {
                for j in 0 ..< input[i].executed.count {
                    let dict = input[i].executed[j]
                    let logdetail: NSDictionary = [
                        "localCatalog":SharingManagerConfiguration.sharedInstance.getlocalCatalog(hiddenID),
                        "offsiteServer":SharingManagerConfiguration.sharedInstance.getoffSiteserver(hiddenID),
                        "dateExecuted":(dict.value(forKey: "dateExecuted") as? String)!,
                        "resultExecuted":(dict.value(forKey: "resultExecuted") as? String)!]
                    switch filterwhat {
                    case .executeDate:
                        if (logdetail.value(forKey: "dateExecuted") as! String).contains(filter) {
                            data.append(logdetail)
                        }
                    case .localCatalog:
                        if (logdetail.value(forKey: "localCatalog") as! String).contains(filter) {
                            data.append(logdetail)
                        }
                    case .remoteServer:
                        if (logdetail.value(forKey: "offsiteServer") as! String).contains(filter) {
                            data.append(logdetail)
                        }
                    case .all:
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
                if let pvc = SharingManagerConfiguration.sharedInstance.LogObjectMain  as? ViewControllerScheduleDetailsAboutRuns {
                    self.delegate_loadingLogdata = pvc
                    self.delegate_loadingLogdata?.stop()
                }
            }
        }
    
    init () {
        self.readfilteredData(filter: "all", filterwhat: .all)
    }
}
