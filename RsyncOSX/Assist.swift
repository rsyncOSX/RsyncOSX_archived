//
//  Assist.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 03/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity function_body_length

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
    var remotecomputers: Set<String>?
    var remoteusers: Set<String>?
    var remotehome: Set<String>?
    var catalogs: Set<String>?
    var localhome: Set<String>?
    var numberofsets: Int = 5
    var assist: [Set<String>]?

    func assistvalues() {
        if let store = PersistentStorageAssist(assistassets: nil).readassist() {
            for i in 0 ..< store.count {
                if let remotecomputers = store[i].value(forKey: DictionaryStrings.remotecomputers.rawValue) as? String {
                    if self.remotecomputers == nil {
                        self.remotecomputers = Set<String>()
                    }
                    self.remotecomputers?.insert(remotecomputers)
                } else if let remoteusers = store[i].value(forKey: DictionaryStrings.remoteusers.rawValue) as? String {
                    if self.remoteusers == nil {
                        self.remoteusers = Set<String>()
                    }
                    self.remoteusers?.insert(remoteusers)
                } else if let remotehome = store[i].value(forKey: DictionaryStrings.remotehome.rawValue) as? String {
                    if self.remotehome == nil {
                        self.remotehome = Set<String>()
                    }
                    self.remotehome?.insert(remotehome)
                } else if let catalogs = store[i].value(forKey: DictionaryStrings.catalogs.rawValue) as? String {
                    if self.catalogs == nil {
                        self.catalogs = Set<String>()
                    }
                    self.catalogs?.insert(catalogs)
                } else if let localhome = store[i].value(forKey: DictionaryStrings.localhome.rawValue) as? String {
                    if self.localhome == nil {
                        self.localhome = Set<String>()
                    }
                    self.localhome?.insert(localhome)
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
                self.assist?.append(self.remotecomputers ?? [])
            case 1:
                self.assist?.append(self.remoteusers ?? [])
            case 2:
                self.assist?.append(self.remotehome ?? [])
            case 3:
                self.assist?.append(self.catalogs ?? [])
            case 4:
                self.assist?.append(self.localhome ?? [])
            default:
                return
            }
        }
    }

    init() {
        self.assistvalues()
    }
}
