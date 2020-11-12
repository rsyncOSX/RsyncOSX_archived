//
//  Validatenewconfigs.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 08/01/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length cyclomatic_complexity

import Foundation

struct Validatenewconfigs: Connected {
    var validated: Bool = false
    init(dict: NSMutableDictionary) {
        guard (dict.value(forKey: DictionaryStrings.localCatalog.rawValue) as? String)?.isEmpty == false, (dict.value(forKey: DictionaryStrings.offsiteCatalog.rawValue) as? String)?.isEmpty == false else { return }
        guard (dict.value(forKey: DictionaryStrings.localCatalog.rawValue) as? String) != "/" || (dict.value(forKey: DictionaryStrings.offsiteCatalog.rawValue) as? String) != "/" else { return }
        if (dict.value(forKey: DictionaryStrings.offsiteServer.rawValue) as? String)?.isEmpty == false {
            guard (dict.value(forKey: DictionaryStrings.offsiteUsername.rawValue) as? String)?.isEmpty == false else { return }
        }
        if (dict.value(forKey: DictionaryStrings.offsiteUsername.rawValue) as? String)?.isEmpty == false {
            guard (dict.value(forKey: DictionaryStrings.offsiteServer.rawValue) as? String)?.isEmpty == false else { return }
        }
        if (dict.value(forKey: DictionaryStrings.task.rawValue) as? String) == ViewControllerReference.shared.snapshot {
            guard (dict.value(forKey: DictionaryStrings.snapshotnum.rawValue) as? Int) == 1 else { return }
            // also check if connected because creating base remote catalog if remote server
            // must be connected to create remote base catalog
            if let remoteserver = dict.value(forKey: DictionaryStrings.offsiteServer.rawValue) as? String {
                guard connected(server: remoteserver) else { return }
            }
        }
        if (dict.value(forKey: DictionaryStrings.task.rawValue) as? String) == ViewControllerReference.shared.syncremote {
            guard (dict.value(forKey: DictionaryStrings.offsiteServer.rawValue) as? String)?.isEmpty == false, (dict.value(forKey: DictionaryStrings.offsiteUsername.rawValue) as? String)?.isEmpty == false else { return }
        }
        self.validated = true
    }

    init(dict: NSMutableDictionary, Edit _: Bool) {
        guard (dict.value(forKey: DictionaryStrings.localCatalogCellID.rawValue) as? String)?.isEmpty == false, (dict.value(forKey: DictionaryStrings.offsiteCatalogCellID.rawValue) as? String)?.isEmpty == false else { return }
        guard (dict.value(forKey: DictionaryStrings.localCatalogCellID.rawValue) as? String) != "/" || (dict.value(forKey: DictionaryStrings.offsiteCatalogCellID.rawValue) as? String) != "/" else { return }
        if (dict.value(forKey: DictionaryStrings.offsiteServerCellID.rawValue) as? String)?.isEmpty == false {
            guard (dict.value(forKey: DictionaryStrings.offsiteUsernameID.rawValue) as? String)?.isEmpty == false else { return }
        }
        if (dict.value(forKey: DictionaryStrings.offsiteUsernameID.rawValue) as? String)?.isEmpty == false {
            guard (dict.value(forKey: DictionaryStrings.offsiteServerCellID.rawValue) as? String)?.isEmpty == false else { return }
        }
        self.validated = true
    }
}
