//
//  ViewControllerCopyFiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 12/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation
import Cocoa

protocol SetIndex: class {
    func setIndex(index: Int)
}

protocol GetSource: class {
    func getSource(index: Int)
}

class ViewControllerCopyFiles: NSViewController {

    weak var configurationsDelegate: GetConfigurationsObject?
    var configurations: Configurations?
    var copyFiles: CopyFiles?
    var index: Int?
    var rsync: Bool = false
    var estimated: Bool = false
    weak var indexDelegate: GetSelecetedIndex?
    private var tabledata: [String]?

    @IBOutlet weak var numberofrows: NSTextField!
    @IBOutlet weak var server: NSTextField!
    @IBOutlet weak var rcatalog: NSTextField!

    // Information about rsync output
    // self.presentViewControllerAsSheet(self.ViewControllerInformation)
    lazy var viewControllerInformation: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardInformationCopyFilesID")) as? NSViewController)!
    }()

    // Source for CopyFiles
    // self.presentViewControllerAsSheet(self.ViewControllerAbout)
    lazy var viewControllerSource: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue:
            "CopyFilesID")) as? NSViewController)!
    }()

     // Set localcatalog to filePath
    @IBAction func copyToIcon(_ sender: NSButton) {
        _ = FileDialog(requester: .copyFilesTo)
    }

    // Abort button
    @IBAction func abort(_ sender: NSButton) {
        self.working.stopAnimation(nil)
        guard self.copyFiles != nil else {
            return
        }
        self.copyButton.isEnabled = true
        self.copyFiles!.abort()
    }

    @IBOutlet weak var tableViewSelect: NSTableView!
    @IBOutlet weak var commandString: NSTextField!
    @IBOutlet weak var remoteCatalog: NSTextField!
    @IBOutlet weak var localCatalog: NSTextField!
    // Progress indicator
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var workingRsync: NSProgressIndicator!
    // Search field
    @IBOutlet weak var search: NSSearchField!
    @IBOutlet weak var copyButton: NSButton!
    // Select source button
    @IBOutlet weak var selectButton: NSButton!

    // Do the work
    @IBAction func copy(_ sender: NSButton) {
        if self.remoteCatalog.stringValue.isEmpty || self.localCatalog.stringValue.isEmpty {
            Alerts.showInfo("From: or To: cannot be empty!")
        } else {
            if self.copyFiles != nil {
                self.rsync = true
                self.workingRsync.startAnimation(nil)
                if self.estimated == false {
                    self.copyFiles!.executeRsync(remotefile: remoteCatalog!.stringValue, localCatalog: localCatalog!.stringValue, dryrun: true)
                    self.copyButton.title = "Execute"
                    self.estimated = true
                } else {
                    self.copyButton.isEnabled = false
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
    @IBAction func getIndex(_ sender: NSButton) {
        self.copyFiles = nil
        if let index = self.index {
            self.copyFiles = CopyFiles(index: index)
            self.working.startAnimation(nil)
            self.displayRemoteserver(index: index)
        } else {
            // Reset search data
            self.resetCopySource()
            // Get Copy Source
            self.presentViewControllerAsSheet(self.viewControllerSource)
        }
    }

    @IBAction func reset(_ sender: NSButton) {
        self.resetCopySource()
    }

    // Reset copy source
    private func resetCopySource() {
        // Empty tabledata
        self.index = nil
        self.tabledata = nil
        globalMainQueue.async(execute: { () -> Void in
            self.tableViewSelect.reloadData()
        })
        self.displayRemoteserver(index: nil)
        self.remoteCatalog.stringValue = ""
        self.selectButton.title = "Get source"
        self.rsync = false
        self.copyButton.isEnabled = true
    }

    private func displayRemoteserver(index: Int?) {
        guard index != nil else {
            self.server.stringValue = ""
            self.rcatalog.stringValue = ""
            self.selectButton.title = "Get source"
            return
        }
        let hiddenID = self.configurations!.gethiddenID(index: index!)
        globalMainQueue.async(execute: { () -> Void in
            self.server.stringValue = self.configurations!.getResourceConfiguration(hiddenID, resource: .offsiteServer)
            self.rcatalog.stringValue = self.configurations!.getResourceConfiguration(hiddenID, resource: .remoteCatalog)
        })
        self.selectButton.title = "Get files"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting reference to ViewObject
        ViewControllerReference.shared.setvcref(viewcontroller: .vccopyfiles, nsviewcontroller: self)
        self.tableViewSelect.delegate = self
        self.tableViewSelect.dataSource = self
        // Progress indicator
        self.working.usesThreadedAnimation = true
        self.workingRsync.usesThreadedAnimation = true
        self.search.delegate = self
        self.localCatalog.delegate = self
        // Double click on row to select
        self.tableViewSelect.doubleAction = #selector(self.tableViewDoubleClick(sender:))
        self.configurationsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain)
            as? ViewControllertabMain
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.configurations = self.configurationsDelegate?.getconfigurationsobject()
        self.indexDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain)
            as? ViewControllertabMain
        self.index = self.indexDelegate?.getindex()
        if let index = self.index {
            self.displayRemoteserver(index: index)
        }
        self.copyButton.isEnabled = true
        self.copyButton.title = "Estimate"
        if let restorePath = self.configurations!.restorePath {
            self.localCatalog.stringValue = restorePath
        } else {
            self.localCatalog.stringValue = ""
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.resetCopySource()
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender: AnyObject) {
        guard self.index != nil else {
            return
        }
        guard self.remoteCatalog!.stringValue.isEmpty == false else {
            return
        }
        guard self.localCatalog!.stringValue.isEmpty == false else {
            return
        }
        let answer = Alerts.dialogOKCancel("Copy single files or directory", text: "Start copy?")
        if answer {
            self.copyButton.title = "Execute"
            self.copyButton.isEnabled = false
            self.rsync = true
            self.workingRsync.startAnimation(nil)
            self.copyFiles!.executeRsync(remotefile: remoteCatalog!.stringValue, localCatalog: localCatalog!.stringValue, dryrun: false)
        }
    }
}

extension ViewControllerCopyFiles: NSSearchFieldDelegate {

    override func controlTextDidChange(_ obj: Notification) {
        let filterstring = self.search.stringValue
        if filterstring.isEmpty {
            globalMainQueue.async(execute: { () -> Void in
                self.tabledata = self.copyFiles?.filter(search: nil)
                self.tableViewSelect.reloadData()
            })
        } else {
            globalMainQueue.async(execute: { () -> Void in
                self.tabledata = self.copyFiles?.filter(search: filterstring)
                self.tableViewSelect.reloadData()
            })
        }
    }

    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        globalMainQueue.async(execute: { () -> Void in
            self.tabledata = self.copyFiles?.filter(search: nil)
            self.tableViewSelect.reloadData()
        })
    }

}

extension ViewControllerCopyFiles: NSTableViewDataSource {

    func numberOfRows(in tableViewMaster: NSTableView) -> Int {
        guard self.tabledata != nil else {
            self.numberofrows.stringValue = "Number of rows:"
            return 0
        }
        self.numberofrows.stringValue = "Number of rows: " + String(self.tabledata!.count)
        return self.tabledata!.count
    }
}

extension ViewControllerCopyFiles: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String?
        var cellIdentifier: String = ""
        guard self.tabledata != nil else {
            return nil
        }
        text = self.tabledata![row]
        /*
        var split = self.tabledata![row].components(separatedBy: "\t")
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
         */
        cellIdentifier = "fileID"
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
            cell.textField?.stringValue = text!
            return cell
        }
        return nil
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            guard self.tabledata != nil else {
                return
            }
            let split = self.tabledata![index].components(separatedBy: "\t")
            guard split.count > 1 else {
                return
            }
            self.remoteCatalog.stringValue = split[1]
            if self.remoteCatalog.stringValue.isEmpty == false && self.localCatalog.stringValue.isEmpty == false {
                self.commandString.stringValue = self.copyFiles!.getCommandDisplayinView(remotefile: self.remoteCatalog.stringValue, localCatalog: self.localCatalog.stringValue)
            } else {
                self.commandString.stringValue = "Please select both \"Restore to:\" and \"Restore:\" to show rsync command"
            }
            self.estimated = false
            self.copyButton.title = "Estimate"
        }
    }
}

// textDidEndEditing

extension ViewControllerCopyFiles: NSTextFieldDelegate {
    override func controlTextDidEndEditing(_ obj: Notification) {
        if self.remoteCatalog.stringValue.isEmpty == false && self.localCatalog.stringValue.isEmpty == false {
            self.commandString.stringValue = (self.copyFiles!.getCommandDisplayinView(remotefile: self.remoteCatalog.stringValue, localCatalog: self.localCatalog.stringValue))
        } else {
            self.commandString.stringValue = "Please select both \"Restore to:\" and \"Restore:\" to show rsync command"
        }
    }
}

extension ViewControllerCopyFiles: Reloadandrefresh {
    // Do a refresh of table
    func reload() {
        guard self.copyFiles != nil else {
            return
        }
        globalMainQueue.async(execute: { () -> Void in
            self.tabledata = self.copyFiles!.filter(search: nil)
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
    func processTermination() {
        if self.rsync == false {
            self.copyFiles!.setRemoteFileList()
            self.reload()
            self.stop()
        } else {
            self.workingRsync.stopAnimation(nil)
            self.presentViewControllerAsSheet(self.viewControllerInformation)
        }
    }

    func fileHandler() {
        // nothing
    }
}

extension ViewControllerCopyFiles: Information {
    func getInformation() -> [String] {
        return self.copyFiles!.getOutput()
    }
}

extension ViewControllerCopyFiles: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismissViewController(viewcontroller)
    }
}

extension ViewControllerCopyFiles: GetPath {
    func pathSet(path: String?, requester: WhichPath) {
        if let setpath = path {
            self.localCatalog.stringValue = setpath
        }
    }
}

extension ViewControllerCopyFiles: SetIndex {
    func setIndex(index: Int) {
        self.index = index
        self.displayRemoteserver(index: index)
    }
}

extension ViewControllerCopyFiles: GetSource {
    func getSource(index: Int) {
        self.index = index
        self.displayRemoteserver(index: index)
        if let index = self.index {
            self.copyFiles = CopyFiles(index: index)
            self.working.startAnimation(nil)
            self.displayRemoteserver(index: index)
        }
    }
}
