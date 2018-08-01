//
//  ViewControllerSnapshots.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.01.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

class ViewControllerSnapshots: NSViewController, SetDismisser, SetConfigurations, Delay, Attributedestring, GetIndex {

    private var hiddenID: Int?
    private var config: Configuration?
    private var snapshotsloggdata: SnapshotsLoggData?
    private var delete: Bool = false
    private var num: Int?
    private var index: Int?

    @IBOutlet weak var snapshotstable: NSTableView!
    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var offsiteCatalog: NSTextField!
    @IBOutlet weak var offsiteUsername: NSTextField!
    @IBOutlet weak var offsiteServer: NSTextField!
    @IBOutlet weak var backupID: NSTextField!
    @IBOutlet weak var sshport: NSTextField!
    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var deletebutton: NSButton!
    @IBOutlet weak var numberOflogfiles: NSTextField!
    @IBOutlet weak var progressdelete: NSProgressIndicator!
    @IBOutlet weak var deletesnapshots: NSSlider!
    @IBOutlet weak var deletesnapshotsnum: NSTextField!
    @IBOutlet weak var gettinglogs: NSProgressIndicator!

    lazy var viewControllerSource: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "CopyFilesID"))
            as? NSViewController)!
    }()

    private func info (num: Int) {
        switch num {
        case 1:
            self.info.stringValue = "Not a snapshot task..."
        case 2:
            self.info.stringValue = "Aborting delete operation..."
        case 3:
            self.info.stringValue = "Delete operation completed..."
        default:
            self.info.stringValue = ""
        }
    }

    private func initdeletesnapshots() {
        self.deletesnapshots.altIncrementValue = 1.0
        self.deletesnapshots.maxValue = Double(self.snapshotsloggdata?.snapshotslogs?.count ?? 0) - 1.0
        self.deletesnapshots.minValue = 0.0
        self.deletesnapshotsnum.stringValue = ""
    }

    @IBAction func updatedeletesnapshotsnum(_ sender: NSSlider) {
        self.deletesnapshotsnum.stringValue = String(self.deletesnapshots.intValue)
        self.num = Int(self.deletesnapshots.intValue)
        globalMainQueue.async(execute: { () -> Void in
            self.snapshotstable.reloadData()
        })
    }

    // Abort button
    @IBAction func abort(_ sender: NSButton) {
        self.info(num: 2)
        self.snapshotsloggdata?.remotecatalogstodelete = nil
    }

    @IBAction func delete(_ sender: NSButton) {
        let delete = Int(self.deletesnapshots.intValue)
        let answer = Alerts.dialogOKCancel("Do you REALLY want to DELETE " + String(delete) + " snapshots?", text: "Cancel or OK")
        if answer {
            self.info(num: 0)
            self.num = nil
            self.snapshotsloggdata!.preparecatalogstodelete(num: delete)
            self.deletebutton.isEnabled = false
            self.deletesnapshots.isEnabled = false
            self.initiateProgressbar()
            self.deletesnapshotcatalogs()
            self.delete = true
        }
    }

    @IBAction func getindex(_ sender: NSButton) {
        self.reloadtabledata()
        self.presentViewControllerAsSheet(self.viewControllerSource)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.snapshotstable.delegate = self
        self.snapshotstable.dataSource = self
        self.gettinglogs.usesThreadedAnimation = true
        self.progressdelete.usesThreadedAnimation = true
        self.deletesnapshotsnum.delegate = self
        ViewControllerReference.shared.setvcref(viewcontroller: .vcsnapshot, nsviewcontroller: self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.deletebutton.isEnabled = false
        self.delete = false
        self.snapshotsloggdata = nil
        self.progressdelete.isHidden = true
        self.info(num: 0)
        self.initdeletesnapshots()
        if let index = self.index(viewcontroller: .vctabmain) {
            let hiddenID = self.configurations?.gethiddenID(index: index)
            if self.configurations?.getConfigurations()[index].task == "snapshot" {
                self.getSource(index: hiddenID!)
            }
        } else {
            globalMainQueue.async(execute: { () -> Void in
                self.snapshotstable.reloadData()
            })
        }
    }

    override func viewDidDisappear() {
        self.reloadtabledata()
    }

    private func deletesnapshotcatalogs() {
        var arguments: SnapshotDeleteCatalogsArguments?
        var deletecommand: SnapshotCommandDeleteCatalogs?
        guard self.snapshotsloggdata?.remotecatalogstodelete != nil else {
            self.progressdelete.isHidden = true
            self.deletebutton.isEnabled = true
            self.deletesnapshots.isEnabled = true
            self.info(num: 0)
            return
        }
        guard self.snapshotsloggdata!.remotecatalogstodelete!.count > 0 else {
            self.progressdelete.isHidden = true
            self.deletebutton.isEnabled = true
            self.deletesnapshots.isEnabled = true
            self.info(num: 0)
            return
        }
        let remotecatalog = self.snapshotsloggdata!.remotecatalogstodelete![0]
        self.snapshotsloggdata!.remotecatalogstodelete!.remove(at: 0)
        if self.snapshotsloggdata!.remotecatalogstodelete!.count == 0 {
            self.snapshotsloggdata!.remotecatalogstodelete = nil
        }
        arguments = SnapshotDeleteCatalogsArguments(config: self.config!, remotecatalog: remotecatalog)
        deletecommand = SnapshotCommandDeleteCatalogs(command: arguments?.getCommand(), arguments: arguments?.getArguments())
        deletecommand?.executeProcess(outputprocess: nil)
    }

    // Progress bar
    private func initiateProgressbar() {
        self.progressdelete.isHidden = false
        self.progressdelete.maxValue = Double(self.deletesnapshots.intValue)
        self.progressdelete.minValue = 0
        self.progressdelete.doubleValue = 0
        self.progressdelete.startAnimation(self)
    }

    private func updateProgressbar(_ value: Double) {
        self.progressdelete.doubleValue = value
    }

    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            let dict = self.snapshotsloggdata!.snapshotslogs![index]
            self.hiddenID = dict.value(forKey: "hiddenID") as? Int
            guard self.hiddenID != nil else { return }
            self.index = self.configurations?.getIndex(hiddenID!)
        } else {
            self.index = nil
        }
    }

}

extension ViewControllerSnapshots: DismissViewController {

    // Protocol DismissViewController
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismissViewController(viewcontroller)
    }
}

extension ViewControllerSnapshots: GetSource {

    // Returning hiddenID as Index
    func getSource(index: Int) {
        self.hiddenID = index
        self.config = self.configurations!.getConfigurations()[self.configurations!.getIndex(hiddenID!)]
        self.snapshotsloggdata = SnapshotsLoggData(config: self.config!)
        self.localCatalog.stringValue = self.config!.localCatalog
        self.offsiteCatalog.stringValue = self.config!.offsiteCatalog
        self.offsiteUsername.stringValue = self.config!.offsiteUsername
        self.offsiteServer.stringValue = self.config!.offsiteServer
        self.backupID.stringValue = self.config!.backupID
        if config!.sshport != nil {
            self.sshport.stringValue = String(describing: self.config!.sshport!)
        }
        if self.config!.task == "snapshot" {
            self.info(num: 0)
            self.gettinglogs.startAnimation(nil)
        } else {
            self.info(num: 1)
        }
    }
}

extension ViewControllerSnapshots: UpdateProgress {
    func processTermination() {
        if delete {
            let deletenum = Int(self.deletesnapshots.intValue)
            if self.snapshotsloggdata!.remotecatalogstodelete == nil {
                self.updateProgressbar(Double(deletenum))
                self.delete = false
                self.progressdelete.isHidden = true
                self.deletebutton.isEnabled = true
                self.deletesnapshots.isEnabled = true
                self.info(num: 3)
                self.snapshotsloggdata = SnapshotsLoggData(config: self.config!)
            } else {
                let progress = deletenum - self.snapshotsloggdata!.remotecatalogstodelete!.count
                self.updateProgressbar(Double(progress))
            }
            self.deletesnapshotcatalogs()
        } else {
            self.deletebutton.isEnabled = true
            self.snapshotsloggdata?.processTermination()
            self.initdeletesnapshots()
            self.gettinglogs.stopAnimation(nil)
            globalMainQueue.async(execute: { () -> Void in
                self.snapshotstable.reloadData()
            })
        }
    }

    func fileHandler() {
        //
    }
}

extension ViewControllerSnapshots: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        guard self.snapshotsloggdata?.snapshotslogs != nil else {
            self.numberOflogfiles.stringValue = "Number of rows:"
            return 0
        }
        self.numberOflogfiles.stringValue = "Number of rows: " + String(self.snapshotsloggdata?.snapshotslogs!.count ?? 0)
        return (self.snapshotsloggdata?.snapshotslogs!.count ?? 0)
    }
}

extension ViewControllerSnapshots: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard row < self.snapshotsloggdata?.snapshotslogs!.count ?? 0 else { return nil }
        let object: NSDictionary = self.snapshotsloggdata!.snapshotslogs![row]
        if self.num != nil {
            if row < self.num! {
                return self.attributedstring(str: object[tableColumn!.identifier] as? String ?? "", color: NSColor.red, align: .left)
            }
        }
        return object[tableColumn!.identifier] as? String
    }
}

extension ViewControllerSnapshots: Reloadandrefresh {
    func reloadtabledata() {
        self.snapshotsloggdata = nil
        self.deletebutton.isEnabled = false
        self.progressdelete.isHidden = true
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.offsiteUsername.stringValue = ""
        self.offsiteServer.stringValue = ""
        self.backupID.stringValue = ""
        self.sshport.stringValue = ""
        globalMainQueue.async(execute: { () -> Void in
            self.snapshotstable.reloadData()
        })
    }
}

extension ViewControllerSnapshots: GetSelecetedIndex {
    func getindex() -> Int? {
        return self.index
    }
}

extension ViewControllerSnapshots: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        if self.deletesnapshotsnum.stringValue.isEmpty == false {
            if let num = Int(self.deletesnapshotsnum.stringValue) {
                if num > self.snapshotsloggdata?.snapshotslogs?.count ?? 0 {
                    self.deletesnapshots.intValue = Int32((self.snapshotsloggdata?.snapshotslogs?.count)! - 1)
                } else {
                    self.deletesnapshots.intValue = Int32(num)
                }
                self.num = Int(self.deletesnapshots.intValue)
                globalMainQueue.async(execute: { () -> Void in
                    self.snapshotstable.reloadData()
                })
            }
        }
    }
}
