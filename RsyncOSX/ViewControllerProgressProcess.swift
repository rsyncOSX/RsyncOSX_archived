//
//  ViewControllerProgressProcess.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa

// Protocol for progress indicator
protocol Count: class {
    func maxCount() -> Int
    func inprogressCount() -> Int
}

class ViewControllerProgressProcess: NSViewController, SetConfigurations, SetDismisser, Abort {

    var count: Double = 0
    var maxcount: Double = 0
    var calculatedNumberOfFiles: Int?
    weak var countDelegate: Count?
    var inmain: Bool = true
    @IBOutlet weak var abort: NSButton!
    @IBOutlet weak var progress: NSProgressIndicator!

    @IBAction func abort(_ sender: NSButton) {
        self.abort()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcprogressview, nsviewcontroller: self)
        if let pvc = self.configurations!.singleTask {
            self.countDelegate = pvc
        } else {
            self.countDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
            self.inmain = false
        }
        self.calculatedNumberOfFiles = self.countDelegate?.maxCount()
        self.initiateProgressbar()
        self.abort.isEnabled = true
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.stopProgressbar()
    }

    private func stopProgressbar() {
        self.progress.stopAnimation(self)
    }

    // Progress bars
    private func initiateProgressbar() {
        if let calculatedNumberOfFiles = self.calculatedNumberOfFiles {
            self.progress.maxValue = Double(calculatedNumberOfFiles)
        }
        self.progress.minValue = 0
        self.progress.doubleValue = 0
        self.progress.startAnimation(self)
    }

    private func updateProgressbar(_ value: Double) {
        self.progress.doubleValue = value
    }

}

extension ViewControllerProgressProcess: UpdateProgress {

    func processTermination() {
        self.stopProgressbar()
        if inmain {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else {
             self.dismissview(viewcontroller: self, vcontroller: .vcsnapshot)
        }
    }

    func fileHandler() {
        guard self.countDelegate != nil else { return }
        self.updateProgressbar(Double(self.countDelegate!.inprogressCount()))
    }
}
