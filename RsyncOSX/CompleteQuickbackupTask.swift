//
//  CompleteQuickbackupTask.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/01/2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

// Class for completion of Operation objects when Process object termination.
// The object does also kicks of next scheduled job by setting new waiter time.
final class CompleteQuickbackupTask: SetConfigurations, SetSchedules {
    private var index: Int?
    // Function for update result of quickbacuptask the job
    // This function is executed when rsyn process terminates
    func finalizeScheduledJob(outputprocess: OutputProcess?) {
        if let index = self.index {
            self.configurations?.setCurrentDateonConfiguration(index: index, outputprocess: outputprocess)
            self.schedulesDelegate?.reloadschedulesobject()
        }
    }

    init(dict: NSDictionary) {
        if let hiddenID = dict.value(forKey: "hiddenID") as? Int {
            self.index = self.configurations?.getIndex(hiddenID)
        }
    }
}
