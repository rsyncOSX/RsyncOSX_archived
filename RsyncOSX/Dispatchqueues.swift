//
//  Dispatchqueues.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.08.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

var globalMainQueue: DispatchQueue {
    return DispatchQueue.main
}

var globalDefaultQueue: DispatchQueue {
    return DispatchQueue.global(qos: .default)
}
