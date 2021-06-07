//
//  TrimTwo.swift
//  RsyncUI
//
//  Created by Thomas Evensen on 05/05/2021.
//
// swiftlint:disable line_length

import Combine
import Foundation

protocol RsyncError: AnyObject {
    func rsyncerror()
}

final class TrimTwo: Errors {
    var subscriptions = Set<AnyCancellable>()
    var trimmeddata = [String]()
    var maxnumber: Int = 0
    var errordiscovered: Bool = false
    weak var errorDelegate: RsyncError?

    // Error handling
    func checkforrsyncerror(_ line: String) throws {
        let error = line.contains("rsync error:")
        if error {
            throw RsyncOSXTypeErrors.rsyncerror
        }
    }

    init(_ data: [String]) {
        data.publisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    return
                case let .failure(error):
                    let error = error as NSError
                    self.error(errordescription: error.description, errortype: .readerror)
                }
            }, receiveValue: { [unowned self] line in
                if line.last != "/" {
                    trimmeddata.append(line)
                    do {
                        try checkforrsyncerror(line)
                    } catch let e {
                        // Only want one notification about error, not multiple
                        // Multiple can be a kind of race situation
                        if errordiscovered == false {
                            self.errorDelegate = SharedReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
                            self.errorDelegate?.rsyncerror()
                            errordiscovered = true
                            let error = e as NSError
                            self.error(errordescription: error.description, errortype: .readerror)
                        }
                    }
                }
                maxnumber = trimmeddata.count
            })
            .store(in: &subscriptions)
    }
}
