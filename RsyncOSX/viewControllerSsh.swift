//
//  ViewControllerSsh.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//swiftlint:disable syntactic_sugar file_length cyclomatic_complexity line_length

import Foundation
import Cocoa

class ViewControllerSsh: NSViewController {

    // The object which checks for keys
    var sshcmd: Ssh?
    // hiddenID of selected index
    var hiddenID: Int?
    // Output
    // output from Rsync
    var output: Array<String>?
    // Execute or not
    var execute: Bool = false

    @IBOutlet weak var dsaCheck: NSButton!
    @IBOutlet weak var rsaCheck: NSButton!
    @IBOutlet weak var detailsTable: NSTableView!

    @IBOutlet weak var scpRsaPubKeyButton: NSButton!
    @IBOutlet weak var scpDsaPubKeyButton: NSButton!

    @IBOutlet weak var checkRsaPubKeyButton: NSButton!
    @IBOutlet weak var checkDsaPubKeyButton: NSButton!

    @IBOutlet weak var createRsaKey: NSButton!
    @IBOutlet weak var createDsaKey: NSButton!
    @IBOutlet weak var createKeys: NSButton!
    @IBOutlet weak var sshCreatRemoteSshButton: NSButton!

    @IBOutlet weak var scpRsaCopyPasteCommand: NSTextField!
    @IBOutlet weak var scpDsaCopyPasteCommand: NSTextField!
    @IBOutlet weak var sshCreateRemoteCatalog: NSTextField!

    // Delegate for getting index from Execute view
    weak var indexDelegate: GetSelecetedIndex?

    // Source for CopyFiles and Ssh
    // self.presentViewControllerAsSheet(self.ViewControllerAbout)
    lazy var viewControllerSource: NSViewController = {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "CopyFilesID"))
            as? NSViewController)!
    }()

    // Open the Terminal.app for pasting commands
    @IBAction func terminalApp(_ sender: NSButton) {
        guard self.sshcmd != nil else {
            return
        }
        self.sshcmd!.openTerminal()
    }

    // Just for grouping rsa and dsa radiobuttons
    @IBAction func radioButtonsCreateKeyPair(_ sender: NSButton) {
        // For selecting either of them
    }

    @IBAction func createPublicPrivateKeyPair(_ sender: NSButton) {

        guard self.sshcmd != nil else {
            return
        }
        if self.createRsaKey.state == .on {
            self.sshcmd!.createLocalKeysRsa()
        }

        if self.createDsaKey.state == .on {
            self.sshcmd!.createLocalKeysDsa()
        }
    }

    @IBAction func source(_ sender: NSButton) {
        self.presentViewControllerAsSheet(self.viewControllerSource)
    }

    @IBAction func createRemoteSshDirectory(_ sender: NSButton) {
        guard self.hiddenID != nil else {
            return
        }
        guard self.sshcmd != nil else {
            return
        }
        self.sshcmd!.createSshRemoteDirectory(hiddenID: self.hiddenID!)
        guard sshcmd!.commandCopyPasteTermninal != nil else {
            self.sshCreateRemoteCatalog.stringValue = " ... no remote server ..."
            return
        }
        self.sshCreateRemoteCatalog.stringValue = sshcmd!.commandCopyPasteTermninal!
    }

    @IBAction func scpRsaPubKey(_ sender: NSButton) {
        guard self.hiddenID != nil else {
            return
        }
        guard self.sshcmd != nil else {
            return
        }
        self.sshcmd!.scpPubKey(key: "rsa", hiddenID: self.hiddenID!)
        guard sshcmd!.commandCopyPasteTermninal != nil else {
            return
        }
        self.scpRsaCopyPasteCommand.stringValue = sshcmd!.commandCopyPasteTermninal!
    }

    @IBAction func scpDsaPubKey(_ sender: NSButton) {
        guard self.hiddenID != nil else {
            return
        }
        guard self.sshcmd != nil else {
            return
        }
        self.sshcmd!.scpPubKey(key: "dsa", hiddenID: self.hiddenID!)
        guard sshcmd!.commandCopyPasteTermninal != nil else {
            return
        }
        self.scpDsaCopyPasteCommand.stringValue = sshcmd!.commandCopyPasteTermninal!
    }

    @IBAction func checkRsaPubKey(_ sender: NSButton) {

        guard self.execute else {
            return
        }

        guard self.hiddenID != nil else {
            return
        }

        guard self.sshcmd != nil else {
            return
        }
        // First chmod key then list key (Processtermination)
        self.sshcmd!.chmodSsh(key: "rsa", hiddenID: self.hiddenID!)
        self.sshcmd!.executeSshCommand()
    }

    @IBAction func checkDsaPubKey(_ sender: NSButton) {

        guard self.execute else {
            return
        }

        guard self.hiddenID != nil else {
            return
        }

        guard self.sshcmd != nil else {
            return
        }
        // First chmod key then list key (Processtermination)
        self.sshcmd!.chmodSsh(key: "dsa", hiddenID: self.hiddenID!)
        self.sshcmd!.executeSshCommand()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Reference to self
        SharingManagerConfiguration.sharedInstance.viewControllerSsh = self
        // Do view setup here.
        self.detailsTable.delegate = self
        self.detailsTable.dataSource = self
        self.output = nil
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.scpDsaPubKeyButton.isEnabled = false
        self.scpRsaPubKeyButton.isEnabled = false
        self.checkDsaPubKeyButton.isEnabled = false
        self.checkRsaPubKeyButton.isEnabled = false
        self.sshCreatRemoteSshButton.isEnabled = false
        self.sshcmd = Ssh()
        // Check for keys
        self.checkPrivatePublicKey()

    }

    func checkPrivatePublicKey() {
        self.sshcmd = nil
        self.sshcmd = Ssh()
        self.sshcmd!.checkForLocalPubKeys()
        if self.sshcmd!.rsaPubKeyExist {
            self.rsaCheck.state = .on
            self.createKeys.isEnabled = false
        } else {
            self.rsaCheck.state = .off
            self.createKeys.isEnabled = true
        }
        if self.sshcmd!.dsaPubKeyExist {
            self.dsaCheck.state = .on
            self.createKeys.isEnabled = false
        } else {
            self.dsaCheck.state = .off
            self.createKeys.isEnabled = true
        }
    }
}

extension ViewControllerSsh: DismissViewController {

    // Protocol DismissViewController
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismissViewController(viewcontroller)
        guard self.hiddenID != nil else {
            return
        }
        self.scpDsaPubKeyButton.isEnabled = true
        self.scpRsaPubKeyButton.isEnabled = true
        self.checkDsaPubKeyButton.isEnabled = true
        self.checkRsaPubKeyButton.isEnabled = true
        self.sshCreatRemoteSshButton.isEnabled = true
    }
}

extension ViewControllerSsh: getSource {

    // Returning hiddenID as Index
    func getSource(index: Int) {
        self.hiddenID = index
        // Make sure that there is a offiseserver, if not set self.index = nil
        let config = SharingManagerConfiguration.sharedInstance.getConfigurations()[SharingManagerConfiguration.sharedInstance.getIndex(hiddenID!)]
        if config.offsiteServer.isEmpty == true {
            self.execute = false
        } else {
            self.execute = true
        }
    }
}

extension ViewControllerSsh : NSTableViewDataSource {

    func numberOfRows(in aTableView: NSTableView) -> Int {
        if self.output != nil {
            return self.output!.count
        } else {
            return 0
        }
    }

}

extension ViewControllerSsh : NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellIdentifier: String = ""

        if tableColumn == tableView.tableColumns[0] {
            text = self.output![row]
            cellIdentifier = "outputID"
        }

        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}

extension ViewControllerSsh: UpdateProgress {

    // Protocol UpdateProgress
    func processTermination() {
        globalMainQueue.async(execute: { () -> Void in
            self.checkPrivatePublicKey()
        })
        // Check if chmod remote ssh directory is next work
        guard self.sshcmd!.chmod != nil else {
            return
        }
        guard self.hiddenID != nil else {
            return
        }
        guard self.sshcmd != nil else {
            return
        }

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
        self.output = self.sshcmd!.getOutput()
        globalMainQueue.async(execute: { () -> Void in
            self.detailsTable.reloadData()
        })
    }

}
