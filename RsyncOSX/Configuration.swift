//
//  configuration.swift
//  Rsync
//
//  Created by Thomas Evensen on 08/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

struct Configuration {
    var hiddenID: Int
    var task: String
    var localCatalog: String
    var offsiteCatalog: String
    var offsiteUsername: String
    var batch: String
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
        // Parameters 1 - 6 is mandatory, set by RsyncOSX.
        self.hiddenID = (dictionary.object(forKey: "hiddenID") as? Int)!
        self.task = (dictionary.object(forKey: "task") as? String)!
        self.localCatalog = (dictionary.object(forKey: "localCatalog") as? String)!
        self.offsiteCatalog = (dictionary.object(forKey: "offsiteCatalog") as? String)!
        self.offsiteUsername = (dictionary.object(forKey: "offsiteUsername") as? String)!
        self.batch = (dictionary.object(forKey: "batch") as? String)!
        self.dryrun = (dictionary.object(forKey: "dryrun") as? String)!
        self.parameter1 = (dictionary.object(forKey: "parameter1") as? String)!
        self.parameter2 = (dictionary.object(forKey: "parameter2") as? String)!
        self.parameter3 = (dictionary.object(forKey: "parameter3") as? String)!
        self.parameter4 = (dictionary.object(forKey: "parameter4") as? String)!
        self.parameter5 = (dictionary.object(forKey: "parameter5") as? String)!
        self.parameter6 = (dictionary.object(forKey: "parameter6") as? String)!
        self.offsiteServer = (dictionary.object(forKey: "offsiteServer") as? String)!
        self.backupID = (dictionary.object(forKey: "backupID") as? String)!
        // Last run of task
        if let dateRun = dictionary.object(forKey: "dateRun") {
            self.dateRun = dateRun as? String
        } else {
            self.dateRun = " "
        }
        // Parameters 8 - 14 is user selected, as well as ssh port.
        if let parameter8 = dictionary.object(forKey: "parameter8") {
            self.parameter8 = parameter8 as? String
        }
        if let parameter9 = dictionary.object(forKey: "parameter9") {
            self.parameter9 = parameter9 as? String
        }
        if let parameter10 = dictionary.object(forKey: "parameter10") {
            self.parameter10 = parameter10 as? String
        }
        if let parameter11 = dictionary.object(forKey: "parameter11") {
            self.parameter11 = parameter11 as? String
        }
        if let parameter12 = dictionary.object(forKey: "parameter12") {
            self.parameter12 = parameter12 as? String
        }
        if let parameter13 = dictionary.object(forKey: "parameter13") {
            self.parameter13 = parameter13 as? String
        }
        if let parameter14 = dictionary.object(forKey: "parameter14") {
            self.parameter14 = parameter14 as? String
        }

        if let rsyncdaemon = dictionary.object(forKey: "rsyncdaemon") {
            self.rsyncdaemon = rsyncdaemon as? Int
        }
        if let sshport = dictionary.object(forKey: "sshport") {
            self.sshport = sshport as? Int
        }
    }
}
