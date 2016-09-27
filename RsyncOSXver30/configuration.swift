//
//  configuration.swift
//  Rsync
//
//  Created by Thomas Evensen on 08/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

struct configuration {
    var hiddenID : Int
    var task: String
    var localCatalog: String
    var offsiteCatalog: String
    var offsiteUsername: String
    var batch: String
    var rsync: String
    var dryrun: String
    var parameter1: String
    var parameter2: String
    var parameter3: String
    var parameter4: String
    var parameter5: String
    var parameter6: String
    var offsiteServer: String
    var backupID: String
    var dateRun: String?
    // parameters choosed by user
    var parameter8: String?
    var parameter9: String?
    var parameter10: String?
    var parameter11: String?
    var parameter12: String?
    var parameter13: String?
    var parameter14: String?
    var rsyncdaemon: Int?
    var sshport: Int?
    
    init(dictionary: NSDictionary) {
        self.hiddenID = dictionary.object(forKey: "hiddenID") as! Int
        self.task = dictionary.object(forKey: "task") as! String
        self.localCatalog = dictionary.object(forKey: "localCatalog") as! String
        self.offsiteCatalog = dictionary.object(forKey: "offsiteCatalog") as! String
        self.offsiteUsername = dictionary.object(forKey: "offsiteUsername") as! String
        self.batch = dictionary.object(forKey: "batch") as! String
        self.rsync = dictionary.object(forKey: "rsync") as! String
        self.dryrun = dictionary.object(forKey: "dryrun") as! String
        self.parameter1 = dictionary.object(forKey: "parameter1") as! String
        self.parameter2 = dictionary.object(forKey: "parameter2") as! String
        self.parameter3 = dictionary.object(forKey: "parameter3") as! String
        self.parameter4 = dictionary.object(forKey: "parameter4") as! String
        self.parameter5 = dictionary.object(forKey: "parameter5") as! String
        self.parameter6 = dictionary.object(forKey: "parameter6") as! String
        self.offsiteServer = dictionary.object(forKey: "offsiteServer") as! String
        self.backupID = dictionary.object(forKey: "backupID") as! String
        if (dictionary.object(forKey: "dateRun") != nil){
            self.dateRun = dictionary.object(forKey: "dateRun") as? String
        } else {
            self.dateRun = " "
        }
        if (dictionary.object(forKey: "parameter8") != nil){
            self.parameter8 = dictionary.object(forKey: "parameter8") as? String
        }
        if (dictionary.object(forKey: "parameter9") != nil){
            self.parameter9 = dictionary.object(forKey: "parameter9") as? String
        }
        if (dictionary.object(forKey: "parameter10") != nil){
            self.parameter10 = dictionary.object(forKey: "parameter10") as? String
        }
        if (dictionary.object(forKey: "parameter11") != nil){
            self.parameter11 = dictionary.object(forKey: "parameter11") as? String
        }
        if (dictionary.object(forKey: "parameter12") != nil){
            self.parameter12 = dictionary.object(forKey: "parameter12") as? String
        }
        if (dictionary.object(forKey: "parameter13") != nil){
            self.parameter13 = dictionary.object(forKey: "parameter13") as? String
        }
        if (dictionary.object(forKey: "parameter14") != nil){
            self.parameter14 = dictionary.object(forKey: "parameter14") as? String
        }
        if (dictionary.object(forKey: "rsyncdaemon") != nil){
            self.rsyncdaemon = dictionary.object(forKey: "rsyncdaemon") as? Int
        }
        if (dictionary.object(forKey: "sshport") != nil){
            self.sshport = dictionary.object(forKey: "sshport") as? Int
        }
    }
}

