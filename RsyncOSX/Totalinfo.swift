//
//  Totalinfo.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.05.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

class Totalinfo {
    private var allconfigurations: [Configuration]?
    private var allschedules: [ConfigurationSchedule]?
    private var allschedulesobj: Allschedules?
    private var allloggs: [NSMutableDictionary]?

    init() {
        self.allconfigurations = AllConfigurations().getallconfigurations()
        self.allschedulesobj = Allschedules(nolog: false)
        self.allschedules = Allschedules(nolog: false).getallschedules()
        self.allloggs = ScheduleLoggData(allschedules: self.allschedulesobj).loggdata
    }
}
