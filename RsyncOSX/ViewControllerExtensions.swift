//
//  ViewControllerExtensions.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 28.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

protocol VcSchedule {
    var storyboard: NSStoryboard? { get }
    var viewControllerScheduleDetails: NSViewController? { get }
    var viewControllerUserconfiguration: NSViewController? { get }
    var viewControllerProfile: NSViewController? { get }
}

extension VcSchedule {
    var storyboard: NSStoryboard? {
        return NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
    }

    // Information Schedule details
    // self.presentViewControllerAsSheet(self.ViewControllerScheduleDetails)
    var viewControllerScheduleDetails: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardScheduleID"))
            as? NSViewController)!
    }

    // Userconfiguration
    // self.presentViewControllerAsSheet(self.ViewControllerUserconfiguration)
    var viewControllerUserconfiguration: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardUserconfigID"))
            as? NSViewController)!
    }

    // Profile
    // self.presentViewControllerAsSheet(self.ViewControllerProfile)
    var viewControllerProfile: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ProfileID"))
            as? NSViewController)!
    }
}

protocol VcMain {
    var storyboard: NSStoryboard? { get }
    var viewControllerInformation: NSViewController? { get }
    var viewControllerProgress: NSViewController? { get }
    var viewControllerBatch: NSViewController? { get }
    var viewControllerUserconfiguration: NSViewController? { get }
    var viewControllerRsyncParams: NSViewController? { get }
    var newVersionViewController: NSViewController? { get }
    var viewControllerProfile: NSViewController? { get }
    var editViewController: NSViewController? { get }
    var viewControllerScheduledBackupInWork: NSViewController? { get }
    var viewControllerAbout: NSViewController? { get }
    var viewControllerScheduleDetails: NSViewController? { get }
}

extension VcMain {
    var storyboard: NSStoryboard? {
        return NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
    }

    // Information about rsync output
    // self.presentViewControllerAsSheet(self.ViewControllerInformation)
    var viewControllerInformation: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardInformationID"))
            as? NSViewController)!
    }

    // Progressbar process
    // self.presentViewControllerAsSheet(self.ViewControllerProgress)
    var viewControllerProgress: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardProgressID"))
            as? NSViewController)!
    }

    // Batch process
    // self.presentViewControllerAsSheet(self.ViewControllerBatch)
    var viewControllerBatch: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardBatchID"))
            as? NSViewController)!
    }

    // Userconfiguration
    // self.presentViewControllerAsSheet(self.ViewControllerUserconfiguration)
    var viewControllerUserconfiguration: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardUserconfigID"))
            as? NSViewController)!
    }

    // Rsync userparams
    // self.presentViewControllerAsSheet(self.ViewControllerRsyncParams)
    var viewControllerRsyncParams: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardRsyncParamsID"))
            as? NSViewController)!
    }

    // New version window
    // self.presentViewControllerAsSheet(self.newVersionViewController)
    var newVersionViewController: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardnewVersionID"))
            as? NSViewController)!
    }

    // Edit
    // self.presentViewControllerAsSheet(self.editViewController)
    var editViewController: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardEditID"))
            as? NSViewController)!
    }

    // Profile
    // self.presentViewControllerAsSheet(self.ViewControllerProfile)
    var viewControllerProfile: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ProfileID"))
            as? NSViewController)!
    }

    // ScheduledBackupInWorkID
    // self.presentViewControllerAsSheet(self.ViewControllerScheduledBackupInWork)
    var viewControllerScheduledBackupInWork: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ScheduledBackupInWorkID"))
            as? NSViewController)!
    }

    // About
    // self.presentViewControllerAsSheet(self.ViewControllerAbout)
    var viewControllerAbout: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "AboutID"))
            as? NSViewController)!
    }

    // Information Schedule details
    // self.presentViewControllerAsSheet(self.ViewControllerScheduleDetails)
    var viewControllerScheduleDetails: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardScheduleID"))
            as? NSViewController)!
    }
}

protocol VcCopyFiles {
    var storyboard: NSStoryboard? { get }
    var viewControllerInformation: NSViewController? { get }
    var viewControllerSource: NSViewController? { get }
}

extension VcCopyFiles {
    var storyboard: NSStoryboard? {
        return NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
    }

    // Information about rsync output
    // self.presentViewControllerAsSheet(self.ViewControllerInformation)
    var viewControllerInformation: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardInformationCopyFilesID")) as? NSViewController)!
    }

    // Source for CopyFiles
    // self.presentViewControllerAsSheet(self.viewControllerSource)
    var viewControllerSource: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "CopyFilesID")) as? NSViewController)!
    }
}

// Protocol for dismissing a viewcontroller
protocol DismissViewController: class {
    func dismiss_view(viewcontroller: NSViewController)
}
protocol SetDismisser {
    weak var dismissDelegateMain: DismissViewController? {get}
    weak var dismissDelegateSchedule: DismissViewController? {get}
    weak var dismissDelegateCopyFiles: DismissViewController? {get}
    weak var dismissDelegateNewConfigurations: DismissViewController? {get}
    weak var dismissDelegateSsh: DismissViewController? {get}
    func dismissview(viewcontroller: NSViewController, vcontroller: ViewController)
}

extension SetDismisser {
    weak var dismissDelegateMain: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
    weak var dismissDelegateSchedule: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllertabSchedule
    }
    weak var dismissDelegateCopyFiles: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vccopyfiles) as? ViewControllerCopyFiles
    }
    weak var dismissDelegateNewConfigurations: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
    }
    weak var dismissDelegateSsh: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcssh) as? ViewControllerSsh
    }

    func dismissview(viewcontroller: NSViewController, vcontroller: ViewController) {
        if vcontroller == .vctabmain {
            self.dismissDelegateMain?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vctabschedule {
            self.dismissDelegateSchedule?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vccopyfiles {
            self.dismissDelegateCopyFiles?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vcnewconfigurations {
            self.dismissDelegateNewConfigurations?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else {
            self.dismissDelegateSsh?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        }
    }
}

// Protocol for deselecting rowtable
protocol DeselectRowTable: class {
    func deselect()
}

protocol Deselect {
    weak var deselectDelegateMain: DeselectRowTable? {get}
    weak var deselectDelegateSchedule: DeselectRowTable? {get}
    func deselectrowtable(vcontroller: ViewController)
}

extension Deselect {
    weak var deselectDelegateMain: DeselectRowTable? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
    weak var deselectDelegateSchedule: DeselectRowTable? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllertabSchedule
    }

    func deselectrowtable(vcontroller: ViewController) {
        if vcontroller == .vctabmain {
            self.deselectDelegateMain?.deselect()
        } else {
            self.deselectDelegateSchedule?.deselect()
        }
    }
}

// Protocol for sending selected index in tableView
// The protocol is implemented in ViewControllertabMain
protocol GetIndex: class {
    weak var getindexDelegate: GetSelecetedIndex? { get }
    func index() -> Int?
}

extension GetIndex {
    weak var getindexDelegate: GetSelecetedIndex? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }

    func index() -> Int? {
        return self.getindexDelegate?.getindex()
    }
}

protocol Coloractivetask {
    var colorindex: Int? { get }
}

extension Coloractivetask {

    var colorindex: Int? {
        return self.color()
    }

    func color() -> Int? {
        if let dict: NSDictionary = ViewControllerReference.shared.scheduledTask {
            if let hiddenID: Int = dict.value(forKey: "hiddenID") as? Int {
                return hiddenID
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

protocol Delay {
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> Void)
}

extension Delay {

    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}

// Protocol for aborting task
protocol AbortOperations: class {
    func abortOperations()
}

protocol AbortTask {
    weak var abortDelegate: AbortOperations? { get }
    func abort()
}

extension AbortTask {
    weak var abortDelegate: AbortOperations? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }

    func abort() {
        self.abortDelegate?.abortOperations()
    }
}

protocol Information: class {
    func getInformation () -> [String]
}

protocol GetInformation {
    weak var informationDelegateMain: Information? {get}
    weak var informationDelegateCopyFiles: Information? {get}
}

extension GetInformation {
    weak var informationDelegateMain: Information? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
    weak var informationDelegateCopyFiles: Information? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vccopyfiles) as? ViewControllerCopyFiles
    }

    func getinfo(viewcontroller: ViewController) -> [String] {
        if viewcontroller == .vctabmain {
            return (self.informationDelegateMain?.getInformation())!
        } else {
            return (self.informationDelegateCopyFiles?.getInformation())!
        }
    }
}
// Protocol for doing updates when optional path for rsync is changed
// or user enable or disable doubleclick to execte
protocol RsyncChanged: class {
    func rsyncchanged()
}

protocol NewRsync {
    weak var newRsyncDelegate: RsyncChanged? {get}
}

extension NewRsync {
    weak var newRsyncDelegate: RsyncChanged? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }

    func newrsync() {
        self.newRsyncDelegate?.rsyncchanged()
    }
}
