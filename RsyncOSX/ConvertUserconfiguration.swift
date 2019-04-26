//
//  ConvertUserconfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26/04/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

final class ConvertUserconfiguration {

    // Converting user configuration to array of NSDictionary
    func convertUserconfiguration() -> [NSDictionary] {
        var version3Rsync: Int?
        var detailedlogging: Int?
        var minimumlogging: Int?
        var fulllogging: Int?
        var executeinmenuapp: Int?
        var rsyncPath: String?
        var restorePath: String?
        var marknumberofdayssince: String?
        var automaticexecutelocalvolumes: Int?
        var array = [NSDictionary]()

        if ViewControllerReference.shared.rsyncVer3 {
            version3Rsync = 1
        } else {
            version3Rsync = 0
        }
        if ViewControllerReference.shared.detailedlogging {
            detailedlogging = 1
        } else {
            detailedlogging = 0
        }
        if ViewControllerReference.shared.minimumlogging {
            minimumlogging = 1
        } else {
            minimumlogging = 0
        }
        if ViewControllerReference.shared.fulllogging {
            fulllogging = 1
        } else {
            fulllogging = 0
        }
        if ViewControllerReference.shared.rsyncPath != nil {
            rsyncPath = ViewControllerReference.shared.rsyncPath!
        }
        if ViewControllerReference.shared.restorePath != nil {
            restorePath = ViewControllerReference.shared.restorePath!
        }
        if ViewControllerReference.shared.executescheduledtasksmenuapp == true {
            executeinmenuapp = 1
        } else {
            executeinmenuapp = 0
        }
        if ViewControllerReference.shared.automaticexecutelocalvolumes {
            automaticexecutelocalvolumes = 1
        } else {
            automaticexecutelocalvolumes = 0
        }
        marknumberofdayssince = String(ViewControllerReference.shared.marknumberofdayssince)
        let dict: NSMutableDictionary = [
            "version3Rsync": version3Rsync ?? 0 as Int,
            "detailedlogging": detailedlogging ?? 0 as Int,
            "minimumlogging": minimumlogging! as Int,
            "fulllogging": fulllogging! as Int,
            "marknumberofdayssince": marknumberofdayssince ?? "5.0",
            "executeinmenuapp": executeinmenuapp ?? 1 as Int,
            "automaticexecutelocalvolumes": automaticexecutelocalvolumes! as Int]
        if rsyncPath != nil {
            dict.setObject(rsyncPath!, forKey: "rsyncPath" as NSCopying)
        }
        if restorePath != nil {
            dict.setObject(restorePath!, forKey: "restorePath" as NSCopying)
        } else {
            dict.setObject("", forKey: "restorePath" as NSCopying)
        }
        if ViewControllerReference.shared.pathrsyncosx != nil {
            dict.setObject(ViewControllerReference.shared.pathrsyncosx!, forKey: "pathrsyncosx" as NSCopying)
        } else {
            dict.setObject("", forKey: "pathrsyncosx" as NSCopying)
        }
        if ViewControllerReference.shared.pathrsyncosxsched != nil {
            dict.setObject(ViewControllerReference.shared.pathrsyncosxsched!, forKey: "pathrsyncosxsched" as NSCopying)
        } else {
            dict.setObject("", forKey: "pathrsyncosxsched" as NSCopying)
        }
        array.append(dict)
        return array
    }
}
