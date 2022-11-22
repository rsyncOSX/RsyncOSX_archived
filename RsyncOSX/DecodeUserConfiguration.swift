//
//  DecodeUserConfiguration.swift
//  RsyncUI
//
//  Created by Thomas Evensen on 12/02/2022.
//

import Foundation

struct DecodeUserConfiguration: Codable {
    let rsyncversion3: Int?
    // Detailed logging
    let detailedlogging: Int?
    // Logging to logfile
    let minimumlogging: Int?
    let fulllogging: Int?
    // let nologging: Int?
    // Monitor network connection
    let monitornetworkconnection: Int?
    // local path for rsync
    let localrsyncpath: String?
    // temporary path for restore
    let pathforrestore: String?
    // days for mark days since last synchronize
    let marknumberofdayssince: String?
    // Global ssh keypath and port
    let sshkeypathandidentityfile: String?
    let sshport: Int?
    // Environment variable
    let environment: String?
    let environmentvalue: String?
    // Paths
    // Paths
    let pathrsyncosx: String?
    let pathrsyncosxsched: String?
    // Enable schedules
    let enableschdules: Int?

    enum CodingKeys: String, CodingKey {
        case rsyncversion3
        case detailedlogging
        case minimumlogging
        case fulllogging
        // case nologging
        case monitornetworkconnection
        case localrsyncpath
        case pathforrestore
        case marknumberofdayssince
        case sshkeypathandidentityfile
        case sshport
        case environment
        case environmentvalue
        case pathrsyncosx
        case pathrsyncosxsched
        case enableschdules
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        rsyncversion3 = try values.decodeIfPresent(Int.self, forKey: .rsyncversion3)
        detailedlogging = try values.decodeIfPresent(Int.self, forKey: .detailedlogging)
        minimumlogging = try values.decodeIfPresent(Int.self, forKey: .minimumlogging)
        fulllogging = try values.decodeIfPresent(Int.self, forKey: .fulllogging)
        // nologging = try values.decodeIfPresent(Int.self, forKey: .nologging)
        monitornetworkconnection = try values.decodeIfPresent(Int.self, forKey: .monitornetworkconnection)
        localrsyncpath = try values.decodeIfPresent(String.self, forKey: .localrsyncpath)
        pathforrestore = try values.decodeIfPresent(String.self, forKey: .pathforrestore)
        marknumberofdayssince = try values.decodeIfPresent(String.self, forKey: .marknumberofdayssince)
        sshkeypathandidentityfile = try values.decodeIfPresent(String.self, forKey: .sshkeypathandidentityfile)
        sshport = try values.decodeIfPresent(Int.self, forKey: .sshport)
        environment = try values.decodeIfPresent(String.self, forKey: .environment)
        environmentvalue = try values.decodeIfPresent(String.self, forKey: .environmentvalue)
        pathrsyncosx = try values.decodeIfPresent(String.self, forKey: .pathrsyncosx)
        pathrsyncosxsched = try values.decodeIfPresent(String.self, forKey: .pathrsyncosxsched)
        enableschdules = try values.decodeIfPresent(Int.self, forKey: .enableschdules)
    }
}
