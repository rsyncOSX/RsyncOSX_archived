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
    
    // External resources
    private var resource:Resources?
    
    weak var dismiss_delegate:DismissViewController?
    var waitToClose:Timer?
    var closeIn:Timer?
    var seconds:Int?
    
    @IBOutlet weak var reminder: NSButton!
    @IBOutlet weak var closeinseconds: NSTextField!
    
    @IBAction func changelogg(_ sender: NSButton) {
        if let resource = self.resource {
            NSWorkspace.shared().open(URL(string: resource.getResource(resource: .changelog))!)
        }
    }
    
    @IBAction func download(_ sender: NSButton) {
        NSWorkspace.shared().open(URL(string: SharingManagerConfiguration.sharedInstance.URLnewVersion!)!)
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
    
    @objc private func setSecondsView() {
        self.seconds = self.seconds! - 1
        self.closeinseconds.stringValue = "Close automatically in : " + String(self.seconds!) + " seconds"
    }
    
    @objc private func closeView() {
        self.waitToClose?.invalidate()
        self.closeIn?.invalidate()
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
    
    @IBAction func dismiss(_ sender: NSButton) {
        self.waitToClose?.invalidate()
        self.closeIn?.invalidate()
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resource = Resources()
        // Dismisser is root controller
        if let pvc2 = self.presenting as? ViewControllertabMain {
            self.dismiss_delegate = pvc2
        }
    }
    
    override func viewDidAppear() {
        self.seconds = 10
        super.viewDidAppear()
        self.waitToClose = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(closeView), userInfo: nil, repeats: false)
        self.closeIn = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setSecondsView), userInfo: nil, repeats: true)
        self.closeinseconds.stringValue = "Close automatically in : 10 seconds"
    }
    
}
