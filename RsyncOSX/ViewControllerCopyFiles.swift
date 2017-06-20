//
//  ViewControllerCopyFiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 12/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

protocol setIndex: class {
    func SetIndex(Index:Int)
}

protocol getSource: class {
    func GetSource(Index:Int)
}

class ViewControllerCopyFiles : NSViewController {
    
    // Object to hold search data
    var copyFiles : CopyFiles?
    // Index of selected row
    var index:Int?
    // Delegate for getting index from Execute view
    weak var index_delegate:GetSelecetedIndex?
    
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
    
    // Source for CopyFiles
    // self.presentViewControllerAsSheet(self.ViewControllerAbout)
    lazy var ViewControllerSource: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "CopyFilesID")
            as! NSViewController
    }()
    
     // Set localcatalog to filePath
    @IBAction func copyToIcon(_ sender: NSButton) {
        _ = FileDialog(requester: .CopyFilesTo)
    }
    
    // Abort button
    @IBAction func Abort(_ sender: NSButton) {
        self.working.stopAnimation(nil)
        guard (self.copyFiles != nil) else {
            return
        }
        self.copyFiles!.Abort()
    }

    
    @IBOutlet weak var tableViewSelect: NSTableView!
    // Array to display in tableview
    fileprivate var filesArray:[String]?
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
    // Select source button
    @IBOutlet weak var SelectButton: NSButton!
    
    // Do the work
    @IBAction func Copy(_ sender: NSButton) {
        if (self.remoteCatalog.stringValue.isEmpty || self.localCatalog.stringValue.isEmpty) {
            Alerts.showInfo("From: or To: cannot be empty!")
        } else {
            if (self.copyFiles != nil) {
                self.rsync = true
                self.workingRsync.startAnimation(nil)
                if (self.estimated == false) {
                    self.copyFiles!.executeRsync(remotefile: remoteCatalog!.stringValue, localCatalog: localCatalog!.stringValue, dryrun: true)
                    self.CopyButton.title = "Execute"
                    self.estimated = true
                } else {
                    self.workingRsync.startAnimation(nil)
                    self.copyFiles!.executeRsync(remotefile: remoteCatalog!.stringValue, localCatalog: localCatalog!.stringValue, dryrun: false)
                    self.estimated = false
                }
            } else {
                Alerts.showInfo("Please select a ROW in Execute window!")
            }
        }
    }
    
    // Getting index from Execute View
    @IBAction func GetIndex(_ sender: NSButton) {
        self.copyFiles = nil
        if let index = self.index {
            self.copyFiles = CopyFiles(index: index)
            self.working.startAnimation(nil)
            self.displayRemoteserver(index: index)
        } else {
            // Reset search data
            self.resetCopySource()
            // Get Copy Source
            self.presentViewControllerAsSheet(self.ViewControllerSource)
        }
    }
    
    @IBAction func Reset(_ sender: NSButton) {
        self.resetCopySource()
    }
    
    // Reset copy source
    fileprivate func resetCopySource() {
        // Empty tabledata
        self.index = nil
        self.filesArray = nil
        GlobalMainQueue.async(execute: { () -> Void in
            self.tableViewSelect.reloadData()
        })
        self.displayRemoteserver(index: nil)
        self.remoteCatalog.stringValue = ""
        self.SelectButton.title = "Get source"
    }
    
    fileprivate func displayRemoteserver(index:Int?) {
        guard (index != nil) else {
            self.server.stringValue = ""
            self.rcatalog.stringValue = ""
            self.SelectButton.title = "Get source"
            return
        }
        let hiddenID = SharingManagerConfiguration.sharedInstance.gethiddenID(index: index!)
        GlobalMainQueue.async(execute: { () -> Void in
            self.server.stringValue = SharingManagerConfiguration.sharedInstance.getResourceConfiguration(hiddenID, resource: .offsiteServer)
            self.rcatalog.stringValue = SharingManagerConfiguration.sharedInstance.getResourceConfiguration(hiddenID, resource: .remoteCatalog)
        })
        self.SelectButton.title = "Get files"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting reference to ViewObject
        SharingManagerConfiguration.sharedInstance.ViewControllerCopyFiles = self
        self.tableViewSelect.delegate = self
        self.tableViewSelect.dataSource = self
        // Register for drag and drop
        self.localCatalog.register(forDraggedTypes: [NSFilenamesPboardType])
        self.remoteCatalog.register(forDraggedTypes: [NSFilenamesPboardType])
        // Progress indicator
        self.working.usesThreadedAnimation = true
        self.workingRsync.usesThreadedAnimation = true
        self.search.delegate = self
        self.localCatalog.delegate = self
        // Double click on row to select
        self.tableViewSelect.doubleAction = #selector(self.tableViewDoubleClick(sender:))
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if let pvc = SharingManagerConfiguration.sharedInstance.ViewControllertabMain as? ViewControllertabMain {
            self.index_delegate = pvc
            self.index = self.index_delegate?.getindex()
            if let index = self.index {
                self.displayRemoteserver(index: index)
            }
        }
        self.CopyButton.title = "Estimate"
        if let restorePath = SharingManagerConfiguration.sharedInstance.restorePath {
            self.localCatalog.stringValue = restorePath
        } else {
            self.localCatalog.stringValue = ""
        }
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.resetCopySource()
    }
    
    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender:AnyObject) {
        
        guard self.index != nil else {
            return
        }
        
        guard (self.remoteCatalog!.stringValue.isEmpty == false ) else {
            return
        }
        
        guard (self.localCatalog!.stringValue.isEmpty == false ) else {
            return
        }
        
        let answer = Alerts.dialogOKCancel("Copy single files or directory", text: "Start copy?")
        if (answer){
            
            self.rsync = true
            self.workingRsync.startAnimation(nil)
            self.copyFiles!.executeRsync(remotefile: remoteCatalog!.stringValue, localCatalog: localCatalog!.stringValue, dryrun: false)
        }
    }

    
}


extension ViewControllerCopyFiles: NSSearchFieldDelegate {
    
    func searchFieldDidStartSearching(_ sender: NSSearchField){
        if (sender.stringValue.isEmpty) {
            GlobalMainQueue.async(execute: { () -> Void in
                self.filesArray = self.copyFiles?.filter(search: nil)
                self.tableViewSelect.reloadData()
            })
        } else {
            GlobalMainQueue.async(execute: { () -> Void in
                self.filesArray = self.copyFiles?.filter(search: sender.stringValue)
                self.tableViewSelect.reloadData()
            })
        }
        
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField){
        GlobalMainQueue.async(execute: { () -> Void in
            self.filesArray = self.copyFiles?.filter(search: nil)
            self.tableViewSelect.reloadData()
        })
    }
    
}

extension ViewControllerCopyFiles: NSTableViewDataSource {
    
    func numberOfRows(in tableViewMaster: NSTableView) -> Int {
        guard self.filesArray != nil else {
            return 0
        }
        return self.filesArray!.count
    }
}


extension ViewControllerCopyFiles: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text:String?
        var cellIdentifier: String = ""
        guard self.filesArray != nil else {
            return nil
        }
        
        var split = self.filesArray![row].components(separatedBy: "\t")
        
        if tableColumn == tableView.tableColumns[0] {
                text = split[0]
            
            cellIdentifier = "sizeID"
        }
        
        if tableColumn == tableView.tableColumns[1] {
            if split.count > 1 {
                text = split[1]
            } else {
                text = split[0]
            }
            
            cellIdentifier = "fileID"
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
            guard self.filesArray != nil else {
                return
            }
            
            let split = self.filesArray![index].components(separatedBy: "\t")
            
            guard split.count > 1 else {
                return
            }
            
            self.remoteCatalog.stringValue = split[1]
            
            if (self.remoteCatalog.stringValue.isEmpty == false && self.localCatalog.stringValue.isEmpty == false) {
                self.commandString.stringValue = self.copyFiles!.getCommandDisplayinView(remotefile: self.remoteCatalog.stringValue, localCatalog: self.localCatalog.stringValue)
            } else {
                self.commandString.stringValue = "Please select both \"Restore to:\" and \"Restore:\" to show rsync command"
            }
            self.estimated = false
            self.CopyButton.title = "Estimate"
        }
    }
}

// textDidEndEditing

extension ViewControllerCopyFiles: NSTextFieldDelegate {
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        if (self.remoteCatalog.stringValue.isEmpty == false && self.localCatalog.stringValue.isEmpty == false) {
            self.commandString.stringValue = (self.copyFiles!.getCommandDisplayinView(remotefile: self.remoteCatalog.stringValue, localCatalog: self.localCatalog.stringValue))
        } else {
            self.commandString.stringValue = "Please select both \"Restore to:\" and \"Restore:\" to show rsync command"
        }
    }
}

extension ViewControllerCopyFiles: RefreshtableView {
    
    // Do a refresh of table
    func refresh() {
        
        guard self.copyFiles != nil else {
            return
        }
        GlobalMainQueue.async(execute: { () -> Void in
            self.filesArray = self.copyFiles!.filter(search: nil)
            self.tableViewSelect.reloadData()
        })
    }
}

extension ViewControllerCopyFiles: StartStopProgressIndicator {
    
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
}

extension ViewControllerCopyFiles: UpdateProgress {
    
    // Messages from Process when job is done or in progress

    
    // When Process terminates
    func ProcessTermination() {
        if (rsync == false) {
            self.copyFiles!.setRemoteFileList()
            self.refresh()
            self.stop()
        } else {
            self.workingRsync.stopAnimation(nil)
            self.presentViewControllerAsSheet(self.ViewControllerInformation)
        }
        
    }
    
    // When Process outputs anything to filehandler
    func FileHandler() {
        // nothing
    }
}

extension ViewControllerCopyFiles: Information {
    
    // Protocol Information
    func getInformation() -> [String] {
        return self.copyFiles!.getOutput()
    }
}

extension ViewControllerCopyFiles: DismissViewController {
    
    // Protocol DismissViewController
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismissViewController(viewcontroller)
    }
}

extension ViewControllerCopyFiles: GetPath {
    
    func pathSet(path: String?, requester : WhichPath) {
        if let setpath = path {
            self.localCatalog.stringValue = setpath
        }
    }
}

extension ViewControllerCopyFiles: setIndex {
    func SetIndex(Index: Int) {
        self.index = Index
        self.displayRemoteserver(index: Index)
    }
}

extension ViewControllerCopyFiles: getSource {
    func GetSource(Index: Int) {
        self.index = Index
        self.displayRemoteserver(index: Index)
        if let index = self.index {
            self.copyFiles = CopyFiles(index: index)
            self.working.startAnimation(nil)
            self.displayRemoteserver(index: index)
        }
    }
}
