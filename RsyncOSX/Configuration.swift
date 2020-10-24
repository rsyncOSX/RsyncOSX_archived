//
//  Created by Thomas Evensen on 08/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity function_body_length line_length

import Foundation

struct Configuration {
    var hiddenID: Int
    var task: String
    var localCatalog: String
    var offsiteCatalog: String
    var offsiteUsername: String
    var parameter1: String
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
    // Calculated days since last backup
    var dayssincelastbackup: String?
    var markdays: Bool = false
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

    var lastruninseconds: Double? {
        if let date = self.dateRun {
            let lastbackup = date.en_us_date_from_string()
            let seconds: TimeInterval = lastbackup.timeIntervalSinceNow
            return seconds * (-1)
        } else {
            return nil
        }
    }

    init(dictionary: NSDictionary) {
        // Parameters 1 - 6 is mandatory, set by RsyncOSX.
        self.hiddenID = (dictionary.object(forKey: "hiddenID") as? Int) ?? 0
        self.task = dictionary.object(forKey: "task") as? String ?? ""
        self.localCatalog = dictionary.object(forKey: "localCatalog") as? String ?? ""
        self.offsiteCatalog = dictionary.object(forKey: "offsiteCatalog") as? String ?? ""
        self.offsiteUsername = dictionary.object(forKey: "offsiteUsername") as? String ?? ""
        self.parameter1 = dictionary.object(forKey: "parameter1") as? String ?? ""
        self.parameter2 = dictionary.object(forKey: "parameter2") as? String ?? ""
        self.parameter3 = dictionary.object(forKey: "parameter3") as? String ?? ""
        self.parameter4 = dictionary.object(forKey: "parameter4") as? String ?? ""
        self.parameter5 = dictionary.object(forKey: "parameter5") as? String ?? ""
        self.parameter6 = dictionary.object(forKey: "parameter6") as? String ?? ""
        self.offsiteServer = dictionary.object(forKey: "offsiteServer") as? String ?? ""
        self.backupID = dictionary.object(forKey: "backupID") as? String ?? ""
        if let snapshotnum = dictionary.object(forKey: "snapshotnum") as? Int {
            self.snapshotnum = snapshotnum
            self.snapdayoffweek = dictionary.object(forKey: "snapdayoffweek") as? String ?? StringDayofweek.Sunday.rawValue
            self.snaplast = dictionary.object(forKey: "snaplast") as? Int ?? 1
        }
        // Last run of task
        if let dateRun = dictionary.object(forKey: "dateRun") {
            self.dateRun = dateRun as? String
            if let secondssince = self.lastruninseconds {
                self.dayssincelastbackup = String(format: "%.2f", secondssince / (60 * 60 * 24))
                if secondssince / (60 * 60 * 24) > ViewControllerReference.shared.marknumberofdayssince {
                    self.markdays = true
                }
            }
        }
        // Parameters 8 - 14 is user selected, as well as ssh parameters.
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
        if let sshidentityfile = dictionary.object(forKey: "sshkeypathandidentityfile") {
            self.sshkeypathandidentityfile = sshidentityfile as? String
        }
        // Pre and post tasks
        if let pretask = dictionary.object(forKey: "pretask") {
            self.pretask = pretask as? String
        }
        if let executepretask = dictionary.object(forKey: "executepretask") {
            self.executepretask = executepretask as? Int
        }
        if let posttask = dictionary.object(forKey: "posttask") {
            self.posttask = posttask as? String
        }
        if let executeposttask = dictionary.object(forKey: "executeposttask") {
            self.executeposttask = executeposttask as? Int
        }
        if let haltshelltasksonerror = dictionary.object(forKey: "haltshelltasksonerror") {
            self.haltshelltasksonerror = haltshelltasksonerror as? Int
        }
    }

    init(dictionary: NSMutableDictionary) {
        self.hiddenID = dictionary.object(forKey: "hiddenID") as? Int ?? 0
        self.task = dictionary.object(forKey: "task") as? String ?? ""
        self.localCatalog = dictionary.object(forKey: "localCatalog") as? String ?? ""
        self.offsiteCatalog = dictionary.object(forKey: "offsiteCatalog") as? String ?? ""
        self.offsiteUsername = dictionary.object(forKey: "offsiteUsername") as? String ?? ""
        self.parameter1 = dictionary.object(forKey: "parameter1") as? String ?? ""
        self.parameter2 = dictionary.object(forKey: "parameter2") as? String ?? ""
        self.parameter3 = dictionary.object(forKey: "parameter3") as? String ?? ""
        self.parameter4 = dictionary.object(forKey: "parameter4") as? String ?? ""
        self.parameter5 = dictionary.object(forKey: "parameter5") as? String ?? ""
        self.parameter6 = dictionary.object(forKey: "parameter6") as? String ?? ""
        self.offsiteServer = dictionary.object(forKey: "offsiteServer") as? String ?? ""
        self.backupID = dictionary.object(forKey: "backupID") as? String ?? ""
    }
}

extension Configuration: Hashable, Equatable {
    static func == (lhs: Configuration, rhs: Configuration) -> Bool {
        return lhs.localCatalog == rhs.localCatalog &&
            lhs.offsiteCatalog == rhs.offsiteCatalog &&
            lhs.offsiteUsername == rhs.offsiteUsername &&
            lhs.offsiteServer == rhs.offsiteServer &&
            lhs.hiddenID == rhs.hiddenID &&
            lhs.task == rhs.task &&
            lhs.parameter1 == rhs.parameter1 &&
            lhs.parameter2 == rhs.parameter2 &&
            lhs.parameter3 == rhs.parameter3 &&
            lhs.parameter4 == rhs.parameter4 &&
            lhs.parameter5 == rhs.parameter5 &&
            lhs.parameter6 == rhs.parameter6 &&
            lhs.parameter14 == rhs.parameter14
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.localCatalog)
        hasher.combine(self.offsiteUsername)
        hasher.combine(self.offsiteServer)
        hasher.combine(String(self.hiddenID))
        hasher.combine(self.task)
        hasher.combine(self.parameter1)
        hasher.combine(self.parameter2)
        hasher.combine(self.parameter3)
        hasher.combine(self.parameter4)
        hasher.combine(self.parameter5)
        hasher.combine(self.parameter6)
        hasher.combine(self.parameter14)
    }
}
