//
//  ViewControllerEstimatingTasks.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.04.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

// Protocol for progress indicator
protocol CountRemoteEstimatingNumberoftasks: AnyObject {
    func maxCount() -> Int
    func inprogressCount() -> Int
}

class ViewControllerEstimatingTasks: NSViewController, Abort, SetConfigurations, SetDismisser {
    weak var countDelegate: CountRemoteEstimatingNumberoftasks?
    private var remoteinfotask: RemoteinfoEstimation?
    var diddissappear: Bool = false

    @IBOutlet var abort: NSButton!
    @IBOutlet var progress: NSProgressIndicator!

    @IBAction func abort(_: NSButton) {
        remoteinfotask?.abort()
        abort()
        remoteinfotask = nil
        closeview()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        SharedReference.shared.setvcref(viewcontroller: .vcestimatingtasks, nsviewcontroller: self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard diddissappear == false else { return }
        abort.isEnabled = true
        remoteinfotask = RemoteinfoEstimation(viewcontroller: self, processtermination: processtermination)
        initiateProgressbar()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        diddissappear = true
        // Release the estimating object
        remoteinfotask?.abort()
        remoteinfotask = nil
    }

    // Progress bars
    private func initiateProgressbar() {
        progress.maxValue = Double(remoteinfotask?.maxCount() ?? 0)
        progress.minValue = 0
        progress.doubleValue = 0
        progress.startAnimation(self)
    }

    private func updateProgressbar(_ value: Double) {
        progress.doubleValue = value
    }

    private func closeview() {
        if (presentingViewController as? ViewControllerMain) != nil {
            dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else if (presentingViewController as? ViewControllerNewConfigurations) != nil {
            dismissview(viewcontroller: self, vcontroller: .vcnewconfigurations)
        } else if (presentingViewController as? ViewControllerRestore) != nil {
            dismissview(viewcontroller: self, vcontroller: .vcrestore)
        } else if (presentingViewController as? ViewControllerSnapshots) != nil {
            dismissview(viewcontroller: self, vcontroller: .vcsnapshot)
        } else if (presentingViewController as? ViewControllerSsh) != nil {
            dismissview(viewcontroller: self, vcontroller: .vcssh)
        } else if (presentingViewController as? ViewControllerLoggData) != nil {
            dismissview(viewcontroller: self, vcontroller: .vcloggdata)
        }
    }
}

extension ViewControllerEstimatingTasks {
    func processtermination() {
        let progress = Double(remoteinfotask?.maxCount() ?? 0) - Double(remoteinfotask?.inprogressCount() ?? 0)
        updateProgressbar(progress)
    }
}

extension ViewControllerEstimatingTasks: StartStopProgressIndicator {
    func start() {
        //
    }

    func stop() {
        weak var openDelegate: OpenQuickBackup?
        if (presentingViewController as? ViewControllerMain) != nil {
            openDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        } else if (presentingViewController as? ViewControllerRestore) != nil {
            openDelegate = SharedReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
        } else if (presentingViewController as? ViewControllerLoggData) != nil {
            openDelegate = SharedReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
        } else if (presentingViewController as? ViewControllerSnapshots) != nil {
            openDelegate = SharedReference.shared.getvcref(viewcontroller: .vcsnapshot) as? ViewControllerSnapshots
        }
        closeview()
        openDelegate?.openquickbackup()
    }
}
