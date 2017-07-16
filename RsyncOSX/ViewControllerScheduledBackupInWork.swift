//
//  ViewControllerScheduledBackupInWork.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 30/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerScheduledBackupinWork: NSViewController {

    // Dismisser
    weak var dismiss_delegate: DismissViewController?
    var waitToClose: Timer?
    var closeIn: Timer?
    var seconds: Int?

    @IBOutlet weak var closeinseconds: NSTextField!
    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var remoteCatalog: NSTextField!
    @IBOutlet weak var remoteServer: NSTextField!
    @IBOutlet weak var schedule: NSTextField!
    @IBOutlet weak var startDate: NSTextField!

    @objc private func closeView() {
        self.waitToClose?.invalidate()
        self.closeIn?.invalidate()
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }

    @IBAction func close(_ sender: NSButton) {
        // Invalidate timer to close view 
        self.waitToClose?.invalidate()
        self.closeIn?.invalidate()
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }

    private func setInfo() {
        if let dict: NSDictionary = SharingManagerSchedule.sharedInstance.scheduledJob {
            self.startDate.stringValue = String(describing: dict.value(forKey: "start") as! Date)
            self.schedule.stringValue = (dict.value(forKey: "schedule") as? String)!
            let hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
            let index = SharingManagerConfiguration.sharedInstance.getIndex(hiddenID)
            let config: Configuration = SharingManagerConfiguration.sharedInstance.getConfigurations()[index]
            self.remoteServer.stringValue = config.offsiteServer
            self.remoteCatalog.stringValue = config.offsiteCatalog
            self.localCatalog.stringValue = config.localCatalog
        }
    }

    @objc private func setSecondsView() {
        self.seconds = self.seconds! - 1
        self.closeinseconds.stringValue = "Close automatically in : " + String(self.seconds!) + " seconds"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting the source for delegate function
        if let pvc = self.presenting as? ViewControllertabMain {
            // Dismisser is root controller
            self.dismiss_delegate = pvc
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.seconds = 10
        self.setInfo()
        self.waitToClose = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(closeView), userInfo: nil, repeats: false)
        self.closeIn = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setSecondsView), userInfo: nil, repeats: true)
        self.closeinseconds.stringValue = "Close automatically in : 10 seconds"
    }

}
