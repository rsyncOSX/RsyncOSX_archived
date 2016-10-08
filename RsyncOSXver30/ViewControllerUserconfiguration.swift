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
        } else {
            SharingManagerConfiguration.sharedInstance.rsyncVer3 = false
        }
        self.dirty = true
    }
    
    @IBOutlet weak var RsyncOSXtest: NSButton!
    
    // We dont save this state, only valid in this run
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
        } else {
            SharingManagerConfiguration.sharedInstance.detailedlogging = false
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
        if (self.rsyncPath.stringValue.isEmpty == false) {
            if (rsyncPath.stringValue.hasSuffix("/") == false){
                rsyncPath.stringValue = rsyncPath.stringValue + "/"
                SharingManagerConfiguration.sharedInstance.rsyncPath = rsyncPath.stringValue
            }
        } else {
            SharingManagerConfiguration.sharedInstance.rsyncPath = nil
        }
        self.dirty = true
    }
    
    private func setscheduledTaskdisableExecute() {
        if (self.scheduledTaskdisableExecute.stringValue.isEmpty == false) {
            if let time = Double(self.scheduledTaskdisableExecute.stringValue) {
                SharingManagerConfiguration.sharedInstance.scheduledTaskdisableExecute = time
            }
        } else {
            SharingManagerConfiguration.sharedInstance.scheduledTaskdisableExecute = 0
        }
        self.dirty = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let pvc = self.presenting as? ViewControllertabMain {
            self.readconfigurations_delegate = pvc
        }
        // Dismisser is root controller
        if let pvc2 = self.presenting as? ViewControllertabMain {
            self.dismiss_delegate = pvc2
        } else if let pvc2 = self.presenting as? ViewControllertabSchedule{
            self.dismiss_delegate = pvc2
        } else if let pvc2 = self.presenting as? ViewControllerNewConfigurations {
            self.dismiss_delegate = pvc2
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.dirty = false
        // Set userconfig
        self.RsyncOSXtest.state = NSOffState
        if (SharingManagerConfiguration.sharedInstance.rsyncVer3) {
            self.version3rsync.state = 1
        } else {
            self.version3rsync.state = 0
        }
        if (SharingManagerConfiguration.sharedInstance.detailedlogging) {
            self.detailedlogging.state = 1
        } else {
            self.detailedlogging.state = 0
        }
        if (SharingManagerConfiguration.sharedInstance.rsyncPath != nil) {
            self.rsyncPath.stringValue = SharingManagerConfiguration.sharedInstance.rsyncPath!
        } else {
            self.rsyncPath.stringValue = ""
        }
        self.scheduledTaskdisableExecute.stringValue = String(SharingManagerConfiguration.sharedInstance.scheduledTaskdisableExecute)
    }
    
}
