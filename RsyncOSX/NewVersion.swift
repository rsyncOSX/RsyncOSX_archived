//
//  newVersion.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 02/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

protocol newVersionDiscovered : class {
    func notifyNewVersion()
}

final class NewVersion {

    private var runningVersion: String?
    private var urlPlist: String?
    private var urlNewVersion: String?

    // External resources
    private var resource: Resources?

    weak var newversionDelegate: newVersionDiscovered?

    private func setURLnewVersion () {
        globalBackgroundQueue.async(execute: { () -> Void in
            if let url = URL(string: self.urlPlist!) {
                do {
                    let contents = NSDictionary (contentsOf: url)
                    guard self.runningVersion != nil else {
                        return
                    }
                    if let url = contents?.object(forKey: self.runningVersion!) {
                        self.urlNewVersion = url as? String
                        SharingManagerConfiguration.sharedInstance.URLnewVersion = self.urlNewVersion
                        if let pvc = SharingManagerConfiguration.sharedInstance.viewControllertabMain as? ViewControllertabMain {
                            self.newversionDelegate = pvc
                            if SharingManagerConfiguration.sharedInstance.allowNotifyinMain == true {
                                self.newversionDelegate?.notifyNewVersion()
                            }
                        }
                    }
                }
            }
        })
    }

    init () {
        let infoPlist = Bundle.main.infoDictionary
        let version = infoPlist?["CFBundleShortVersionString"]
        if version != nil {
            self.runningVersion = version as? String
        }

        self.resource = Resources()
        if let resource = self.resource {
            self.urlPlist = resource.getResource(resource: .urlPlist)
        }
        self.setURLnewVersion()
    }

}
