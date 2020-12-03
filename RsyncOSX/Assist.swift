//
//  Assist.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 03/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity

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
    var remotecomputers = Set<String>() {
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

    var numberofsets: Int = 5
    var assist: [Set<String>]?
    var dirty: Bool = false

    func assistvalues() {
        if let store = PersistentStorageAssist(assist: nil).readassist() {
            for i in 0 ..< store.count {
                if let remotecomputers = store[i].value(forKey: DictionaryStrings.remotecomputers.rawValue) as? String {
                    self.remotecomputers.insert(remotecomputers)
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
        }
        self.assist = [Set<String>]()
        for i in 0 ..< self.numberofsets {
            switch i {
            case 0:
                self.assist?.append(self.remotecomputers)
            case 1:
                self.assist?.append(self.remoteusers)
            case 2:
                self.assist?.append(self.remotehome)
            case 3:
                self.assist?.append(self.catalogs)
            case 4:
                self.assist?.append(self.localhome)
            default:
                return
            }
        }
        self.dirty = false
    }

    init() {
        self.assistvalues()
    }
}
