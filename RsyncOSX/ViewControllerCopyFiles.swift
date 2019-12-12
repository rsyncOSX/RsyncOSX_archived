//
//  ViewControllerCopyFiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 12/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length function_body_length

import Cocoa
import Foundation

protocol GetSource: class {
    func getSourceindex(index: Int)
}

protocol Updateremotefilelist: class {
    func updateremotefilelist()
}

class ViewControllerCopyFiles: NSViewController, SetConfigurations, Delay, Connected, VcMain, Checkforrsync {
    var copyfiles: CopyFiles?
    var remotefilelist: Remotefilelist?
    var rsyncindex: Int?
    var estimated: Bool = false
    private var restoretabledata: [String]?
    var diddissappear: Bool = false
    var outputprocess: OutputProcess?
    private var maxcount: Int = 0

    @IBOutlet var numberofrows: NSTextField!
    @IBOutlet var server: NSTextField!
    @IBOutlet var rcatalog: NSTextField!
    @IBOutlet var info: NSTextField!
    @IBOutlet var restoretableView: NSTableView!
    @IBOutlet var rsynctableView: NSTableView!
    @IBOutlet var commandString: NSTextField!
    @IBOutlet var remoteCatalog: NSTextField!
    @IBOutlet var restorecatalog: NSTextField!
    @IBOutlet var working: NSProgressIndicator!
    @IBOutlet var search: NSSearchField!
    @IBOutlet var restorebutton: NSButton!

    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    @IBAction func quickbackup(_: NSButton) {
        guard self.checkforrsync() == false else { return }
        self.openquickbackup()
    }

    @IBAction func automaticbackup(_: NSButton) {
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    // Selecting profiles
    @IBAction func profiles(_: NSButton) {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerProfile!)
        }
    }

    // Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerUserconfiguration!)
        }
    }

    // Abort button
    @IBAction func abort(_: NSButton) {
        self.working.stopAnimation(nil)
        guard self.copyfiles != nil else { return }
        self.restorebutton.isEnabled = true
        self.copyfiles!.abort()
    }

    // Do the work
    @IBAction func restore(_: NSButton) {
        guard self.remoteCatalog.stringValue.isEmpty == false, self.restorecatalog.stringValue.isEmpty == false else {
            self.info.stringValue = Infocopyfiles().info(num: 3)
            return
        }
        guard self.copyfiles != nil else { return }
        self.restorebutton.isEnabled = false
        if self.estimated == false {
            self.working.startAnimation(nil)
            self.copyfiles!.executecopyfiles(remotefile: self.remoteCatalog!.stringValue, localCatalog: self.restorecatalog!.stringValue, dryrun: true, updateprogress: self)
            self.estimated = true
            self.outputprocess = self.copyfiles?.outputprocess
        } else {
            self.presentAsSheet(self.viewControllerProgress!)
            self.copyfiles!.executecopyfiles(remotefile: self.remoteCatalog!.stringValue, localCatalog: self.restorecatalog!.stringValue, dryrun: false, updateprogress: self)
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
        guard hiddenID > -1 else { return }
        globalMainQueue.async { () -> Void in
            self.server.stringValue = self.configurations!.getResourceConfiguration(hiddenID, resource: .offsiteServer)
            self.rcatalog.stringValue = self.configurations!.getResourceConfiguration(hiddenID, resource: .remoteCatalog)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vccopyfiles, nsviewcontroller: self)
        self.restoretableView.delegate = self
        self.restoretableView.dataSource = self
        self.rsynctableView.delegate = self
        self.rsynctableView.dataSource = self
        self.working.usesThreadedAnimation = true
        self.search.delegate = self
        self.restorecatalog.delegate = self
        self.remoteCatalog.delegate = self
        self.restoretableView.doubleAction = #selector(self.tableViewDoubleClick(sender:))
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard self.diddissappear == false else {
            globalMainQueue.async { () -> Void in
                self.rsynctableView.reloadData()
            }
            return
        }
        if let restorePath = ViewControllerReference.shared.restorePath {
            self.restorecatalog.stringValue = restorePath
        } else {
            self.restorecatalog.stringValue = ""
        }
        self.verifylocalCatalog()
        globalMainQueue.async { () -> Void in
            self.rsynctableView.reloadData()
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.diddissappear = true
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender _: AnyObject) {
        guard self.remoteCatalog.stringValue.isEmpty == false else { return }
        guard self.restorecatalog.stringValue.isEmpty == false else { return }
        let question: String = NSLocalizedString("Copy single files or directory?", comment: "Restore")
        let text: String = NSLocalizedString("Start restore?", comment: "Restore")
        let dialog: String = NSLocalizedString("Restore", comment: "Restore")
        let answer = Alerts.dialogOrCancel(question: question, text: text, dialog: dialog)
        if answer {
            self.restorebutton.isEnabled = false
            self.working.startAnimation(nil)
            self.copyfiles!.executecopyfiles(remotefile: remoteCatalog!.stringValue, localCatalog: restorecatalog!.stringValue, dryrun: false, updateprogress: self)
        }
    }

    private func verifylocalCatalog() {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: self.restorecatalog.stringValue) == false {
            self.info.stringValue = Infocopyfiles().info(num: 1)
        } else {
            self.info.stringValue = Infocopyfiles().info(num: 0)
        }
    }

    private func inprogress() -> Bool {
        guard self.copyfiles != nil else { return false }
        if self.copyfiles?.process != nil {
            return true
        } else {
            return false
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        if myTableViewFromNotification == self.restoretableView {
            self.info.stringValue = Infocopyfiles().info(num: 0)
            let indexes = myTableViewFromNotification.selectedRowIndexes
            if let index = indexes.first {
                guard self.restoretabledata != nil else { return }
                self.remoteCatalog.stringValue = self.restoretabledata![index]
                guard self.remoteCatalog.stringValue.isEmpty == false, self.restorecatalog.stringValue.isEmpty == false else {
                    self.info.stringValue = Infocopyfiles().info(num: 3)
                    return
                }
                self.commandString.stringValue = self.copyfiles!.getCommandDisplayinView(remotefile: self.remoteCatalog.stringValue, localCatalog: self.restorecatalog.stringValue)
                self.estimated = false
                self.restorebutton.title = "Estimate"
                self.restorebutton.isEnabled = true
            }
        } else {
            let indexes = myTableViewFromNotification.selectedRowIndexes
            self.commandString.stringValue = ""
            if let index = indexes.first {
                guard self.getremotefiles(index: index) == true else { return }
                self.info.stringValue = Infocopyfiles().info(num: 0)
                self.restorebutton.title = "Estimate"
                self.restorebutton.isEnabled = false
                self.remoteCatalog.stringValue = ""
                self.rsyncindex = index
                let hiddenID = self.configurations!.getConfigurationsDataSourceSynchronize()![index].value(forKey: "hiddenID") as? Int ?? -1
                self.copyfiles = CopyFiles(hiddenID: hiddenID)
                self.remotefilelist = Remotefilelist(hiddenID: hiddenID)
                self.working.startAnimation(nil)
                self.displayRemoteserver(index: index)
            } else {
                self.rsyncindex = nil
                self.restoretabledata = nil
                globalMainQueue.async { () -> Void in
                    self.restoretableView.reloadData()
                }
            }
        }
    }

    private func getremotefiles(index: Int) -> Bool {
        guard self.inprogress() == false else {
            self.working.stopAnimation(nil)
            guard self.copyfiles != nil else { return false }
            self.restorebutton.isEnabled = true
            self.copyfiles!.abort()
            return false
        }
        let config = self.configurations!.getConfigurations()[index]
        guard self.connected(config: config) == true else {
            self.restorebutton.isEnabled = false
            self.info.stringValue = Infocopyfiles().info(num: 4)
            return false
        }
        guard config.task != ViewControllerReference.shared.syncremote else { return false }
        return true
    }
}

extension ViewControllerCopyFiles: NSSearchFieldDelegate {
    func controlTextDidChange(_ notification: Notification) {
        if (notification.object as? NSTextField)! == self.search {
            self.delayWithSeconds(0.25) {
                if self.search.stringValue.isEmpty {
                    globalMainQueue.async { () -> Void in
                        if let index = self.rsyncindex {
                            if let hiddenID = self.configurations!.getConfigurationsDataSourceSynchronize()![index].value(forKey: "hiddenID") as? Int {
                                self.remotefilelist = Remotefilelist(hiddenID: hiddenID)
                            }
                        }
                    }
                } else {
                    globalMainQueue.async { () -> Void in
                        self.restoretabledata = self.restoretabledata!.filter { $0.contains(self.search.stringValue) }
                        self.restoretableView.reloadData()
                    }
                }
            }
            self.verifylocalCatalog()
        } else {
            self.delayWithSeconds(0.25) {
                self.verifylocalCatalog()
                self.restorebutton.title = "Estimate"
                self.restorebutton.isEnabled = true
                self.estimated = false
                guard self.remoteCatalog.stringValue.count > 0 else { return }
                self.commandString.stringValue = self.copyfiles?.getCommandDisplayinView(remotefile: self.remoteCatalog.stringValue, localCatalog: self.restorecatalog.stringValue) ?? ""
            }
        }
    }

    func searchFieldDidEndSearching(_: NSSearchField) {
        if let index = self.rsyncindex {
            if self.configurations!.getConfigurationsDataSourceSynchronize()![index].value(forKey: "hiddenID") as? Int != nil {
                self.working.startAnimation(nil)
            }
        }
    }
}

extension ViewControllerCopyFiles: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == self.restoretableView {
            let numberofrows: String = NSLocalizedString("Number remote files:", comment: "Copy files")
            guard self.restoretabledata != nil else {
                self.numberofrows.stringValue = numberofrows
                return 0
            }
            self.numberofrows.stringValue = numberofrows + String(self.restoretabledata!.count)
            return self.restoretabledata!.count
        } else {
            return self.configurations?.getConfigurationsDataSourceSynchronize()?.count ?? 0
        }
    }
}

extension ViewControllerCopyFiles: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == self.restoretableView {
            guard self.restoretabledata != nil else { return nil }
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "files"), owner: self) as? NSTableCellView {
                cell.textField?.stringValue = self.restoretabledata?[row] ?? ""
                return cell
            }
        } else {
            guard row < self.configurations!.getConfigurationsDataSourceSynchronize()!.count else { return nil }
            let object: NSDictionary = self.configurations!.getConfigurationsDataSourceSynchronize()![row]
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
        self.maxcount = self.outputprocess?.getMaxcount() ?? 0
        if let vc = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess {
            vc.processTermination()
            self.restorebutton.isEnabled = false
            self.restorebutton.title = "Estimate"
        } else {
            self.restorebutton.title = "Restore"
            self.restorebutton.isEnabled = true
        }
        self.working.stopAnimation(nil)
    }

    func fileHandler() {
        if let vc = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess {
            vc.fileHandler()
        }
    }
}

extension ViewControllerCopyFiles: Count {
    func maxCount() -> Int {
        return self.maxcount
    }

    func inprogressCount() -> Int {
        return self.copyfiles?.outputprocess?.count() ?? 0
    }
}

extension ViewControllerCopyFiles: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
    }
}

extension ViewControllerCopyFiles: TemporaryRestorePath {
    func temporaryrestorepath() {
        if let restorePath = ViewControllerReference.shared.restorePath {
            self.restorecatalog.stringValue = restorePath
        } else {
            self.restorecatalog.stringValue = ""
        }
        self.verifylocalCatalog()
    }
}

extension ViewControllerCopyFiles: NewProfile {
    func newProfile(profile _: String?) {
        self.restoretabledata = nil
        globalMainQueue.async { () -> Void in
            self.restoretableView.reloadData()
            self.rsynctableView.reloadData()
        }
    }

    func enableselectprofile() {
        //
    }
}

extension ViewControllerCopyFiles: OpenQuickBackup {
    func openquickbackup() {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        }
    }
}

extension ViewControllerCopyFiles: Updateremotefilelist {
    func updateremotefilelist() {
        self.restoretabledata = self.remotefilelist?.remotefilelist
        globalMainQueue.async { () -> Void in
            self.restoretableView.reloadData()
        }
        self.working.stopAnimation(nil)
        self.remotefilelist = nil
    }
}
