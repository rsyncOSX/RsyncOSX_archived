//
//  ViewControllerUserconfiguration.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 30/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

//swiftlint:disable syntactic_sugar file_length cyclomatic_complexity line_length

import Foundation
import Cocoa

// Protocol for doing updates when optional path for rsync is changed
// or user enable or disable doubleclick to execte
protocol RsyncChanged : class {
    func rsyncchanged()
    func displayAllowDoubleclick()
}

class ViewControllerUserconfiguration: NSViewController {

    var dirty: Bool = false
    // Delegate to read configurations after toggeling between
    // test- and real mode
    weak var rsyncchangedDelegate: RsyncChanged?
    // Dismisser
    weak var dismissDelegate: DismissViewController?

    @IBOutlet weak var rsyncPath: NSTextField!
    @IBOutlet weak var version3rsync: NSButton!
    @IBOutlet weak var detailedlogging: NSButton!
    @IBOutlet weak var allowDoubleClick: NSButton!
    @IBOutlet weak var noRsync: NSTextField!
    @IBOutlet weak var rsyncerror: NSButton!
    @IBOutlet weak var restorePath: NSTextField!

    @IBAction func toggleversion3rsync(_ sender: NSButton) {
        if self.version3rsync.state == .on {
            Configurations.shared.rsyncVer3 = true
        } else {
            Configurations.shared.rsyncVer3 = false
        }
        if let pvc = self.presenting as? ViewControllertabMain {
            self.rsyncchangedDelegate = pvc
            self.rsyncchangedDelegate?.rsyncchanged()
        }
        self.dirty = true
        self.verifyRsync()
    }

    @IBAction func toggleDetailedlogging(_ sender: NSButton) {
        if self.detailedlogging.state == .on {
            Configurations.shared.detailedlogging = true
        } else {
            Configurations.shared.detailedlogging = false
        }
        self.dirty = true
    }

    @IBAction func close(_ sender: NSButton) {
        if self.dirty {
            // Before closing save changed configuration
            self.setRsyncPath()
            self.verifyRsync()
            self.setRestorePath()
            _ = PersistentStoreAPI.sharedInstance.saveUserconfiguration()
        }
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

    @IBAction func toggleAllowDoubleclick(_ sender: NSButton) {
        if self.allowDoubleClick.state == .on {
            Configurations.shared.allowDoubleclick = true
        } else {
            Configurations.shared.allowDoubleclick = false
        }
        if let pvc = self.presenting as? ViewControllertabMain {
            self.rsyncchangedDelegate = pvc
            self.rsyncchangedDelegate?.displayAllowDoubleclick()
        }
        self.dirty = true

    }

    @IBAction func toggleError(_ sender: NSButton) {
        if self.rsyncerror.state == .on {
            Configurations.shared.rsyncerror = true
        } else {
            Configurations.shared.rsyncerror = false
        }
        self.dirty = true
    }

    private func setRsyncPath() {
        if self.rsyncPath.stringValue.isEmpty == false {
            if rsyncPath.stringValue.hasSuffix("/") == false {
                rsyncPath.stringValue += "/"
                Configurations.shared.rsyncPath = rsyncPath.stringValue
            }
        } else {
            Configurations.shared.rsyncPath = nil
        }
        self.dirty = true
    }

    private func setRestorePath() {
        if self.restorePath.stringValue.isEmpty == false {
            if restorePath.stringValue.hasSuffix("/") == false {
                restorePath.stringValue += "/"
                Configurations.shared.restorePath = restorePath.stringValue
            }
        } else {
            Configurations.shared.restorePath = nil
        }
        self.dirty = true
    }

    // Function verifying rsync in path
    private func verifyRsync() {
        if self.version3rsync.state == .on {
            let fileManager = FileManager.default
            if let rsyncPath = Configurations.shared.rsyncPath {
                let path = rsyncPath + "rsync"
                if fileManager.fileExists(atPath: path) == false {
                    self.noRsync.isHidden = false
                    Configurations.shared.noRysync = true
                } else {
                    Configurations.shared.noRysync = false
                    self.noRsync.isHidden = true
                }
            } else {
                let path = "/usr/local/bin/rsync"
                if fileManager.fileExists(atPath: path) == false {
                    self.noRsync.isHidden = false
                    Configurations.shared.noRysync = true
                } else {
                    Configurations.shared.noRysync = false
                    self.noRsync.isHidden = true
                }
            }
        } else {
            Configurations.shared.noRysync = false
            self.noRsync.isHidden = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Dismisser is root controller
        if let pvc2 = self.presenting as? ViewControllertabMain {
            self.dismissDelegate = pvc2
        } else if let pvc2 = self.presenting as? ViewControllertabSchedule {
            self.dismissDelegate = pvc2
        } else if let pvc2 = self.presenting as? ViewControllerNewConfigurations {
            self.dismissDelegate = pvc2
        }
        self.rsyncPath.delegate = self
        self.restorePath.delegate = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.dirty = false
        // Set userconfig
        self.checkUserConfig()
        // Check path for rsync
        self.verifyRsync()
    }

    // Function for check and set user configuration
    private func checkUserConfig() {
        if Configurations.shared.rsyncVer3 {
            self.version3rsync.state = .on
        } else {
            self.version3rsync.state = .off
        }
        if Configurations.shared.detailedlogging {
            self.detailedlogging.state = .on
        } else {
            self.detailedlogging.state = .off
        }
        if Configurations.shared.rsyncPath != nil {
            self.rsyncPath.stringValue = Configurations.shared.rsyncPath!
        } else {
            self.rsyncPath.stringValue = ""
        }
        if Configurations.shared.allowDoubleclick {
            self.allowDoubleClick.state = .on
        } else {
            self.allowDoubleClick.state = .off
        }
        if Configurations.shared.rsyncerror {
            self.rsyncerror.state = .on
        } else {
            self.rsyncerror.state = .off
        }
        if Configurations.shared.restorePath != nil {
            self.restorePath.stringValue = Configurations.shared.restorePath!
        } else {
            self.restorePath.stringValue = ""
        }
    }

}

extension ViewControllerUserconfiguration : NSTextFieldDelegate {

    override func controlTextDidChange(_ obj: Notification) {
        self.version3rsync.state = .on
        self.dirty = true
    }

}
