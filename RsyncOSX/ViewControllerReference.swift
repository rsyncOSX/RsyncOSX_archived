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
    case vctabmain
    case vcloggdata
    case vcnewconfigurations
    case vctabschedule
    case vccopyfiles
    case vcssh
    case vcabout
}

class ViewControllerReference {

    // Creates a singelton of this class
    class var  shared: ViewControllerReference {
        struct Singleton {
            static let instance = ViewControllerReference()
        }
        return Singleton.instance
    }

    // Reference to main View
    private var viewControllertabMain: NSViewController?
    // Reference to Copy files
    private var viewControllerCopyFiles: NSViewController?
    // Reference to the New tasks
    private var viewControllerNewConfigurations: NSViewController?
    // Reference to the  Schedule
    private var viewControllertabSchedule: NSViewController?
    // Reference to the Operation object
    // Reference is set in when Scheduled task is executed
    private var operation: CompleteScheduledOperation?
    // Which profile to use, if default nil
    private var viewControllerLoggData: NSViewController?
    // Reference to Ssh view
    private var viewControllerSsh: NSViewController?
    // Reference to About
    private var viewControllerAbout: NSViewController?

    func getvcref(viewcontroller: ViewController) -> NSViewController? {
        switch viewcontroller {
        case .vctabmain:
            print("viewcontrollertabmain")
            return self.viewControllertabMain
        case .vcloggdata:
            print("viewcontrollerloggdata")
            return self.viewControllerLoggData
        case .vcnewconfigurations:
            print("viewcontrollernewconfigurations")
            return self.viewControllerNewConfigurations
        case .vctabschedule:
            print("viewcontrollertabschedule")
            return self.viewControllertabSchedule
        case .vccopyfiles:
            print("viewcontrollercopyfiles")
            return self.viewControllerCopyFiles
        case .vcssh:
            print("viewcontrollerssh")
            return self.viewControllerSsh
        case .vcabout:
            print("viewcontrollerabout")
            return self.viewControllerAbout
        }
    }

    func setvcref(viewcontroller: ViewController, nsviewcontroller: NSViewController) {
        switch viewcontroller {
        case .vctabmain:
            self.viewControllertabMain = nsviewcontroller
        case .vcloggdata:
            self.viewControllerLoggData = nsviewcontroller
        case .vcnewconfigurations:
            self.viewControllerNewConfigurations = nsviewcontroller
        case .vctabschedule:
            self.viewControllertabSchedule = nsviewcontroller
        case .vccopyfiles:
            self.viewControllerCopyFiles = nsviewcontroller
        case .vcssh:
            self.viewControllerSsh = nsviewcontroller
        case .vcabout:
            self.viewControllerAbout = nsviewcontroller
        }
    }
}
