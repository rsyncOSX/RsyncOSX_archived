//
//  ViewControllerExtensions.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 28.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

protocol VcMain {
    var storyboard: NSStoryboard? { get }
}

extension VcMain {
    var storyboard: NSStoryboard? {
        return NSStoryboard(name: "Main", bundle: nil)
    }

    var sheetviewstoryboard: NSStoryboard? {
        return NSStoryboard(name: "SheetViews", bundle: nil)
    }

    // StoryboardOutputID
    var viewControllerAllOutput: NSViewController? {
        return (storyboard?.instantiateController(withIdentifier: "StoryboardOutputID")
            as? NSViewController)
    }

    // Sheetviews
    // Userconfiguration
    var viewControllerUserconfiguration: NSViewController? {
        return (sheetviewstoryboard?.instantiateController(withIdentifier: "StoryboardUserconfigID")
            as? NSViewController)
    }

    // Information about rsync output
    var viewControllerInformation: NSViewController? {
        return (sheetviewstoryboard?.instantiateController(withIdentifier: "StoryboardInformationID")
            as? NSViewController)
    }

    // Profile
    var viewControllerProfile: NSViewController? {
        return (sheetviewstoryboard?.instantiateController(withIdentifier: "ProfileID")
            as? NSViewController)
    }

    // About
    var viewControllerAbout: NSViewController? {
        return (sheetviewstoryboard?.instantiateController(withIdentifier: "AboutID")
            as? NSViewController)
    }

    // Remote Info
    var viewControllerRemoteInfo: NSViewController? {
        return (sheetviewstoryboard?.instantiateController(withIdentifier: "StoryboardRemoteInfoID")
            as? NSViewController)
    }

    // Quick backup process
    var viewControllerQuickBackup: NSViewController? {
        return (sheetviewstoryboard?.instantiateController(withIdentifier: "StoryboardQuickBackupID")
            as? NSViewController)
    }

    // local and remote info
    var viewControllerInformationLocalRemote: NSViewController? {
        return (sheetviewstoryboard?.instantiateController(withIdentifier: "StoryboardLocalRemoteID")
            as? NSViewController)
    }

    // Estimating
    var viewControllerEstimating: NSViewController? {
        return (sheetviewstoryboard?.instantiateController(withIdentifier: "StoryboardEstimatingID")
            as? NSViewController)
    }

    // Progressbar process
    var viewControllerProgress: NSViewController? {
        return (sheetviewstoryboard?.instantiateController(withIdentifier: "StoryboardProgressID")
            as? NSViewController)
    }

    // Rsync userparams
    var viewControllerRsyncParams: NSViewController? {
        return (sheetviewstoryboard?.instantiateController(withIdentifier: "StoryboardRsyncParamsID")
            as? NSViewController)
    }

    // Edit
    var editViewController: NSViewController? {
        return (sheetviewstoryboard?.instantiateController(withIdentifier: "StoryboardEditID")
            as? NSViewController)
    }

    // RsyncCommand
    var rsynccommand: NSViewController? {
        return (sheetviewstoryboard?.instantiateController(withIdentifier: "RsyncCommand")
            as? NSViewController)
    }

    // Add task
    var addtaskViewController: NSViewController? {
        return (sheetviewstoryboard?.instantiateController(withIdentifier: "AddTaskID")
            as? NSViewController)
    }
}

// Protocol for dismissing a viewcontroller
protocol DismissViewController: AnyObject {
    func dismiss_view(viewcontroller: NSViewController)
}

protocol SetDismisser {
    func dismissview(viewcontroller: NSViewController, vcontroller: ViewController)
}

extension SetDismisser {
    var dismissDelegateMain: DismissViewController? {
        return SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    var dismissDelegateCopyFiles: DismissViewController? {
        return SharedReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
    }

    var dimissDelegateSnapshot: DismissViewController? {
        return SharedReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
    }

    var dismissDelegateLoggData: DismissViewController? {
        return SharedReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
    }

    var dismissDelegateSsh: DismissViewController? {
        return SharedReference.shared.getvcref(viewcontroller: .vcssh) as? ViewControllerSsh
    }

    func dismissview(viewcontroller _: NSViewController, vcontroller: ViewController) {
        if vcontroller == .vctabmain {
            dismissDelegateMain?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vcrestore {
            dismissDelegateCopyFiles?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vcsnapshot {
            dimissDelegateSnapshot?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vcloggdata {
            dismissDelegateLoggData?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vcssh {
            dismissDelegateSsh?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        }
    }
}

// Protocol for deselecting rowtable
protocol DeselectRowTable: AnyObject {
    func deselect()
}

protocol Deselect {
    var deselectDelegateMain: DeselectRowTable? { get }
}

extension Deselect {
    var deselectDelegateMain: DeselectRowTable? {
        return SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    func deselectrowtable(vcontroller: ViewController) {
        if vcontroller == .vctabmain {
            deselectDelegateMain?.deselect()
        }
    }
}

protocol Index {
    func index() -> Int?
}

extension Index {
    func index() -> Int? {
        weak var getindexDelegate: GetSelecetedIndex?
        getindexDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        return getindexDelegate?.getindex()
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
    func connected(config: Configuration?) -> Bool
    func connected(server: String?) -> Bool
}

extension Connected {
    func connected(config: Configuration?) -> Bool {
        var port = 22
        if let config = config {
            if config.offsiteServer.isEmpty == false {
                if let sshport: Int = config.sshport { port = sshport }
                let success = TCPconnections().verifyTCPconnection(config.offsiteServer, port: port, timeout: 1)
                return success
            } else {
                return true
            }
        }
        return false
    }

    func connected(server: String?) -> Bool {
        if let server = server {
            let port = 22
            if server.isEmpty == false {
                let success = TCPconnections().verifyTCPconnection(server, port: port, timeout: 1)
                return success
            } else {
                return true
            }
        }
        return false
    }
}

protocol Abort {
    func abort()
}

extension Abort {
    func abort() {
        let view = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        view?.abortOperations()
    }
}

protocol Help {
    func help()
}

extension Help {
    func help() {
        NSWorkspace.shared.open(URL(string: "https://rsyncosx.netlify.app/post/rsyncosxdocs/")!)
    }
}

protocol GetOutput: AnyObject {
    func getoutput() -> [String]
}

protocol OutPut {
    var informationDelegateMain: GetOutput? { get }
}

extension OutPut {
    var informationDelegateMain: GetOutput? {
        return SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    func getinfo() -> [String] {
        return (informationDelegateMain?.getoutput()) ?? [""]
    }
}

protocol RsyncIsChanged: AnyObject {
    func rsyncischanged()
}

protocol NewRsync {
    func newrsync()
}

extension NewRsync {
    func newrsync() {
        let view = SharedReference.shared.getvcref(viewcontroller: .vcsidebar) as? ViewControllerSideBar
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
        let view = SharedReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
        view?.temporaryrestorepath()
    }
}

extension Sequence {
    func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T>,
        using comparator: (T, T) -> Bool = (<)
    ) -> [Element] {
        sorted { a, b in
            comparator(a[keyPath: keyPath], b[keyPath: keyPath])
        }
    }
}
