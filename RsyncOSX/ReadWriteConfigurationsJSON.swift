//
//  ReadWriteJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 16/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Files
import Foundation

class ReadWriteConfigurationsJSON: ReadWriteJSON {
    var configurations: [Configuration]?
    var decodedjson: [Any]?

    private func createJSONfromstructs() {
        var structscodable: [ConvertOneConfigCodable]?
        if let configurations = self.configurations {
            structscodable = [ConvertOneConfigCodable]()
            for i in 0 ..< configurations.count {
                structscodable?.append(ConvertOneConfigCodable(config: configurations[i]))
            }
        }
        self.jsonstring = self.encodedata(data: structscodable)
    }

    private func encodedata(data: [ConvertOneConfigCodable]?) -> String? {
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

    private func decode(jsonfileasstring: String) {
        if let jsonstring = jsonfileasstring.data(using: .utf8) {
            do {
                let decoder = JSONDecoder()
                self.decodedjson = try decoder.decode([DecodeConfigJSON].self, from: jsonstring)
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .json)
            }
        }
    }

    func JSONFromPersistentStore() {
        do {
            let test = try self.readJSONFromPersistentStore()
            self.decode(jsonfileasstring: test ?? "")
        } catch {}
    }

    init(configurations: [Configuration]?, profile: String?) {
        super.init(profile: profile, filename: ViewControllerReference.shared.fileconfigurationsjson)
        self.configurations = configurations
        self.profile = profile
        self.createJSONfromstructs()
    }

    init(profile: String?) {
        super.init(profile: profile, filename: ViewControllerReference.shared.fileconfigurationsjson)
        self.profile = profile
        self.JSONFromPersistentStore()
    }
}
