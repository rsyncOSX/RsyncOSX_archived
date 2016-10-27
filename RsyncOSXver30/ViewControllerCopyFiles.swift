//
//  ViewControllerCopyFiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 12/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerCopyFiles : NSViewController, UpdateProgress, RefreshtableViewtabMain, StartStopProgressIndicatorViewBatch, Information,  DismissViewController, NSSearchFieldDelegate, GetPath {
    
    // Object to hold search data
    var copyObject : CopyFiles?
    // Index of selected row
    var index:Int?
    // Delegate for getting index from Execute view
    weak var index_delegate:SendSelecetedIndex?
    // Info about server and remote catalogs
    @IBOutlet weak var server: NSTextField!
    @IBOutlet weak var rcatalog: NSTextField!
    
    // rsync task
    var rsync:Bool = false
    var estimated:Bool = false
    
    // Information about rsync output
    // self.presentViewControllerAsSheet(self.ViewControllerInformation)
    lazy var ViewControllerInformation: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "StoryboardInformationCopyFilesID")
            as! NSViewController
    }()
    
    
    // Proctocol function RefreshtableViewtabMain
    // Do a refresh of table
    func refreshInMain() {
        GlobalMainQueue.async(execute: { () -> Void in
            self.filesArray = self.copyObject?.filter(search: nil)
            self.tableViewSelect.reloadData()
        })
    }
    
    // Protocol StartStopProgressIndicatorViewBatch
    func stop() {
        self.working.stopAnimation(nil)
    }
    func start() {
        self.working.startAnimation(nil)
    }
    func complete() {
        // nothing
    }
    // Set localcatalog to filePath
    @IBAction func copyToIcon(_ sender: NSButton) {
        _ = FileDialog(requester: .CopyFilesTo)
    }
    // Protocol Information
    func getInformation() -> [String] {
        return self.copyObject!.getOutput()
    }
    // Protocol DismissViewController
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismissViewController(viewcontroller)
    }
    
    // Abort button
    @IBAction func Abort(_ sender: NSButton) {
        if (self.copyObject != nil) {
            self.copyObject!.Abort()
        }
    }
    
    @IBOutlet weak var tableViewSelect: NSTableView!
    // Array to display in tableview
    var filesArray:[String]?
    // Present the commandstring
    @IBOutlet weak var commandString: NSTextField!
    @IBOutlet weak var remoteCatalog: NSTextField!
    @IBOutlet weak var localCatalog: NSTextField!
    // Progress indicator
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var workingRsync: NSProgressIndicator!
    // Search field
    @IBOutlet weak var search: NSSearchField!
    @IBOutlet weak var CopyButton: NSButton!
   
    
    // Do the work
    @IBAction func Copy(_ sender: NSButton) {
        if (self.remoteCatalog.stringValue.isEmpty || self.localCatalog.stringValue.isEmpty) {
            Alerts.showInfo("From: or To: cannot be empty!")
        } else {
            if (self.copyObject != nil) {
                self.rsync = true
                self.workingRsync.startAnimation(nil)
                if (self.estimated == false) {
                    self.copyObject!.execute(remotefile: remoteCatalog!.stringValue, localCatalog: localCatalog!.stringValue, dryrun: true)
                    self.CopyButton.title = "Execute"
                    self.estimated = true
                } else {
                    self.workingRsync.startAnimation(nil)
                    self.copyObject!.execute(remotefile: remoteCatalog!.stringValue, localCatalog: localCatalog!.stringValue, dryrun: false)
                    self.estimated = false
                }
            } else {
                Alerts.showInfo("Please select a ROW in Execute window!")
            }
        }
    }
    // Getting index from Execute View
    @IBAction func GetIndex(_ sender: NSButton) {
        self.copyObject = nil
        if let pvc = SharingManagerConfiguration.sharedInstance.ViewObjectMain as? ViewControllertabMain {
            self.index_delegate = pvc
            self.index = self.index_delegate?.getindex()
        }
        if (self.index! > -1) {
            self.copyObject = CopyFiles(index: self.index!)
            self.working.startAnimation(nil)
            self.displayRemoteserver(index: self.index!)
        } else {
            Alerts.showInfo("Please select a ROW in Execute window!")
        }
    }
    
    // Protocol UpdateProgress
    // Messages from Process when job is done or in progress
    
    // When Process outputs anything to filehandler
    func FileHandler() {
        // nothing
    }
    
    // When Process terminates
    func ProcessTermination() {
        if (rsync == false) {
            // do next job within copyobject
            self.copyObject!.nextWork()
        } else {
            self.workingRsync.stopAnimation(nil)
            self.presentViewControllerAsSheet(self.ViewControllerInformation)
        }
        
    }
    
    // Protocol GetPath
    func pathSet(path: String?, requester : WhichPath) {
        if let setpath = path {
            self.localCatalog.stringValue = setpath
        }
    }
    
    private func displayRemoteserver(index:Int) {
        let hiddenID = SharingManagerConfiguration.sharedInstance.gethiddenID(index: index)
        self.server.stringValue = SharingManagerConfiguration.sharedInstance.getoffSiteserver(hiddenID)
        self.rcatalog.stringValue = SharingManagerConfiguration.sharedInstance.getremoteCatalog(hiddenID)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting reference to ViewObject
        SharingManagerConfiguration.sharedInstance.CopyObjectMain = self
        self.tableViewSelect.delegate = self
        self.tableViewSelect.dataSource = self
        // Register for drag and drop
        self.localCatalog.register(forDraggedTypes: [NSFilenamesPboardType])
        self.remoteCatalog.register(forDraggedTypes: [NSFilenamesPboardType])
        // Progress indicator
        self.working.usesThreadedAnimation = true
        self.workingRsync.usesThreadedAnimation = true
        self.search.delegate = self
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.CopyButton.title = "Estimate"
        self.localCatalog.stringValue = ""
    }
    

    func searchFieldDidStartSearching(_ sender: NSSearchField){
        if (sender.stringValue.isEmpty) {
            GlobalMainQueue.async(execute: { () -> Void in
                self.filesArray = self.copyObject?.filter(search: nil)
                self.tableViewSelect.reloadData()
            })
        } else {
            GlobalMainQueue.async(execute: { () -> Void in
                self.filesArray = self.copyObject?.filter(search: sender.stringValue)
                self.tableViewSelect.reloadData()
            })
        }
        
    }
    func searchFieldDidEndSearching(_ sender: NSSearchField){
        GlobalMainQueue.async(execute: { () -> Void in
            self.filesArray = self.copyObject?.filter(search: nil)
            self.tableViewSelect.reloadData()
        })
    }
    
}

extension ViewControllerCopyFiles : NSTableViewDataSource {
    
    func numberOfRows(in tableViewMaster: NSTableView) -> Int {
        if (self.filesArray != nil) {
            return (self.filesArray?.count)!
        } else {
            return 0
        }
    }
}


extension ViewControllerCopyFiles : NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text:String?
        var cellIdentifier: String = ""
        let data = self.filesArray![row]
        if tableColumn == tableView.tableColumns[0] {
            text = data
            cellIdentifier = "dataID"
        }
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView {
            cell.textField?.stringValue = text!
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = notification.object as! NSTableView
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.remoteCatalog.stringValue = self.filesArray![index]
            self.commandString.stringValue = (self.copyObject?.getCommandDisplayinView(remotefile: self.remoteCatalog.stringValue, localCatalog: self.localCatalog.stringValue))!
            self.estimated = false
            self.CopyButton.title = "Estimate"
        }
    }
}

extension ViewControllerCopyFiles : NSDraggingDestination {
    
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
