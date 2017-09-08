//
//  ViewControllerEdit.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerEdit: NSViewController {

    // configurationsNoS
    weak var configurationsDelegate: GetConfigurationsObject?
    var configurationsNoS: Configurations?
    // configurationsNoS

    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var offsiteCatalog: NSTextField!
    @IBOutlet weak var offsiteUsername: NSTextField!
    @IBOutlet weak var offsiteServer: NSTextField!
    @IBOutlet weak var backupID: NSTextField!
    @IBOutlet weak var sshport: NSTextField!
    @IBOutlet weak var rsyncdaemon: NSButton!

    var index: Int?
    weak var getindexDelegate: GetSelecetedIndex?
    weak var dismissDelegate: DismissViewController?
    var singleFile: Bool = false

    // Close and dismiss view
    @IBAction func close(_ sender: NSButton) {
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    // Update configuration, save and dismiss view
    @IBAction func update(_ sender: NSButton) {
        var config: [Configuration] = self.configurationsNoS!.getConfigurations()
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
        self.configurationsNoS!.updateConfigurations(config[self.index!], index: self.index!)
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Dismisser is root controller
        self.dismissDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain)
            as? ViewControllertabMain
        self.getindexDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain)
            as? ViewControllertabMain
        // configurationsNoS
        self.configurationsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain)
            as? ViewControllertabMain
        // configurationsNoS
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.configurationsNoS = self.configurationsDelegate?.getconfigurationsobject()
        // Reset all values in view
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.offsiteUsername.stringValue = ""
        self.offsiteServer.stringValue = ""
        self.backupID.stringValue = ""
        self.sshport.stringValue = ""
        self.rsyncdaemon.state = .off
        // Getting index of selected configuration
        self.index = self.getindexDelegate?.getindex()
        let config: Configuration = self.configurationsNoS!.getConfigurations()[self.index!]
        self.localCatalog.stringValue = config.localCatalog
        // Check for single file
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
    }

}
