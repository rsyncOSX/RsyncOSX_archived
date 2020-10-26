//
//  ReadWriteJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 16/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Files
import Foundation

class ReadWriteConfigurationsJSON: NamesandPaths, FileErrors {
    var jsonstring: String?
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

    func readJSONFromPersistentStore() {
        if var atpath = self.fullroot {
            do {
                if self.profile != nil {
                    atpath += "/" + (self.profile ?? "")
                }
                // check if file exists befor reading, if not bail out
                guard try Folder(path: atpath).containsFile(named: ViewControllerReference.shared.fileconfigurationsjson) else { return }
                let jsonfile = atpath + "/" + ViewControllerReference.shared.fileconfigurationsjson
                let file = try File(path: jsonfile)
                let jsonfromstore = try file.readAsString()
                if let jsonstring = jsonfromstore.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        self.decodedjson = try decoder.decode([DecodeConfigJSON].self, from: jsonstring)
                    } catch let e {
                        let error = e as NSError
                        self.error(error: error.description, errortype: .json)
                    }
                }
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .json)
            }
        }
    }

    func writeJSONToPersistentStore() {
        if var atpath = self.fullroot {
            do {
                if self.profile != nil {
                    atpath += "/" + (self.profile ?? "")
                }
                let folder = try Folder(path: atpath)
                let file = try folder.createFile(named: ViewControllerReference.shared.fileconfigurationsjson)
                if let data = self.jsonstring {
                    try file.write(data)
                }
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .json)
            }
        }
    }

    func writeconvertedtostore() {
        if var atpath = self.fullroot {
            if self.profile != nil {
                atpath += "/" + (self.profile ?? "")
            }
            do {
                if try Folder(path: atpath).containsFile(named: ViewControllerReference.shared.fileconfigurationsjson) {
                    let question: String = NSLocalizedString("JSON file exists: ", comment: "Logg")
                    let text: String = NSLocalizedString("Cancel or Save", comment: "Logg")
                    let dialog: String = NSLocalizedString("Save", comment: "Logg")
                    let answer = Alerts.dialogOrCancel(question: question + " " + ViewControllerReference.shared.fileconfigurationsjson, text: text, dialog: dialog)
                    if answer {
                        self.writeJSONToPersistentStore()
                    }
                }
            } catch {}
        }
    }

    init(configurations: [Configuration]?, profile: String?) {
        super.init(profileorsshrootpath: .profileroot)
        self.configurations = configurations
        self.profile = profile
        self.createJSONfromstructs()
    }

    init(profile: String?) {
        super.init(profileorsshrootpath: .profileroot)
        self.profile = profile
        self.readJSONFromPersistentStore()
    }
}
