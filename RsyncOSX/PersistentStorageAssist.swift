//
//  PersistentStorageAssist.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 02/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Files
import Foundation

final class PersistentStorageAssist: ReadWriteDictionary {
    var assistsets: [Set<String>]?

    // Save assist configuration
    func saveassist() {
        let root = NamesandPaths(profileorsshrootpath: .profileroot)
        if let atpath = root.fullroot {
            do {
                if try Folder(path: atpath).containsFile(named: ViewControllerReference.shared.assistplist) {
                    let question: String = NSLocalizedString("PLIST file exists: ", comment: "Logg")
                    let text: String = NSLocalizedString("Cancel or Save", comment: "Logg")
                    let dialog: String = NSLocalizedString("Save", comment: "Logg")
                    let answer = Alerts.dialogOrCancel(question: question + " " +
                        ViewControllerReference.shared.assistplist, text: text, dialog: dialog)
                    if answer {
                        if let array: [NSDictionary] = ConvertAssist(assistassets: self.assistsets).assist {
                            self.writeToStore(array: array)
                        }
                    }
                } else {
                    if let array: [NSDictionary] = ConvertAssist(assistassets: self.assistsets).assist {
                        self.writeToStore(array: array)
                    }
                }
            } catch {}
        }
    }

    // Read assist
    func readassist() -> [NSDictionary]? {
        return self.readNSDictionaryFromPersistentStore()
    }

    // Writing assist to persistent store
    // Configuration is [NSDictionary]
    private func writeToStore(array: [NSDictionary]) {
        // Getting the object just for the write method, no read from persistent store
        self.writeNSDictionaryToPersistentStorage(array: array)
    }

    init(assist: Assist?) {
        super.init(profile: nil, whattoreadwrite: .assist)
        if let assist = assist {
            self.assistsets = [Set]()
            if let remotecomputers = assist.remotecomputers { self.assistsets?.append(remotecomputers) }
            if let remoteusers = assist.remoteusers { self.assistsets?.append(remoteusers) }
            if let remotehome = assist.remotehome { self.assistsets?.append(remotehome) }
            if let catalogs = assist.catalogs { self.assistsets?.append(catalogs) }
            if let localhome = assist.localhome { self.assistsets?.append(localhome) }
        }
    }
}
