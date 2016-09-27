//
//  ViewControllerUserconfiguration.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 30/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

protocol ReadConfigurationsAgain : class {
    func readConfigurations()
}

class ViewControllerUserconfiguration : NSViewController {
    
    var dirty:Bool = false
    
    var userconfig:userconfiguration?
    // Delegate to read configurations after toggeling between
    // test- and real mode
    weak var readconfigurations_delegate:ReadConfigurationsAgain?
    // Dismisser
    weak var dismiss_delegate:DismissViewController?

    
    
    @IBOutlet weak var rsyncPath: NSTextField!
    @IBOutlet weak var version3rsync: NSButton!
    @IBOutlet weak var detailedlogging: NSButton!
    @IBOutlet weak var scheduledTaskdisableExecute: NSTextField!
    
    @IBAction func toggleversion3rsync(_ sender: NSButton) {
        if (self.version3rsync.state == NSOnState) {
            SharingManagerConfiguration.sharedInstance.rsyncVer3 = true
            config.sharedInstance.version3rsync = 1
        } else {
            SharingManagerConfiguration.sharedInstance.rsyncVer3 = false
            config.sharedInstance.version3rsync = 0
        }
    }
    
    @IBOutlet weak var RsyncOSXtest: NSButton!
    
    @IBAction func toggleRsyncOSXtest(_ sender: NSButton) {
        SharingManagerSchedule.sharedInstance.cleanAllSchedules()
        if (self.RsyncOSXtest.state == NSOnState) {
            SharingManagerConfiguration.sharedInstance.testRun = true
            
        } else {
            SharingManagerConfiguration.sharedInstance.testRun = false
        }
        SharingManagerConfiguration.sharedInstance.setDataDirty(dirty: true)
        // Load all tasks into memory
        SharingManagerConfiguration.sharedInstance.getAllConfigurationsandArguments()
        self.readconfigurations_delegate?.readConfigurations()

    }
    
    @IBAction func toggleDetailedlogging(_ sender: NSButton) {
        if (self.detailedlogging.state == NSOnState) {
            SharingManagerConfiguration.sharedInstance.detailedlogging = true
            config.sharedInstance.detailedlogging = 1
            
        } else {
            SharingManagerConfiguration.sharedInstance.detailedlogging = false
            config.sharedInstance.detailedlogging = 0
        }
        self.dirty = true
    }
    
    @IBAction func close(_ sender: NSButton) {
        if (self.dirty) {
            // Before closing save changed configuration
            self.setRsyncPath()
            self.setscheduledTaskdisableExecute()
            _ = storeAPI.sharedInstance.saveuserconfig()
        }
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
    
    private func setRsyncPath(){
        if (!self.rsyncPath.stringValue.isEmpty) {
            if (!rsyncPath.stringValue.hasSuffix("/")){
                rsyncPath.stringValue = rsyncPath.stringValue + "/"
                config.sharedInstance.rsyncPath = rsyncPath.stringValue
                SharingManagerConfiguration.sharedInstance.rsyncPath = rsyncPath.stringValue
            }
        } else {
            config.sharedInstance.rsyncPath = nil
        }
        self.dirty = true
    }
    
    private func setscheduledTaskdisableExecute() {
        if (!self.scheduledTaskdisableExecute.stringValue.isEmpty) {
            if let time = Double(self.scheduledTaskdisableExecute.stringValue) {
                SharingManagerConfiguration.sharedInstance.scheduledTaskdisableExecute = time
                config.sharedInstance.scheduledTaskdisableExecute = time
            } else {
                self.scheduledTaskdisableExecute.stringValue = String(config.sharedInstance.scheduledTaskdisableExecute)
            }
        } else {
            self.scheduledTaskdisableExecute.stringValue = String(config.sharedInstance.scheduledTaskdisableExecute)
        }
        self.dirty = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Read userconfiguration
        userconfig = userconfiguration(configRsyncOSX: nil)
        if let pvc = self.presenting as? ViewControllertabMain {
            self.readconfigurations_delegate = pvc
        }
        // Dismisser is root controller
        if let pvc2 = self.presenting as? ViewControllertabMain {
            self.dismiss_delegate = pvc2
        }

    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // Only temporary setting
        if (userconfig!.testRun == true) {
            self.RsyncOSXtest.state = NSOnState
        } else {
            self.RsyncOSXtest.state = NSOffState
        }
        self.dirty = false
        // Set userconfig
        self.version3rsync.state = config.sharedInstance.version3rsync
        self.detailedlogging.state = config.sharedInstance.detailedlogging
        if (config.sharedInstance.rsyncPath != nil) {
            self.rsyncPath.stringValue = config.sharedInstance.rsyncPath!
        }
        self.scheduledTaskdisableExecute.stringValue = String(config.sharedInstance.scheduledTaskdisableExecute)
        
    }
    
}
