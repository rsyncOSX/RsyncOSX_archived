//
//  FileDialog.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

protocol GetPath : class {
    func pathSet(path : String?, requester : WhichPath)
}

enum WhichPath {
    case CopyFilesTo
    case AddLocalCatalog
    case AddRemoteCatalog
}

final class FileDialog {
    
    weak var path_delegate:GetPath?
    private var whichPath:WhichPath?
    
    private func openfiledlg (title: String, message: String, requester : WhichPath) {
        GlobalMainQueue.async(execute: { () -> Void in
            let myFiledialog: NSOpenPanel = NSOpenPanel()
            myFiledialog.prompt = "Select"
            // myFiledialog.worksWhenModal = true
            myFiledialog.allowsMultipleSelection = false
            myFiledialog.canChooseDirectories = true
            myFiledialog.resolvesAliases = true
            myFiledialog.title = title
            myFiledialog.message = message
            let value = myFiledialog.runModal()
            switch (value) {
            case 0: break
            case 1:
                // Select is choosen
                let path = myFiledialog.url?.relativePath
                // We are sending over the path to the correct requestor
                switch (requester) {
                case .CopyFilesTo:
                    if let pvc = SharingManagerConfiguration.sharedInstance.CopyObjectMain as? ViewControllerCopyFiles {
                        self.path_delegate = pvc
                        self.path_delegate?.pathSet(path: path, requester: .CopyFilesTo)
                    }
                case .AddLocalCatalog:
                    if let pvc = SharingManagerConfiguration.sharedInstance.AddObjectMain as? ViewControllerNewConfigurations {
                        self.path_delegate = pvc
                        self.path_delegate?.pathSet(path: path, requester: .AddLocalCatalog)
                    }
                case .AddRemoteCatalog:
                    if let pvc = SharingManagerConfiguration.sharedInstance.AddObjectMain as? ViewControllerNewConfigurations {
                        self.path_delegate = pvc
                        self.path_delegate?.pathSet(path: path, requester: .AddRemoteCatalog)
                    }
                }
            default:break
            }
        })
    }
    
    init(requester : WhichPath) {
        self.openfiledlg(title: "Catalogs", message: "Select catalog", requester : requester)
    }
}
