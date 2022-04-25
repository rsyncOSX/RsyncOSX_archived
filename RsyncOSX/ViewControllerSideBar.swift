//
//  ViewControllerSideBar.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 29/11/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length function_body_length

import Cocoa
import Foundation

enum Sidebarmessages {
    case mainviewbuttons
    // case addviewbuttons
    case snapshotviewbuttons
    case logsviewbuttons
    case sshviewbuttons
    case restoreviewbuttons
    case reset
}

enum Sidebaractionsmessages {
    case Change
    case Parameter
    case Delete
    case Add
    case Save
    case Filelist
    case Estimate
    case Restore
    case Reset
    case CreateKey
    case Remote
    case Tag
    case Snap
}

protocol Sidebaractions: AnyObject {
    func sidebaractions(action: Sidebarmessages)
}

protocol Sidebarbuttonactions: AnyObject {
    func sidebarbuttonactions(action: Sidebaractionsmessages)
}

class ViewControllerSideBar: NSViewController, SetConfigurations, Delay, VcMain, Checkforrsync, Setcolor {
    // Buttons
    @IBOutlet var button1: NSButton!
    @IBOutlet var button2: NSButton!
    @IBOutlet var button3: NSButton!
    @IBOutlet var button4: NSButton!
    @IBOutlet var button5: NSButton!
    @IBOutlet var button6: NSButton!

    @IBOutlet var profilelabel: NSTextField!
    @IBOutlet var rsyncversionshort: NSTextField!

    var whichviewispresented: Sidebarmessages?

    @IBAction func actionbutton1(_: NSButton) {
        if let view = whichviewispresented {
            switch view {
            case .mainviewbuttons:
                guard SharedReference.shared.process == nil else { return }
                presentAsModalWindow(editViewController!)
            /*
             case .addviewbuttons:
                 weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
                 deleteDelegate?.sidebarbuttonactions(action: .Add)
              */
            case .snapshotviewbuttons:
                return
            case .logsviewbuttons:
                return
            case .sshviewbuttons:
                return
            case .restoreviewbuttons:
                weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
                deleteDelegate?.sidebarbuttonactions(action: .Filelist)
            default:
                return
            }
        }
    }

    @IBAction func actionbutton2(_: NSButton) {
        if let view = whichviewispresented {
            switch view {
            case .mainviewbuttons:
                guard SharedReference.shared.process == nil else { return }
                presentAsModalWindow(viewControllerRsyncParams!)
            /*
             case .addviewbuttons:
                 presentAsModalWindow(viewControllerAssist!)
             */
            case .snapshotviewbuttons:
                weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
                deleteDelegate?.sidebarbuttonactions(action: .Tag)
            case .logsviewbuttons:
                return
            case .sshviewbuttons:
                return
            case .restoreviewbuttons:
                weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
                deleteDelegate?.sidebarbuttonactions(action: .Estimate)
            default:
                return
            }
        }
    }

    @IBAction func actionbutton3(_: NSButton) {
        if let view = whichviewispresented {
            switch view {
            case .mainviewbuttons:
                guard SharedReference.shared.process == nil else { return }
                weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
                deleteDelegate?.sidebarbuttonactions(action: .Delete)
            /*
             case .addviewbuttons:
                 // Delete
                 weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
                 deleteDelegate?.sidebarbuttonactions(action: .Delete)
             */
            case .snapshotviewbuttons:
                weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
                deleteDelegate?.sidebarbuttonactions(action: .Delete)
            case .logsviewbuttons:
                weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
                deleteDelegate?.sidebarbuttonactions(action: .Delete)
            case .sshviewbuttons:
                weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vcssh) as? ViewControllerSsh
                deleteDelegate?.sidebarbuttonactions(action: .CreateKey)
            case .restoreviewbuttons:
                weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
                deleteDelegate?.sidebarbuttonactions(action: .Restore)
            default:
                return
            }
        }
    }

    @IBAction func actionbutton4(_: NSButton) {
        if let view = whichviewispresented {
            switch view {
            case .mainviewbuttons:
                guard SharedReference.shared.process == nil else { return }
                presentAsModalWindow(rsynccommand!)
            case .snapshotviewbuttons:
                weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
                deleteDelegate?.sidebarbuttonactions(action: .Save)
            case .logsviewbuttons:
                weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
                deleteDelegate?.sidebarbuttonactions(action: .Snap)
            case .sshviewbuttons:
                weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vcssh) as? ViewControllerSsh
                deleteDelegate?.sidebarbuttonactions(action: .Remote)
            case .restoreviewbuttons:
                weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
                deleteDelegate?.sidebarbuttonactions(action: .Reset)
            default:
                return
            }
        }
    }

    @IBAction func actionbutton5(_: NSButton) {
        if let view = whichviewispresented {
            switch view {
            case .mainviewbuttons:
                guard SharedReference.shared.process == nil else { return }
                presentAsModalWindow(schedulesview!)
            case .snapshotviewbuttons:
                return
            case .logsviewbuttons:
                return
            case .sshviewbuttons:
                return
            case .restoreviewbuttons:
                return
            default:
                return
            }
        }
    }

    @IBAction func actionbutton6(_: NSButton) {
        if let view = whichviewispresented {
            switch view {
            case .mainviewbuttons:
                guard SharedReference.shared.process == nil else { return }
                presentAsModalWindow(addtaskViewController!)
            default:
                return
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        SharedReference.shared.setvcref(viewcontroller: .vcsidebar, nsviewcontroller: self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        rsyncischanged()
    }
}

extension ViewControllerSideBar: SetProfileinfo {
    func setprofile(profile: String?) {
        if let profile = configurations?.getProfile() {
            profilelabel.stringValue = profile
            profilelabel.textColor = setcolor(nsviewcontroller: self, color: .white)
        } else {
            profilelabel.stringValue = "Default"
            profilelabel.textColor = setcolor(nsviewcontroller: self, color: .green)
        }
    }
}

extension ViewControllerSideBar: Sidebaractions {
    func sidebaractions(action: Sidebarmessages) {
        whichviewispresented = action
        switch action {
        case .mainviewbuttons:
            button1.isHidden = false
            button2.isHidden = false
            button3.isHidden = false
            button4.isHidden = false
            if SharedReference.shared.enableschdules {
                button5.isHidden = false
            } else {
                button5.isHidden = true
            }
            button6.isHidden = false
            button1.title = NSLocalizedString("Change", comment: "Sidebar")
            button2.title = NSLocalizedString("Parameter", comment: "Sidebar")
            button3.title = NSLocalizedString("Delete", comment: "Sidebar")
            button4.title = NSLocalizedString("Command", comment: "Sidebar")
            button5.title = NSLocalizedString("Schedules", comment: "Sidebar")
            button6.title = NSLocalizedString("Add task", comment: "Sidebar")
        /*
         case .addviewbuttons:
             button1.isHidden = false
             button2.isHidden = false
             button3.isHidden = false
             button4.isHidden = true
             button5.isHidden = true
             button1.title = NSLocalizedString("Add", comment: "Sidebar")
             button2.title = NSLocalizedString("Assist", comment: "Sidebar")
             button3.title = NSLocalizedString("Delete", comment: "Sidebar")
          */
        case .snapshotviewbuttons:
            button1.isHidden = true
            button2.isHidden = false
            button3.isHidden = false
            button4.isHidden = false
            button5.isHidden = true
            button6.isHidden = true
            button2.title = NSLocalizedString("Tag", comment: "Sidebar")
            button3.title = NSLocalizedString("Delete", comment: "Sidebar")
            button4.title = NSLocalizedString("Save", comment: "Sidebar")
        case .logsviewbuttons:
            button1.isHidden = true
            button2.isHidden = true
            button3.isHidden = false
            button4.isHidden = false
            button5.isHidden = true
            button6.isHidden = true
            button3.title = NSLocalizedString("Delete", comment: "Sidebar")
            button4.title = NSLocalizedString("Scan", comment: "Sidebar")
        case .sshviewbuttons:
            button1.isHidden = true
            button2.isHidden = true
            button3.isHidden = false
            button4.isHidden = false
            button5.isHidden = true
            button6.isHidden = true
            button3.title = NSLocalizedString("Create key", comment: "Sidebar")
            button4.title = NSLocalizedString("Remote", comment: "Sidebar")
        case .restoreviewbuttons:
            button1.isHidden = false
            button2.isHidden = false
            button3.isHidden = false
            button4.isHidden = false
            button5.isHidden = true
            button6.isHidden = true
            button1.title = NSLocalizedString("Filelist", comment: "Sidebar")
            button2.title = NSLocalizedString("Estimate", comment: "Sidebar")
            button3.title = NSLocalizedString("Restore", comment: "Sidebar")
            button4.title = NSLocalizedString("Reset", comment: "Sidebar")
        case .reset:
            button1.isHidden = true
            button2.isHidden = true
            button3.isHidden = true
            button4.isHidden = true
            button5.isHidden = true
            button6.isHidden = true
        }
    }
}

// Rsync path is changed, update displayed rsync command
extension ViewControllerSideBar: RsyncIsChanged {
    func rsyncischanged() {
        setinfoaboutrsync()
    }
}

extension ViewControllerSideBar: Setinfoaboutrsync {
    internal func setinfoaboutrsync() {
        if SharedReference.shared.norsync == true {
            rsyncversionshort.stringValue = "no rsync"
        } else {
            rsyncversionshort.stringValue = SharedReference.shared.rsyncversionshort ?? "rsync version"
        }
    }
}
