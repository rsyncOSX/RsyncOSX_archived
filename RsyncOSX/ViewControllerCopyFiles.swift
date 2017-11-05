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

class ViewControllerCopyFiles: NSViewController, SetConfigurations, GetIndex, Delay, VcCopyFiles {

    var copyFiles: CopyFiles?
    var index: Int?
    var rsync: Bool = false
    var estimated: Bool = false
    private var tabledata: [String]?

    @IBOutlet weak var numberofrows: NSTextField!
    @IBOutlet weak var server: NSTextField!
    @IBOutlet weak var rcatalog: NSTextField!
    @IBOutlet weak var nolocalcatalog: NSTextField!

     // Set localcatalog to filePath
    @IBAction func copyToIcon(_ sender: NSButton) {
        _ = FileDialog(requester: .copyFilesTo)
    }

    // Abort button
    @IBAction func abort(_ sender: NSButton) {
        self.working.stopAnimation(nil)
        guard self.copyFiles != nil else { return }
        self.copyButton.isEnabled = true
        self.copyFiles!.abort()
    }

    @IBOutlet weak var tableViewSelect: NSTableView!
    @IBOutlet weak var commandString: NSTextField!
    @IBOutlet weak var remoteCatalog: NSTextField!
    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var workingRsync: NSProgressIndicator!
    @IBOutlet weak var search: NSSearchField!
    @IBOutlet weak var copyButton: NSButton!
    @IBOutlet weak var selectButton: NSButton!
    @IBOutlet weak var error: NSTextField!
    @IBOutlet weak var configfrommain: NSTextField!

    // Do the work
    @IBAction func copy(_ sender: NSButton) {
        guard self.remoteCatalog.stringValue.isEmpty == false && self.localCatalog.stringValue.isEmpty == false else {
            self.error.isHidden = false
            return
        }
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
            self.presentViewControllerAsSheet(self.viewControllerSource!)
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
        self.configfrommain.isHidden = true
        globalMainQueue.async(execute: { () -> Void in
            self.tableViewSelect.reloadData()
        })
        self.displayRemoteserver(index: nil)
        self.remoteCatalog.stringValue = ""
        self.selectButton.title = "Get source"
        self.rsync = false
        self.copyButton.isEnabled = true
        self.error.isHidden = true
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
        ViewControllerReference.shared.setvcref(viewcontroller: .vccopyfiles, nsviewcontroller: self)
        self.tableViewSelect.delegate = self
        self.tableViewSelect.dataSource = self
        self.working.usesThreadedAnimation = true
        self.workingRsync.usesThreadedAnimation = true
        self.search.delegate = self
        self.localCatalog.delegate = self
        self.tableViewSelect.doubleAction = #selector(self.tableViewDoubleClick(sender:))
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.index = self.index()
        if let index = self.index {
            self.displayRemoteserver(index: index)
            self.configfrommain.isHidden = false
        }
        self.copyButton.isEnabled = true
        self.copyButton.title = "Estimate"
        guard self.localCatalog.stringValue.isEmpty == true else {
            self.verifylocalCatalog()
            return
        }
        if let restorePath = ViewControllerReference.shared.restorePath {
            self.localCatalog.stringValue = restorePath
        } else {
            self.localCatalog.stringValue = ""
        }
        self.verifylocalCatalog()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.resetCopySource()
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender: AnyObject) {
        guard self.index != nil else { return }
        guard self.remoteCatalog!.stringValue.isEmpty == false else { return }
        guard self.localCatalog!.stringValue.isEmpty == false else { return }
        let answer = Alerts.dialogOKCancel("Copy single files or directory", text: "Start copy?")
        if answer {
            self.copyButton.title = "Execute"
            self.copyButton.isEnabled = false
            self.rsync = true
            self.workingRsync.startAnimation(nil)
            self.copyFiles!.executeRsync(remotefile: remoteCatalog!.stringValue, localCatalog: localCatalog!.stringValue, dryrun: false)
        }
    }

    private func verifylocalCatalog() {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: self.localCatalog.stringValue) {
            self.nolocalcatalog.isHidden = true
        } else {
            self.nolocalcatalog.isHidden = false
        }
    }
}

extension ViewControllerCopyFiles: NSSearchFieldDelegate {

    override func controlTextDidChange(_ obj: Notification) {
        self.delayWithSeconds(0.25) {
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
        self.verifylocalCatalog()
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
        guard self.tabledata != nil else { return nil }
        let cellIdentifier: String = "fileID"
        text = self.tabledata![row]
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
            cell.textField?.stringValue = text!
            return cell
        }
        return nil
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        self.error.isHidden = true
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            guard self.tabledata != nil else { return }
            self.remoteCatalog.stringValue = self.tabledata![index]
            guard self.remoteCatalog.stringValue.isEmpty == false && self.localCatalog.stringValue.isEmpty == false else {
                self.error.isHidden = false
                return
            }
            self.commandString.stringValue = self.copyFiles!.getCommandDisplayinView(remotefile: self.remoteCatalog.stringValue, localCatalog: self.localCatalog.stringValue)
            self.estimated = false
            self.copyButton.title = "Estimate"
        }
    }
}

extension ViewControllerCopyFiles: Reloadandrefresh {
    func reloadtabledata() {
        guard self.copyFiles != nil else { return }
        globalMainQueue.async(execute: { () -> Void in
            self.tabledata = self.copyFiles!.filter(search: nil)
            self.tableViewSelect.reloadData()
        })
    }
}

extension ViewControllerCopyFiles: StartStopProgressIndicator {
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
            self.reloadtabledata()
            self.stop()
        } else {
            self.workingRsync.stopAnimation(nil)
            self.presentViewControllerAsSheet(self.viewControllerInformation!)
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
