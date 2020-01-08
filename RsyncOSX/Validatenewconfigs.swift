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
