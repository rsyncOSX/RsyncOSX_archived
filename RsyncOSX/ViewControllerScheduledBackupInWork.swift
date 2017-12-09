//
//  ViewControllerScheduledBackupInWork.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 30/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

class ViewControllerScheduledBackupinWork: NSViewController, SetConfigurations, SetSchedules, SetDismisser {

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
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    @IBAction func close(_ sender: NSButton) {
        self.waitToClose?.invalidate()
        self.closeIn?.invalidate()
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    private func setInfo() {
        if let dict: NSDictionary = ViewControllerReference.shared.scheduledTask {
            self.startDate.stringValue = String(describing: (dict.value(forKey: "start") as? Date)!)
            self.schedule.stringValue = (dict.value(forKey: "schedule") as? String)!
            let hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
            let index = self.configurations!.getIndex(hiddenID)
            let config: Configuration = self.configurations!.getConfigurations()[index]
            self.remoteServer.stringValue = config.offsiteServer
            self.remoteCatalog.stringValue = config.offsiteCatalog
            self.localCatalog.stringValue = config.localCatalog
        }
    }

    @objc private func setSecondsView() {
        self.seconds = self.seconds! - 1
        self.closeinseconds.stringValue = "Close automatically in: " + String(self.seconds!) + " seconds"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.seconds = 5
        self.setInfo()
        self.waitToClose = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(closeView), userInfo: nil, repeats: false)
        self.closeIn = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setSecondsView), userInfo: nil, repeats: true)
        self.closeinseconds.stringValue = "Close automatically in: 5 seconds"
    }

}
