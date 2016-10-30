//
//  ViewControllerScheduledBackupInWork.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 30/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerScheduledBackupinWork : NSViewController {
    
    // Dismisser
    weak var dismiss_delegate:DismissViewController?
    
    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var remoteCatalog: NSTextField!
    @IBOutlet weak var remoteServer: NSTextField!
    @IBOutlet weak var schedule: NSTextField!
    @IBOutlet weak var startDate: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting the source for delegate function
        if let pvc = self.presenting as? ViewControllertabMain {
            // Dismisser is root controller
            self.dismiss_delegate = pvc
        }
        self.setInfo()
       
    }
    
    @IBAction func close(_ sender: NSButton) {
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
    
    private func setInfo() {
        if let dict:NSDictionary = SharingManagerSchedule.sharedInstance.scheduledJob {
            self.startDate.stringValue = String(describing: dict.value(forKey: "start") as! Date)
            self.schedule.stringValue = (dict.value(forKey: "schedule") as? String)!
            let hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
            let index = SharingManagerConfiguration.sharedInstance.getIndex(hiddenID)
            let config:configuration = SharingManagerConfiguration.sharedInstance.getConfigurations()[index]
            self.remoteServer.stringValue = config.offsiteServer
            self.remoteCatalog.stringValue = config.offsiteCatalog
            self.localCatalog.stringValue = config.localCatalog
        }
    }
    
    
}
