//
//  ViewControllerNewVersion.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 02/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerNewVersion : NSViewController {
    
    @IBOutlet weak var reminder: NSButton!
    weak var dismiss_delegate:DismissViewController?
    
    @IBAction func togglereminder(_ sender: NSButton) {
        if self.reminder.state == NSOnState {
            SharingManagerConfiguration.sharedInstance.remindernewVersion = true
        } else {
            SharingManagerConfiguration.sharedInstance.remindernewVersion = false
        }
    }
    @IBAction func changelogg(_ sender: NSButton) {
        NSWorkspace.shared().open(URL(string: "https://rsyncosx.blogspot.no/2016/03/revision-history.html")!)
    }
    
    @IBAction func download(_ sender: NSButton) {
        if (SharingManagerConfiguration.sharedInstance.testRun == false) {
            NSWorkspace.shared().open(URL(string: SharingManagerConfiguration.sharedInstance.URLnewVersion!)!)
        }
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
    
    @IBAction func dismiss(_ sender: NSButton) {
       self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Dismisser is root controller
        if let pvc2 = self.presenting as? ViewControllertabMain {
            self.dismiss_delegate = pvc2
        }
    }
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // check for new version
        // if true present download
        self.reminder.state = NSOffState
    }
    
}
