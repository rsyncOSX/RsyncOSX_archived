//
//  AssistDefault.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 04/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Files
import Foundation

final class AssistDefault {
    var catalogs = Set<String>()
    var localhome = Set<String>()
    var remoteservers = Set<String>()
    var remoteusers = Set<String>()
    var nameandpaths: NamesandPaths?

    func setcatalogs() -> Set<String>? {
        if let atpath = self.nameandpaths?.userHomeDirectoryPath {
            var catalogs = Set<String>()
            do {
                for folders in try Folder(path: atpath).subfolders {
                    catalogs.insert(folders.name)
                }
                return catalogs.filter { $0.isEmpty == false }
            } catch {
                return nil
            }
        }
        return nil
    }

    func setlocalhome() -> Set<String> {
        var home = Set<String>()
        home.insert(self.nameandpaths?.userHomeDirectoryPath ?? "")
        return home
    }

    func setremotes() {
        if let remote = ConfigurationsAsDictionarys().uniqueserversandlogins() {
            for i in 0 ..< remote.count {
                if let remoteuser = (remote[i].value(forKey: DictionaryStrings.offsiteServerCellID.rawValue) as? String),
                   let remoteserver = (remote[i].value(forKey: DictionaryStrings.offsiteUsernameID.rawValue) as? String)
                {
                    if remoteusers.contains(remoteuser) == false {
                        self.remoteusers.insert(remoteuser)
                    }
                    if remoteservers.contains(remoteserver) == false {
                        self.remoteservers.insert(remoteserver)
                    }
                }
            }
        }
    }

    init() {
        self.nameandpaths = NamesandPaths(profileorsshrootpath: .profileroot)
        self.localhome = setlocalhome()
        if let catalogs = self.setcatalogs() {
            self.catalogs = catalogs
        }
        self.setremotes()
    }
}
