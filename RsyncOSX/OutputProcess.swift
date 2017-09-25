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
            if line.characters.last != "/" {
                self.output!.append(line)
            }
        }
        self.endIndex = self.output!.count
        // Set maxnumber so far
        self.maxNumber = self.endIndex!
        // rsync error
        let error = sentence.contains("rsync error:")
        // There is an error in transferring files
        // We only informs in main view if error
        if error {
            self.errorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain)
                as? ViewControllertabMain
            self.errorDelegate?.rsyncerror()
        }
    }

    // Add line to output
    func addLine2 (_ str: String) {
        let sentence = str
        if self.startIndex == nil {
            self.startIndex = 0
        } else {
            self.startIndex = self.getOutputCount()+1
        }
        sentence.enumerateLines { (line, _) in
            /*
            let substr = line.dropFirst(10).trimmingCharacters(in: .whitespacesAndNewlines)
            let str = substr.components(separatedBy: " ").dropFirst(3).joined()
            if str.isEmpty == false {
                self.output!.append(str)
            }
             */
            self.output!.append(line)
        }
        self.endIndex = self.output!.count
        // Set maxnumber so far
        self.maxNumber = self.endIndex!
    }

    init () {
        self.output = Array<String>()
    }
 }
