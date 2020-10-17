//
//  ReadWriteJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 16/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation
import SwiftyJSON

class ReadWriteJSON: SetConfigurations {
    var jsonstring: String?
    
    func createJSON() {
        var structscodable: [ConvertOneConfigCodable]?
        if let configurations = self.configurations?.configurations {
            structscodable = [ConvertOneConfigCodable]()
            for i in 0 ..< configurations.count {
                structscodable?.append(ConvertOneConfigCodable(config: configurations[i]))
            }
        }
        self.jsonstring = self.encode(data: structscodable)
    }

    func encode(data: [ConvertOneConfigCodable]?) -> String? {
        do {
            let jsonData = try JSONEncoder().encode(data)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            return nil
        }
        return nil
    }

    func readJSONFromPersistentStore() -> Any? {
        return nil
    }

    func writeJSONToPersistentStore() {
        let jsonString = "{\"location\": \"the moon\"}"
        if let jsonData = jsonString.data(using: .utf8),
           let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                            in: .userDomainMask).first
        {
            let pathWithFileName = documentDirectory.appendingPathComponent("myJsonData")
            do {
                try jsonData.write(to: pathWithFileName)
            } catch {
                // handle error
            }
        }
    }

    init() {}
}
