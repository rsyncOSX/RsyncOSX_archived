//
//  PersistentStorageConfigurationJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

class PersistentStorageConfigurationJSON: ReadWriteJSON, SetConfigurations {
    var configurations: [Configuration]?
    var decodedjson: [Any]?

    // Variable computes max hiddenID used
    // MaxhiddenID is used when new configurations are added.
    var maxhiddenID: Int {
        // Reading Configurations from memory
        if let store = self.configurations?.getConfigurations() {
            if store.count > 0 {
                _ = store.sorted { (config1, config2) -> Bool in
                    if config1.hiddenID > config2.hiddenID {
                        return true
                    } else {
                        return false
                    }
                }
                let index = store.count - 1
                return store[index].hiddenID
            }
        } else {
            return 0
        }
        return 0
    }

    // Saving Configuration from MEMORY to persistent store
    // Reads Configurations from MEMORY and saves to persistent Store
    func saveconfigInMemoryToPersistentStore() {
        if let configurations = self.configurations?.getConfigurations() {
            self.writeToStore(configurations: configurations)
        }
    }

    // Add new configuration in memory to permanent storage
    func newConfigurations(dict: NSMutableDictionary) {
        var array = [NSDictionary]()
        if let configs: [Configuration] = self.configurations?.getConfigurations() {
            for i in 0 ..< configs.count {
                if let dict: NSMutableDictionary = ConvertConfigurations(index: i).configuration {
                    array.append(dict)
                }
            }
            dict.setObject(self.maxhiddenID + 1, forKey: "hiddenID" as NSCopying)
            array.append(dict)
            self.configurations?.appendconfigurationstomemory(dict: array[array.count - 1])
            self.saveconfigInMemoryToPersistentStore()
        }
    }

    private func writeToStore(configurations _: [Configuration]?) {
        // let store = ReadWriteConfigurationsJSON(configurations: configurations, profile: self.profile)
        self.writeJSONToPersistentStore()
        self.configurationsDelegate?.reloadconfigurationsobject()
        if ViewControllerReference.shared.menuappisrunning {
            Notifications().showNotification(message: "Sending reload message to menu app")
            DistributedNotificationCenter.default().postNotificationName(NSNotification.Name("no.blogspot.RsyncOSX.reload"), object: nil, deliverImmediately: true)
        }
    }

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
