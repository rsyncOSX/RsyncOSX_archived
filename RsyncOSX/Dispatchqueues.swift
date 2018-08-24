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

var globalBackgroundQueue: DispatchQueue {
    return DispatchQueue.global(qos: .background)
}
var globalUserInitiatedQueue: DispatchQueue {
    return DispatchQueue.global(qos: .userInitiated)
}
var globalUtilityQueue: DispatchQueue {
    return DispatchQueue.global(qos: .utility)
}
var globalUserInteractiveQueue: DispatchQueue {
    return DispatchQueue.global(qos: .userInteractive)
}
var globalDefaultQueue: DispatchQueue {
    return DispatchQueue.global(qos: .default)
}
