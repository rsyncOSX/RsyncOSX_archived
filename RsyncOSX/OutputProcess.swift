//
//  outputProcess.swift
//
//  Created by Thomas Evensen on 11/01/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length cyclomatic_complexity

import Foundation

protocol RsyncError: AnyObject {
    func rsyncerror()
}

enum Trim {
    case one
    case two
    case three
}

class OutputProcess {
    var output: [String]?
    var trimmedoutput: [String]?
    var startindex: Int?
    var maxnumber: Int = 0
    weak var errorDelegate: RsyncError?
    var error: Bool = false

    func getMaxcount() -> Int {
        if self.trimmedoutput == nil {
            _ = self.trimoutput(trim: .two)
        }
        return self.maxnumber
    }

    func count() -> Int {
        return self.output?.count ?? 0
    }

    func getrawOutput() -> [String]? {
        return self.output
    }

    func getOutput() -> [String]? {
        if self.trimmedoutput != nil {
            return self.trimmedoutput
        } else {
            return self.output
        }
    }

    func addlinefromoutput(str: String) {
        if self.startindex == nil {
            self.startindex = 0
        } else {
            self.startindex = self.output?.count ?? 0 + 1
        }
        str.enumerateLines { line, _ in
            self.output?.append(line)
        }
    }

    func trimoutput(trim: Trim) -> [String]? {
        var out = [String]()
        guard self.output != nil else { return nil }
        switch trim {
        case .one:
            for i in 0 ..< self.output!.count {
                let substr = self.output![i].dropFirst(10).trimmingCharacters(in: .whitespacesAndNewlines)
                let str = substr.components(separatedBy: " ").dropFirst(3).joined(separator: " ")
                if str.isEmpty == false, str.contains(".DS_Store") == false {
                    out.append("./" + str)
                }
            }
        case .two:
            for i in 0 ..< self.output!.count where self.output![i].last != "/" {
                out.append(self.output![i])
                self.error = self.output![i].contains("rsync error:")
                if self.error {
                    self.errorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
                    self.errorDelegate?.rsyncerror()
                    _ = Logging(self, true)
                }
            }
            self.maxnumber = out.count
        case .three:
            for i in 0 ..< self.output!.count {
                let substr = self.output![i].dropFirst(10).trimmingCharacters(in: .whitespacesAndNewlines)
                let str = substr.components(separatedBy: " ").dropFirst(3).joined(separator: " ")
                if str.isEmpty == false {
                    if str.contains(".DS_Store") == false {
                        out.append(str)
                    }
                }
            }
        }
        self.trimmedoutput = out
        return out
    }

    init() {
        self.output = [String]()
    }
}
