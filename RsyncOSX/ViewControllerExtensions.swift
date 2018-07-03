//
//  ViewControllerExtensions.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 28.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length file_length

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
    var viewControllerInformationLocalRemote: NSViewController? { get }
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

    // Restore
    // self.presentViewControllerAsSheet(self.restoreViewController)
    var restoreViewController: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardRestoreID"))
            as? NSViewController)!
    }

    // Profile
    // self.presentViewControllerAsSheet(self.viewControllerProfile)
    var viewControllerProfile: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ProfileID"))
            as? NSViewController)!
    }

    // ScheduledBackupInWorkID
    // self.presentViewControllerAsSheet(self.viewControllerScheduledBackupInWork)
    var viewControllerScheduledBackupInWork: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ScheduledBackupInWorkID"))
            as? NSViewController)!
    }

    // About
    // self.presentViewControllerAsSheet(self.viewControllerAbout)
    var viewControllerAbout: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "AboutID"))
            as? NSViewController)!
    }

    // Information Schedule details
    // self.presentViewControllerAsSheet(self.viewControllerScheduleDetails)
    var viewControllerScheduleDetails: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardScheduleID"))
            as? NSViewController)!
    }

    // Quick backup process
    // self.presentViewControllerAsSheet(self.viewControllerQuickBackup)
    var viewControllerQuickBackup: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardQuickBackupID"))
            as? NSViewController)!
    }

    // Remote Info
    // self.presentViewControllerAsSheet(self.viewControllerQuickBackup)
    var viewControllerRemoteInfo: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardRemoteInfoID"))
            as? NSViewController)!
    }

    // Estimating
    // self.presentViewControllerAsSheet(self.viewControllerEstimating)
    var viewControllerEstimating: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardEstimatingID"))
            as? NSViewController)!
    }

    // local and remote info
    // self.presentViewControllerAsSheet(self.viewControllerInformationLocalRemote)
    var viewControllerInformationLocalRemote: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardLocalRemoteID"))
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
    var dismissDelegateMain: DismissViewController? {get}
    var dismissDelegateSchedule: DismissViewController? {get}
    var dismissDelegateCopyFiles: DismissViewController? {get}
    var dismissDelegateNewConfigurations: DismissViewController? {get}
    var dismissDelegateSsh: DismissViewController? {get}
    var dimissDelegateSnapshot: DismissViewController? {get}
    var dismissDelegateEncrypt: DismissViewController? {get}
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
    weak var dimissDelegateSnapshot: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
    }
    weak var dismissDelegateEncrypt: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcencrypt) as? ViewControllerEncrypt
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
        } else if vcontroller == .vcssh {
            self.dismissDelegateSsh?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vcsnapshot {
            self.dimissDelegateSnapshot?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vcencrypt {
            self.dismissDelegateEncrypt?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        }
    }
}

// Protocol for deselecting rowtable
protocol DeselectRowTable: class {
    func deselect()
}

protocol Deselect {
    var deselectDelegateMain: DeselectRowTable? {get}
    var deselectDelegateSchedule: DeselectRowTable? {get}
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
    var getindexDelegateMain: GetSelecetedIndex? { get }
    var getindexDelegateSnapshot: GetSelecetedIndex? { get }
}

extension GetIndex {
    weak var getindexDelegateMain: GetSelecetedIndex? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }

    weak var getindexDelegateSnapshot: GetSelecetedIndex? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
    }

    func index(viewcontroller: ViewController) -> Int? {
        switch viewcontroller {
        case .vctabmain:
            return self.getindexDelegateMain?.getindex()
        case .vcsnapshot:
            return self.getindexDelegateSnapshot?.getindex()
        default:
            return self.getindexDelegateMain?.getindex()
        }
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
    var abortDelegate: AbortOperations? { get }
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
    var informationDelegateMain: Information? {get}
    var informationDelegateCopyFiles: Information? {get}
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
    var newRsyncDelegate: RsyncChanged? {get}
}

extension NewRsync {
    weak var newRsyncDelegate: RsyncChanged? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }

    func newrsync() {
        self.newRsyncDelegate?.rsyncchanged()
    }
}

protocol Createandreloadconfigurations: class {
    func createandreloadconfigurations()
}

// Protocol for doing a refresh of tabledata
protocol Reloadsortedandrefresh: class {
    func reloadsortedandrefreshtabledata()
}

// Protocol for sorting
protocol Sorting {
    func sortbyrundate(notsorted: [NSMutableDictionary]?, sortdirection: Bool) -> [NSMutableDictionary]?
    func sortbystring(notsorted: [NSMutableDictionary]?, sortby: Sortandfilter, sortdirection: Bool) -> [NSMutableDictionary]?
    func filterbystring(filterby: Sortandfilter) -> String
}

extension Sorting {
    func sortbyrundate(notsorted: [NSMutableDictionary]?, sortdirection: Bool) -> [NSMutableDictionary]? {
        guard notsorted != nil else { return nil }
        let dateformatter = Tools().setDateformat()
        let sorted = notsorted!.sorted { (dict1, dict2) -> Bool in
            let date1 = (dateformatter.date(from: (dict1.value(forKey: "dateExecuted") as? String) ?? "") ?? dateformatter.date(from: "01 Jan 1900 00:00")!)
            let date2 = (dateformatter.date(from: (dict2.value(forKey: "dateExecuted") as? String) ?? "") ?? dateformatter.date(from: "01 Jan 1900 00:00")!)
            if date1.timeIntervalSince(date2) > 0 {
                return sortdirection
            } else {
                return !sortdirection
            }
        }
        return sorted
    }

    func sortbystring(notsorted: [NSMutableDictionary]?, sortby: Sortandfilter, sortdirection: Bool) -> [NSMutableDictionary]? {
        guard notsorted != nil else { return nil }
        var sortstring: String?
        switch sortby {
        case .localcatalog:
            sortstring = "localCatalog"
        case .remoteserver:
            sortstring = "offsiteServer"
        case .task:
            sortstring = "task"
        case .backupid:
            sortstring = "backupID"
        case .profile:
            sortstring = "profile"
        default:
            sortstring = ""
        }
        let sorted = notsorted!.sorted { (dict1, dict2) -> Bool in
            if (dict1.value(forKey: sortstring!) as? String) ?? "" > (dict2.value(forKey: sortstring!) as? String) ?? "" {
                return sortdirection
            } else {
                return !sortdirection
            }
        }
        return sorted
    }

    func filterbystring(filterby: Sortandfilter) -> String {
        switch filterby {
        case .localcatalog:
            return "localCatalog"
        case .profile:
            return "profile"
        case .remotecatalog:
            return "offsiteCatalog"
        case .remoteserver:
            return "offsiteServer"
        case .task:
            return "task"
        case .backupid:
            return "backupID"
        case .numberofdays:
            return ""
        case .executedate:
            return "dateExecuted"
        }
    }
}

protocol Allerrors: class {
    func allerrors(outputprocess: OutputProcess?)
}
