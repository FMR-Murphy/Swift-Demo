//
//  PSPSystem.swift
//  Swift-Demo
//
//  Created by Fang on 2020/9/2.
//

import UIKit

class PSPSystem: AbstractSystem {
    
    override func loadSystem() {
        print("PSPSystem load")
    }
    
    func commandX() {
        implementor.loadCommand(command: .kX)
    }
    
    func commandO() {
        implementor.loadCommand(command: .kO)
    }
}
