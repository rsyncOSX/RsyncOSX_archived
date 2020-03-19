//
//  batchOperations.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 25/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable trailing_comma

import Foundation

final class BatchTaskWorkQueu {
    // Structure holding updated data for batchrun
    var data = [NSMutableDictionary]()
    var batchQueu = [(Int, Int)]()
    var completed: Bool = false

    func batchruniscompleted() -> Bool {
        return self.completed
    }

    // Return the number of rows
    func getbatchtaskstodocount() -> Int {
        return self.data.count
    }

    // Get next batch from Queue, REMOVES the first element
    // (-1,-1) indicates end of Queue
    func removenexttaskinqueue() -> (Int, Int) {
        guard self.batchQueu.count > 0 else {
            self.completed = true
            return (-1, -1)
        }
        return self.batchQueu.removeFirst()
    }

    // Get next batch from Queue, COPY ONLY the first element
    // (-1,-1) indicates end of Queue
    func copyofnexttaskinqueue() -> (Int, Int) {
        guard self.batchQueu.count > 0 else {
            self.completed = true
            return (-1, -1)
        }
        return self.batchQueu[0]
    }

    init(configurations _: Configurations?) {
        /*
         if let batchtasks = configurations?.getConfigurationsBatch() {
             for i in 0 ..< batchtasks.count {
                 let row: NSMutableDictionary = [
                     "taskCellID": batchtasks[i].task,
                     "localCatalogCellID": batchtasks[i].localCatalog,
                     "offsiteServerCellID": batchtasks[i].offsiteServer,
                     "offsiteCatalogCellID": batchtasks[i].offsiteCatalog,
                     "hiddenID": batchtasks[i].hiddenID,
                 ]
                 if (row.object(forKey: "offsiteServerCellID") as? String)!.isEmpty {
                     row.setValue("localhost", forKey: "offsiteServerCellID")
                 }
                 self.data.append(row)
                 self.batchQueu.append((batchtasks[i].hiddenID, 1))
             }
         }
         */
    }
}
