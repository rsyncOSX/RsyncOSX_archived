//
//  ViewControllerInformationLocalRemote.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.05.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerInformationLocalRemote: NSViewController, SetDismisser, GetIndex {

    private var index: Int?
    private var outputprocess: OutputProcess?
    private var complete: Bool = false
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

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcinfolocalremote, nsviewcontroller: self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.working.startAnimation(nil)
        self.complete = false
        self.index = self.index(viewcontroller: .vctabmain)
         if let index = self.index {
            self.outputprocess = OutputProcess()
            _ = EstimateRemoteInformationTask(index: index, outputprocess: self.outputprocess, local: true)
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
                self.localtotalNumber.stringValue = infotask.totalNumber!
                self.localtotalNumberSizebytes.stringValue = infotask.totalNumberSizebytes!
                self.localtotalDirs.stringValue = infotask.totalDirs!
            } else {
                self.transferredNumber.stringValue = infotask.transferredNumber!
                self.transferredNumberSizebytes.stringValue = infotask.transferredNumberSizebytes!
                self.totalNumber.stringValue = infotask.totalNumber!
                self.totalNumberSizebytes.stringValue = infotask.totalNumberSizebytes!
                self.totalDirs.stringValue = infotask.totalDirs!
                self.newfiles.stringValue = infotask.newfiles!
                self.deletefiles.stringValue = infotask.deletefiles!
                self.working.stopAnimation(nil)
            }
        })
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
