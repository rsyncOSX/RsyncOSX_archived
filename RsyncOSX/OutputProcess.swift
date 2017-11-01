//
//  outputProcess.swift
//
//  Created by Thomas Evensen on 11/01/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar line_length

import Foundation

protocol RsyncError: class {
    func rsyncerror()
}

enum Trim {
    case one
    case two
}

final class OutputProcess {

    private var output: Array<String>?
    private var trimmedoutput: Array<String>?
    private var startIndex: Int?
    private var endIndex: Int?
    private var maxNumber: Int = 0
    weak var errorDelegate: ViewControllertabMain?
    weak var lastrecordDelegate: ViewControllertabMain?

    func getMaxcount() -> Int {
        if self.trimmedoutput == nil {
            _ = self.trimoutput(trim: .two)
        }
        return self.maxNumber
    }

    func count() -> Int {
        return self.output?.count ?? 0
    }

    func getOutput() -> Array<String>? {
        if self.trimmedoutput != nil {
            return self.trimmedoutput
        } else {
            return self.output
        }
    }

    // Add line from output
    func addlinefromoutput (_ str: String) {
        if self.startIndex == nil {
            self.startIndex = 0
        } else {
            self.startIndex = self.output!.count + 1
        }
        str.enumerateLines { (line, _) in
            self.output!.append(line)
        }
    }

    func trimoutput(trim: Trim) -> Array<String>? {
        var out = Array<String>()
        guard self.output != nil else { return nil }
        switch trim {
        case .one:
            for i in 0 ..< self.output!.count {
                let substr = self.output![i].dropFirst(10).trimmingCharacters(in: .whitespacesAndNewlines)
                // let str = substr.components(separatedBy: " ").dropFirst(3).joined()
                let str = substr.components(separatedBy: " ").dropFirst(3).joined(separator: " ")
                if str.isEmpty == false {
                    out.append("./" + str)
                }
            }
        case .two:
            for i in 0 ..< self.output!.count where self.output![i].last != "/" {
                out.append(self.output![i])
                let error = self.output![i].contains("rsync error:")
                if error {
                    self.errorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
                    self.errorDelegate?.rsyncerror()
                }
            }
            self.endIndex = out.count
            self.maxNumber = self.endIndex!
        }
        self.trimmedoutput = out
        return out
    }

    init () {
        self.output = Array<String>()
    }
 }
