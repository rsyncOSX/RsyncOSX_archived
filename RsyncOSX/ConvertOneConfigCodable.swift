//
//  ConvertConfigurationsCodable.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 16/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
//

import Foundation

struct ConvertOneConfigCodable: Codable {
    var hiddenID: Int
    var task: String
    var localCatalog: String
    var offsiteCatalog: String
    var offsiteUsername: String
    var parameter1: String?
    var parameter2: String
    var parameter3: String
    var parameter4: String
    var parameter5: String
    var parameter6: String
    var offsiteServer: String
    var backupID: String
    var dateRun: String?
    var snapshotnum: Int?
    // parameters choosed by user
    var parameter8: String?
    var parameter9: String?
    var parameter10: String?
    var parameter11: String?
    var parameter12: String?
    var parameter13: String?
    var parameter14: String?
    var rsyncdaemon: Int?
    // SSH parameters
    var sshport: Int?
    var sshkeypathandidentityfile: String?
    var profile: String?
    // Snapshots, day to save and last = 1 or every last=0
    var snapdayoffweek: String?
    var snaplast: Int?
    // Pre and post tasks
    var executepretask: Int?
    var pretask: String?
    var executeposttask: Int?
    var posttask: String?
    var haltshelltasksonerror: Int?

    init(config: Configuration?) {
        self.hiddenID = config?.hiddenID ?? -1
        self.task = config?.task ?? ""
        self.localCatalog = config?.localCatalog ?? ""
        self.offsiteCatalog = config?.offsiteCatalog ?? ""
        self.offsiteUsername = config?.offsiteUsername ?? ""
        self.parameter1 = config?.parameter1 ?? ""
        self.parameter2 = config?.parameter2 ?? ""
        self.parameter3 = config?.parameter3 ?? ""
        self.parameter4 = config?.parameter4 ?? ""
        self.parameter5 = config?.parameter5 ?? ""
        self.parameter6 = config?.parameter6 ?? ""
        self.offsiteServer = config?.offsiteServer ?? ""
        self.backupID = config?.backupID ?? ""
        self.dateRun = config?.dateRun
        self.snapshotnum = config?.snapshotnum
        // parameters choosed by user
        self.parameter8 = config?.parameter8
        self.parameter9 = config?.parameter9
        self.parameter10 = config?.parameter10
        self.parameter11 = config?.parameter11
        self.parameter12 = config?.parameter12
        self.parameter13 = config?.parameter13
        self.parameter14 = config?.parameter14
        self.rsyncdaemon = config?.rsyncdaemon
        // SSH parameters
        self.sshport = config?.sshport
        self.sshkeypathandidentityfile = config?.sshkeypathandidentityfile
        self.profile = config?.profile
        // Snapshots, day to save and last = 1 or every last=0
        self.snapdayoffweek = config?.snapdayoffweek
        self.snaplast = config?.snaplast
        // Pre and post tasks
        self.executepretask = config?.executepretask
        self.pretask = config?.pretask
        self.executeposttask = config?.executeposttask
        self.posttask = config?.posttask
        self.haltshelltasksonerror = config?.haltshelltasksonerror
    }
}
