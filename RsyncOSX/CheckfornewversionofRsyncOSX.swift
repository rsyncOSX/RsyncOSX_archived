//
//  VersionofRsyncOSX.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 08/12/2022.
//  Copyright © 2022 Thomas Evensen. All rights reserved.
//

import Foundation

protocol NewVersionDiscovered: AnyObject {
    func notifyNewVersion()
}

struct VersionsofRsyncOSX: Codable {
    let url: String?
    let version: String?

    enum CodingKeys: String, CodingKey {
        case url
        case version
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        version = try values.decodeIfPresent(String.self, forKey: .version)
    }
}

struct GetversionsofRsyncUI {
    let urlSession = URLSession.shared
    let jsonDecoder = JSONDecoder()

    func getversionsofrsyncosxbyurl() async throws -> [VersionsofRsyncOSX]? {
        if let url = URL(string: Resources().getResource(resource: .urlJSON)) {
            let (data, _) = try await urlSession.data(from: url)
            return try jsonDecoder.decode([VersionsofRsyncOSX].self, from: data)
        } else {
            return nil
        }
    }
}

@MainActor
final class CheckfornewversionofRsyncOSX {
    weak var newversionDelegateMain: NewVersionDiscovered?

    func getversionsofrsyncosx() async {
        do {
            let versions = GetversionsofRsyncUI()
            if let versionsofrsyncosx = try await versions.getversionsofrsyncosxbyurl() {
                let runningversion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
                let check = versionsofrsyncosx.filter { runningversion.isEmpty ? true : $0.version == runningversion }
                if check.count > 0 {
                    SharedReference.shared.URLnewVersion = check[0].url
                    self.newversionDelegateMain = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
                    self.newversionDelegateMain?.notifyNewVersion()
                    SharedReference.shared.newversionofrsyncosx = true
                } else {
                    SharedReference.shared.newversionofrsyncosx = false
                }
            }

        } catch {
            SharedReference.shared.newversionofrsyncosx = false
        }
    }
}

