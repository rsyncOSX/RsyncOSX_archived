//
//  Equal.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 27/11/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

struct Equal {
    func isequalelement<T: Hashable>(data: [T]?, element: T) -> Bool {
        guard data != nil else { return false }
        let filter = data!.filter { $0 == element }
        if filter.count > 0 {
            return true
        } else {
            return false
        }
    }

    func isequalstructs<T: Hashable>(rhs: T, lhs: T) -> Bool {
        return rhs == lhs
    }
}
