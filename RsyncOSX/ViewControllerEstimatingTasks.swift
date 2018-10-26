//
//  ViewControllerEstimatingTasks.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.04.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

// Protocol for progress indicator
protocol CountEstimating: class {
    func maxCount() -> Int
    func inprogressCount() -> Int
}

protocol Updateestimating: class {
    func updateProgressbar()
    func dismissview()
}

protocol DismissViewEstimating: class {
    func dismissestimating(viewcontroller: NSViewController)
}

class ViewControllerEstimatingTasks: NSViewController, AbortTask {

    var count: Double = 0
    var maxcount: Double = 0
    var calculatedNumberOfFiles: Int?
    var vc: ViewControllertabMain?
    weak var countDelegate: CountEstimating?
    weak var dismissDelegate: DismissViewEstimating?

    @IBOutlet weak var abort: NSButton!
    @IBOutlet weak var progress: NSProgressIndicator!

    @IBAction func abort(_ sender: NSButton) {
        self.abort()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcestimatingtasks, nsviewcontroller: self)
        self.vc = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.dismissDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        if let pvc = self.vc?.configurations!.remoteinfotaskworkqueue {
            self.countDelegate = pvc
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
}

extension ViewControllerEstimatingTasks: Updateestimating {
    func dismissview() {
        self.stopProgressbar()
        self.dismissDelegate?.dismissestimating(viewcontroller: self)
    }

    func updateProgressbar() {
        self.progress.doubleValue = Double(self.calculatedNumberOfFiles! - self.countDelegate!.inprogressCount())
    }
}
