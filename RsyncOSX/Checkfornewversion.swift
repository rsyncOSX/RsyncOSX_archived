//
//  newVersion.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 02/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

protocol newVersionDiscovered : class {
    func notifyNewVersion()
}

final class Checkfornewversion {

    private var runningVersion: String?
    private var urlPlist: String?
    private var urlNewVersion: String?

    // External resources
    private var resource: Resources?

    weak var newversionDelegate: newVersionDiscovered?

    //If new version set URL for download link and notify caller
    private func urlnewVersion (inMain: Bool) {
        globalBackgroundQueue.async(execute: { () -> Void in
            if let url = URL(string: self.urlPlist!) {
                do {
                    let contents = NSDictionary (contentsOf: url)
                    guard self.runningVersion != nil else {
                        return
                    }
                    if let url = contents?.object(forKey: self.runningVersion!) {
                        self.urlNewVersion = url as? String
                        // Setting reference to new vesrion if any
                        Configurations.shared.URLnewVersion = self.urlNewVersion
                        if inMain {
                            if let pvc = Configurations.shared.viewControllertabMain as? ViewControllertabMain {
                                self.newversionDelegate = pvc
                                if Configurations.shared.allowNotifyinMain == true {
                                    self.newversionDelegate?.notifyNewVersion()
                                }
                            }
                        } else {
                            if let pvc = Configurations.shared.viewControllerAbout as? ViewControllerAbout {
                                self.newversionDelegate = pvc
                                self.newversionDelegate?.notifyNewVersion()
                            }
                        }
                    }
                }
            }
        })
    }

    // Return version of RsyncOSX
    func rsyncOSXversion() -> String? {
        return self.runningVersion
    }

    init (inMain: Bool) {
        let infoPlist = Bundle.main.infoDictionary
        let version = infoPlist?["CFBundleShortVersionString"]
        if version != nil {
            self.runningVersion = version as? String
        }

        self.resource = Resources()
        if let resource = self.resource {
            self.urlPlist = resource.getResource(resource: .urlPlist)
        }
        self.urlnewVersion(inMain: inMain)
    }

}
