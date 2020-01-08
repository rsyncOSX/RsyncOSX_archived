//
//  Validatenewconfigs.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 08/01/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

struct Validatenewconfigs {
    var validated: Bool = false
    /*
     let dict: NSMutableDictionary = [
                "task": config.task,
                "backupID": config.backupID,
                "localCatalog": config.localCatalog,
                "offsiteCatalog": config.offsiteCatalog,
                "batch": config.batch,
                "offsiteServer": config.offsiteServer,
                "offsiteUsername": config.offsiteUsername,
                "parameter1": config.parameter1,
                "parameter2": config.parameter2,
                "parameter3": config.parameter3,
                "parameter4": config.parameter4,
                "parameter5": config.parameter5,
                "parameter6": config.parameter6,
                "dateRun": config.dateRun!,
                "hiddenID": config.hiddenID,
            ]

     dict.setValue(ViewControllerReference.shared.snapshot, forKey: "task")
     dict.setValue(1, forKey: "snapshotnum")
     ViewControllerReference.shared.syncremote, forKey: "task")
     */
    init(dict: NSMutableDictionary) {
        guard (dict.value(forKey: "localCatalog") as? String)?.isEmpty == false, (dict.value(forKey: "offsiteCatalog") as? String)?.isEmpty == false else { return }
        guard (dict.value(forKey: "localCatalog") as? String) != "/" || (dict.value(forKey: "offsiteCatalog") as? String) != "/" else { return }
        guard (dict.value(forKey: "localCatalog") as? String) != (dict.value(forKey: "offsiteCatalog") as? String) else { return }
        if (dict.value(forKey: "offsiteServer") as? String)?.isEmpty == false {
            guard (dict.value(forKey: "offsiteUsername") as? String)?.isEmpty == false else { return }
        }
        if (dict.value(forKey: "task") as? String) == ViewControllerReference.shared.snapshot {
            guard (dict.value(forKey: "snapshotnum") as? Int) == 1 else { return }
        }
        if (dict.value(forKey: "task") as? String) == ViewControllerReference.shared.syncremote {
            guard (dict.value(forKey: "offsiteServer") as? String)?.isEmpty == false, (dict.value(forKey: "offsiteUsername") as? String)?.isEmpty == false else { return }
        }
        self.validated = true
    }
}
