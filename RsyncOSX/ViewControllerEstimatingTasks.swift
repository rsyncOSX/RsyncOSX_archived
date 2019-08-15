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

class ViewControllerEstimatingTasks: NSViewController, Abort, SetConfigurations {

    var count: Double = 0
    var maxcount: Double = 0
    var calculatedNumberOfFiles: Int?
    var vc: ViewControllertabMain?
    weak var countDelegate: CountEstimating?
    weak var dismissDelegate: DismissViewEstimating?
    var diddissappear: Bool = false

    @IBOutlet weak var abort: NSButton!
    @IBOutlet weak var progress: NSProgressIndicator!

    @IBAction func abort(_ sender: NSButton) {
        self.abort()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard self.diddissappear == false else { return }
        self.configurations?.remoteinfoestimation = RemoteinfoEstimation()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcestimatingtasks, nsviewcontroller: self)
        self.vc = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.dismissDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        if let pvc = self.vc?.configurations?.remoteinfoestimation {
            self.countDelegate = pvc
        }
        self.calculatedNumberOfFiles = self.countDelegate?.maxCount()
        self.initiateProgressbar()
        self.abort.isEnabled = true
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.diddissappear = true
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
        self.progress.stopAnimation(self)
        self.dismissDelegate?.dismissestimating(viewcontroller: self)
    }

    func updateProgressbar() {
        let count = self.countDelegate?.inprogressCount() ?? 0
        self.progress.doubleValue = Double(self.calculatedNumberOfFiles! - count)
        // When estimating is completed dismiss view
        if self.configurations!.remoteinfoestimation!.stackoftasktobeestimated == nil {
            // self.configurations!.remoteinfoestimation?.selectalltaskswithnumbers(deselect: false)
            self.configurations!.remoteinfoestimation?.setbackuplist()
            weak var openDelegate: OpenQuickBackup?
            switch ViewControllerReference.shared.activetab ?? .vctabmain {
            case .vcnewconfigurations:
                openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
            case .vctabmain:
                openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
            case .vctabschedule:
                openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabschedule) as? ViewControllertabSchedule
            case .vccopyfiles:
                openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vccopyfiles) as? ViewControllerCopyFiles
            case .vcsnapshot:
                openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
            case .vcverify:
                openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcverify) as? ViewControllerVerify
            case .vcssh:
                openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcssh) as? ViewControllerSsh
            case .vcloggdata:
                openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
            default:
                openDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
            }
            openDelegate?.openquickbackup()
        }
        self.dismissview()
    }
}
