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

class ViewControllerCopyFiles: NSViewController, SetConfigurations, Delay, VcCopyFiles {

    var copyFiles: CopySingleFiles?
    var rsyncindex: Int?
    var getfiles: Bool = false
    var estimated: Bool = false
    private var tabledata: [String]?
    var diddissappear: Bool = false

    @IBOutlet weak var numberofrows: NSTextField!
    @IBOutlet weak var server: NSTextField!
    @IBOutlet weak var rcatalog: NSTextField!
    @IBOutlet weak var info: NSTextField!

    private func info(num: Int) {
        switch num {
        case 1:
            self.info.stringValue = "No such local catalog for restore or set it in user config..."
        case 2:
            self.info.stringValue = "Not a remote task, use Finder to copy files..."
        case 3:
            self.info.stringValue = "Local or remote catalog cannot be empty..."
        default:
            self.info.stringValue = ""
        }
    }

    // Abort button
    @IBAction func abort(_ sender: NSButton) {
        self.working.stopAnimation(nil)
        guard self.copyFiles != nil else { return }
        self.restorebutton.isEnabled = true
        self.copyFiles!.abort()
    }

    @IBOutlet weak var restoretableView: NSTableView!
    @IBOutlet weak var rsynctableView: NSTableView!
    @IBOutlet weak var commandString: NSTextField!
    @IBOutlet weak var remoteCatalog: NSTextField!
    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var workingRsync: NSProgressIndicator!
    @IBOutlet weak var search: NSSearchField!
    @IBOutlet weak var restorebutton: NSButton!

    // Do the work
    @IBAction func restore(_ sender: NSButton) {
        guard self.remoteCatalog.stringValue.isEmpty == false && self.localCatalog.stringValue.isEmpty == false else {
            self.info(num: 3)
            return
        }
        guard self.copyFiles != nil else { return }
        self.restorebutton.isEnabled = false
        self.getfiles = true
        self.workingRsync.startAnimation(nil)
        if self.estimated == false {
            self.copyFiles!.executeRsync(remotefile: self.remoteCatalog!.stringValue, localCatalog: self.localCatalog!.stringValue, dryrun: true)
            self.estimated = true
        } else {
            self.copyFiles!.executeRsync(remotefile: self.remoteCatalog!.stringValue, localCatalog: self.localCatalog!.stringValue, dryrun: false)
            self.estimated = false
        }
    }

    private func displayRemoteserver(index: Int?) {
        guard index != nil else {
            self.server.stringValue = ""
            self.rcatalog.stringValue = ""
            return
        }
        let hiddenID = self.configurations!.gethiddenID(index: index!)
        globalMainQueue.async(execute: { () -> Void in
            self.server.stringValue = self.configurations!.getResourceConfiguration(hiddenID, resource: .offsiteServer)
            self.rcatalog.stringValue = self.configurations!.getResourceConfiguration(hiddenID, resource: .remoteCatalog)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vccopyfiles, nsviewcontroller: self)
        self.restoretableView.delegate = self
        self.restoretableView.dataSource = self
        self.rsynctableView.delegate = self
        self.rsynctableView.dataSource = self
        self.working.usesThreadedAnimation = true
        self.workingRsync.usesThreadedAnimation = true
        self.search.delegate = self
        self.localCatalog.delegate = self
        self.remoteCatalog.delegate = self
        self.restoretableView.doubleAction = #selector(self.tableViewDoubleClick(sender:))
    }

    override func viewDidAppear() {
        guard self.diddissappear == false else {
            globalMainQueue.async(execute: { () -> Void in
                self.rsynctableView.reloadData()
            })
            return
        }
        super.viewDidAppear()
        self.verifylocalCatalog()
        globalMainQueue.async(execute: { () -> Void in
            self.rsynctableView.reloadData()
        })
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.diddissappear = true
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender: AnyObject) {
        guard self.remoteCatalog.stringValue.isEmpty == false else { return }
        guard self.localCatalog.stringValue.isEmpty == false else { return }
        let answer = Alerts.dialogOKCancel("Copy single files or directory", text: "Start restore?")
        if answer {
            self.restorebutton.isEnabled = false
            self.getfiles = true
            self.workingRsync.startAnimation(nil)
            self.copyFiles!.executeRsync(remotefile: remoteCatalog!.stringValue, localCatalog: localCatalog!.stringValue, dryrun: false)
        }
    }

    private func verifylocalCatalog() {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: self.localCatalog.stringValue) == false {
            self.info(num: 1)
        }
    }

    private func inprogress() -> Bool {
        guard self.copyFiles != nil else { return false }
        if self.copyFiles?.process != nil {
            return true
        } else {
            return false
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        if myTableViewFromNotification == self.restoretableView {
            self.info(num: 0)
            let indexes = myTableViewFromNotification.selectedRowIndexes
            if let index = indexes.first {
                guard self.tabledata != nil else { return }
                self.remoteCatalog.stringValue = self.tabledata![index]
                guard self.remoteCatalog.stringValue.isEmpty == false && self.localCatalog.stringValue.isEmpty == false else {
                    self.info(num: 3)
                    return
                }
                self.commandString.stringValue = self.copyFiles!.getCommandDisplayinView(remotefile: self.remoteCatalog.stringValue, localCatalog: self.localCatalog.stringValue)
                self.estimated = false
                self.restorebutton.title = "Estimate"
                self.restorebutton.isEnabled = true
            }
        } else {
            let indexes = myTableViewFromNotification.selectedRowIndexes
            self.commandString.stringValue = ""
            if let index = indexes.first {
                guard self.inprogress() == false else {
                    self.working.stopAnimation(nil)
                    guard self.copyFiles != nil else { return }
                    self.restorebutton.isEnabled = true
                    self.copyFiles!.abort()
                    return
                }
                self.getfiles = false
                self.restorebutton.title = "Estimate"
                self.restorebutton.isEnabled = false
                self.remoteCatalog.stringValue = ""
                self.rsyncindex = index
                let hiddenID = self.configurations!.getConfigurationsDataSourcecountBackupSnapshot()![index].value(forKey: "hiddenID") as? Int ?? -1
                self.copyFiles = CopySingleFiles(hiddenID: hiddenID)
                self.working.startAnimation(nil)
                self.displayRemoteserver(index: index)
            } else {
                self.rsyncindex = nil
            }
        }
    }

    private func reloadtabledata() {
        guard self.copyFiles != nil else { return }
        globalMainQueue.async(execute: { () -> Void in
            self.tabledata = self.copyFiles!.filter(search: nil)
            self.restoretableView.reloadData()
        })
    }
}

extension ViewControllerCopyFiles: NSSearchFieldDelegate {

    override func controlTextDidChange(_ notification: Notification) {
        if (notification.object as? NSTextField)! == self.search {
            self.delayWithSeconds(0.25) {
                if self.search.stringValue.isEmpty {
                    globalMainQueue.async(execute: { () -> Void in
                        self.tabledata = self.copyFiles?.filter(search: nil)
                        self.restoretableView.reloadData()
                    })
                } else {
                    globalMainQueue.async(execute: { () -> Void in
                        self.tabledata = self.copyFiles?.filter(search: self.search.stringValue)
                        self.restoretableView.reloadData()
                    })
                }
            }
            self.verifylocalCatalog()
        } else {
            self.restorebutton.title = "Estimate"
            self.restorebutton.isEnabled = true
            self.estimated = false
            guard self.remoteCatalog.stringValue.count > 0 else { return }
            self.delayWithSeconds(0.25) {
                self.commandString.stringValue = self.copyFiles!.getCommandDisplayinView(remotefile: self.remoteCatalog.stringValue, localCatalog: self.localCatalog.stringValue)
            }
        }
    }

    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        globalMainQueue.async(execute: { () -> Void in
            self.tabledata = self.copyFiles?.filter(search: nil)
            self.restoretableView.reloadData()
        })
    }
}

extension ViewControllerCopyFiles: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == self.restoretableView {
            guard self.tabledata != nil else {
                self.numberofrows.stringValue = "Number of remote files: 0"
                return 0
            }
            self.numberofrows.stringValue = "Number of remote files: " + String(self.tabledata!.count)
            return self.tabledata!.count
        } else {
             return self.configurations?.getConfigurationsDataSourcecountBackupSnapshot()?.count ?? 0
        }
    }
}

extension ViewControllerCopyFiles: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == self.restoretableView {
            guard self.tabledata != nil else { return nil }
            let cellIdentifier = "files"
            let text: String = self.tabledata![row]
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
        } else {
            guard row < self.configurations!.getConfigurationsDataSourcecountBackupSnapshot()!.count else { return nil }
            let object: NSDictionary = self.configurations!.getConfigurationsDataSourcecountBackupSnapshot()![row]
            let cellIdentifier: String = tableColumn!.identifier.rawValue
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                cell.textField?.stringValue = object.value(forKey: cellIdentifier) as? String ?? ""
                return cell
            }
        }
        return nil
    }
}

extension ViewControllerCopyFiles: UpdateProgress {
    func processTermination() {
        if self.getfiles == false {
            self.copyFiles!.setRemoteFileList()
            self.reloadtabledata()
            self.working.stopAnimation(nil)
        } else {
            self.restorebutton.title = "Restore"
            self.workingRsync.stopAnimation(nil)
            self.presentViewControllerAsSheet(self.viewControllerInformation!)
            self.restorebutton.isEnabled = true
        }
        self.copyFiles?.process = nil
    }

    func fileHandler() {
        // nothing
    }
}

extension ViewControllerCopyFiles: GetPath {
    func pathSet(path: String?, requester: WhichPath) {
        if let setpath = path {
            self.localCatalog.stringValue = setpath
        }
    }
}

extension ViewControllerCopyFiles: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismissViewController(viewcontroller)
    }
}

extension ViewControllerCopyFiles: Information {
    func getInformation() -> [String] {
        return self.copyFiles!.getOutput()
    }
}
