//
//  ViewControllerProgressProcess.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Cocoa

// Protocol for progress indicator
protocol Count: class {
    func maxCount() -> Int
    func inprogressCount() -> Int
}

// Protocol for aborting task
protocol AbortOperations: class {
    func abortOperations()
}

protocol AbortTask {
    weak var abortDelegate: AbortOperations? { get }
    func abort()
}

extension AbortTask {
    weak var abortDelegate: AbortOperations? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }

    func abort() {
        self.abortDelegate?.abortOperations()
    }
}

class ViewControllerProgressProcess: NSViewController, SetConfigurations, SetDismisser, AbortTask {

    var count: Double = 0
    var maxcount: Double = 0
    var calculatedNumberOfFiles: Int?
    weak var countDelegate: Count?

    @IBOutlet weak var progress: NSProgressIndicator!

    @IBAction func abort(_ sender: NSButton) {
        self.abort()
        self.processTermination()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcprogressview, nsviewcontroller: self)
        if let pvc2 = self.configurations!.singleTask {
            self.countDelegate = pvc2
        }
        self.calculatedNumberOfFiles = self.countDelegate?.maxCount()
        self.initiateProgressbar()
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
        self.dismiss_view(viewcontroller: self)
    }

    func fileHandler() {
        guard self.countDelegate != nil else { return }
        self.updateProgressbar(Double(self.countDelegate!.inprogressCount()))
    }

}
