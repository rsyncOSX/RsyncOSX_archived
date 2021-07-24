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
    case enableconvertjsonbutton
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

class ViewControllerSideBar: NSViewController, SetConfigurations, Delay, VcMain, Checkforrsync, Setcolor {
    @IBOutlet var jsonbutton: NSButton!
    @IBOutlet var jsonlabel: NSTextField!
    @IBOutlet var pathtorsyncosxschedbutton: NSButton!
    @IBOutlet var menuappisrunning: NSButton!
    // Buttons
    @IBOutlet var button1: NSButton!
    @IBOutlet var button2: NSButton!
    @IBOutlet var button3: NSButton!
    @IBOutlet var button4: NSButton!

    @IBOutlet var profilelabel: NSTextField!

    var whichviewispresented: Sidebarmessages?

    @IBAction func rsyncosxsched(_: NSButton) {
        let running = Running()
        guard running.rsyncOSXschedisrunning == false else { return }
        guard running.verifyrsyncosxsched() == true else { return }
        NSWorkspace.shared.open(URL(fileURLWithPath: (SharedReference.shared.pathrsyncosxsched ?? "/Applications/") + SharedReference.shared.namersyncosssched))
        NSApp.terminate(self)
    }

    @IBAction func actionbutton1(_: NSButton) {
        if let view = whichviewispresented {
            switch view {
            case .mainviewbuttons:
                guard SharedReference.shared.process == nil else { return }
                presentAsModalWindow(editViewController!)
            case .addviewbuttons:
                weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
                deleteDelegate?.sidebarbuttonactions(action: .Add)
            case .scheduleviewbuttons:
                weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllerSchedule
                deleteDelegate?.sidebarbuttonactions(action: .Once)
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
            case .addviewbuttons:
                presentAsModalWindow(viewControllerAssist!)
            case .scheduleviewbuttons:
                weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllerSchedule
                deleteDelegate?.sidebarbuttonactions(action: .Daily)
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
                // Delete
                guard SharedReference.shared.process == nil else { return }
                weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
                deleteDelegate?.sidebarbuttonactions(action: .Delete)
            case .addviewbuttons:
                // Delete
                weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
                deleteDelegate?.sidebarbuttonactions(action: .Delete)
            case .scheduleviewbuttons:
                weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllerSchedule
                deleteDelegate?.sidebarbuttonactions(action: .Weekly)
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
            case .addviewbuttons:
                return
            case .scheduleviewbuttons:
                weak var deleteDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllerSchedule
                deleteDelegate?.sidebarbuttonactions(action: .Update)
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

    @IBAction func Json(_: NSButton) {
        let text: String = NSLocalizedString("Convert files?", comment: "main")
        let dialog: String = NSLocalizedString("Convert", comment: "main")
        let question: String = NSLocalizedString("Convert PLIST files?", comment: "main")
        let answer = Alerts.dialogOrCancel(question: question, text: text, dialog: dialog)
        if answer {
            let configs = ReadConfigurationsPLIST(configurations?.getProfile())
            let schedules = ReadSchedulesPLIST(configurations?.getProfile())
            configs.writedatatojson()
            schedules.writedatatojson()
            NSApp.terminate(self)
        }
        jsonbutton.isHidden = true
        SharedReference.shared.convertjsonbutton = false
    }

    // Function for setting profile
    func displayProfile() {
        guard configurations?.tcpconnections?.connectionscheckcompleted ?? true else {
            profilelabel.stringValue = NSLocalizedString("Profile: please wait...", comment: "Execute")
            return
        }
        if let profile = configurations?.getProfile() {
            profilelabel.stringValue = NSLocalizedString("Profile:", comment: "Execute ") + " " + profile
            profilelabel.textColor = setcolor(nsviewcontroller: self, color: .white)
        } else {
            profilelabel.stringValue = NSLocalizedString("Profile:", comment: "Execute ") + " default"
            profilelabel.textColor = setcolor(nsviewcontroller: self, color: .green)
        }
    }

    func enableconvertjsonbutton() {
        if SharedReference.shared.convertjsonbutton {
            SharedReference.shared.convertjsonbutton = false
        } else {
            SharedReference.shared.convertjsonbutton = true
        }
        jsonbutton.title = "Convert"
        jsonbutton.isHidden = !SharedReference.shared.convertjsonbutton
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
        SharedReference.shared.setvcref(viewcontroller: .vcsidebar, nsviewcontroller: self)
        pathtorsyncosxschedbutton.toolTip = NSLocalizedString("The menu app", comment: "Execute")
        delayWithSeconds(0.5) {
            self.menuappicons()
            self.displayProfile()
        }
    }
}

extension ViewControllerSideBar: MenuappChanged {
    func menuappchanged() {
        menuappicons()
    }
}

extension ViewControllerSideBar: Sidebaractions {
    func sidebaractions(action: Sidebarmessages) {
        whichviewispresented = action
        switch action {
        case .enableconvertjsonbutton:
            enableconvertjsonbutton()
        case .mainviewbuttons:
            button1.isHidden = false
            button2.isHidden = false
            button3.isHidden = false
            button4.isHidden = false
            button1.title = NSLocalizedString("Change", comment: "Sidebar")
            button2.title = NSLocalizedString("Parameter", comment: "Sidebar")
            button3.title = NSLocalizedString("Delete", comment: "Sidebar")
            button4.title = NSLocalizedString("Command", comment: "Sidebar")
        case .addviewbuttons:
            button1.isHidden = false
            button2.isHidden = false
            button3.isHidden = false
            button4.isHidden = true
            button1.title = NSLocalizedString("Add", comment: "Sidebar")
            button2.title = NSLocalizedString("Assist", comment: "Sidebar")
            button3.title = NSLocalizedString("Delete", comment: "Sidebar")
        case .scheduleviewbuttons:
            button1.isHidden = false
            button2.isHidden = false
            button3.isHidden = false
            button4.isHidden = false
            button1.title = NSLocalizedString("Once", comment: "Sidebar")
            button2.title = NSLocalizedString("Daily", comment: "Sidebar")
            button3.title = NSLocalizedString("Weekly", comment: "Sidebar")
            button4.title = NSLocalizedString("Update", comment: "Sidebar")
        case .snapshotviewbuttons:
            button1.isHidden = true
            button2.isHidden = false
            button3.isHidden = false
            button4.isHidden = false
            button2.title = NSLocalizedString("Tag", comment: "Sidebar")
            button3.title = NSLocalizedString("Delete", comment: "Sidebar")
            button4.title = NSLocalizedString("Save", comment: "Sidebar")
        case .logsviewbuttons:
            button1.isHidden = true
            button2.isHidden = true
            button3.isHidden = false
            button4.isHidden = false
            button3.title = NSLocalizedString("Delete", comment: "Sidebar")
            button4.title = NSLocalizedString("Scan", comment: "Sidebar")
        case .sshviewbuttons:
            button1.isHidden = true
            button2.isHidden = true
            button3.isHidden = false
            button4.isHidden = false
            button3.title = NSLocalizedString("Create key", comment: "Sidebar")
            button4.title = NSLocalizedString("Remote", comment: "Sidebar")
        case .restoreviewbuttons:
            button1.isHidden = false
            button2.isHidden = false
            button3.isHidden = false
            button4.isHidden = false
            button1.title = NSLocalizedString("Filelist", comment: "Sidebar")
            button2.title = NSLocalizedString("Estimate", comment: "Sidebar")
            button3.title = NSLocalizedString("Restore", comment: "Sidebar")
            button4.title = NSLocalizedString("Reset", comment: "Sidebar")
        case .reset:
            button1.isHidden = true
            button2.isHidden = true
            button3.isHidden = true
            button4.isHidden = true
        case .JSONlabel:
            jsonlabel.isHidden = !SharedReference.shared.json
        }
    }
}
