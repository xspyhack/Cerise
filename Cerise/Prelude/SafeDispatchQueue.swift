//
//  SafeDispatchQueue.swift
//  Cerise
//
//  Created by alex.huo on 2019/3/20.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation

/**
 Safety dispatch queue, if to be dispatch queue is the main queue,
 add current queue is the main queue,
 the work item will be execute immediately instead of being dispatched.
 ref: https://github.com/ReactiveCocoa/ReactiveCocoa/pull/2912
 */
public struct SafeDispatchQueue {
    private let mainQueueKey = DispatchSpecificKey<String>()
    private let mainQueueContext = "main"
    private var base: DispatchQueue

    init(_ base: DispatchQueue) {
        self.base = base
        DispatchQueue.main.setSpecific(key: mainQueueKey, value: mainQueueContext)
    }

    public func async(execute workItem: DispatchWorkItem) {
        if base === DispatchQueue.main {
            if DispatchQueue.getSpecific(key: mainQueueKey) == mainQueueContext {
                workItem.perform()
            } else {
                DispatchQueue.main.async(execute: workItem)
            }
        } else {
            base.async(execute: workItem)
        }
    }

    public func async(execute work: @escaping @convention(block) () -> Void) {
        let workItem = DispatchWorkItem(block: work)
        async(execute: workItem)
    }
}

extension DispatchQueue {
    var safe: SafeDispatchQueue {
        return SafeDispatchQueue(self)
    }
}
