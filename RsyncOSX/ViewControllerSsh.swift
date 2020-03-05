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

class ViewControllerSsh: NSViewController, SetConfigurations, VcMain, Checkforrsync {
    var sshcmd: Ssh?
    var hiddenID: Int?
    var data: [String]?
    var outputprocess: OutputProcess?
    var execute: Bool = false

    @IBOutlet var dsaCheck: NSButton!
    @IBOutlet var rsaCheck: NSButton!
    @IBOutlet var detailsTable: NSTableView!
    @IBOutlet var checkRsaPubKeyButton: NSButton!
    @IBOutlet var checkDsaPubKeyButton: NSButton!
    @IBOutlet var createRsaKey: NSButton!
    @IBOutlet var createDsaKey: NSButton!
    @IBOutlet var createKeys: NSButton!
    @IBOutlet var scpRsaCopyPasteCommand: NSTextField!
    @IBOutlet var scpDsaCopyPasteCommand: NSTextField!
    @IBOutlet var sshCreateRemoteCatalog: NSTextField!
    @IBOutlet var remoteserverbutton: NSButton!

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

    // Just for grouping rsa and dsa radiobuttons
    @IBAction func radioButtonsCreateKeyPair(_: NSButton) {
        // For selecting either of them
    }

    @IBAction func createPublicPrivateKeyPair(_: NSButton) {
        self.outputprocess = OutputProcess()
        self.sshcmd = Ssh(outputprocess: self.outputprocess)
        if self.createRsaKey.state == .on {
            self.sshcmd?.createLocalKeysRsa()
        }
        if self.createDsaKey.state == .on {
            self.sshcmd?.createLocalKeysDsa()
        }
    }

    @IBAction func source(_: NSButton) {
        guard self.sshcmd != nil else {
            self.data = ["Press the \"Check\" button before this action..."]
            globalMainQueue.async { () -> Void in
                self.detailsTable.reloadData()
            }
            return
        }
        self.presentAsSheet(self.viewControllerSource!)
    }

    func createRemoteSshDirectory() {
        if let hiddenID = self.hiddenID {
            self.sshcmd?.createSshRemoteDirectory(hiddenID: hiddenID)
            guard sshcmd?.commandCopyPasteTermninal != nil else {
                self.sshCreateRemoteCatalog.stringValue = NSLocalizedString("... no remote server ...", comment: "Ssh")
                return
            }
            self.sshCreateRemoteCatalog.stringValue = sshcmd?.commandCopyPasteTermninal ?? ""
        }
    }

    func scpRsaPubKey() {
        if let hiddenID = self.hiddenID {
            self.sshcmd?.scpPubKey(key: "rsa", hiddenID: hiddenID)
            self.scpRsaCopyPasteCommand.stringValue = sshcmd?.commandCopyPasteTermninal ?? ""
        }
    }

    func scpDsaPubKey() {
        if let hiddenID = self.hiddenID {
            self.sshcmd?.scpPubKey(key: "dsa", hiddenID: hiddenID)
            self.scpDsaCopyPasteCommand.stringValue = sshcmd?.commandCopyPasteTermninal ?? ""
        }
    }

    @IBAction func checkRsaPubKey(_: NSButton) {
        self.outputprocess = OutputProcess()
        self.sshcmd = Ssh(outputprocess: self.outputprocess)
        guard self.execute == true else { return }
        if let hiddenID = self.hiddenID {
            self.sshcmd?.chmodSsh(key: "rsa", hiddenID: hiddenID)
            self.sshcmd?.executeSshCommand()
        }
    }

    @IBAction func checkDsaPubKey(_: NSButton) {
        self.outputprocess = OutputProcess()
        self.sshcmd = Ssh(outputprocess: self.outputprocess)
        guard self.execute == true else { return }
        if let hiddenID = self.hiddenID {
            self.sshcmd?.chmodSsh(key: "dsa", hiddenID: hiddenID)
            self.sshcmd?.executeSshCommand()
        }
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

    @IBAction func commencecheck(_: NSButton) {
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

extension ViewControllerSsh: UpdateProgress {
    func processTermination() {
        globalMainQueue.async { () -> Void in
            self.checkPrivatePublicKey()
        }
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
