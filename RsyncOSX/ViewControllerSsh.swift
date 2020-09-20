//
//  ViewControllerSsh.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

class ViewControllerSsh: NSViewController, SetConfigurations, VcMain, Checkforrsync, Help {
    var sshcmd: Ssh?
    var hiddenID: Int?
    var data: [String]?
    var outputprocess: OutputProcess?

    @IBOutlet var rsaCheck: NSButton!
    @IBOutlet var detailsTable: NSTableView!
    @IBOutlet var copykeycommand: NSTextField!
    @IBOutlet var sshport: NSTextField!
    @IBOutlet var sshkeypathandidentityfile: NSTextField!
    @IBOutlet var verifykeycommand: NSTextField!

    lazy var viewControllerSource: NSViewController? = {
        (self.storyboard!.instantiateController(withIdentifier: "CopyFilesID")
            as? NSViewController)
    }()

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
        self.presentAsModalWindow(self.viewControllerProfile!)
    }

    // Userconfiguration button
    @IBAction func userconfiguration(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerUserconfiguration!)
    }

    @IBAction func showHelp(_: AnyObject?) {
        self.help()
    }

    @IBAction func createPublicPrivateRSAKeyPair(_: NSButton) {
        self.outputprocess = OutputProcess()
        self.sshcmd = Ssh(outputprocess: self.outputprocess,
                          processtermination: self.processtermination,
                          filehandler: self.filehandler)
        guard self.sshcmd?.islocalpublicrsakeypresent() ?? true == false else { return }
        self.sshcmd?.creatersakeypair()
    }

    @IBAction func source(_: NSButton) {
        guard self.sshcmd != nil else { return }
        self.presentAsModalWindow(self.viewControllerSource!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcssh, nsviewcontroller: self)
        self.detailsTable.delegate = self
        self.detailsTable.dataSource = self
        self.outputprocess = nil
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.changesshparameters()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.copykeycommand.stringValue = ""
        self.verifykeycommand.stringValue = ""
    }

    func checkforPrivateandPublicRSAKeypair() {
        self.sshcmd = Ssh(outputprocess: nil,
                          processtermination: self.processtermination,
                          filehandler: self.filehandler)
        if self.sshcmd?.islocalpublicrsakeypresent() ?? false {
            self.rsaCheck.state = .on
        } else {
            self.rsaCheck.state = .off
        }
    }

    func changesshparameters() {
        self.sshkeypathandidentityfile.stringValue = ViewControllerReference.shared.sshkeypathandidentityfile ?? ""
        if let sshport = ViewControllerReference.shared.sshport {
            self.sshport.stringValue = String(sshport)
        } else {
            self.sshport.stringValue = ""
        }
        self.checkforPrivateandPublicRSAKeypair()
    }

    func copylocalpubrsakeyfile() {
        guard self.sshcmd?.islocalpublicrsakeypresent() ?? false == true else { return }
        self.outputprocess = OutputProcess()
        self.sshcmd = Ssh(outputprocess: self.outputprocess,
                          processtermination: self.processtermination,
                          filehandler: self.filehandler)
        if let hiddenID = self.hiddenID {
            self.sshcmd?.copykeyfile(hiddenID: hiddenID)
            self.copykeycommand.stringValue = sshcmd?.commandCopyPasteTerminal ?? ""
            self.sshcmd?.verifyremotekey(hiddenID: hiddenID)
            self.verifykeycommand.stringValue = sshcmd?.commandCopyPasteTerminal ?? ""
        }
    }
}

extension ViewControllerSsh: GetSource {
    func getSourceindex(index: Int) {
        self.hiddenID = index
        self.copylocalpubrsakeyfile()
        self.changesshparameters()
    }
}

extension ViewControllerSsh: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return self.data?.count ?? 0
    }
}

extension ViewControllerSsh: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "outputID"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = self.data?[row] ?? ""
            return cell
        } else {
            return nil
        }
    }
}

extension ViewControllerSsh {
    func processtermination() {
        globalMainQueue.async { () -> Void in
            self.checkforPrivateandPublicRSAKeypair()
        }
    }

    func filehandler() {
        self.data = self.outputprocess?.getOutput()
        globalMainQueue.async { () -> Void in
            self.detailsTable.reloadData()
        }
    }
}

extension ViewControllerSsh: OpenQuickBackup {
    func openquickbackup() {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        }
    }
}

extension ViewControllerSsh: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
    }
}
