//
//  Rsync.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 10.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class Rsync: processCmd {
    
    init (arguments:Array<String>?) {
        
        super.init(command: nil, arguments: arguments, aScheduledOperation: false)
        // Process is inated from Main
        if let pvc = SharingManagerConfiguration.sharedInstance.ViewControllertabMain as? ViewControllertabMain {
            self.delegate_update = pvc
        }
    }
    
}

