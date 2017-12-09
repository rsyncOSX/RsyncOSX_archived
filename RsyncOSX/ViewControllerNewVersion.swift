//
//  ViewControllerNewVersion.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 02/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation
import Cocoa

class ViewControllerNewVersion: NSViewController, SetDismisser {

    private var resource: Resources?
    var waitToClose: Timer?
    var closeIn: Timer?
    var seconds: Int?

    @IBOutlet weak var reminder: NSButton!
    @IBOutlet weak var closeinseconds: NSTextField!

    @IBAction func changelogg(_ sender: NSButton) {
        if let resource = self.resource {
            NSWorkspace.shared.open(URL(string: resource.getResource(resource: .changelog))!)
        }
    }

    @IBAction func download(_ sender: NSButton) {
        guard ViewControllerReference.shared.URLnewVersion != nil else {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
            return
        }
        NSWorkspace.shared.open(URL(string: ViewControllerReference.shared.URLnewVersion!)!)
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    @objc private func setSecondsView() {
        self.seconds = self.seconds! - 1
        self.closeinseconds.stringValue = "Close automatically in: " + String(self.seconds!) + " seconds"
    }

    @objc private func closeView() {
        self.waitToClose?.invalidate()
        self.closeIn?.invalidate()
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)    }

    @IBAction func dismiss(_ sender: NSButton) {
        self.waitToClose?.invalidate()
        self.closeIn?.invalidate()
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.resource = Resources()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.seconds = 5
        self.waitToClose = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(closeView), userInfo: nil, repeats: false)
        self.closeIn = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setSecondsView), userInfo: nil, repeats: true)
        self.closeinseconds.stringValue = "Close automatically in: 5 seconds"
    }

}
