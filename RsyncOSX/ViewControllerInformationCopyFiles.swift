//
//  ViewControllerInformationCopyFiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 14/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Cocoa

class ViewControllerInformationCopyFiles: NSViewController {

    @IBOutlet weak var detailsTable: NSTableView!
    var output: [String]?
    weak var informationDelegate: Information?
    weak var dismissDelegate: DismissViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailsTable.delegate = self
        self.detailsTable.dataSource = self
        self.informationDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vccopyfiles) as? ViewControllerCopyFiles
        self.dismissDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vccopyfiles) as? ViewControllerCopyFiles
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.output = self.informationDelegate?.getInformation()
        globalMainQueue.async(execute: { () -> Void in
            self.detailsTable.reloadData()
        })
    }

    @IBAction func close(_ sender: NSButton) {
        self.dismissDelegate?.dismiss_view(viewcontroller: self)
    }

}

extension ViewControllerInformationCopyFiles: NSTableViewDataSource {

    func numberOfRows(in aTableView: NSTableView) -> Int {
        return self.output?.count ?? 0
    }

}

extension ViewControllerInformationCopyFiles: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellIdentifier: String = ""
        if tableColumn == tableView.tableColumns[0] {
            text = self.output![row]
            cellIdentifier = "outputID"
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier),
                     owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }

}
