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
        if self.snapshotsloggdata?.snapshotsloggdata == nil {
            // self.numberOflogfiles.stringValue = "Number of rows:"
            return 0
        } else {
            // self.numberOflogfiles.stringValue = "Number of rows: " + String(self.tabledata!.count)
            return (self.snapshotsloggdata?.snapshotsloggdata!.count ?? 0)
        }
    }

}

extension ViewControllerSnapshots: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard self.snapshotsloggdata?.snapshotsloggdata != nil else { return nil }
        let object: NSDictionary = self.snapshotsloggdata!.snapshotsloggdata![row]
        return object[tableColumn!.identifier] as? String
    }
}
