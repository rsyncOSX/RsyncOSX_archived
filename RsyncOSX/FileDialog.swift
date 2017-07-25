//
//  FileDialog.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//swiftlint:disable line_length

import Foundation
import Cocoa

protocol GetPath : class {
    func pathSet(path: String?, requester: WhichPath)
}

enum WhichPath {
    case copyFilesTo
    case addLocalCatalog
    case addRemoteCatalog
}

final class FileDialog {

    weak var pathDelegate: GetPath?

    private func openfiledlg (title: String, message: String, requester: WhichPath) {
        let myFiledialog: NSOpenPanel = NSOpenPanel()
        myFiledialog.prompt = "Select"
        // myFiledialog.worksWhenModal = true
        myFiledialog.allowsMultipleSelection = false
        myFiledialog.canChooseDirectories = true
        myFiledialog.resolvesAliases = true
        myFiledialog.title = title
        myFiledialog.message = message
        let value = myFiledialog.runModal()
        switch value.rawValue {
        case 0: break
        case 1:
            // Select is choosen
            let path = myFiledialog.url?.relativePath
            // We are sending over the path to the correct requestor
            switch requester {
            case .copyFilesTo:
                if let pvc = Configurations.shared.viewControllerCopyFiles as? ViewControllerCopyFiles {
                    self.pathDelegate = pvc
                    self.pathDelegate?.pathSet(path: path, requester: .copyFilesTo)
                }
            case .addLocalCatalog:
                if let pvc = Configurations.shared.viewControllerNewConfigurations as? ViewControllerNewConfigurations {
                    self.pathDelegate = pvc
                    self.pathDelegate?.pathSet(path: path, requester: .addLocalCatalog)
                }
            case .addRemoteCatalog:
                if let pvc = Configurations.shared.viewControllerNewConfigurations as? ViewControllerNewConfigurations {
                    self.pathDelegate = pvc
                    self.pathDelegate?.pathSet(path: path, requester: .addRemoteCatalog)
                }
            }
            default:break
        }
    }

    init(requester: WhichPath) {
        self.openfiledlg(title: "Catalogs", message: "Select catalog", requester : requester)
    }
}
