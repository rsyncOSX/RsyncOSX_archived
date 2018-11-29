//
//  ViewControllerEdit.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerEdit: NSViewController, SetConfigurations, SetDismisser, Index, Delay {

    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var offsiteCatalog: NSTextField!
    @IBOutlet weak var offsiteUsername: NSTextField!
    @IBOutlet weak var offsiteServer: NSTextField!
    @IBOutlet weak var backupID: NSTextField!
    @IBOutlet weak var sshport: NSTextField!
    @IBOutlet weak var rsyncdaemon: NSButton!
    @IBOutlet weak var snapshotnum: NSTextField!

    var index: Int?
    var singleFile: Bool = false

    @IBAction func enabledisableresetsnapshotnum(_ sender: NSButton) {
        let config: Configuration = self.configurations!.getConfigurations()[self.index!]
        guard config.task == "snapshot" else { return }
        Alerts.showInfo("Dont change the snapshot num if you don´t know what you are doing...")
        if self.snapshotnum.isEnabled {
            self.snapshotnum.isEnabled = false
        } else {
            self.snapshotnum.isEnabled = true
        }
    }
    // Close and dismiss view
    @IBAction func close(_ sender: NSButton) {
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    // Update configuration, save and dismiss view
    @IBAction func update(_ sender: NSButton) {
        var config: [Configuration] = self.configurations!.getConfigurations()
        if self.localCatalog.stringValue.hasSuffix("/") == false && self.singleFile == false {
            self.localCatalog.stringValue += "/"
        }
        config[self.index!].localCatalog = self.localCatalog.stringValue
        if self.offsiteCatalog.stringValue.hasSuffix("/") == false {
            self.offsiteCatalog.stringValue += "/"
        }
        config[self.index!].offsiteCatalog = self.offsiteCatalog.stringValue
        config[self.index!].offsiteServer = self.offsiteServer.stringValue
        config[self.index!].offsiteUsername = self.offsiteUsername.stringValue
        config[self.index!].backupID = self.backupID.stringValue
        let port = self.sshport.stringValue
        if port.isEmpty == false {
            if let port = Int(port) {
                config[self.index!].sshport = port
            }
        } else {
            config[self.index!].sshport = nil
        }
        config[self.index!].rsyncdaemon = self.rsyncdaemon.state.rawValue
        if self.snapshotnum.stringValue.count > 0 {
            config[self.index!].snapshotnum = Int(self.snapshotnum.stringValue)
        }
        self.configurations!.updateConfigurations(config[self.index!], index: self.index!)
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.snapshotnum.delegate = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.offsiteUsername.stringValue = ""
        self.offsiteServer.stringValue = ""
        self.backupID.stringValue = ""
        self.sshport.stringValue = ""
        self.rsyncdaemon.state = .off
        self.index = self.index()
        let config: Configuration = self.configurations!.getConfigurations()[self.index!]
        self.localCatalog.stringValue = config.localCatalog
        if self.localCatalog.stringValue.hasSuffix("/") == false {
            self.singleFile = true
        } else {
            self.singleFile = false
        }
        self.offsiteCatalog.stringValue = config.offsiteCatalog
        self.offsiteUsername.stringValue = config.offsiteUsername
        self.offsiteServer.stringValue = config.offsiteServer
        self.backupID.stringValue = config.backupID
        if let port = config.sshport {
            self.sshport.stringValue = String(port)
        }
        if let rsyncdaemon = config.rsyncdaemon {
            self.rsyncdaemon.state = NSControl.StateValue(rawValue: rsyncdaemon)
        }
        if let snapshotnum = config.snapshotnum {
            self.snapshotnum.stringValue = String(snapshotnum)
        }
    }
}

extension ViewControllerEdit: NSTextFieldDelegate {
    override func controlTextDidChange(_ notification: Notification) {
        delayWithSeconds(0.5) {
            if let num = Int(self.snapshotnum.stringValue) {
                let config: Configuration = self.configurations!.getConfigurations()[self.index!]
                guard num < config.snapshotnum ?? 0 && num > 0 else {
                    self.snapshotnum.stringValue = String(config.snapshotnum ?? 1)
                    return
                }
            } else {
                let config: Configuration = self.configurations!.getConfigurations()[self.index!]
                self.snapshotnum.stringValue = String(config.snapshotnum ?? 1)
            }
        }
    }
}
