//
//  Readwritefiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 25/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  let str = "/Rsync/" + serialNumber + profile? + "/scheduleRsync.plist"
//  let str = "/Rsync/" + serialNumber + profile? + "/configRsync.plist"
//  let str = "/Rsync/" + serialNumber + "/config.plist"
//
// swiftlint:disable line_length

import Cocoa
import Foundation

class ReadWriteDictionary: NamesandPaths {
    // Function for reading data from persistent store
    func readNSDictionaryFromPersistentStore() -> [NSDictionary]? {
        var data: [NSDictionary]?
        let dictionary = NSDictionary(contentsOfFile: self.filename ?? "")
        if let items = dictionary?.object(forKey: self.key ?? "") as? NSArray {
            data = [NSDictionary]()
            for i in 0 ..< items.count {
                if let item = items[i] as? NSDictionary {
                    data?.append(item)
                }
            }
        }
        return data
    }

    // Function for write data to persistent store
    @discardableResult
    func writeNSDictionaryToPersistentStorage(array: [NSDictionary]) -> Bool {
        let dictionary = NSDictionary(object: array, forKey: (self.key ?? "") as NSCopying)
        let write = dictionary.write(toFile: self.filename ?? "", atomically: true)
        if write && ViewControllerReference.shared.menuappisrunning {
            Notifications().showNotification(message: "Sending reload message to menu app")
            DistributedNotificationCenter.default().postNotificationName(NSNotification.Name("no.blogspot.RsyncOSX.reload"), object: nil, deliverImmediately: true)
        }
        return write
    }

    override init(whattoreadwrite: WhatToReadWrite, profile: String?) {
        super.init(whattoreadwrite: whattoreadwrite, profile: profile)
    }
}
