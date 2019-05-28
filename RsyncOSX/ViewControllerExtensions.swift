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
        return NSStoryboard(name: "Main", bundle: nil)
    }

    // Information Schedule details
    // self.presentViewControllerAsSheet(self.ViewControllerScheduleDetails)
    var viewControllerScheduleDetails: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardScheduleID")
            as? NSViewController)!
    }

    // Userconfiguration
    // self.presentViewControllerAsSheet(self.ViewControllerUserconfiguration)
    var viewControllerUserconfiguration: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardUserconfigID")
            as? NSViewController)!
    }

    // Profile
    // self.presentViewControllerAsSheet(self.ViewControllerProfile)
    var viewControllerProfile: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "ProfileID")
            as? NSViewController)!
    }

}

protocol VcExecute {
    var storyboard: NSStoryboard? { get }
}

extension VcExecute {

    var storyboard: NSStoryboard? {
        return NSStoryboard(name: "Main", bundle: nil)
    }

    // Remote Info
    // self.presentViewControllerAsSheet(self.viewControllerQuickBackup)
    var viewControllerRemoteInfo: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardRemoteInfoID")
            as? NSViewController)!
    }

    // Quick backup process
    // self.presentViewControllerAsSheet(self.viewControllerQuickBackup)
    var viewControllerQuickBackup: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardQuickBackupID")
            as? NSViewController)!
    }

    // Estimating
    // self.presentViewControllerAsSheet(self.viewControllerEstimating)
    var viewControllerEstimating: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardEstimatingID")
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
    var viewControllerAbout: NSViewController? { get }
    var viewControllerScheduleDetails: NSViewController? { get }
    var viewControllerInformationLocalRemote: NSViewController? { get }
}

extension VcMain {

    var storyboard: NSStoryboard? {
        return NSStoryboard(name: "Main", bundle: nil)
    }

    // Information about rsync output
    // self.presentViewControllerAsSheet(self.ViewControllerInformation)
    var viewControllerInformation: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardInformationID")
            as? NSViewController)!
    }

    // Progressbar process
    // self.presentViewControllerAsSheet(self.viewControllerProgress)
    var viewControllerProgress: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardProgressID")
            as? NSViewController)!
    }

    // Batch process
    // self.presentViewControllerAsSheet(self.ViewControllerBatch)
    var viewControllerBatch: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardBatchID")
            as? NSViewController)!
    }

    // Userconfiguration
    // self.presentViewControllerAsSheet(self.ViewControllerUserconfiguration)
    var viewControllerUserconfiguration: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardUserconfigID")
            as? NSViewController)!
    }

    // Rsync userparams
    // self.presentViewControllerAsSheet(self.ViewControllerRsyncParams)
    var viewControllerRsyncParams: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardRsyncParamsID")
            as? NSViewController)!
    }

    // New version window
    // self.presentViewControllerAsSheet(self.newVersionViewController)
    var newVersionViewController: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardnewVersionID")
            as? NSViewController)!
    }

    // Edit
    // self.presentViewControllerAsSheet(self.editViewController)
    var editViewController: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardEditID")
            as? NSViewController)!
    }

    // Restore
    // self.presentViewControllerAsSheet(self.restoreViewController)
    var restoreViewController: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardRestoreID")
            as? NSViewController)!
    }

    // Profile
    // self.presentViewControllerAsSheet(self.viewControllerProfile)
    var viewControllerProfile: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "ProfileID")
            as? NSViewController)!
    }

    // About
    // self.presentViewControllerAsSheet(self.viewControllerAbout)
    var viewControllerAbout: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "AboutID")
            as? NSViewController)!
    }

    // Information Schedule details
    // self.presentViewControllerAsSheet(self.viewControllerScheduleDetails)
    var viewControllerScheduleDetails: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardScheduleID")
            as? NSViewController)!
    }

    // Quick backup process
    // self.presentViewControllerAsSheet(self.viewControllerQuickBackup)
    var viewControllerQuickBackup: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardQuickBackupID")
            as? NSViewController)!
    }

    // Remote Info
    // self.presentViewControllerAsSheet(self.viewControllerQuickBackup)
    var viewControllerRemoteInfo: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardRemoteInfoID")
            as? NSViewController)!
    }

    // Estimating
    // self.presentViewControllerAsSheet(self.viewControllerEstimating)
    var viewControllerEstimating: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardEstimatingID")
            as? NSViewController)!
    }

    // local and remote info
    // self.presentViewControllerAsSheet(self.viewControllerInformationLocalRemote)
    var viewControllerInformationLocalRemote: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardLocalRemoteID")
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
        return NSStoryboard(name: "Main", bundle: nil)
    }

    // Information about rsync output
    // self.presentViewControllerAsSheet(self.ViewControllerInformation)
    var viewControllerInformation: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardInformationCopyFilesID") as? NSViewController)!
    }

    // Source for CopyFiles
    // self.presentViewControllerAsSheet(self.viewControllerSource)
    var viewControllerSource: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "CopyFilesID") as? NSViewController)!
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
    func dismissview(viewcontroller: NSViewController, vcontroller: ViewController)
}

extension SetDismisser {
    var dismissDelegateMain: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
    var dismissDelegateSchedule: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllertabSchedule
    }
    var dismissDelegateCopyFiles: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vccopyfiles) as? ViewControllerCopyFiles
    }
    var dismissDelegateNewConfigurations: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
    }
    var dismissDelegateSsh: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcssh) as? ViewControllerSsh
    }
    var dimissDelegateSnapshot: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
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
    var deselectDelegateMain: DeselectRowTable? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
    var deselectDelegateSchedule: DeselectRowTable? {
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

protocol Index {
    func index() -> Int?
}

extension Index {
    func index() -> Int? {
        let view = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        return view?.getindex()
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

protocol Connected {
    func connected(config: Configuration) -> Bool
}

extension Connected {
    func connected(config: Configuration) -> Bool {
        var port: Int = 22
        if config.offsiteServer.isEmpty == false {
            if let sshport: Int = config.sshport { port = sshport }
            let (success, _) = TCPconnections().testTCPconnection(config.offsiteServer, port: port, timeout: 1)
            return success
        } else {
            return true
        }
    }
}

protocol Abort: class {
    func abort()
}

extension Abort {
    func abort() {
        let view = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        view?.abortOperations()
    }
}

protocol GetOutput: class {
    func getoutput () -> [String]
}

protocol OutPut {
    var informationDelegateMain: GetOutput? {get}
    var informationDelegateCopyFiles: GetOutput? {get}
}

extension OutPut {
    var informationDelegateMain: GetOutput? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
    var informationDelegateCopyFiles: GetOutput? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vccopyfiles) as? ViewControllerCopyFiles
    }

    func getinfo(viewcontroller: ViewController) -> [String] {
        if viewcontroller == .vctabmain {
            return (self.informationDelegateMain?.getoutput())!
        } else {
            return (self.informationDelegateCopyFiles?.getoutput())!
        }
    }
}

protocol RsyncIsChanged: class {
    func rsyncischanged()
}

protocol NewRsync {
    func newrsync()
}

extension NewRsync {
    func newrsync() {
        let view = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        view?.rsyncischanged()
    }
}

protocol TemporaryRestorePath {
    func temporaryrestorepath()
}

protocol ChangeTemporaryRestorePath {
    func changetemporaryrestorepath()
}

extension ChangeTemporaryRestorePath {
    func changetemporaryrestorepath() {
        let view = ViewControllerReference.shared.getvcref(viewcontroller: .vccopyfiles) as? ViewControllerCopyFiles
        view?.temporaryrestorepath()
    }
}

protocol Createandreloadconfigurations: class {
    func createandreloadconfigurations()
}

// Protocol for doing a refresh of tabledata
protocol Reloadsortedandrefresh {
    func reloadsortedandrefreshtabledata()
}

// Protocol for sorting
protocol Sorting {
    func sortbyrundate(notsortedlist: [NSMutableDictionary]?, sortdirection: Bool) -> [NSMutableDictionary]?
    func sortbystring(notsortedlist: [NSMutableDictionary]?, sortby: Sortandfilter, sortdirection: Bool) -> [NSMutableDictionary]?
    func filterbystring(filterby: Sortandfilter) -> String
}

extension Sorting {
    func sortbyrundate(notsortedlist: [NSMutableDictionary]?, sortdirection: Bool) -> [NSMutableDictionary]? {
        guard notsortedlist != nil else { return nil }
        let dateformatter = DateFormatter()
        dateformatter.formatterBehavior = .behavior10_4
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .short
        let sorted = notsortedlist!.sorted { (dict1, dict2) -> Bool in
            let date1localized = dateformatter.date(from: (dict1.value(forKey: "dateExecuted") as? String) ?? "")
            let date2localized = dateformatter.date(from: (dict2.value(forKey: "dateExecuted") as? String) ?? "")
            if date1localized != nil && date2localized != nil {
                if date1localized!.timeIntervalSince(date2localized!) > 0 {
                    return sortdirection
                } else {
                   return !sortdirection
                }
            } else {
                return !sortdirection
            }
        }
        return sorted
    }

    func sortbystring(notsortedlist: [NSMutableDictionary]?, sortby: Sortandfilter, sortdirection: Bool) -> [NSMutableDictionary]? {
        guard notsortedlist != nil else { return nil }
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
        let sorted = notsortedlist!.sorted { (dict1, dict2) -> Bool in
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
    func getoutputerrors() -> OutputErrors?
}
