//
//  ViewControllerSideBar.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 29/11/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length function_body_length cyclomatic_complexity

import Cocoa
import Foundation

enum Sidebarmessages {
    case enableconvertjsonbutton
    case verifyjson
    case mainviewbuttons
    case addviewbuttons
    case scheduleviewbuttons
    case snapshotviewbuttons
    case logsviewbuttons
    case sshviewbuttons
    case restoreviewbuttons
    case reset
    case JSONlabel
}

enum Sidebaractionsmessages {
    case Change
    case Parameter
    case Delete
    case Add
    case Once
    case Daily
    case Weekly
    case Update
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

class ViewControllerSideBar: NSViewController, SetConfigurations, Delay, VcMain, Checkforrsync {
    @IBOutlet var jsonbutton: NSButton!
    @IBOutlet var jsonlabel: NSTextField!
    @IBOutlet var pathtorsyncosxschedbutton: NSButton!
    @IBOutlet var menuappisrunning: NSButton!
    // Buttons
    @IBOutlet var button1: NSButton!
    @IBOutlet var button2: NSButton!
    @IBOutlet var button3: NSButton!
    @IBOutlet var button4: NSButton!

    var whichviewispresented: Sidebarmessages?

    @IBAction func rsyncosxsched(_: NSButton) {
        let running = Running()
        guard running.rsyncOSXschedisrunning == false else { return }
        guard running.verifyrsyncosxsched() == true else { return }
        NSWorkspace.shared.open(URL(fileURLWithPath: (ViewControllerReference.shared.pathrsyncosxsched ?? "/Applications/") + ViewControllerReference.shared.namersyncosssched))
        NSApp.terminate(self)
    }

    @IBAction func actionbutton1(_: NSButton) {
        if let view = self.whichviewispresented {
            switch view {
            case .mainviewbuttons:
                self.presentAsModalWindow(self.editViewController!)
            case .addviewbuttons:
                weak var deleteDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
                deleteDelegate?.sidebarbuttonactions(action: .Add)
            case .scheduleviewbuttons:
                weak var deleteDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllerSchedule
                deleteDelegate?.sidebarbuttonactions(action: .Once)
            case .snapshotviewbuttons:
                return
            case .logsviewbuttons:
                return
            case .sshviewbuttons:
                return
            case .restoreviewbuttons:
                weak var deleteDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
                deleteDelegate?.sidebarbuttonactions(action: .Filelist)
            default:
                return
            }
        }
    }

    @IBAction func actionbutton2(_: NSButton) {
        if let view = self.whichviewispresented {
            switch view {
            case .mainviewbuttons:
                self.presentAsModalWindow(self.viewControllerRsyncParams!)
            case .addviewbuttons:
                self.presentAsModalWindow(self.viewControllerAssist!)
            case .scheduleviewbuttons:
                weak var deleteDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllerSchedule
                deleteDelegate?.sidebarbuttonactions(action: .Daily)
            case .snapshotviewbuttons:
                weak var deleteDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
                deleteDelegate?.sidebarbuttonactions(action: .Tag)
            case .logsviewbuttons:
                return
            case .sshviewbuttons:
                return
            case .restoreviewbuttons:
                weak var deleteDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
                deleteDelegate?.sidebarbuttonactions(action: .Estimate)
            default:
                return
            }
        }
    }

    @IBAction func actionbutton3(_: NSButton) {
        if let view = self.whichviewispresented {
            switch view {
            case .mainviewbuttons:
                // Delete
                weak var deleteDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
                deleteDelegate?.sidebarbuttonactions(action: .Delete)
            case .addviewbuttons:
                // Delete
                weak var deleteDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
                deleteDelegate?.sidebarbuttonactions(action: .Delete)
            case .scheduleviewbuttons:
                weak var deleteDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllerSchedule
                deleteDelegate?.sidebarbuttonactions(action: .Weekly)
            case .snapshotviewbuttons:
                weak var deleteDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
                deleteDelegate?.sidebarbuttonactions(action: .Delete)
            case .logsviewbuttons:
                weak var deleteDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
                deleteDelegate?.sidebarbuttonactions(action: .Delete)
            case .sshviewbuttons:
                weak var deleteDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcssh) as? ViewControllerSsh
                deleteDelegate?.sidebarbuttonactions(action: .CreateKey)
            case .restoreviewbuttons:
                weak var deleteDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
                deleteDelegate?.sidebarbuttonactions(action: .Restore)
            default:
                return
            }
        }
    }

    @IBAction func actionbutton4(_: NSButton) {
        if let view = self.whichviewispresented {
            switch view {
            case .mainviewbuttons:
                self.presentAsModalWindow(self.rsynccommand!)
            case .addviewbuttons:
                return
            case .scheduleviewbuttons:
                weak var deleteDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllerSchedule
                deleteDelegate?.sidebarbuttonactions(action: .Update)
            case .snapshotviewbuttons:
                weak var deleteDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
                deleteDelegate?.sidebarbuttonactions(action: .Save)
            case .logsviewbuttons:
                weak var deleteDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
                deleteDelegate?.sidebarbuttonactions(action: .Snap)
            case .sshviewbuttons:
                weak var deleteDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcssh) as? ViewControllerSsh
                deleteDelegate?.sidebarbuttonactions(action: .Remote)
            case .restoreviewbuttons:
                weak var deleteDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
                deleteDelegate?.sidebarbuttonactions(action: .Reset)
            default:
                return
            }
        }
    }

    func verifyjson() {
        self.verify()
    }

    func verify() {
        if let profile = self.configurations?.getProfile() {
            _ = VerifyJSON(profile: profile)
        } else {
            _ = VerifyJSON(profile: nil)
        }
    }

    @IBAction func Json(_: NSButton) {
        if let profile = self.configurations?.getProfile() {
            PersistentStorage().convert(profile: profile)
        } else {
            PersistentStorage().convert(profile: nil)
        }
        self.jsonbutton.isHidden = true
        ViewControllerReference.shared.convertjsonbutton = false
        self.verify()
    }

    func enableconvertjsonbutton() {
        if ViewControllerReference.shared.convertjsonbutton {
            ViewControllerReference.shared.convertjsonbutton = false
        } else {
            ViewControllerReference.shared.convertjsonbutton = true
        }
        if ViewControllerReference.shared.json == true {
            self.jsonbutton.title = "PLIST"
        } else {
            self.jsonbutton.title = "JSON"
        }
        self.jsonbutton.isHidden = !ViewControllerReference.shared.convertjsonbutton
    }

    func menuappicons() {
        globalMainQueue.async { () -> Void in
            let running = Running()
            if running.rsyncOSXschedisrunning == true {
                self.menuappisrunning.image = #imageLiteral(resourceName: "green")
            } else {
                self.menuappisrunning.image = #imageLiteral(resourceName: "red")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcsidebar, nsviewcontroller: self)
        self.pathtorsyncosxschedbutton.toolTip = NSLocalizedString("The menu app", comment: "Execute")
        self.delayWithSeconds(0.5) {
            self.menuappicons()
        }
    }
}

extension ViewControllerSideBar: MenuappChanged {
    func menuappchanged() {
        self.menuappicons()
    }
}

extension ViewControllerSideBar: Sidebaractions {
    func sidebaractions(action: Sidebarmessages) {
        self.whichviewispresented = action
        switch action {
        case .enableconvertjsonbutton:
            self.enableconvertjsonbutton()
        case .verifyjson:
            self.verify()
        case .mainviewbuttons:
            self.button1.isHidden = false
            self.button2.isHidden = false
            self.button3.isHidden = false
            self.button4.isHidden = false
            self.button1.title = NSLocalizedString("Change", comment: "Sidebar")
            self.button2.title = NSLocalizedString("Parameter", comment: "Sidebar")
            self.button3.title = NSLocalizedString("Delete", comment: "Sidebar")
            self.button4.title = NSLocalizedString("Command", comment: "Sidebar")
        case .addviewbuttons:
            self.button1.isHidden = false
            self.button2.isHidden = false
            self.button3.isHidden = false
            self.button4.isHidden = true
            self.button1.title = NSLocalizedString("Add", comment: "Sidebar")
            self.button2.title = NSLocalizedString("Assist", comment: "Sidebar")
            self.button3.title = NSLocalizedString("Delete", comment: "Sidebar")
        case .scheduleviewbuttons:
            self.button1.isHidden = false
            self.button2.isHidden = false
            self.button3.isHidden = false
            self.button4.isHidden = false
            self.button1.title = NSLocalizedString("Once", comment: "Sidebar")
            self.button2.title = NSLocalizedString("Daily", comment: "Sidebar")
            self.button3.title = NSLocalizedString("Weekly", comment: "Sidebar")
            self.button4.title = NSLocalizedString("Update", comment: "Sidebar")
        case .snapshotviewbuttons:
            self.button1.isHidden = true
            self.button2.isHidden = false
            self.button3.isHidden = false
            self.button4.isHidden = false
            self.button2.title = NSLocalizedString("Tag", comment: "Sidebar")
            self.button3.title = NSLocalizedString("Delete", comment: "Sidebar")
            self.button4.title = NSLocalizedString("Save", comment: "Sidebar")
        case .logsviewbuttons:
            self.button1.isHidden = true
            self.button2.isHidden = true
            self.button3.isHidden = false
            self.button4.isHidden = false
            self.button3.title = NSLocalizedString("Delete", comment: "Sidebar")
            self.button4.title = NSLocalizedString("Snap", comment: "Sidebar")
        case .sshviewbuttons:
            self.button1.isHidden = true
            self.button2.isHidden = true
            self.button3.isHidden = false
            self.button4.isHidden = false
            self.button3.title = NSLocalizedString("Create key", comment: "Sidebar")
            self.button4.title = NSLocalizedString("Remote", comment: "Sidebar")
        case .restoreviewbuttons:
            self.button1.isHidden = false
            self.button2.isHidden = false
            self.button3.isHidden = false
            self.button4.isHidden = false
            self.button1.title = NSLocalizedString("Filelist", comment: "Sidebar")
            self.button2.title = NSLocalizedString("Estimate", comment: "Sidebar")
            self.button3.title = NSLocalizedString("Restore", comment: "Sidebar")
            self.button4.title = NSLocalizedString("Reset", comment: "Sidebar")
        case .reset:
            self.button1.isHidden = true
            self.button2.isHidden = true
            self.button3.isHidden = true
            self.button4.isHidden = true
        case .JSONlabel:
            self.jsonlabel.isHidden = !ViewControllerReference.shared.json
        }
    }
}
