//
//  TrimFour.swift
//  RsyncUI
//
//  Created by Thomas Evensen on 05/05/2021.
//

import Combine
import Foundation

final class TrimFour: Errors {
    var subscriptions = Set<AnyCancellable>()
    var trimmeddata = [String]()

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
                let substr = line.dropFirst(10).trimmingCharacters(in: .whitespacesAndNewlines)
                let str = substr.components(separatedBy: " ").dropFirst(1).dropLast(2).joined(separator: " ")
                if str.count > 4,
                   str.contains(".DS_Store") == false,
                   str.contains("./.") == false
                {
                    trimmeddata.append(str)
                }
            })
            .store(in: &subscriptions)
    }
}
