//
//  outputProcess.swift
//
//  Created by Thomas Evensen on 11/01/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable syntactic_sugar

import Foundation

protocol RsyncError: class {
    func rsyncerror()
}

final class OutputProcess {

    private var output: Array<String>?
    private var startIndex: Int?
    private var endIndex: Int?
    private var maxNumber: Int = 0
    weak var errorDelegate: ViewControllertabMain?
    weak var lastrecordDelegate: ViewControllertabMain?

    func getMaxcount() -> Int {
        _ = self.trimoutput2()
        return self.maxNumber
    }

    func getOutputCount () -> Int {
        guard self.output != nil else {
            return 0
        }
        return self.output!.count
    }

    func getOutput () -> Array<String> {
        guard self.output != nil else {
            return [""]
        }
        return self.output!
    }

    // Add line to output
    func addLine (_ str: String) {
        let sentence = str
        if self.startIndex == nil {
            self.startIndex = 0
        } else {
            self.startIndex = self.getOutputCount()+1
        }
        sentence.enumerateLines { (line, _) in
            self.output!.append(line)
        }
    }

    func trimoutput1() -> Array<String>? {
        var out = Array<String>()
        guard self.output != nil else {
            return nil
        }
        for i in 0 ..< self.output!.count {
            let substr = self.output![i].dropFirst(10).trimmingCharacters(in: .whitespacesAndNewlines)
            let str = substr.components(separatedBy: " ").dropFirst(3).joined()
            if str.isEmpty == false {
                out.append("./" + str)
            }
        }
        return out
    }

    func trimoutput2() -> Array<String>? {
        var out = Array<String>()
        guard self.output != nil else {
            return nil
        }
        for i in 0 ..< self.output!.count where self.output![i].characters.last != "/" {
            out.append(self.output![i])
            let error = self.output![i].contains("rsync error:")
            if error {
                self.errorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain)
                    as? ViewControllertabMain
                self.errorDelegate?.rsyncerror()
            }
        }
        self.endIndex = out.count
        self.maxNumber = self.endIndex!
        return out
    }

    init () {
        self.output = Array<String>()
    }
 }
