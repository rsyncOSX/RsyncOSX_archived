//
//  ReadWriteJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 18/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Files
import Foundation

enum Jsontype {
    case configurations
    case schedules
}

class ReadWriteJSON: NamesandPaths {
    var jsonstring: String?
    var jsonname: String?
    var decodejson: [Any]?
    var jsontype: Jsontype?

    func readJSONFromPersistentStore() {
        if var atpath = self.fullroot {
            do {
                if self.profile != nil {
                    atpath += "/" + (self.profile ?? "")
                }
                let jsonfile = atpath + "/" + (self.jsonname ?? "")
                let file = try File(path: jsonfile)
                let jsonfromstore = try file.readAsString()
                if let jsonstring = jsonfromstore.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        if self.jsontype ?? .schedules == .schedules {
                            self.decodejson = try decoder.decode([SchedulesJson].self, from: jsonstring)
                        } else {
                            self.decodejson = try decoder.decode([ConfigurationsJson].self, from: jsonstring)
                        }
                        let logg = OutputProcess()
                        logg.addlinefromoutput(str: self.jsonname ?? "" + "JSON: readJSONFromPersistentStore success")
                        _ = Logging(logg, true)
                    } catch {}
                }
            } catch {}
        }
    }

    func writeJSONToPersistentStore() {
        if var atpath = self.fullroot {
            do {
                if self.profile != nil {
                    atpath += "/" + (self.profile ?? "")
                }
                let folder = try Folder(path: atpath)
                let file = try folder.createFile(named: self.jsonname ?? "")
                if let data = self.jsonstring {
                    try file.write(data)
                    let logg = OutputProcess()
                    logg.addlinefromoutput(str: self.jsonname ?? "" + " JSON: writeJSONToPersistentStore success")
                    _ = Logging(logg, true)
                }
            } catch {}
        }
    }

    init(profile: String?, jsonname: String?, jsontype: Jsontype) {
        super.init(profileorsshrootpath: .profileroot)
        self.profile = profile
        self.jsonname = jsonname
        self.jsontype = jsontype
    }
}
