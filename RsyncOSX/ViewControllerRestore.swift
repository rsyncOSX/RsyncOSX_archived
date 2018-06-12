//
//  ViewControllerEdit.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerRestore: NSViewController, SetConfigurations, SetDismisser, GetIndex, AbortTask {

    @IBOutlet weak var localCatalog: NSTextField!
    @IBOutlet weak var offsiteCatalog: NSTextField!
    @IBOutlet weak var offsiteUsername: NSTextField!
    @IBOutlet weak var offsiteServer: NSTextField!
    @IBOutlet weak var backupID: NSTextField!
    @IBOutlet weak var sshport: NSTextField!
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var gotit: NSTextField!

    @IBOutlet weak var transferredNumber: NSTextField!
    @IBOutlet weak var transferredNumberSizebytes: NSTextField!
    @IBOutlet weak var newfiles: NSTextField!
    @IBOutlet weak var deletefiles: NSTextField!
    @IBOutlet weak var totalNumber: NSTextField!
    @IBOutlet weak var totalDirs: NSTextField!
    @IBOutlet weak var totalNumberSizebytes: NSTextField!
    @IBOutlet weak var restoreprogress: NSProgressIndicator!
    @IBOutlet weak var restorebutton: NSButton!

    var outputprocess: OutputProcess?
    var estimation: Bool?
    var completed: Bool?

    // Close and dismiss view
    @IBAction func close(_ sender: NSButton) {
        if self.completed == false {
            self.abort()
        }
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    @IBAction func restore(_ sender: NSButton) {
        let answer = Alerts.dialogOKCancel("Do you REALLY want to start a RESTORE ?", text: "Cancel or OK")
        if answer {
            if let index = self.index(viewcontroller: .vctabmain) {
                self.initiateProgressbar()
                self.outputprocess = OutputProcess()
                _ = RestoreTask(index: index, outputprocess: self.outputprocess, dryrun: false)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcrestore, nsviewcontroller: self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.estimation = true
        self.completed = false
        self.restorebutton.isEnabled = false
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.offsiteUsername.stringValue = ""
        self.offsiteServer.stringValue = ""
        self.backupID.stringValue = ""
        self.sshport.stringValue = ""
        if let index = self.index(viewcontroller: .vctabmain) {
            let config: Configuration = self.configurations!.getConfigurations()[index]
            self.localCatalog.stringValue = config.localCatalog
            self.offsiteCatalog.stringValue = config.offsiteCatalog
            self.offsiteUsername.stringValue = config.offsiteUsername
            self.offsiteServer.stringValue = config.offsiteServer
            self.backupID.stringValue = config.backupID
            if let port = config.sshport {
                self.sshport.stringValue = String(port)
            }
            self.working.startAnimation(nil)
            self.outputprocess = OutputProcess()
            _ = RestoreTask(index: index, outputprocess: self.outputprocess, dryrun: true)
        }
    }

    private func setNumbers(outputprocess: OutputProcess?) {
        globalMainQueue.async(execute: { () -> Void in
            let infotask = RemoteInfoTask(outputprocess: outputprocess)
            self.transferredNumber.stringValue = infotask.transferredNumber!
            self.transferredNumberSizebytes.stringValue = infotask.transferredNumberSizebytes!
            self.totalNumber.stringValue = infotask.totalNumber!
            self.totalNumberSizebytes.stringValue = infotask.totalNumberSizebytes!
            self.totalDirs.stringValue = infotask.totalDirs!
            self.newfiles.stringValue = infotask.newfiles!
            self.deletefiles.stringValue = infotask.deletefiles!
            self.working.stopAnimation(nil)
            self.restorebutton.isEnabled = true
            self.gotit.stringValue = "Got it..."
        })
    }

    // Progressbar restore
    private func initiateProgressbar() {
        if let calculatedNumberOfFiles = self.outputprocess?.getMaxcount() {
            self.restoreprogress.maxValue = Double(calculatedNumberOfFiles)
        }
        self.restoreprogress.minValue = 0
        self.restoreprogress.doubleValue = 0
        self.restoreprogress.startAnimation(self)
    }

    private func updateProgressbar(_ value: Double) {
        self.restoreprogress.doubleValue = value
    }

}

extension ViewControllerRestore: UpdateProgress {
    func processTermination() {
        if estimation == true {
            self.estimation = false
            self.setNumbers(outputprocess: self.outputprocess)
        } else {
            self.restorebutton.isEnabled = false
        }
        self.completed = true
    }

    func fileHandler() {
        if self.estimation == false {
            self.updateProgressbar(Double(self.outputprocess!.count()))
        }
    }
}
