//
//  batchOperations.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 25/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//swiftlint:disable syntactic_sugar

import Foundation

final class BatchTaskWorkQueu {

    // Structure holding updated data for batchrun
    private var data = Array<NSMutableDictionary>()
    // BatchQueue
    // First = hiddenID, second 0 estimate or 1 real run
    private var batchQueu = [(Int, Int)]()
    // Just holding the indexes
    private var index = Array<Int>()
    // Holding value for working on row
    private var row: Int?

    // Returning current row
    func getRow() -> Int {
        guard self.row != nil else {
            return 0
        }
        return self.row!
    }

    // Set estimated (0 or 1) for row at index
    func setEstimated(numberOfFiles: Int) {
        let index = self.index[0]
        self.data[index].setValue(1, forKey: "estimatedCellID")
        self.data[index].setValue(String(numberOfFiles), forKey: "maxnumberOfFilesCellID")
        self.row = index
    }

    // Set percent completed during process
    func updateInProcess(numberOfFiles: Int) {
        let index = self.index[0]
        self.data[index].setValue(String(numberOfFiles), forKey: "numberOfFilesCellID")
        self.row = index
    }

    // Set Completed
    func setCompleted () {
        let index = self.index.removeFirst()
        let numberOfFiles = self.data[index].value(forKey: "maxnumberOfFilesCellID")
        self.data[index].setValue(numberOfFiles, forKey: "numberOfFilesCellID")
        self.data[index].setValue(1, forKey: "completedCellID")
        self.row = index
    }

    // Pops of the first element of index Queue
    func removeFirst() {
        self.index.removeFirst()
    }

    // Return data
    func getupdatedBatchdata() -> Array<NSMutableDictionary> {
        return self.data
    }

    // Return the number of rows
    func getbatchDataQueuecount() -> Int {
        return self.data.count
    }

    // Get next batch from Queue, REMOVES the first element
    // (-1,-1) indicates end of Queue
    func nextBatchRemove() -> (Int, Int) {
        guard self.batchQueu.count > 0 else {
            return (-1, -1)
        }
        return self.batchQueu.removeFirst()
    }

    // Get next batch from Queue, COPY ONLY the first element
    // (-1,-1) indicates end of Queue
    func nextBatchCopy() -> (Int, Int) {
        guard self.batchQueu.count > 0 else {
            return (-1, -1)
        }
        return self.batchQueu[0]
    }

    // Func abort Queue
    func abortOperations() {
        // Remove all objects in Queueu
        self.batchQueu.removeAll()
    }

    init (batchtasks: Array<Configuration>) {
        for i in 0 ..< batchtasks.count {
            let row: NSMutableDictionary = [
                "taskCellID": String(i+1),
                "localCatalogCellID": batchtasks[i].localCatalog,
                "offsiteServerCellID": batchtasks[i].offsiteServer,
                "estimatedCellID": 0,
                "completedCellID": 0,
                "numberOfFilesCellID": "0",
                "maxnumberOfFilesCellID": "0"]
            if (row.object(forKey: "offsiteServerCellID") as? String)!.isEmpty {
                row.setValue("localhost", forKey: "offsiteServerCellID")
            }
            self.data.append(row)
            // Appending data for batchQueue
            // Estimaterun queu = (hiddenID,0)
            self.batchQueu.append((batchtasks[i].hiddenID, 0))
            // Real run queu = (hiddenID,1)
            self.batchQueu.append((batchtasks[i].hiddenID, 1))
            // Appendig index
            self.index.append(i)
        }
    }
}
