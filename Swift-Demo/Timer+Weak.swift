//
//  Timer+Weak.swift
//  Swift-Demo
//
//  Created by Fang on 2020/11/2.
//

import Foundation


class Block<T> {
    let f: T
    init(_ f:T) {
        self.f = f
    }
}

extension Timer {
    open class func weak_scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) -> Timer {
        if #available(iOS 10.0, *) {
            return Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats, block: block)
        }
        return Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(weak_timerAction), userInfo: Block(block), repeats: repeats)
    }
    
    @objc class func weak_timerAction(_ sender: Timer) -> Swift.Void {
        if let block = sender.userInfo as? Block<(Timer) -> Swift.Void> {
            block.f(sender)
        }
    }
}
