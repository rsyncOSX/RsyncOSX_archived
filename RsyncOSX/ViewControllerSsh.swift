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
    var Ssh:ssh?
    // hiddenID of selected index
    var hiddenID:Int?
    // Output
    // output from Rsync
    var output:Array<String>?
    
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
    
    @IBOutlet weak var chmodKeyButton: NSButton!
    
    // Delegate for getting index from Execute view
    weak var index_delegate:GetSelecetedIndex?
    
    // Source for CopyFiles
    // self.presentViewControllerAsSheet(self.ViewControllerAbout)
    lazy var ViewControllerSource: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "CopyFilesID")
            as! NSViewController
    }()
    
    @IBAction func TerminalApp(_ sender: NSButton) {
        guard self.Ssh != nil else {
            return
        }
        self.Ssh!.openTerminal()
    }
    
    @IBAction func RadioButtonsCreateKeyPair(_ sender: NSButton) {
        // For selecting either of them
    }
    
    @IBAction func createPublicPrivateKeyPair(_ sender: NSButton) {
        
        guard self.Ssh != nil else {
            return
        }
        if (self.createRsaKey.state == NSOnState) {
            self.Ssh!.createKeysRsa()
        }
        
        if (self.createDsaKey.state == NSOnState){
            self.Ssh!.createKeysDsa()
        }
    }

    @IBAction func Source(_ sender: NSButton) {
        self.presentViewControllerAsSheet(self.ViewControllerSource)
    }
    
    @IBAction func scpRsaPubKey(_ sender: NSButton) {
        
        guard self.hiddenID != nil else {
            return
        }
        guard self.Ssh != nil else {
            return
        }
        self.Ssh!.ScpPubKey(key: "rsa", hiddenID: self.hiddenID!)
        self.Ssh!.executeSshCommand()
    }
    
    
    @IBAction func scpDsaPubKey(_ sender: NSButton) {
        
        guard self.hiddenID != nil else {
            return
        }
        guard self.Ssh != nil else {
            return
        }
        self.Ssh!.ScpPubKey(key: "dsa", hiddenID: self.hiddenID!)
        self.Ssh!.executeSshCommand()
    }
    
    @IBAction func checkRsaPubKey(_ sender: NSButton) {
        guard self.hiddenID != nil else {
            return
        }
        
        guard self.Ssh != nil else {
            return
        }
        self.Ssh!.checkRemotePubKey(key: "rsa", hiddenID: self.hiddenID!)
        self.Ssh!.executeSshCommand()
    }
    
    @IBAction func checkDsaPubKey(_ sender: NSButton) {
        guard self.hiddenID != nil else {
            return
        }
        
        guard self.Ssh != nil else {
            return
        }
        self.Ssh!.checkRemotePubKey(key: "dsa", hiddenID: self.hiddenID!)
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
        self.chmodKeyButton.isEnabled = false
        self.Ssh = ssh()
        // Check for keys
        self.checkPrivatePublicKey()
        
        
    }
    
    func checkPrivatePublicKey() {
        
        self.Ssh = nil
        self.Ssh = ssh()
        self.Ssh!.checkKeys()
        if self.Ssh!.rsaPubKeyExist {
            self.rsaCheck.state = NSOnState
            self.createKeys.isEnabled = false
        } else {
            self.rsaCheck.state = NSOffState
            self.createKeys.isEnabled = true
        }
        if self.Ssh!.dsaPubKeyExist {
            self.dsaCheck.state = NSOnState
            self.createKeys.isEnabled = false
        } else {
            self.dsaCheck.state = NSOffState
            self.createKeys.isEnabled = true
        }
    }
    
    @IBAction func chmodSsh(_ sender: NSButton) {
        
        guard self.hiddenID != nil else {
            return
        }
        
        guard self.Ssh != nil else {
            return
        }
        
        if (self.createRsaKey.state == NSOnState) {
            self.Ssh!.chmodSsh(key: "rsa", hiddenID: self.hiddenID!)
        }
        
        if (self.createDsaKey.state == NSOnState){
           self.Ssh!.chmodSsh(key: "dsa", hiddenID: self.hiddenID!)
        }
        self.Ssh!.executeSshCommand()
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
        self.chmodKeyButton.isEnabled = true
    }
}

extension ViewControllerSsh: getSource {
    
    // Returning hiddenID as Index
    func GetSource(Index: Int) {
        self.hiddenID = Index
    }
}

extension ViewControllerSsh : NSTableViewDataSource {
    
    func numberOfRows(in aTableView: NSTableView) -> Int {
        if (self.output != nil) {
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
        
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}

extension ViewControllerSsh: UpdateProgress {
    
    // Protocol UpdateProgress
    
    func ProcessTermination() {
        self.output = self.Ssh!.getOutput()
        GlobalMainQueue.async(execute: { () -> Void in
            self.detailsTable.reloadData()
            self.checkPrivatePublicKey()
        })
    }
    
    func FileHandler() {
        // self.updateProgressbar(Double(self.count_delegate!.inprogressCount()))
    }
    
    
}
