//
//  ViewControllerInformationLocalRemote.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.05.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

protocol SetLocalRemoteInfo: class {
    func setlocalremoteinfo(info: NSMutableDictionary?)
    func getlocalremoteinfo(index: Int) -> NSMutableDictionary?
}

class ViewControllerInformationLocalRemote: NSViewController, SetDismisser, GetIndex, SetConfigurations {

    private var index: Int?
    private var outputprocess: OutputProcess?
    private var complete: Bool = false
    private var numbers: NSMutableDictionary?
    weak var localremoteinfoDelegate: SetLocalRemoteInfo?
    @IBOutlet weak var transferredNumber: NSTextField!
    @IBOutlet weak var transferredNumberSizebytes: NSTextField!
    @IBOutlet weak var newfiles: NSTextField!
    @IBOutlet weak var deletefiles: NSTextField!
    @IBOutlet weak var totalNumber: NSTextField!
    @IBOutlet weak var totalDirs: NSTextField!
    @IBOutlet weak var totalNumberSizebytes: NSTextField!
    @IBOutlet weak var localtotalNumber: NSTextField!
    @IBOutlet weak var localtotalDirs: NSTextField!
    @IBOutlet weak var localtotalNumberSizebytes: NSTextField!
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var gotit: NSTextField!
    @IBOutlet weak var datelastbackup: NSTextField!
    @IBOutlet weak var dayslastbackup: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcinfolocalremote, nsviewcontroller: self)
        self.localremoteinfoDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.complete = false
        self.index = self.index(viewcontroller: .vctabmain)
        if let index = self.index {
            if let info = self.localremoteinfoDelegate?.getlocalremoteinfo(index: index) {
                self.setcachedNumbers(dict: info)
            } else {
                self.working.startAnimation(nil)
                let datelastbackup = self.configurations?.getConfigurations()[index].dateRun ?? "none"
                let numberlastbackup = self.configurations?.getConfigurations()[index].dayssincelastbackup ?? "none"
                self.datelastbackup.stringValue = "Date last backup: " + datelastbackup
                self.dayslastbackup.stringValue = "Days since last backup: " + numberlastbackup
                self.outputprocess = OutputProcess()
                _ = EstimateRemoteInformationTask(index: index, outputprocess: self.outputprocess, local: true)
            }
         }
    }

    @IBAction func close(_ sender: NSButton) {
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    // Function for getting numbers out of output object updated when
    // Process object executes the job.
    private func setNumbers(outputprocess: OutputProcess?, local: Bool) {
        globalMainQueue.async(execute: { () -> Void in
            let infotask = RemoteInfoTask(outputprocess: outputprocess)
            if local {
                self.numbers = NSMutableDictionary()
                self.localtotalNumber.stringValue = infotask.totalNumber!
                self.localtotalNumberSizebytes.stringValue = infotask.totalNumberSizebytes!
                self.localtotalDirs.stringValue = infotask.totalDirs!
                self.numbers?.setValue(self.index!, forKey: "index")
                self.numbers?.setValue(infotask.totalNumber!, forKey: "localtotalNumber")
                self.numbers?.setValue(infotask.totalNumberSizebytes!, forKey: "localtotalNumberSizebytes")
                self.numbers?.setValue(infotask.totalDirs!, forKey: "localtotalDirs")
            } else {
                self.transferredNumber.stringValue = infotask.transferredNumber!
                self.transferredNumberSizebytes.stringValue = infotask.transferredNumberSizebytes!
                self.totalNumber.stringValue = infotask.totalNumber!
                self.totalNumberSizebytes.stringValue = infotask.totalNumberSizebytes!
                self.totalDirs.stringValue = infotask.totalDirs!
                self.newfiles.stringValue = infotask.newfiles!
                self.deletefiles.stringValue = infotask.deletefiles!
                self.numbers?.setValue(infotask.transferredNumber!, forKey: "transferredNumber")
                self.numbers?.setValue(infotask.transferredNumberSizebytes!, forKey: "transferredNumberSizebytes")
                self.numbers?.setValue(infotask.totalNumber!, forKey: "totalNumber")
                self.numbers?.setValue(infotask.totalNumberSizebytes!, forKey: "totalNumberSizebytes")
                self.numbers?.setValue(infotask.totalDirs!, forKey: "totalDirs")
                self.numbers?.setValue(infotask.newfiles!, forKey: "newfiles")
                self.numbers?.setValue(infotask.deletefiles!, forKey: "deletefiles")
                self.localremoteinfoDelegate!.setlocalremoteinfo(info: self.numbers)
                self.working.stopAnimation(nil)
                self.gotit.stringValue = "Got it..."
            }
        })
    }

    private func setcachedNumbers(dict: NSMutableDictionary) {
        self.localtotalNumber.stringValue = (dict.value(forKey: "localtotalNumber") as? String) ?? ""
        self.localtotalNumberSizebytes.stringValue = (dict.value(forKey: "localtotalNumberSizebytes") as? String) ?? ""
        self.localtotalDirs.stringValue = (dict.value(forKey: "localtotalDirs") as? String) ?? ""
        self.transferredNumber.stringValue = (dict.value(forKey: "transferredNumber") as? String) ?? ""
        self.transferredNumberSizebytes.stringValue = (dict.value(forKey: "transferredNumberSizebytes") as? String) ?? ""
        self.totalNumber.stringValue = (dict.value(forKey: "totalNumber") as? String) ?? ""
        self.totalNumberSizebytes.stringValue = (dict.value(forKey: "totalNumberSizebytes") as? String) ?? ""
        self.totalDirs.stringValue = (dict.value(forKey: "totalDirs") as? String) ?? ""
        self.newfiles.stringValue = (dict.value(forKey: "newfiles") as? String) ?? ""
        self.deletefiles.stringValue = (dict.value(forKey: "deletefiles") as? String) ?? ""
        self.gotit.stringValue = "Loaded cached data..."
    }
}

extension ViewControllerInformationLocalRemote: UpdateProgress {
    func processTermination() {
        if self.complete == false {
            self.setNumbers(outputprocess: self.outputprocess, local: true)
        } else {
            self.setNumbers(outputprocess: self.outputprocess, local: false)
        }
        if let index = self.index {
            if self.complete == false {
                self.complete = true
                self.outputprocess = OutputProcess()
                _ = EstimateRemoteInformationTask(index: index, outputprocess: self.outputprocess, local: false)
            }
        }
    }

    func fileHandler() {
        //
    }
}
