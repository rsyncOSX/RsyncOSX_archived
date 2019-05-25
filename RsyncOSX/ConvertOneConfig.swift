//
//  ConvertOneConfig.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 25/05/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

struct ConvertOneConfig {
    var config: Configuration?

    var dict: NSMutableDictionary {
        let row: NSMutableDictionary = [
            "taskCellID": self.config!.task,
            "hiddenID": self.config!.hiddenID,
            "localCatalogCellID": self.config!.localCatalog,
            "offsiteCatalogCellID": self.config!.offsiteCatalog,
            "offsiteServerCellID": self.config!.offsiteServer,
            "backupIDCellID": self.config!.backupID,
            "runDateCellID": self.config!.dateRun!,
            "daysID": self.config!.dayssincelastbackup ?? "",
            "markdays": self.config!.markdays,
            "selectCellID": 0]
        return row
    }

    var dict2: NSDictionary {
        let row: NSDictionary = [
            "taskCellID": self.config!.task,
            "hiddenID": self.config!.hiddenID,
            "localCatalogCellID": self.config!.localCatalog,
            "offsiteCatalogCellID": self.config!.offsiteCatalog,
            "offsiteServerCellID": self.config!.offsiteServer,
            "backupIDCellID": self.config!.backupID,
            "runDateCellID": self.config!.dateRun!,
            "daysID": self.config!.dayssincelastbackup ?? "",
            "markdays": self.config!.markdays,
            "selectCellID": 0]
        return row
    }

    var dict3: NSMutableDictionary {
        var batch: Int = 0
        if self.config!.batch == "yes" {
            batch = 1
        }
        let row: NSMutableDictionary = [
            "taskCellID": self.config!.task,
            "batchCellID": batch,
            "localCatalogCellID": self.config!.localCatalog,
            "offsiteCatalogCellID": self.config!.offsiteCatalog,
            "offsiteServerCellID": self.config!.offsiteServer,
            "backupIDCellID": self.config!.backupID,
            "runDateCellID": self.config!.dateRun ?? "",
            "daysID": self.config!.dayssincelastbackup ?? "",
            "snapCellID": self.config!.snapshotnum ?? ""]
        return row
    }

    init(config: Configuration) {
        self.config = config
    }
}
