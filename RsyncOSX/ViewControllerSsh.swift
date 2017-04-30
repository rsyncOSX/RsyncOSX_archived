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
    
    // Delegate for getting index from Execute view
    weak var index_delegate:GetSelecetedIndex?
    
    // Source for CopyFiles
    // self.presentViewControllerAsSheet(self.ViewControllerAbout)
    lazy var ViewControllerSource: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "CopyFilesID")
            as! NSViewController
    }()

    @IBAction func Source(_ sender: NSButton) {
        self.scpDsaPubKeyButton.isEnabled = true
        self.scpRsaPubKeyButton.isEnabled = true
        self.checkDsaPubKeyButton.isEnabled = true
        self.checkRsaPubKeyButton.isEnabled = true
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
        
        self.Ssh = ssh()
        if self.Ssh!.rsaPubKey {
            self.rsaCheck.state = NSOnState
        } else {
            self.rsaCheck.state = NSOffState
        }
        if self.Ssh!.dsaPubKey {
            self.dsaCheck.state = NSOnState
        } else {
            self.dsaCheck.state = NSOffState
        }
    }
}

extension ViewControllerSsh: DismissViewController {
    
    // Protocol DismissViewController
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismissViewController(viewcontroller)
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
        })
    }
    
    func FileHandler() {
        // self.updateProgressbar(Double(self.count_delegate!.inprogressCount()))
    }
    
    
}
