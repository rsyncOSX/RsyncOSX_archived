//
//  ViewControllerProgressProcess.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

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
        switch countDelegate {
        case is ViewControllerSnapshots:
            dismissview(viewcontroller: self, vcontroller: .vcsnapshot)
        case is ViewControllerRestore:
            dismissview(viewcontroller: self, vcontroller: .vcrestore)
        default:
            dismissview(viewcontroller: self, vcontroller: .vctabmain)
        }
        abort()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        SharedReference.shared.setvcref(viewcontroller: .vcprogressview, nsviewcontroller: self)
        if (presentingViewController as? ViewControllerMain) != nil {
            if let pvc = (presentingViewController as? ViewControllerMain)?.singletask {
                countDelegate = pvc
            }
        } else if (presentingViewController as? ViewControllerRestore) != nil {
            countDelegate = SharedReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
        } else if (presentingViewController as? ViewControllerSnapshots) != nil {
            countDelegate = SharedReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        }
        initiateProgressbar()
        abort.isEnabled = true
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        stopProgressbar()
        SharedReference.shared.setvcref(viewcontroller: .vcprogressview, nsviewcontroller: nil)
    }

    private func stopProgressbar() {
        progress.stopAnimation(self)
    }

    // Progress bars
    private func initiateProgressbar() {
        if (presentingViewController as? ViewControllerSnapshots) != nil {
            progress.maxValue = Double(countDelegate?.maxCount() ?? 0)
        } else {
            progress.maxValue = Double((countDelegate?.maxCount() ?? 0) + SharedReference.shared.extralines)
        }
        progress.minValue = 0
        progress.doubleValue = 0
        progress.startAnimation(self)
    }

    private func updateProgressbar(_ value: Double) {
        progress.doubleValue = value
    }
}

extension ViewControllerProgressProcess: UpdateProgress {
    func processTermination() {
        stopProgressbar()
        switch countDelegate {
        case is ViewControllerMain:
            dismissview(viewcontroller: self, vcontroller: .vctabmain)
        case is ViewControllerSnapshots:
            dismissview(viewcontroller: self, vcontroller: .vcsnapshot)
        case is ViewControllerRestore:
            dismissview(viewcontroller: self, vcontroller: .vcrestore)
        default:
            dismissview(viewcontroller: self, vcontroller: .vctabmain)
        }
    }

    func fileHandler() {
        updateProgressbar(Double(countDelegate?.inprogressCount() ?? 0))
    }
}
