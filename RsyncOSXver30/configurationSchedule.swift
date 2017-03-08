//
//  configurationSchedule.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 02/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

struct configurationSchedule {
    var hiddenID : Int
    var dateStart: String
    var dateStop: String?
    var schedule : String
    var executed = Array<NSMutableDictionary>()
    var delete:Bool?
    
    init(dictionary: NSDictionary, executed : NSArray?) {
        self.hiddenID = dictionary.object(forKey: "hiddenID") as! Int
        self.dateStart = dictionary.object(forKey: "dateStart") as! String
        self.schedule = dictionary.object(forKey: "schedule") as! String
        if let date = dictionary.object(forKey: "dateStop") as? String {
            self.dateStop = date
        }
        if (executed != nil) {
             for i in 0 ..< executed!.count {
                self.executed.append(executed![i] as! NSMutableDictionary)
            }
        }
    }
}

