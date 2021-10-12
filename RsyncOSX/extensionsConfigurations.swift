//
//  extensionsConfigurations.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.08.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

// Protocol for returning object Configurations
protocol GetConfigurationsObject: AnyObject {
    func getconfigurationsobject() -> Configurations?
}

protocol SetConfigurations {
    var configurationsDelegate: GetConfigurationsObject? { get }
}

extension SetConfigurations {
    var configurationsDelegate: GetConfigurationsObject? {
        return SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    var configurations: Configurations? {
        return configurationsDelegate?.getconfigurationsobject()
    }
}

// Protocol for doing a refresh of tabledata
protocol Reloadandrefresh: AnyObject {
    func reloadtabledata()
}

protocol ReloadTable {
    var reloadDelegateMain: Reloadandrefresh? { get }
    var reloadDelegateSchedule: Reloadandrefresh? { get }
    var reloadDelegateLoggData: Reloadandrefresh? { get }
    var reloadDelegateSnapshot: Reloadandrefresh? { get }
}

extension ReloadTable {
    var reloadDelegateMain: Reloadandrefresh? {
        return SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    var reloadDelegateSchedule: Reloadandrefresh? {
        return SharedReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllerSchedule
    }

    var reloadDelegateLoggData: Reloadandrefresh? {
        return SharedReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
    }

    var reloadDelegateSnapshot: Reloadandrefresh? {
        return SharedReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
    }
}

// Used to select argument
enum ArgumentsRsync {
    case arg
    case argdryRun
    case argdryRunlocalcataloginfo
}

// Enum which resource to return
enum ResourceInConfiguration {
    case remoteCatalog
    case localCatalog
    case offsiteServer
    case task
    case backupid
    case offsiteusername
    case sshport
}
