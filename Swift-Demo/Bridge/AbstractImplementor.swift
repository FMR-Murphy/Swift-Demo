//
//  AbstractImplementor.swift
//  Swift-Demo
//
//  Created by Fang on 2020/9/2.
//

import UIKit

enum ECommandType : NSInteger {
    case kUp
    case kDown
    case kLeft
    case kRight
    case kA
    case kB
    case kO
    case kX
}

class AbstractImplementor: NSObject {
    
    func loadCommand(command: ECommandType) {
        
    }

}
