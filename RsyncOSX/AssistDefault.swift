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
    var catalogs: Set<String>?
    var localhome: Set<String>?
    var nameandpaths: NamesandPaths?

    func setcatalogs() -> Set<String>? {
        if let atpath = self.nameandpaths?.userHomeDirectoryPath {
            var catalogs = Set<String>()
            do {
                for folders in try Folder(path: atpath).subfolders {
                    catalogs.insert(folders.name)
                }
                return catalogs
            } catch {
                return nil
            }
        }
        return nil
    }

    func setlocalhome() -> Set<String>? {
        var home = Set<String>()
        home.insert(self.nameandpaths?.userHomeDirectoryPath ?? "")
        return home
    }

    init() {
        self.nameandpaths = NamesandPaths(profileorsshrootpath: .profileroot)
        self.localhome = setlocalhome()
        self.catalogs = setcatalogs()
    }
}
