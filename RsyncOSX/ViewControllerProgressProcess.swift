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
protocol Count: AnyObject {
    func maxCount() -> Int
    func inprogressCount() -> Int
}

class ViewControllerProgressProcess: NSViewController, SetConfigurations, SetDismisser, Abort {
    var count: Double = 0
    var maxcount: Double = 0
    weak var countDelegate: Count?
    @IBOutlet var abort: NSButton!
    @IBOutlet var progress: NSProgressIndicator!

    @IBAction func abort(_: NSButton) {
        switch self.countDelegate {
        case is ViewControllerSnapshots:
            self.dismissview(viewcontroller: self, vcontroller: .vcsnapshot)
        case is ViewControllerRestore:
            self.dismissview(viewcontroller: self, vcontroller: .vcrestore)
        default:
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        }
        self.abort()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcprogressview, nsviewcontroller: self)
        if (self.presentingViewController as? ViewControllerMain) != nil {
            if let pvc = (self.presentingViewController as? ViewControllerMain)?.singletask {
                self.countDelegate = pvc
            }
        } else if (self.presentingViewController as? ViewControllerRestore) != nil {
            self.countDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
        } else if (self.presentingViewController as? ViewControllerSnapshots) != nil {
            self.countDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        }
        self.initiateProgressbar()
        self.abort.isEnabled = true
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.stopProgressbar()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcprogressview, nsviewcontroller: nil)
    }

    private func stopProgressbar() {
        self.progress.stopAnimation(self)
    }

    // Progress bars
    private func initiateProgressbar() {
        if (self.presentingViewController as? ViewControllerSnapshots) != nil {
            self.progress.maxValue = Double(self.countDelegate?.maxCount() ?? 0)
        } else {
            self.progress.maxValue = Double((self.countDelegate?.maxCount() ?? 0) + ViewControllerReference.shared.extralines)
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
        switch self.countDelegate {
        case is ViewControllerMain:
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        case is ViewControllerSnapshots:
            self.dismissview(viewcontroller: self, vcontroller: .vcsnapshot)
        case is ViewControllerRestore:
            self.dismissview(viewcontroller: self, vcontroller: .vcrestore)
        default:
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        }
    }

    func fileHandler() {
        self.updateProgressbar(Double(self.countDelegate?.inprogressCount() ?? 0))
    }
}
