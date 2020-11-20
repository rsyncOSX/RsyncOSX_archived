//
//  PersistantStorage.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/11/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

final class PersistentStorage {
    var configJSON: PersistentStorageConfigurationJSON?
    var scheduleJSON: PersistentStorageSchedulingJSON?
    var configPLIST: PersistentStorageConfigurationPLIST?
    var schedulePLIST: PersistentStorageSchedulingPLIST?
    var whattoreadorwrite: WhatToReadWrite?

    func saveMemoryToPersistentStore() {
        if ViewControllerReference.shared.json {
            switch self.whattoreadorwrite {
            case .configuration:
                self.configJSON?.saveconfigInMemoryToPersistentStore()
            case .schedule:
                self.scheduleJSON?.savescheduleInMemoryToPersistentStore()
            default:
                return
            }
        } else {
            switch self.whattoreadorwrite {
            case .configuration:
                self.configPLIST?.saveconfigInMemoryToPersistentStore()
            case .schedule:
                self.schedulePLIST?.savescheduleInMemoryToPersistentStore()
            default:
                return
            }
        }
    }

    init(profile: String, whattoreadorwrite: WhatToReadWrite, readonly: Bool) {
        self.whattoreadorwrite = whattoreadorwrite
        if ViewControllerReference.shared.json {
            switch whattoreadorwrite {
            case .configuration:
                self.configJSON = PersistentStorageConfigurationJSON(profile: profile, readonly: readonly)
            case .schedule:
                self.scheduleJSON = PersistentStorageSchedulingJSON(profile: profile, readonly: readonly)
            default:
                return
            }
        } else {
            switch whattoreadorwrite {
            case .configuration:
                self.configPLIST = PersistentStorageConfigurationPLIST(profile: profile, readonly: readonly)
            case .schedule:
                self.schedulePLIST = PersistentStorageSchedulingPLIST(profile: profile, readonly: readonly)
            default:
                return
            }
        }
    }

    init(profile: String, whattoreadorwrite: WhatToReadWrite) {
        self.whattoreadorwrite = whattoreadorwrite
        if ViewControllerReference.shared.json {
            switch whattoreadorwrite {
            case .configuration:
                self.configJSON = PersistentStorageConfigurationJSON(profile: profile)
            case .schedule:
                self.scheduleJSON = PersistentStorageSchedulingJSON(profile: profile)
            default:
                return
            }
        } else {
            switch whattoreadorwrite {
            case .configuration:
                self.configPLIST = PersistentStorageConfigurationPLIST(profile: profile)
            case .schedule:
                self.schedulePLIST = PersistentStorageSchedulingPLIST(profile: profile)
            default:
                return
            }
        }
    }
    
    deinit {
        self.configJSON = nil
        self.configPLIST = nil
        self.scheduleJSON = nil
        self.schedulePLIST = nil
    }
}
