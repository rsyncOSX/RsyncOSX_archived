//  ReadUserConfigurationPLIST.swift
//  RsyncUI
//
//  Created by Thomas Evensen on 16/05/2021.
//
// swiftlint:disable line_length cyclomatic_complexity function_body_length

import Combine
import Foundation

final class ReadUserConfigurationPLIST: NamesandPaths {
    var filenamedatastore = [SharedReference.shared.userconfigplist]
    var subscriptons = Set<AnyCancellable>()

    private func setuserconfiguration(_ dict: NSDictionary?) {
        if let dict = dict {
            // Another version of rsync
            if let version3rsync = dict.value(forKey: DictionaryStrings.version3Rsync.rawValue) as? Int {
                if version3rsync == 1 {
                    SharedReference.shared.rsyncversion3 = true
                } else {
                    SharedReference.shared.rsyncversion3 = false
                }
            }
            // Detailed logging
            if let detailedlogging = dict.value(forKey: DictionaryStrings.detailedlogging.rawValue) as? Int {
                if detailedlogging == 1 {
                    SharedReference.shared.detailedlogging = true
                } else {
                    SharedReference.shared.detailedlogging = false
                }
            }
            // Optional path for rsync
            if let rsyncPath = dict.value(forKey: DictionaryStrings.rsyncPath.rawValue) as? String {
                SharedReference.shared.localrsyncpath = rsyncPath
            }
            // Temporary path for restores single files or directory
            if let restorePath = dict.value(forKey: DictionaryStrings.restorePath.rawValue) as? String {
                if restorePath.count > 0 {
                    SharedReference.shared.temporarypathforrestore = restorePath
                } else {
                    SharedReference.shared.temporarypathforrestore = nil
                }
            }
            // Mark tasks
            if let marknumberofdayssince = dict.value(forKey: DictionaryStrings.marknumberofdayssince.rawValue) as? String {
                if Double(marknumberofdayssince)! > 0 {
                    let oldmarknumberofdayssince = SharedReference.shared.marknumberofdayssince
                    SharedReference.shared.marknumberofdayssince = Double(marknumberofdayssince)!
                }
            }
            // Paths rsyncOSX and RsyncOSXsched
            if let pathrsyncosx = dict.value(forKey: DictionaryStrings.pathrsyncosx.rawValue) as? String {
                if pathrsyncosx.isEmpty == true {
                    SharedReference.shared.pathrsyncosx = nil
                } else {
                    SharedReference.shared.pathrsyncosx = pathrsyncosx
                }
            }
            if let pathrsyncosxsched = dict.value(forKey: DictionaryStrings.pathrsyncosxsched.rawValue) as? String {
                if pathrsyncosxsched.isEmpty == true {
                    SharedReference.shared.pathrsyncosxsched = nil
                } else {
                    SharedReference.shared.pathrsyncosxsched = pathrsyncosxsched
                }
            }
            // No logging, minimum logging or full logging
            if let minimumlogging = dict.value(forKey: DictionaryStrings.minimumlogging.rawValue) as? Int {
                if minimumlogging == 1 {
                    SharedReference.shared.minimumlogging = true
                } else {
                    SharedReference.shared.minimumlogging = false
                }
            }
            if let fulllogging = dict.value(forKey: DictionaryStrings.fulllogging.rawValue) as? Int {
                if fulllogging == 1 {
                    SharedReference.shared.fulllogging = true
                } else {
                    SharedReference.shared.fulllogging = false
                }
            }
            if let environment = dict.value(forKey: DictionaryStrings.environment.rawValue) as? String {
                SharedReference.shared.environment = environment
            }
            if let environmentvalue = dict.value(forKey: DictionaryStrings.environmentvalue.rawValue) as? String {
                SharedReference.shared.environmentvalue = environmentvalue
            }
            if let haltonerror = dict.value(forKey: DictionaryStrings.haltonerror.rawValue) as? Int {
                if haltonerror == 1 {
                    SharedReference.shared.haltonerror = true
                } else {
                    SharedReference.shared.haltonerror = false
                }
            }
            if let sshkeypathandidentityfile = dict.value(forKey: DictionaryStrings.sshkeypathandidentityfile.rawValue) as? String {
                SharedReference.shared.sshkeypathandidentityfile = sshkeypathandidentityfile
            }
            if let sshport = dict.value(forKey: DictionaryStrings.sshport.rawValue) as? Int {
                SharedReference.shared.sshport = sshport
            }
            if let monitornetworkconnection = dict.value(forKey: DictionaryStrings.monitornetworkconnection.rawValue) as? Int {
                if monitornetworkconnection == 1 {
                    SharedReference.shared.monitornetworkconnection = true
                } else {
                    SharedReference.shared.monitornetworkconnection = false
                }
            }
        }
    }

    @discardableResult
    init() {
        super.init(.configurations)
        filenamedatastore.publisher
            .compactMap { name -> URL? in
                URL(fileURLWithPath: (fullpathmacserial ?? "") + name)
            }
            .tryMap { url -> NSDictionary in
                try NSDictionary(contentsOf: url, error: ())
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    return
                case let .failure(error):
                    let error = error as NSError
                    self.error(errordescription: error.description, errortype: .readerror)
                }
            }, receiveValue: { [unowned self] data in
                if let items = data.object(forKey: SharedReference.shared.userconfigkey) as? NSArray {
                    let userconfig = items.map { row -> NSDictionary? in
                        switch row {
                        case is NSNull:
                            return nil
                        case let value as NSDictionary:
                            return value
                        default:
                            return nil
                        }
                    }
                    guard userconfig.count > 0 else { return }
                    setuserconfiguration(userconfig[0])
                }
                subscriptons.removeAll()
            }).store(in: &subscriptons)
        _ = Setrsyncpath()
        _ = RsyncVersionString()
    }
}
