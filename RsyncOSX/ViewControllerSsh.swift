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
    
    @IBOutlet weak var dsaCheck: NSButton!
    @IBOutlet weak var rsaCheck: NSButton!
    
    // Delegate for getting index from Execute view
    weak var index_delegate:GetSelecetedIndex?
    
    // Information about rsync output
    // self.presentViewControllerAsSheet(self.ViewControllerInformation)
    lazy var ViewControllerInformation: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "StoryboardInformationCopyFilesID")
            as! NSViewController
    }()
    
    // Source for CopyFiles
    // self.presentViewControllerAsSheet(self.ViewControllerAbout)
    lazy var ViewControllerSource: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "CopyFilesID")
            as! NSViewController
    }()

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
        self.Ssh!.ScpPubKey(str: "rsa", hiddenID: self.hiddenID!)
        
    }
    
    
    @IBAction func scpDsaPubKey(_ sender: NSButton) {
        
        guard self.hiddenID != nil else {
            return
        }
        
        guard self.Ssh != nil else {
            return
        }
        self.Ssh!.ScpPubKey(str: "dsa", hiddenID: self.hiddenID!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
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
