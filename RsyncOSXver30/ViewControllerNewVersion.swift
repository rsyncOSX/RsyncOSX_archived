//
//  ViewControllerNewVersion.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 02/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerNewVersion : NSViewController {
    
    @IBOutlet weak var reminder: NSButton!
    weak var dismiss_delegate:DismissViewController?
    var waitToClose:Timer?

    
    @IBAction func changelogg(_ sender: NSButton) {
        NSWorkspace.shared().open(URL(string: "https://rsyncosx.blogspot.no/2016/03/revision-history.html")!)
    }
    
    @IBAction func download(_ sender: NSButton) {
        NSWorkspace.shared().open(URL(string: SharingManagerConfiguration.sharedInstance.URLnewVersion!)!)
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
    
    @objc private func closeView() {
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
    
    @IBAction func dismiss(_ sender: NSButton) {
        self.waitToClose?.invalidate()
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.waitToClose = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(closeView), userInfo: nil, repeats: false)
        // Dismisser is root controller
        if let pvc2 = self.presenting as? ViewControllertabMain {
            self.dismiss_delegate = pvc2
        }
    }
    
}
