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
    case verifyjson
    case mainviewbuttons
    case addviewbuttons
    case scheduleviewbuttons
    case snapshotviewbuttons
    case logsviewbuttons
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
}

protocol Sidebaractions: AnyObject {
    func sidebaractions(action: Sidebarmessages)
}

protocol Sidebarbuttonactions: AnyObject {
    func sidebarbuttonactions(action: Sidebaractionsmessages)
}

class ViewControllerSideBar: NSViewController, SetConfigurations, Delay, VcMain {
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
                return
            case .scheduleviewbuttons:
                return
            case .snapshotviewbuttons:
                return
            case .logsviewbuttons:
                return
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
                return
            case .snapshotviewbuttons:
                return
            case .logsviewbuttons:
                return
            default:
                return
            }
        }
    }

    @IBAction func actionbutton3(_: NSButton) {
        if let view = self.whichviewispresented {
            switch view {
            case .mainviewbuttons:
                return
            case .addviewbuttons:
                return
            case .scheduleviewbuttons:
                return
            case .snapshotviewbuttons:
                return
            case .logsviewbuttons:
                return
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
                return
            case .snapshotviewbuttons:
                return
            case .logsviewbuttons:
                return
            default:
                return
            }
        }
    }

    func verifyjson() {
        self.verify()
    }

    func verify() {
        let verify: VerifyJSON?
        if let profile = self.configurations?.getProfile() {
            verify = VerifyJSON(profile: profile)
        } else {
            verify = VerifyJSON(profile: nil)
        }
        if verify?.verifyconf ?? false, verify?.verifysched ?? false == true {
            // self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
            // self.info.stringValue = NSLocalizedString("Verify OK...", comment: "Verify")
        } else {
            // self.info.textColor = setcolor(nsviewcontroller: self, color: .red)
            // self.info.stringValue = NSLocalizedString("Verify not OK, see logfile (⌘O)...", comment: "Verify")
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
            self.button2.isHidden = true
            self.button3.isHidden = false
            self.button4.isHidden = false
            self.button3.title = NSLocalizedString("Delete", comment: "Sidebar")
            self.button4.title = NSLocalizedString("Save", comment: "Sidebar")
        case .logsviewbuttons:
            self.button1.isHidden = true
            self.button2.isHidden = true
            self.button3.isHidden = false
            self.button4.isHidden = true
            self.button3.title = NSLocalizedString("Delete", comment: "Sidebar")
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

/*
 // Function for getting numbers out of output object updated when
 // Process object executes the job.
 func setNumbers(outputprocess: OutputProcess?) {
     globalMainQueue.async { () -> Void in
         guard outputprocess != nil else {
             self.transferredNumber.stringValue = ""
             self.transferredNumberSizebytes.stringValue = ""
             self.totalNumber.stringValue = ""
             self.totalNumberSizebytes.stringValue = ""
             self.totalDirs.stringValue = ""
             self.newfiles.stringValue = ""
             self.deletefiles.stringValue = ""
             return
         }
         let remoteinfotask = RemoteinfonumbersOnetask(outputprocess: outputprocess)
         self.transferredNumber.stringValue = remoteinfotask.transferredNumber!
         self.transferredNumberSizebytes.stringValue = remoteinfotask.transferredNumberSizebytes!
         self.totalNumber.stringValue = remoteinfotask.totalNumber!
         self.totalNumberSizebytes.stringValue = remoteinfotask.totalNumberSizebytes!
         self.totalDirs.stringValue = remoteinfotask.totalDirs!
         self.newfiles.stringValue = remoteinfotask.newfiles!
         self.deletefiles.stringValue = remoteinfotask.deletefiles!
     }
 }

 */
