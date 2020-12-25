//
//  Car.swift
//  Swift-Demo
//
//  Created by Fang on 2020/9/3.
//

import UIKit

class Car: AbstractCar {
    
    
    override func run() {
        print("小汽车 run with \(street.roadName())")
    }
}
