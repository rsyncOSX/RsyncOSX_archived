//
//  ViewControllerSsh.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerSsh: NSViewController {

    // The object which checks for keys
    var Ssh: ssh?
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
    @IBAction func TerminalApp(_ sender: NSButton) {
        guard self.Ssh != nil else {
            return
        }
        self.Ssh!.openTerminal()
    }

    // Just for grouping rsa and dsa radiobuttons
    @IBAction func RadioButtonsCreateKeyPair(_ sender: NSButton) {
        // For selecting either of them
    }

    @IBAction func createPublicPrivateKeyPair(_ sender: NSButton) {

        guard self.Ssh != nil else {
            return
        }
        if self.createRsaKey.state == .on {
            self.Ssh!.createLocalKeysRsa()
        }

        if self.createDsaKey.state == .on {
            self.Ssh!.createLocalKeysDsa()
        }
    }

    @IBAction func Source(_ sender: NSButton) {
        self.presentViewControllerAsSheet(self.viewControllerSource)
    }

    @IBAction func createRemoteSshDirectory(_ sender: NSButton) {
        guard self.hiddenID != nil else {
            return
        }
        guard self.Ssh != nil else {
            return
        }
        self.Ssh!.createSshRemoteDirectory(hiddenID: self.hiddenID!)
        guard Ssh!.commandCopyPasteTermninal != nil else {
            self.sshCreateRemoteCatalog.stringValue = " ... no remote server ..."
            return
        }
        self.sshCreateRemoteCatalog.stringValue = Ssh!.commandCopyPasteTermninal!
    }

    @IBAction func scpRsaPubKey(_ sender: NSButton) {
        guard self.hiddenID != nil else {
            return
        }
        guard self.Ssh != nil else {
            return
        }
        self.Ssh!.ScpPubKey(key: "rsa", hiddenID: self.hiddenID!)
        guard Ssh!.commandCopyPasteTermninal != nil else {
            return
        }
        self.scpRsaCopyPasteCommand.stringValue = Ssh!.commandCopyPasteTermninal!
    }

    @IBAction func scpDsaPubKey(_ sender: NSButton) {
        guard self.hiddenID != nil else {
            return
        }
        guard self.Ssh != nil else {
            return
        }
        self.Ssh!.ScpPubKey(key: "dsa", hiddenID: self.hiddenID!)
        guard Ssh!.commandCopyPasteTermninal != nil else {
            return
        }
        self.scpDsaCopyPasteCommand.stringValue = Ssh!.commandCopyPasteTermninal!
    }

    @IBAction func checkRsaPubKey(_ sender: NSButton) {

        guard self.execute else {
            return
        }

        guard self.hiddenID != nil else {
            return
        }

        guard self.Ssh != nil else {
            return
        }
        // First chmod key then list key (Processtermination)
        self.Ssh!.chmodSsh(key: "rsa", hiddenID: self.hiddenID!)
        self.Ssh!.executeSshCommand()
    }

    @IBAction func checkDsaPubKey(_ sender: NSButton) {

        guard self.execute else {
            return
        }

        guard self.hiddenID != nil else {
            return
        }

        guard self.Ssh != nil else {
            return
        }
        // First chmod key then list key (Processtermination)
        self.Ssh!.chmodSsh(key: "dsa", hiddenID: self.hiddenID!)
        self.Ssh!.executeSshCommand()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Reference to self
        SharingManagerConfiguration.sharedInstance.ViewControllerSsh = self
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
        self.Ssh = ssh()
        // Check for keys
        self.checkPrivatePublicKey()

    }

    func checkPrivatePublicKey() {
        self.Ssh = nil
        self.Ssh = ssh()
        self.Ssh!.CheckForLocalPubKeys()
        if self.Ssh!.rsaPubKeyExist {
            self.rsaCheck.state = .on
            self.createKeys.isEnabled = false
        } else {
            self.rsaCheck.state = .off
            self.createKeys.isEnabled = true
        }
        if self.Ssh!.dsaPubKeyExist {
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
        guard self.Ssh!.chmod != nil else {
            return
        }
        guard self.hiddenID != nil else {
            return
        }
        guard self.Ssh != nil else {
            return
        }

        switch self.Ssh!.chmod!.pop() {
        case .chmodRsa:
            self.Ssh!.checkRemotePubKey(key: "rsa", hiddenID: self.hiddenID!)
            self.Ssh!.executeSshCommand()
        case .chmodDsa:
            self.Ssh!.checkRemotePubKey(key: "dsa", hiddenID: self.hiddenID!)
            self.Ssh!.executeSshCommand()
        default:
            self.Ssh!.chmod = nil
        }
    }

    func fileHandler() {
        self.output = self.Ssh!.getOutput()
        globalMainQueue.async(execute: { () -> Void in
            self.detailsTable.reloadData()
        })
    }

}
