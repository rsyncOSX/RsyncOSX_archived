//
//  ConvertOneConfig.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 25/05/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable trailing_comma

import Foundation

struct ConvertOneConfig {
    var config: Configuration?

    var dict: NSMutableDictionary {
        let row: NSMutableDictionary = [
            "taskCellID": self.config?.task ?? "",
            DictionaryStrings.hiddenID.rawValue: self.config?.hiddenID ?? "",
            "localCatalogCellID": self.config?.localCatalog ?? "",
            "offsiteCatalogCellID": self.config?.offsiteCatalog ?? "",
            "offsiteUsernameID": self.config?.offsiteUsername ?? "",
            "offsiteServerCellID": self.config?.offsiteServer ?? "",
            "backupIDCellID": self.config?.backupID ?? "",
            "runDateCellID": self.config?.dateRun ?? "",
            DictionaryStrings.daysID.rawValue: self.config?.dayssincelastbackup ?? "",
            DictionaryStrings.markdays.rawValue: self.config?.markdays ?? "",
            "snapCellID": self.config?.snapshotnum ?? "",
            DictionaryStrings.selectCellID.rawValue: 0,
            "executepretask": self.config?.executepretask ?? 0,
            "executeposttask": self.config?.executeposttask ?? 0,
        ]
        return row
    }

    init(config: Configuration) {
        self.config = config
    }
}
