//
//  AbstractCar.swift
//  Swift-Demo
//
//  Created by Fang on 2020/9/3.
//

import UIKit

class AbstractCar: NSObject {
    
    let street : AbstractRoad
    init(street: AbstractRoad) {
        self.street = street
    }
    
    
    func run() {
        
    }
    
}
