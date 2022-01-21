//
//  newVersion.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 02/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

protocol NewVersionDiscovered: AnyObject {
    func notifyNewVersion()
}

final class Checkfornewversion {
    private var runningVersion: String?
    private var urlPlist: String?
    private var urlNewVersion: String?

    weak var newversionDelegateMain: NewVersionDiscovered?

    // If new version set URL for download link and notify caller
    private func urlnewVersion() {
        globalBackgroundQueue.async { () in
            if let url = URL(string: self.urlPlist ?? "") {
                do {
                    let contents = NSDictionary(contentsOf: url)
                    if let url = contents?.object(forKey: self.runningVersion ?? "") {
                        self.urlNewVersion = url as? String
                        // Setting reference to new version if any
                        SharedReference.shared.URLnewVersion = self.urlNewVersion
                        self.newversionDelegateMain = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
                        self.newversionDelegateMain?.notifyNewVersion()
                        SharedReference.shared.newversionofrsyncosx = true
                    }
                }
            }
        }
    }

    // Return version of RsyncOSX
    func rsyncOSXversion() -> String? {
        return runningVersion
    }

    @discardableResult
    init() {
        runningVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let resource = Resources()
        urlPlist = resource.getResource(resource: .urlPLIST)
        urlnewVersion()
    }
}
