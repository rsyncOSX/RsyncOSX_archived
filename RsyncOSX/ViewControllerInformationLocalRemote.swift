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

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcinfolocalremote, nsviewcontroller: self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
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
    private func setNumbers(outputprocess: OutputProcess?) {
        globalMainQueue.async(execute: { () -> Void in
            guard outputprocess != nil else {
                /*
                self.transferredNumber.stringValue = ""
                self.transferredNumberSizebytes.stringValue = ""
                self.totalNumber.stringValue = ""
                self.totalNumberSizebytes.stringValue = ""
                self.totalDirs.stringValue = ""
                self.newfiles.stringValue = ""
                self.deletefiles.stringValue = ""
                */
                return
            }
            let infotask = RemoteInfoTask(outputprocess: outputprocess)
            /*
            self.transferredNumber.stringValue = remoteinfotask.transferredNumber!
            self.transferredNumberSizebytes.stringValue = remoteinfotask.transferredNumberSizebytes!
            self.totalNumber.stringValue = remoteinfotask.totalNumber!
            self.totalNumberSizebytes.stringValue = remoteinfotask.totalNumberSizebytes!
            self.totalDirs.stringValue = remoteinfotask.totalDirs!
            self.newfiles.stringValue = remoteinfotask.newfiles!
            self.deletefiles.stringValue = remoteinfotask.deletefiles!
            */
        })
    }
}

extension ViewControllerInformationLocalRemote: UpdateProgress {
    func processTermination() {
        self.setNumbers(outputprocess: self.outputprocess)
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
