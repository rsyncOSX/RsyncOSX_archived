//
//  ViewControllerReference.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 05.09.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

enum ViewController {
    case viewcontrollertabmain
}

struct ViewControllerReference {
    
    // let pvc = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ViewControllertabMain")) as? ViewControllertabMain
    // self.configurationsDelegate = pvc
    // self.configurations = self.configurationsDelegate?.readconfigurationdata()
    func getviewcontrollerreference(viewcontroller: ViewController) -> NSViewController? {
        switch viewcontroller {
        case .viewcontrollertabmain:
            let view = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ViewControllertabMain")) as? ViewControllertabMain
            return view
        default:
            return nil
        }
    }
}
