//
//  ViewControllerNew.swift
//  Rsync
//
//  Created by Thomas Evensen on 13/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa


class ViewControllerNewConfigurations: NSViewController, GetPath, DismissViewController {
    
    // Table holding all new Configurations
    @IBOutlet weak var newTableView: NSTableView!
    
    // NSMutableDictionary as datasource for tableview
    var tabledata : [NSMutableDictionary]?
    let parameterTest:String = "--dry-run"
    let parameter1:String = "--archive"
    let parameter2:String = "--verbose"
    let parameter3:String = "--compress"
    let parameter4:String = "--delete"
    let parameter5:String = "-e"
    let parameter6:String = "ssh"
    
    var newConfigs:Bool = false
    
    @IBOutlet weak var viewParameter1: NSTextField!
    @IBOutlet weak var viewParameter2: NSTextField!
    @IBOutlet weak var viewParameter3: NSTextField!
    @IBOutlet weak var viewParameter4: NSTextField!
    @IBOutlet weak var viewParameter5: NSTextField!
    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var offsiteCatalog: NSTextField!
    @IBOutlet weak var offsiteUsername: NSTextField!
    @IBOutlet weak var offsiteServer: NSTextField!
    @IBOutlet weak var backupID: NSTextField!
    @IBOutlet weak var sshport: NSTextField!
    @IBOutlet weak var rsyncdaemon: NSButton!
    @IBOutlet weak var singleFile: NSButton!
    
    // Userconfiguration
    // self.presentViewControllerAsSheet(self.ViewControllerUserconfiguration)
    lazy var ViewControllerUserconfiguration: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "StoryboardUserconfigID")
            as! NSViewController
    }()
    
    
    // Telling the view to dismiss any presented Viewcontroller
    func dismiss_view(viewcontroller:NSViewController) {
        self.dismissViewController(viewcontroller)
    }


    // Protocol GetPath
    func pathSet(path: String?, requester : WhichPath) {
        if let setpath = path {
            switch (requester) {
            case .AddLocalCatalog:
                self.localCatalog.stringValue = setpath
            case .AddRemoteCatalog:
                self.offsiteCatalog.stringValue = setpath
            default:
                break
            }
        }
    }
    
    @IBAction func copyLocalCatalog(_ sender: NSButton) {
        _ = FileDialog(requester: .AddLocalCatalog)
    }
    
    @IBAction func copyRemoteCatalog(_ sender: NSButton) {
        _ = FileDialog(requester: .AddRemoteCatalog)
    }
    
    // Userconfiguration button
    @IBAction func Userconfiguration(_ sender: NSButton) {
        GlobalMainQueue.async(execute: { () -> Void in
            self.presentViewControllerAsSheet(self.ViewControllerUserconfiguration)
        })
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // self.tabledata = SharingManagerConfiguration.sharedInstance.getnewConfigurations()
        // Set the delegates
        self.newTableView.delegate = self
        self.newTableView.dataSource = self
        SharingManagerConfiguration.sharedInstance.destroyNewConfigurations()
        // Allow dragging
        self.localCatalog.register(forDraggedTypes: [NSFilenamesPboardType])
        self.offsiteCatalog.register(forDraggedTypes: [NSFilenamesPboardType])
        // Tooltip
        self.localCatalog.toolTip = "By using Finder drag and drop filepaths."
        self.offsiteCatalog.toolTip = "By using Finder drag and drop filepaths."
        SharingManagerConfiguration.sharedInstance.AddObjectMain = self
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.setFields()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        if (self.newConfigs) {
            storeAPI.sharedInstance.saveNewConfigurations()
            self.newConfigs = false
        }
    }

    // handler and getter for setting localcatalog
    // for å hente lokal katalog
    
    private func setFields() {
        self.viewParameter1.stringValue = parameter1
        self.viewParameter2.stringValue = parameter2
        self.viewParameter3.stringValue = parameter3
        self.viewParameter4.stringValue = parameter4
        self.viewParameter5.stringValue = parameter5 + " " + parameter6
        self.viewParameter1.stringValue = ""
        self.viewParameter2.stringValue = ""
        self.viewParameter3.stringValue = ""
        self.viewParameter4.stringValue = ""
        self.viewParameter5.stringValue = ""
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.offsiteUsername.stringValue = ""
        self.offsiteServer.stringValue = ""
        self.backupID.stringValue = ""
        self.rsyncdaemon.state = NSOffState
        self.singleFile.state = NSOffState
    }
    
    
    @IBAction func newConfig (_ sender: NSButton) {
            
        let dict:NSMutableDictionary = [
                "task":"backup",
                "backupID":backupID.stringValue,
                "localCatalog":localCatalog.stringValue,
                "offsiteCatalog":offsiteCatalog.stringValue,
                "offsiteServer":offsiteServer.stringValue,
                "offsiteUsername":offsiteUsername.stringValue,
                "parameter1":parameter1,
                "parameter2":parameter2,
                "parameter3":parameter3,
                "parameter4":parameter4,
                "parameter5":parameter5,
                "parameter6":parameter6,
                "dryrun":"--dry-run",
                "rsync":"rsync",
                "dateRun":"",
                "singleFile":0]
        dict.setValue("no", forKey: "batch")
        if self.singleFile.state == NSOnState {
            dict.setValue(1, forKey: "singleFile")
        }
    
            if (!localCatalog.stringValue.hasSuffix("/") && self.singleFile.state == NSOffState){
                localCatalog.stringValue = localCatalog.stringValue + "/"
                dict.setValue(localCatalog.stringValue, forKey: "localCatalog")
            }
            if (!offsiteCatalog.stringValue.hasSuffix("/")){
                offsiteCatalog.stringValue = offsiteCatalog.stringValue + "/"
                dict.setValue(offsiteCatalog.stringValue, forKey: "offsiteCatalog")
            }
            dict.setObject(self.rsyncdaemon.state, forKey: "rsyncdaemon" as NSCopying)
            if (sshport.stringValue != "") {
                if let port:Int = Int(self.sshport.stringValue) {
                    dict.setObject(port, forKey: "sshport" as NSCopying)
                }
            }
            SharingManagerConfiguration.sharedInstance.addNewConfigurations(dict)
            self.tabledata = SharingManagerConfiguration.sharedInstance.getnewConfigurations()
            GlobalMainQueue.async(execute: { () -> Void in
                self.newTableView.reloadData()
            })
            self.newConfigs = true
            self.setFields()
        } 
    

    
    
    
}

extension ViewControllerNewConfigurations : NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return SharingManagerConfiguration.sharedInstance.newConfigurationsCount()
    }
    
}

extension ViewControllerNewConfigurations : NSTableViewDelegate {
   
    @objc(tableView:objectValueForTableColumn:row:) func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let object:NSMutableDictionary = SharingManagerConfiguration.sharedInstance.getnewConfigurations()![row]
        return object[tableColumn!.identifier] as? String
    }
    
    @objc(tableView:setObjectValue:forTableColumn:row:) func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        self.tabledata![row].setObject(object!, forKey: (tableColumn?.identifier)! as NSCopying)
    }
}

extension ViewControllerNewConfigurations : NSDraggingDestination {
    
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


