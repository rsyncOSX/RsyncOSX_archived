//
//  userconfiguration.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length cyclomatic_complexity function_body_length

import Foundation

// Reading userconfiguration from file into RsyncOSX
struct Userconfiguration {
    private func readUserconfiguration(dict: NSDictionary) {
        // Another version of rsync
        if let version3rsync = dict.value(forKey: "version3Rsync") as? Int {
            if version3rsync == 1 {
                ViewControllerReference.shared.rsyncversion3 = true
            } else {
                ViewControllerReference.shared.rsyncversion3 = false
            }
        }
        // Detailed logging
        if let detailedlogging = dict.value(forKey: "detailedlogging") as? Int {
            if detailedlogging == 1 {
                ViewControllerReference.shared.detailedlogging = true
            } else {
                ViewControllerReference.shared.detailedlogging = false
            }
        }
        // Optional path for rsync
        if let rsyncPath = dict.value(forKey: "rsyncPath") as? String {
            ViewControllerReference.shared.localrsyncpath = rsyncPath
        }
        // Temporary path for restores single files or directory
        if let restorePath = dict.value(forKey: "restorePath") as? String {
            if restorePath.count > 0 {
                ViewControllerReference.shared.temporarypathforrestore = restorePath
            } else {
                ViewControllerReference.shared.temporarypathforrestore = nil
            }
        }
        // Mark tasks
        if let marknumberofdayssince = dict.value(forKey: "marknumberofdayssince") as? String {
            if Double(marknumberofdayssince)! > 0 {
                let oldmarknumberofdayssince = ViewControllerReference.shared.marknumberofdayssince
                ViewControllerReference.shared.marknumberofdayssince = Double(marknumberofdayssince)!
                if oldmarknumberofdayssince != ViewControllerReference.shared.marknumberofdayssince {
                    weak var reloadconfigurationsDelegate: Createandreloadconfigurations?
                    reloadconfigurationsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
                    reloadconfigurationsDelegate?.createandreloadconfigurations()
                }
            }
        }
        // Paths rsyncOSX and RsyncOSXsched
        if let pathrsyncosx = dict.value(forKey: "pathrsyncosx") as? String {
            if pathrsyncosx.isEmpty == true {
                ViewControllerReference.shared.pathrsyncosx = nil
            } else {
                ViewControllerReference.shared.pathrsyncosx = pathrsyncosx
            }
        }
        if let pathrsyncosxsched = dict.value(forKey: "pathrsyncosxsched") as? String {
            if pathrsyncosxsched.isEmpty == true {
                ViewControllerReference.shared.pathrsyncosxsched = nil
            } else {
                ViewControllerReference.shared.pathrsyncosxsched = pathrsyncosxsched
            }
        }
        // No logging, minimum logging or full logging
        if let minimumlogging = dict.value(forKey: "minimumlogging") as? Int {
            if minimumlogging == 1 {
                ViewControllerReference.shared.minimumlogging = true
            } else {
                ViewControllerReference.shared.minimumlogging = false
            }
        }
        if let fulllogging = dict.value(forKey: "fulllogging") as? Int {
            if fulllogging == 1 {
                ViewControllerReference.shared.fulllogging = true
            } else {
                ViewControllerReference.shared.fulllogging = false
            }
        }
        if let automaticexecutelocalvolumes = dict.value(forKey: "automaticexecutelocalvolumes") as? Int {
            if automaticexecutelocalvolumes == 1 {
                ViewControllerReference.shared.automaticexecutelocalvolumes = true
            } else {
                ViewControllerReference.shared.automaticexecutelocalvolumes = false
            }
        }
        if let environment = dict.value(forKey: "environment") as? String {
            ViewControllerReference.shared.environment = environment
        }
        if let environmentvalue = dict.value(forKey: "environmentvalue") as? String {
            ViewControllerReference.shared.environmentvalue = environmentvalue
        }
        if let haltonerror = dict.value(forKey: "haltonerror") as? Int {
            if haltonerror == 1 {
                ViewControllerReference.shared.haltonerror = true
            } else {
                ViewControllerReference.shared.haltonerror = false
            }
        }
        if let sshkeypathandidentityfile = dict.value(forKey: "sshkeypathandidentityfile") as? String {
            ViewControllerReference.shared.sshkeypathandidentityfile = sshkeypathandidentityfile
        }
        if let sshport = dict.value(forKey: "sshport") as? Int {
            ViewControllerReference.shared.sshport = sshport
        }
    }

    init(userconfigRsyncOSX: [NSDictionary]) {
        if userconfigRsyncOSX.count > 0 {
            self.readUserconfiguration(dict: userconfigRsyncOSX[0])
        }
        _ = Setrsyncpath()
        _ = RsyncVersionString()
    }
}
