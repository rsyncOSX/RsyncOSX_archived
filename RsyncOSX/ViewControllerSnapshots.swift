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

class ViewControllerSnapshots: NSViewController, SetDismisser, SetConfigurations {

    private var hiddenID: Int?
    private var config: Configuration?
    private var snapshotsloggdata: SnapshotsLoggData?
    private var delete: Bool = false

    @IBOutlet weak var snapshotstable: NSTableView!
    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var offsiteCatalog: NSTextField!
    @IBOutlet weak var offsiteUsername: NSTextField!
    @IBOutlet weak var offsiteServer: NSTextField!
    @IBOutlet weak var backupID: NSTextField!
    @IBOutlet weak var sshport: NSTextField!
    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var deletebutton: NSButton!
    @IBOutlet weak var deletenum: NSTextField!
    @IBOutlet weak var numberOflogfiles: NSTextField!
    @IBOutlet weak var progressdelete: NSProgressIndicator!
    @IBOutlet weak var confirmdelete: NSButton!

    // Source for CopyFiles and Ssh
    // self.presentViewControllerAsSheet(self.ViewControllerAbout)
    lazy var viewControllerSource: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "CopyFilesID"))
            as? NSViewController)!
    }()

    private func info (num: Int) {
        switch num {
        case 1:
            self.info.stringValue = "Not a snapshot task..."
        case 2:
            self.info.stringValue = "Cannot delete all snapshot catalogs..."
        case 3:
            self.info.stringValue = "Please confirm delete..."
        case 4:
            self.info.stringValue = "Max 5 catalogs to delete..."
        case 5:
            self.info.stringValue = "Enter a real number..."
        default:
            self.info.stringValue = ""
        }
    }

    @IBAction func delete(_ sender: NSButton) {
        if let delete = Int(self.deletenum.stringValue) {
            guard delete < self.snapshotsloggdata?.expandedremotecatalogs?.count ?? 0 else {
                self.info(num: 2)
                return
            }
            guard delete <= 5 else {
                self.info(num: 4)
                return
            }
            guard self.confirmdelete.state == .on else {
                self.info(num: 3)
                return
            }
            guard delete > 0 else {
                self.info(num: 5)
                return
            }
            self.snapshotsloggdata!.preparecatalogstodelete(num: delete)
            self.info(num: 0)
            self.deletebutton.isEnabled = false
            self.deletenum.isEnabled = false
            self.initiateProgressbar()
            self.deletesnapshotcatalogs()
        } else {
            self.info(num: 5)
            return
        }
        self.delete = true
    }

    @IBAction func getindex(_ sender: NSButton) {
        self.reloadtabledata()
        self.presentViewControllerAsSheet(self.viewControllerSource)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.snapshotstable.delegate = self
        self.snapshotstable.dataSource = self
        ViewControllerReference.shared.setvcref(viewcontroller: .vcsnapshot, nsviewcontroller: self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.deletebutton.isEnabled = false
        self.delete = false
        self.snapshotsloggdata = nil
        self.progressdelete.isHidden = true
        self.confirmdelete.state = .off
        self.info(num: 0)
        globalMainQueue.async(execute: { () -> Void in
            self.snapshotstable.reloadData()
        })
    }

    override func viewDidDisappear() {
        self.reloadtabledata()
    }

    private func deletesnapshotcatalogs() {
        var arguments: SnapshotDeleteCatalogsArguments?
        var deletecommand: SnapshotCommandDeleteCatalogs?
        guard self.snapshotsloggdata?.remotecatalogstodelete != nil else {
            return
        }
        guard self.snapshotsloggdata!.remotecatalogstodelete!.count > 0 else { return }
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
        if let deletenum = Double(self.deletenum.stringValue) {
            self.progressdelete.maxValue = deletenum
        } else {
            return
        }
        self.progressdelete.minValue = 0
        self.progressdelete.doubleValue = 0
        self.progressdelete.startAnimation(self)
    }

    private func updateProgressbar(_ value: Double) {
        self.progressdelete.doubleValue = value
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
        } else {
            self.info(num: 1)
        }
    }
}

extension ViewControllerSnapshots: UpdateProgress {
    func processTermination() {
        if delete {
            if let deletenum = Int(self.deletenum.stringValue) {
                if self.snapshotsloggdata!.remotecatalogstodelete == nil {
                    self.updateProgressbar(Double(deletenum))
                    self.delete = false
                    self.deletenum.stringValue = ""
                    self.snapshotsloggdata = SnapshotsLoggData(config: self.config!)
                } else {
                    let progress = deletenum - self.snapshotsloggdata!.remotecatalogstodelete!.count
                    self.updateProgressbar(Double(progress))
                }
            }
            self.deletesnapshotcatalogs()
        } else {
            self.deletebutton.isEnabled = true
            self.snapshotsloggdata?.processTermination()
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
        return object[tableColumn!.identifier] as? String
    }
}

extension ViewControllerSnapshots: Reloadandrefresh {
    func reloadtabledata() {
        self.snapshotsloggdata = nil
        self.deletebutton.isEnabled = false
        self.deletenum.isEnabled = true
        self.deletenum.stringValue = ""
        self.progressdelete.isHidden = true
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.offsiteUsername.stringValue = ""
        self.offsiteServer.stringValue = ""
        self.backupID.stringValue = ""
        self.sshport.stringValue = ""
        self.confirmdelete.state = .off
        globalMainQueue.async(execute: { () -> Void in
            self.snapshotstable.reloadData()
        })
    }
}
