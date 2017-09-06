//
//  ViewControllerReference.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 05.09.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
// let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
//  let pvc = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier
// (rawValue: "ViewControllertabMain")) as? ViewControllertabMain
// self.configurationsDelegate = pvc
// self.configurations = self.configurationsDelegate?.readconfigurationdata()

import Foundation
import Cocoa

enum ViewController {
    case viewcontrollertabmain
    case viewcontrollerloggdata
    case viewcontrollernewconfigurations
    case viewcontrollertabschedule
}

struct ViewControllerReference {
    func getviewcontrollerreference(viewcontroller: ViewController) -> NSViewController? {
        switch viewcontroller {
        case .viewcontrollertabmain:
            print("viewcontrollertabmain")
            return Configurations.shared.viewControllertabMain
        case .viewcontrollerloggdata:
            print("viewcontrollerloggdata")
            return Configurations.shared.viewControllerLoggData
        case .viewcontrollernewconfigurations:
            print("viewcontrollernewconfigurations")
            return Configurations.shared.viewControllerNewConfigurations
        case .viewcontrollertabschedule:
            print("viewcontrollertabschedule")
            return Configurations.shared.viewControllertabSchedule
        }
    }
}
