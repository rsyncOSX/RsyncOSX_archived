//
//  ViewControllerProfile.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 17/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa


class ViewControllerProfile : NSViewController {

    // Dismisser
    weak var dismiss_delegate:DismissViewController?
    
    @IBAction func close(_ sender: NSButton) {
        self.dismiss_delegate?.dismiss_view(viewcontroller: self)
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Dismisser is root controller
        if let pvc2 = self.presenting as? ViewControllertabMain {
            self.dismiss_delegate = pvc2
        } else if let pvc2 = self.presenting as? ViewControllertabSchedule{
            self.dismiss_delegate = pvc2
        } else if let pvc2 = self.presenting as? ViewControllerNewConfigurations {
            self.dismiss_delegate = pvc2
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }

}
