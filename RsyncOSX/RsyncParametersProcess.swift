//
//  RsyncParametersProcess.swift
//
//  Created by Thomas Evensen on 08/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable type_body_length cyclomatic_complexity

import Foundation

final class RsyncParametersProcess {

    private var stats: Bool?
    private var arguments: [String]?
    var localCatalog: String?
    var offsiteCatalog: String?
    var offsiteUsername: String?
    var offsiteServer: String?
    var remoteargs: String?
    var linkdestparam: String?
    private let suffixString = "--suffix=_`date +'%Y-%m-%d.%H.%M'`"
    private let suffixString2 = "--suffix=_$(date +%Y-%m-%d.%H.%M)"

    private func setParameters1To6(_ config: Configuration, dryRun: Bool, forDisplay: Bool, verify: Bool) {
        var parameter1: String?
        if verify {
            parameter1 = "--checksum"
        } else {
            parameter1 = config.parameter1
        }
        let parameter2: String = config.parameter2
        let parameter3: String = config.parameter3
        let parameter4: String = config.parameter4
        let parameter5: String = config.parameter5
        let offsiteServer: String = config.offsiteServer
        self.arguments!.append(parameter1 ?? "")
        if verify {
            if forDisplay {self.arguments!.append(" ")}
            self.arguments!.append("--recursive")
        }
        if forDisplay {self.arguments!.append(" ")}
        self.arguments!.append(parameter2)
        if forDisplay {self.arguments!.append(" ")}
        if offsiteServer.isEmpty  == false {
            if parameter3.isEmpty == false {
                self.arguments!.append(parameter3)
                if forDisplay {self.arguments!.append(" ")}
            }
        }
        self.arguments!.append(parameter4)
        if forDisplay {self.arguments!.append(" ")}
        if offsiteServer.isEmpty {
            // nothing
        } else {
            if parameter5.isEmpty == false {
                self.sshportparameter(config, forDisplay: forDisplay)
            }
        }
    }

    private func sshportparameter(_ config: Configuration, forDisplay: Bool) {
        let parameter5: String = config.parameter5
        let parameter6: String = config.parameter6
        // -e
        self.arguments!.append(parameter5)
        if forDisplay {self.arguments!.append(" ")}
        if let sshport = config.sshport {
            // "ssh -p xxx"
            if forDisplay {self.arguments!.append(" \"")}
            self.arguments!.append("ssh -p " + String(sshport))
            if forDisplay {self.arguments!.append("\" ")}
        } else {
            // ssh
            self.arguments!.append(parameter6)
        }
        if forDisplay {self.arguments!.append(" ")}
    }

    // Compute user selected parameters parameter8 ... parameter14
    // Brute force, check every parameter, not special elegant, but it works

    private func setParameters8To14(_ config: Configuration, dryRun: Bool, forDisplay: Bool) {
        self.stats = false
        if config.parameter8 != nil {
            self.appendParameter(parameter: config.parameter8!, forDisplay: forDisplay)
        }
        if config.parameter9 != nil {
            self.appendParameter(parameter: config.parameter9!, forDisplay: forDisplay)
        }
        if config.parameter10 != nil {
            self.appendParameter(parameter: config.parameter10!, forDisplay: forDisplay)
        }
        if config.parameter11 != nil {
            self.appendParameter(parameter: config.parameter11!, forDisplay: forDisplay)
        }
        if config.parameter12 != nil {
            self.appendParameter(parameter: config.parameter12!, forDisplay: forDisplay)
        }
        if config.parameter13 != nil {
            self.appendParameter(parameter: config.parameter13!, forDisplay: forDisplay)
        }
        if config.parameter14 != nil {
            if config.offsiteServer.isEmpty == true {
                if config.parameter14! == self.suffixString || config.parameter14! == self.suffixString2 {
                    self.appendParameter(parameter: self.setdatesuffixlocalhost(), forDisplay: forDisplay)
                }
            } else {
                self.appendParameter(parameter: config.parameter14!, forDisplay: forDisplay)
            }
        }
        // Append --stats parameter to collect info about run
        if dryRun {
            self.dryrunparameter(config, forDisplay: forDisplay)
        } else {
            if self.stats == false {
                self.appendParameter(parameter: "--stats", forDisplay: forDisplay)
            }
        }
    }

    private func setdatesuffixlocalhost() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "-yyyy-MM-dd"
        return  "--suffix=" + formatter.string(from: Date())
    }

    private func dryrunparameter(_ config: Configuration, forDisplay: Bool) {
        let dryrun: String = config.dryrun
        self.arguments!.append(dryrun)
        if forDisplay {self.arguments!.append(" ")}
        if self.stats! == false {
            self.arguments!.append("--stats")
            if forDisplay {self.arguments!.append(" ")}
        }
    }

    // Check userselected parameter and append it to arguments array passed to rsync or displayed
    // on screen.

    private func appendParameter (parameter: String, forDisplay: Bool) {
        if parameter.count > 1 {
            if parameter == "--stats" {
                self.stats = true
            }
            self.arguments!.append(parameter)
            if forDisplay {
                self.arguments!.append(" ")
            }
        }
    }

    /// Function for initialize arguments array. RsyncOSX computes four argumentstrings
    /// two arguments for dryrun, one for rsync and one for display
    /// two arguments for realrun, one for rsync and one for display
    /// which argument to compute is set in parameter to function
    /// - parameter config: structure (configuration) holding configuration for one task
    /// - parameter dryRun: true if compute dryrun arguments, false if compute arguments for real run
    /// - paramater forDisplay: true if for display, false if not
    /// - returns: Array of Strings
    func argumentsRsync(_ config: Configuration, dryRun: Bool, forDisplay: Bool) -> [String] {
        self.localCatalog = config.localCatalog
        self.remoteargs(config)
        self.setParameters1To6(config, dryRun: dryRun, forDisplay: forDisplay, verify: false)
        self.setParameters8To14(config, dryRun: dryRun, forDisplay: forDisplay)
        switch config.task {
        case ViewControllerReference.shared.backup, ViewControllerReference.shared.combined:
            self.argumentsforsynchronize(dryRun: dryRun, forDisplay: forDisplay)
        case ViewControllerReference.shared.snapshot:
            self.linkdestparameter(config, verify: false)
            self.argumentsforsynchronizesnapshot(dryRun: dryRun, forDisplay: forDisplay)
        default:
            break
        }
        return self.arguments!
    }

    func argumentsRestore(_ config: Configuration, dryRun: Bool, forDisplay: Bool, tmprestore: Bool) -> [String] {
        self.localCatalog = config.localCatalog
        if config.snapshotnum != nil {
            self.remoteargssnapshot(config)
        } else {
            self.remoteargs(config)
        }
        self.setParameters1To6(config, dryRun: dryRun, forDisplay: forDisplay, verify: false)
        self.setParameters8To14(config, dryRun: dryRun, forDisplay: forDisplay)
        if tmprestore {
            self.argumentsforrestore(dryRun: dryRun, forDisplay: forDisplay, tmprestore: tmprestore)
        } else {
            self.argumentsforrestore(dryRun: dryRun, forDisplay: forDisplay, tmprestore: tmprestore)
        }
        return self.arguments!
    }

    func argumentsVerify(_ config: Configuration, forDisplay: Bool) -> [String] {
        self.localCatalog = config.localCatalog
        self.remoteargs(config)
        self.setParameters1To6(config, dryRun: true, forDisplay: forDisplay, verify: true)
        self.setParameters8To14(config, dryRun: true, forDisplay: forDisplay)
        switch config.task {
        case ViewControllerReference.shared.backup, ViewControllerReference.shared.combined:
            self.argumentsforsynchronize(dryRun: true, forDisplay: forDisplay)
        case ViewControllerReference.shared.snapshot:
            self.linkdestparameter(config, verify: true)
            self.argumentsforsynchronizesnapshot(dryRun: true, forDisplay: forDisplay)
        default:
            break
        }
        return self.arguments!
    }

    func argumentsRsyncLocalcatalogInfo(_ config: Configuration, dryRun: Bool, forDisplay: Bool) -> [String] {
        self.localCatalog = config.localCatalog
        self.setParameters1To6(config, dryRun: dryRun, forDisplay: forDisplay, verify: false)
        self.setParameters8To14(config, dryRun: dryRun, forDisplay: forDisplay)
        switch config.task {
        case ViewControllerReference.shared.backup, ViewControllerReference.shared.combined:
            self.argumentsforsynchronize(dryRun: dryRun, forDisplay: forDisplay)
        case ViewControllerReference.shared.snapshot:
            self.argumentsforsynchronizesnapshot(dryRun: dryRun, forDisplay: forDisplay)
        default:
            break
        }
        return self.arguments!
    }

    private func remoteargs(_ config: Configuration) {
        self.offsiteCatalog = config.offsiteCatalog
        self.offsiteUsername = config.offsiteUsername
        self.offsiteServer = config.offsiteServer
        if self.offsiteServer!.isEmpty == false {
            if config.rsyncdaemon != nil {
                if config.rsyncdaemon == 1 {
                    self.remoteargs = self.offsiteUsername! + "@" + self.offsiteServer! + "::" + self.offsiteCatalog!
                } else {
                    self.remoteargs = self.offsiteUsername! + "@" + self.offsiteServer! + ":" + self.offsiteCatalog!
                }
            } else {
                self.remoteargs = self.offsiteUsername! + "@" + self.offsiteServer! + ":" + self.offsiteCatalog!
            }
        }
    }

    private func remoteargssnapshot(_ config: Configuration) {
        let snapshotnum = config.snapshotnum ?? 1
        self.offsiteCatalog = config.offsiteCatalog + String(snapshotnum - 1) + "/"
        self.offsiteUsername = config.offsiteUsername
        self.offsiteServer = config.offsiteServer
        if self.offsiteServer!.isEmpty == false {
            if config.rsyncdaemon != nil {
                if config.rsyncdaemon == 1 {
                    self.remoteargs = self.offsiteUsername! + "@" + self.offsiteServer! + "::" + self.offsiteCatalog!
                } else {
                    self.remoteargs = self.offsiteUsername! + "@" + self.offsiteServer! + ":" + self.offsiteCatalog!
                }
            } else {
                self.remoteargs = self.offsiteUsername! + "@" + self.offsiteServer! + ":" + self.offsiteCatalog!
            }
        }
    }

    // Additional parameters if snapshot
    private func linkdestparameter(_ config: Configuration, verify: Bool) {
        let snapshotnum = config.snapshotnum ?? 1
        self.linkdestparam =  "--link-dest=" + config.offsiteCatalog + String(snapshotnum - 1)
        if self.remoteargs != nil {
            if verify {
                 self.remoteargs! += String(snapshotnum - 1)
            } else {
                self.remoteargs! += String(snapshotnum)
            }
        }
        if verify {
             self.offsiteCatalog! += String(snapshotnum - 1)
        } else {
            self.offsiteCatalog! += String(snapshotnum)
        }
    }

    private func argumentsforsynchronize(dryRun: Bool, forDisplay: Bool) {
        self.arguments!.append(self.localCatalog!)
        guard self.offsiteCatalog != nil else { return }
        if self.offsiteServer!.isEmpty {
            if forDisplay {self.arguments!.append(" ")}
            self.arguments!.append(self.offsiteCatalog!)
            if forDisplay {self.arguments!.append(" ")}
        } else {
            if forDisplay {self.arguments!.append(" ")}
            self.arguments!.append(remoteargs!)
            if forDisplay {self.arguments!.append(" ")}
        }
    }

    private func argumentsforsynchronizesnapshot(dryRun: Bool, forDisplay: Bool) {
        guard self.linkdestparam != nil else {
            self.arguments!.append(self.localCatalog!)
            return
        }
        self.arguments!.append(self.linkdestparam!)
        if forDisplay {self.arguments!.append(" ")}
        self.arguments!.append(self.localCatalog!)
        if self.offsiteServer!.isEmpty {
            if forDisplay {self.arguments!.append(" ")}
            self.arguments!.append(self.offsiteCatalog!)
            if forDisplay {self.arguments!.append(" ")}
        } else {
            if forDisplay {self.arguments!.append(" ")}
            self.arguments!.append(remoteargs!)
            if forDisplay {self.arguments!.append(" ")}
        }
    }

    private func argumentsforrestore(dryRun: Bool, forDisplay: Bool, tmprestore: Bool) {
        if self.offsiteServer!.isEmpty {
            self.arguments!.append(self.offsiteCatalog!)
            if forDisplay {self.arguments!.append(" ")}
        } else {
            if forDisplay {self.arguments!.append(" ")}
            self.arguments!.append(remoteargs!)
            if forDisplay {self.arguments!.append(" ")}
        }
        if tmprestore {
            let restorepath = ""
            self.arguments!.append(restorepath)
        } else {
            self.arguments!.append(self.localCatalog!)
        }
    }

    init () {
        self.arguments = [String]()
    }
}
