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
            DictionaryStrings.taskCellID.rawValue: config?.task ?? "",
            DictionaryStrings.hiddenID.rawValue: config?.hiddenID ?? "",
            DictionaryStrings.localCatalogCellID.rawValue: config?.localCatalog ?? "",
            DictionaryStrings.offsiteCatalogCellID.rawValue: config?.offsiteCatalog ?? "",
            DictionaryStrings.offsiteUsernameID.rawValue: config?.offsiteUsername ?? "",
            DictionaryStrings.offsiteServerCellID.rawValue: config?.offsiteServer ?? "",
            DictionaryStrings.backupIDCellID.rawValue: config?.backupID ?? "",
            DictionaryStrings.runDateCellID.rawValue: config?.dateRun ?? "",
            DictionaryStrings.daysID.rawValue: config?.dayssincelastbackup ?? "",
            DictionaryStrings.markdays.rawValue: config?.markdays ?? "",
            DictionaryStrings.snapCellID.rawValue: config?.snapshotnum ?? "",
            DictionaryStrings.selectCellID.rawValue: 0,
            DictionaryStrings.executepretask.rawValue: config?.executepretask ?? 0,
            DictionaryStrings.executeposttask.rawValue: config?.executeposttask ?? 0,
        ]
        return row
    }

    init(config: Configuration) {
        self.config = config
    }
}
