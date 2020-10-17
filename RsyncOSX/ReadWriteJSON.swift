//
//  ReadWriteJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 16/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Files
import Foundation
import SwiftyJSON

class ReadWriteJSON: NamesandPaths {
    var jsonstring: String?
    var configurations: [Configuration]?
    var decodejson: [Any]?

    func createJSON() {
        var structscodable: [ConvertOneConfigCodable]?
        if let configurations = self.configurations {
            structscodable = [ConvertOneConfigCodable]()
            for i in 0 ..< configurations.count {
                structscodable?.append(ConvertOneConfigCodable(config: configurations[i]))
            }
        }
        self.jsonstring = self.encodedata(data: structscodable)
    }

    func encodedata(data: [ConvertOneConfigCodable]?) -> String? {
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

    func decodedata() {
        if let jsonstring = self.jsonstring!.data(using: .utf8) {
            do {
                let decoder = JSONDecoder()
                self.decodejson = try decoder.decode([ConfigurationsJson].self, from: jsonstring)

            } catch {}
        }
    }

    func readJSONFromPersistentStore() -> Any? {
        return nil
    }

    func writeJSONToPersistentStore() {
        if var atpath = self.fullroot {
            do {
                if self.profile != nil {
                    atpath += "/" + (self.profile ?? "")
                }
                let folder = try Folder(path: atpath)
                let file = try folder.createFile(named: "configurations.json")
                if let data = self.jsonstring {
                    try file.write(data)
                }
            } catch {}
        }
    }

    init(configurations: [Configuration]?, profile: String?) {
        super.init(profileorsshrootpath: .profileroot)
        self.configurations = configurations
        self.profile = profile
    }
}
