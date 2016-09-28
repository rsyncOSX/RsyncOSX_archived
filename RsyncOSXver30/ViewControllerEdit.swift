//
//  ViewControllerEdit.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerEdit : NSViewController {
    
    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var offsiteCatalog: NSTextField!
    @IBOutlet weak var offsiteUsername: NSTextField!
    @IBOutlet weak var offsiteServer: NSTextField!
    @IBOutlet weak var backupID: NSTextField!
    @IBOutlet weak var sshport: NSTextField!
    @IBOutlet weak var rsyncdaemon: NSButton!
    
    // Index selectted row
    var index:Int?
    
    // Get index of selected row
    weak var getindex_delegate : SendSelecetedIndex?
    // after update reread configuration
    weak var readconfigurations_delegate:ReadConfigurationsAgain?
    // Dismisser
    weak var dismiss_delegate:DismissViewController?
    
    @IBAction func Close(_ sender: NSButton) {
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
    
    @IBAction func Update(_ sender: NSButton) {
        var config:[configuration] = SharingManagerConfiguration.sharedInstance.getConfigurations()
        
        if (!self.localCatalog.stringValue.hasSuffix("/")){
            self.localCatalog.stringValue = self.localCatalog.stringValue + "/"
        }
        config[self.index!].localCatalog = self.localCatalog.stringValue
        if (!self.offsiteCatalog.stringValue.hasSuffix("/")){
            self.offsiteCatalog.stringValue = self.offsiteCatalog.stringValue + "/"
        }
        config[self.index!].offsiteCatalog = self.offsiteCatalog.stringValue
        config[self.index!].offsiteServer = self.offsiteServer.stringValue
        config[self.index!].offsiteUsername = self.offsiteUsername.stringValue
        config[self.index!].backupID = self.backupID.stringValue
        let port = self.sshport.stringValue
        if (port.isEmpty == false) {
            config[self.index!].sshport = Int(port)
        }
        config[self.index!].rsyncdaemon = self.rsyncdaemon.state
        SharingManagerConfiguration.sharedInstance.updateConfigurations(config[self.index!], index: self.index!)
        self.readconfigurations_delegate?.readConfigurations()
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let pvc = SharingManagerConfiguration.sharedInstance.ViewObjectMain as? ViewControllertabMain {
            self.readconfigurations_delegate = pvc
        }
        // Dismisser is root controller
        if let pvc2 = self.presenting as? ViewControllertabMain {
            self.dismiss_delegate = pvc2
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if let pvc = self.presenting as? ViewControllertabMain {
            self.getindex_delegate = pvc
            self.index = self.getindex_delegate?.getindex()
        }
        self.localCatalog.stringValue = SharingManagerConfiguration.sharedInstance.getConfigurations()[self.index!].localCatalog
        self.offsiteCatalog.stringValue = SharingManagerConfiguration.sharedInstance.getConfigurations()[self.index!].offsiteCatalog
        self.offsiteUsername.stringValue = SharingManagerConfiguration.sharedInstance.getConfigurations()[self.index!].offsiteUsername
        self.offsiteServer.stringValue = SharingManagerConfiguration.sharedInstance.getConfigurations()[self.index!].offsiteServer
        self.backupID.stringValue = SharingManagerConfiguration.sharedInstance.getConfigurations()[self.index!].backupID
        if let port = SharingManagerConfiguration.sharedInstance.getConfigurations()[self.index!].sshport {
            self.sshport.stringValue = String(port)
        }
        if let rsyncdaemon = SharingManagerConfiguration.sharedInstance.getConfigurations()[self.index!].rsyncdaemon {
            self.rsyncdaemon.state = rsyncdaemon
        }
    }
    
}

extension ViewControllerEdit : NSDraggingDestination {
    
    private func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        let sourceDragMask = sender.draggingSourceOperationMask()
        let pboard = sender.draggingPasteboard()
        if pboard.availableType(from: [NSFilenamesPboardType]) == NSFilenamesPboardType {
            if sourceDragMask.rawValue & NSDragOperation.generic.rawValue != 0 {
                return NSDragOperation.copy
            }
        }
        return NSDragOperation.copy
    }
    
    private func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.generic
    }
    
    func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
}
