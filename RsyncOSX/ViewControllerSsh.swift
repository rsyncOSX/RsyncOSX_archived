//
//  ViewControllerSsh.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

class ViewControllerSsh: NSViewController, SetConfigurations, VcExecute {

    var sshcmd: Ssh?
    var hiddenID: Int?
    var data: [String]?
    var outputprocess: OutputProcess?
    var execute: Bool = false

    @IBOutlet weak var dsaCheck: NSButton!
    @IBOutlet weak var rsaCheck: NSButton!
    @IBOutlet weak var detailsTable: NSTableView!
    @IBOutlet weak var checkRsaPubKeyButton: NSButton!
    @IBOutlet weak var checkDsaPubKeyButton: NSButton!
    @IBOutlet weak var createRsaKey: NSButton!
    @IBOutlet weak var createDsaKey: NSButton!
    @IBOutlet weak var createKeys: NSButton!
    @IBOutlet weak var scpRsaCopyPasteCommand: NSTextField!
    @IBOutlet weak var scpDsaCopyPasteCommand: NSTextField!
    @IBOutlet weak var sshCreateRemoteCatalog: NSTextField!
    @IBOutlet weak var remoteserverbutton: NSButton!
    @IBOutlet weak var terminalappbutton: NSButton!

    // self.presentViewControllerAsSheet(self.ViewControllerAbout)
    lazy var viewControllerSource: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: "CopyFilesID")
            as? NSViewController)!
    }()

    @IBAction func totinfo(_ sender: NSButton) {
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        self.configurations!.processtermination = .remoteinfotask
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        })
    }

    @IBAction func quickbackup(_ sender: NSButton) {
        guard ViewControllerReference.shared.norsync == false else {
            _ = Norsync()
            return
        }
        self.openquickbackup()
    }

    @IBAction func automaticbackup(_ sender: NSButton) {
        self.configurations!.processtermination = .automaticbackup
        self.configurations?.remoteinfotaskworkqueue = RemoteInfoTaskWorkQueue()
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    @IBAction func terminalApp(_ sender: NSButton) {
        guard self.sshcmd != nil else {
            self.data = ["Press the \"Check\" button before this action..."]
            globalMainQueue.async(execute: { () -> Void in
                self.detailsTable.reloadData()
            })
            return
        }
        self.sshcmd!.openTerminal()
    }

    // Just for grouping rsa and dsa radiobuttons
    @IBAction func radioButtonsCreateKeyPair(_ sender: NSButton) {
        // For selecting either of them
    }

    @IBAction func createPublicPrivateKeyPair(_ sender: NSButton) {
        self.outputprocess = OutputProcess()
        self.sshcmd = Ssh(outputprocess: self.outputprocess)
        guard self.sshcmd != nil else { return }
        if self.createRsaKey.state == .on {
            self.sshcmd!.createLocalKeysRsa()
        }
        if self.createDsaKey.state == .on {
            self.sshcmd!.createLocalKeysDsa()
        }
    }

    @IBAction func source(_ sender: NSButton) {
        guard self.sshcmd != nil else {
            self.data = ["Press the \"Check\" button before this action..."]
            globalMainQueue.async(execute: { () -> Void in
                self.detailsTable.reloadData()
            })
            return
        }
        self.presentAsSheet(self.viewControllerSource)
    }

    func createRemoteSshDirectory() {
        guard self.hiddenID != nil else { return }
        guard self.sshcmd != nil else { return }
        self.sshcmd!.createSshRemoteDirectory(hiddenID: self.hiddenID!)
        guard sshcmd!.commandCopyPasteTermninal != nil else {
            self.sshCreateRemoteCatalog.stringValue = NSLocalizedString("... no remote server ...", comment: "Ssh")
            return
        }
        self.sshCreateRemoteCatalog.stringValue = sshcmd!.commandCopyPasteTermninal!
    }

    func scpRsaPubKey() {
        guard self.hiddenID != nil else { return }
        guard self.sshcmd != nil else { return }
        self.sshcmd!.scpPubKey(key: "rsa", hiddenID: self.hiddenID!)
        guard sshcmd!.commandCopyPasteTermninal != nil else { return }
        self.scpRsaCopyPasteCommand.stringValue = sshcmd!.commandCopyPasteTermninal!
    }

    func scpDsaPubKey() {
        guard self.hiddenID != nil else { return }
        guard self.sshcmd != nil else { return }
        self.sshcmd!.scpPubKey(key: "dsa", hiddenID: self.hiddenID!)
        guard sshcmd!.commandCopyPasteTermninal != nil else { return }
        self.scpDsaCopyPasteCommand.stringValue = sshcmd!.commandCopyPasteTermninal!
    }

    @IBAction func checkRsaPubKey(_ sender: NSButton) {
        self.outputprocess = OutputProcess()
        self.sshcmd = Ssh(outputprocess: self.outputprocess)
        guard self.execute else { return }
        guard self.hiddenID != nil else { return }
        guard self.sshcmd != nil else { return }
        self.sshcmd!.chmodSsh(key: "rsa", hiddenID: self.hiddenID!)
        self.sshcmd!.executeSshCommand()
    }

    @IBAction func checkDsaPubKey(_ sender: NSButton) {
        self.outputprocess = OutputProcess()
        self.sshcmd = Ssh(outputprocess: self.outputprocess)
        guard self.execute else { return }
        guard self.hiddenID != nil else { return }
        guard self.sshcmd != nil else { return }
        self.sshcmd!.chmodSsh(key: "dsa", hiddenID: self.hiddenID!)
        self.sshcmd!.executeSshCommand()
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
        ViewControllerReference.shared.activetab = .vcssh
        self.checkDsaPubKeyButton.isEnabled = false
        self.checkRsaPubKeyButton.isEnabled = false
        self.createKeys.isEnabled = false
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.scpDsaCopyPasteCommand.stringValue = ""
        self.scpRsaCopyPasteCommand.stringValue = ""
        self.sshCreateRemoteCatalog.stringValue = ""
    }

    @IBAction func commencecheck(_ sender: NSButton) {
        self.checkPrivatePublicKey()
    }

    private func checkPrivatePublicKey() {
        self.sshcmd = Ssh(outputprocess: nil)
        self.sshcmd!.checkForLocalPubKeys()
        if self.sshcmd!.rsaPubKeyExist {
            self.rsaCheck.state = .on
            self.createKeys.isEnabled = false
            self.createRsaKey.state = .off
        } else {
            self.rsaCheck.state = .off
            self.createKeys.isEnabled = true
            self.createRsaKey.state = .on
        }
        if self.sshcmd!.dsaPubKeyExist {
            self.dsaCheck.state = .on
            self.createKeys.isEnabled = false
            self.createDsaKey.state = .off
        } else {
            self.dsaCheck.state = .off
            self.createKeys.isEnabled = true
            if self.sshcmd!.rsaPubKeyExist {
                self.createDsaKey.state = .on
            }
        }
    }
}

extension ViewControllerSsh: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
        self.checkDsaPubKeyButton.isEnabled = true
        self.checkRsaPubKeyButton.isEnabled = true
        self.createRemoteSshDirectory()
        self.scpRsaPubKey()
        self.scpDsaPubKey()
    }
}

extension ViewControllerSsh: GetSource {
    func getSourceindex(index: Int) {
        self.hiddenID = index
        let config = self.configurations!.getConfigurations()[self.configurations!.getIndex(hiddenID!)]
        if config.offsiteServer.isEmpty == true {
            self.execute = false
        } else {
            self.execute = true
        }
    }
}

extension ViewControllerSsh: NSTableViewDataSource {
    func numberOfRows(in aTableView: NSTableView) -> Int {
        return self.data?.count ?? 0
    }
}

extension ViewControllerSsh: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "outputID"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue =  self.data?[row] ?? ""
            return cell
        } else {
            return nil
        }
    }
}

extension ViewControllerSsh: UpdateProgress {
    func processTermination() {
        globalMainQueue.async(execute: { () -> Void in
            self.checkPrivatePublicKey()
        })
        guard self.sshcmd != nil else { return }
        guard self.sshcmd!.chmod != nil else { return }
        guard self.hiddenID != nil else { return }
        switch self.sshcmd!.chmod!.pop() {
        case .chmodRsa:
            self.sshcmd!.checkRemotePubKey(key: "rsa", hiddenID: self.hiddenID!)
            self.sshcmd!.executeSshCommand()
        case .chmodDsa:
            self.sshcmd!.checkRemotePubKey(key: "dsa", hiddenID: self.hiddenID!)
            self.sshcmd!.executeSshCommand()
        default:
            self.sshcmd!.chmod = nil
        }
    }

    func fileHandler() {
        self.data = self.outputprocess!.getOutput()
        globalMainQueue.async(execute: { () -> Void in
            self.detailsTable.reloadData()
        })
    }
}

extension ViewControllerSsh: OpenQuickBackup {
    func openquickbackup() {
        self.configurations!.processtermination = .quicktask
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        })
    }
}
