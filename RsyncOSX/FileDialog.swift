//
//  FileDialog.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

protocol GetPath: class {
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
        self.pathDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations)
            as? ViewControllerNewConfigurations
        switch value.rawValue {
        case 0: break
        case 1:
            // Select is choosen
            let path = myFiledialog.url?.relativePath
            // We are sending over the path to the correct requestor
            switch requester {
            case .copyFilesTo:
                self.pathDelegate?.pathSet(path: path, requester: .copyFilesTo)
            case .addLocalCatalog:
                self.pathDelegate?.pathSet(path: path, requester: .addLocalCatalog)
            case .addRemoteCatalog:
                self.pathDelegate?.pathSet(path: path, requester: .addRemoteCatalog)
            }
        default:
            break
        }
    }

    init(requester: WhichPath) {
        self.openfiledlg(title: "Catalogs", message: "Select catalog", requester: requester)
    }
}
