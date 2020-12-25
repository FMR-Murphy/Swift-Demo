//
//  AbstractSystem.swift
//  Swift-Demo
//
//  Created by Fang on 2020/9/2.
//

import UIKit

/*
 控制类
 */

class AbstractSystem: NSObject {
    
    let implementor : AbstractImplementor
    
    init(implementor: AbstractImplementor) {
        self.implementor = implementor
    }
    
    //加载系统
    func loadSystem() {
        
    }
    
    func commandUp() {
        implementor.loadCommand(command: .kUp)
    }
    
    func commandDown() {
        implementor.loadCommand(command: .kDown)
    }
    
    func commandLeft() {
        implementor.loadCommand(command: .kLeft)
    }
    
    func commandRight() {
        implementor.loadCommand(command: .kRight)
    }
    
    func commandA() {
        implementor.loadCommand(command: .kA)
    }
    
    func commandB() {
        implementor.loadCommand(command: .kB)
    }
}
