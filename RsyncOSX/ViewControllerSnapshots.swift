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

    @IBOutlet weak var snapshotstable: NSTableView!
    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var offsiteCatalog: NSTextField!
    @IBOutlet weak var offsiteUsername: NSTextField!
    @IBOutlet weak var offsiteServer: NSTextField!
    @IBOutlet weak var backupID: NSTextField!
    @IBOutlet weak var sshport: NSTextField!

    // Source for CopyFiles and Ssh
    // self.presentViewControllerAsSheet(self.ViewControllerAbout)
    lazy var viewControllerSource: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "CopyFilesID"))
            as? NSViewController)!
    }()

    @IBAction func getindex(_ sender: NSButton) {
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
        globalMainQueue.async(execute: { () -> Void in
            self.snapshotstable.reloadData()
        })
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.snapshotsloggdata = nil
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
        self.localCatalog.stringValue = config!.localCatalog
        self.offsiteCatalog.stringValue = config!.offsiteCatalog
        self.offsiteUsername.stringValue = config!.offsiteUsername
        self.offsiteServer.stringValue = config!.offsiteServer
        self.backupID.stringValue = config!.backupID
        if config!.sshport != nil {
            self.sshport.stringValue = String(describing: config!.sshport!)
        }
    }
}

extension ViewControllerSnapshots: UpdateProgress {
    func processTermination() {
        self.snapshotsloggdata?.processTermination()
        globalMainQueue.async(execute: { () -> Void in
            self.snapshotstable.reloadData()
        })
    }

    func fileHandler() {
        //
    }
}

extension ViewControllerSnapshots: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        guard self.snapshotsloggdata?.snapshotsloggdata != nil else { return 0 }
        return (self.snapshotsloggdata?.snapshotsloggdata!.count ?? 0)
    }
}

extension ViewControllerSnapshots: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard row < self.snapshotsloggdata?.snapshotsloggdata!.count ?? 0 else { return nil }
        let object: NSDictionary = self.snapshotsloggdata!.snapshotsloggdata![row]
        return object[tableColumn!.identifier] as? String
    }
}
