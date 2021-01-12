//
//  Assist.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 03/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

enum Addvalues {
    case remotecomputers
    case remoteusers
    case remotehome
    case catalogs
    case localhome
    case none
}

protocol AssistTransfer: AnyObject {
    func assisttransfer(values: [String]?)
}

final class Assist {
    var remoteservers = Set<String>() {
        didSet { self.dirty = true }
    }

    var remoteusers = Set<String>() {
        didSet { self.dirty = true }
    }

    var remotehome = Set<String>() {
        didSet { self.dirty = true }
    }

    var catalogs = Set<String>() {
        didSet { self.dirty = true }
    }

    var localhome = Set<String>() {
        didSet { self.dirty = true }
    }

    var dirty: Bool = false

    func assistvalues() {
        if let store = PersistentStorageAssist(assist: nil).readassist() {
            for i in 0 ..< store.count {
                if let remotecomputers = store[i].value(forKey: DictionaryStrings.remotecomputers.rawValue) as? String {
                    self.remoteservers.insert(remotecomputers)
                } else if let remoteusers = store[i].value(forKey: DictionaryStrings.remoteusers.rawValue) as? String {
                    self.remoteusers.insert(remoteusers)
                } else if let remotehome = store[i].value(forKey: DictionaryStrings.remotehome.rawValue) as? String {
                    self.remotehome.insert(remotehome)
                } else if let catalogs = store[i].value(forKey: DictionaryStrings.catalogs.rawValue) as? String {
                    self.catalogs.insert(catalogs)
                } else if let localhome = store[i].value(forKey: DictionaryStrings.localhome.rawValue) as? String {
                    self.localhome.insert(localhome)
                }
            }
        } else {
            let defaultvalues = AssistDefault()
            self.localhome = defaultvalues.localhome
            self.catalogs = defaultvalues.catalogs
            self.remoteusers = defaultvalues.remoteusers
            self.remoteservers = defaultvalues.remoteservers
        }
        self.dirty = false
    }

    init(reset: Bool) {
        if reset {
            let defaultvalues = AssistDefault()
            self.localhome = defaultvalues.localhome
            self.catalogs = defaultvalues.catalogs
            self.remoteusers = defaultvalues.remoteusers
            self.remoteservers = defaultvalues.remoteservers
            self.dirty = true
        } else {
            self.assistvalues()
            self.dirty = false
        }
    }
}
