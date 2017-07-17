//
//  ViewControllerEdit.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//swiftlint:disable syntactic_sugar file_length cyclomatic_complexity line_length

import Foundation
import Cocoa

// Protocol for instruction RsyncOSX to read configurations data again
protocol ReadConfigurationsAgain : class {
    func readConfigurations()
}

class ViewControllerEdit: NSViewController {

    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var offsiteCatalog: NSTextField!
    @IBOutlet weak var offsiteUsername: NSTextField!
    @IBOutlet weak var offsiteServer: NSTextField!
    @IBOutlet weak var backupID: NSTextField!
    @IBOutlet weak var sshport: NSTextField!
    @IBOutlet weak var rsyncdaemon: NSButton!

    // Index selectted row
    var index: Int?
    // Get index of selected row
    weak var getindexDelegate: GetSelecetedIndex?
    // after update reread configuration
    weak var readconfigurationsDelegate: ReadConfigurationsAgain?
    // Dismisser
    weak var dismissDelegate: DismissViewController?
    // Single file if last character is NOT "/"
    var singleFile: Bool = false

    // Close and dismiss view
    @IBAction func close(_ sender: NSButton) {
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    // Update configuration, save and dismiss view
    @IBAction func update(_ sender: NSButton) {

        var config: [Configuration] = SharingManagerConfiguration.sharedInstance.getConfigurations()

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
        SharingManagerConfiguration.sharedInstance.updateConfigurations(config[self.index!], index: self.index!)
        self.readconfigurationsDelegate?.readConfigurations()
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Dismisser is root controller
        if let pvc = self.presenting as? ViewControllertabMain {
            self.readconfigurationsDelegate = pvc
            self.dismissDelegate = pvc
            self.getindexDelegate = pvc
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
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
        let config: Configuration = SharingManagerConfiguration.sharedInstance.getConfigurations()[self.index!]
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
