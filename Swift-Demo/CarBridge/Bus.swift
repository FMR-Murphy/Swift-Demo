//
//  Bus.swift
//  Swift-Demo
//
//  Created by Fang on 2020/9/3.
//

import UIKit

class Bus: AbstractCar {
    
    override func run() {
        print("公交车run with\(street.roadName())")
    }
}
